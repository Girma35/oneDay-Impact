-- ============================================================================
-- OneDay Supabase Database Migration
-- ============================================================================
-- Tables:   profiles, challenges, completed_challenges,
--           achievements, user_achievements, community_goals
-- Features: RLS policies, auto-update triggers, achievement awarding,
--           streak tracking, level calculation, global rank computation
-- ============================================================================

-- ────────────────────────────────────────────────────────────────────────────
-- 1. PROFILES  (extends auth.users with app-specific data)
-- ────────────────────────────────────────────────────────────────────────────

create table public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  username    text unique not null,
  full_name   text not null,
  avatar_url  text,
  level       int not null default 1,
  total_xp    int not null default 0,
  streak      int not null default 0,
  best_streak int not null default 0,
  rank_title  text not null default 'BEGINNER',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Auto-create profile on signup
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, username, full_name, avatar_url)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'username', split_part(new.email, '@', 1)),
    coalesce(new.raw_user_meta_data ->> 'full_name', split_part(new.email, '@', 1)),
    coalesce(new.raw_user_meta_data ->> 'avatar_url', null)
  );
  return new;
end;
$$;

-- Trigger: create profile row when a new user signs up
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Auto-update updated_at timestamp on any profile change
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger set_profiles_updated_at
  before update on public.profiles
  for each row execute procedure public.set_updated_at();

-- RLS
alter table public.profiles enable row level security;

-- Anyone can read profiles (leaderboard, etc.)
create policy "Profiles are viewable by everyone"
  on public.profiles for select
  using (true);

-- Users can update only their own profile
create policy "Users can update own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- Users can insert only their own profile (backup for manual flows)
create policy "Users can insert own profile"
  on public.profiles for insert
  with check (auth.uid() = id);


-- ────────────────────────────────────────────────────────────────────────────
-- 2. CHALLENGES  (daily challenges served from DB instead of hardcoded mocks)
-- ────────────────────────────────────────────────────────────────────────────

create table public.challenges (
  id                    uuid primary key default gen_random_uuid(),
  title                 text not null,
  description           text not null,
  category              text not null
    check (category in ('environment', 'elders', 'education', 'cleanliness', 'farming', 'water')),
  image_url             text not null,
  impact_points         int not null default 0,
  verification_keywords text[] not null default '{}',
  active_date           date not null,           -- which day this challenge is featured
  created_at            timestamptz not null default now()
);

-- Index: quickly find today's challenges
create index idx_challenges_active_date on public.challenges (active_date);

-- RLS
alter table public.challenges enable row level security;

-- Anyone can read challenges (feed page is public)
create policy "Challenges are viewable by everyone"
  on public.challenges for select
  using (true);

-- Only service role / admins can insert/update/delete challenges
create policy "Only service role can modify challenges"
  on public.challenges for all
  using (auth.role() = 'service_role');


-- ────────────────────────────────────────────────────────────────────────────
-- 3. COMPLETED_CHALLENGES  (tracks every verified challenge completion)
-- ────────────────────────────────────────────────────────────────────────────

create table public.completed_challenges (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references public.profiles(id) on delete cascade,
  challenge_id    uuid not null references public.challenges(id) on delete cascade,
  proof_image_url text,
  points_earned   int not null,
  verified_at     timestamptz not null default now()
);

-- Immutable date helper (required for expression indexes — timestamptz::date is not IMMUTABLE)
create or replace function public.date_immutable(t timestamptz)
returns date
language sql
immutable strict
as $$ select (t at time zone 'UTC')::date $$;

-- Unique constraint using expression index (same challenge allowed on different days)
-- Uses the immutable wrapper so PostgreSQL accepts it in the index expression
create unique index idx_unique_completion
  on public.completed_challenges (user_id, challenge_id, public.date_immutable(verified_at));

-- Indexes: common query patterns
create index idx_completed_user on public.completed_challenges (user_id);
create index idx_completed_verified_at on public.completed_challenges (verified_at);
create index idx_completed_challenge on public.completed_challenges (challenge_id);

-- Index for global rank calculation
create index idx_profiles_total_xp on public.profiles (total_xp desc);

-- RLS
alter table public.completed_challenges enable row level security;

-- Users can read their own completions
create policy "Users can view own completions"
  on public.completed_challenges for select
  using (auth.uid() = user_id);

-- NOTE: Users do NOT insert completions directly. The app calls a server-side
-- function or uses service_role to insert. This prevents users from setting
-- arbitrary points_earned. If client-side insert is needed, add a trigger to
-- enforce points_earned = challenge.impact_points. For now, only service_role
-- can insert (RLS default = blocked).
create policy "Service role can insert completions"
  on public.completed_challenges for insert
  with check (auth.role() = 'service_role');

-- Users cannot update/delete completions (immutable record)
-- No update/delete policies = blocked by default

-- Service role can read all for community stats
create policy "Service role can read all completions"
  on public.completed_challenges for select
  using (auth.role() = 'service_role');


-- ────────────────────────────────────────────────────────────────────────────
-- 4. ACHIEVEMENTS  (badge definitions — shared, not per-user)
-- ────────────────────────────────────────────────────────────────────────────

create table public.achievements (
  id            uuid primary key default gen_random_uuid(),
  key           text unique not null,     -- e.g. 'early_bird', 'green_thumb'
  title         text not null,
  description   text not null,
  icon_name     text not null,            -- Flutter IconData name for UI
  color_hex     text not null default '#000000',
  bg_color_hex  text not null default '#FFFFFF',
  criteria      jsonb not null            -- e.g. {"type":"streak","value":7}
);

-- RLS
alter table public.achievements enable row level security;

-- Anyone can read achievement definitions
create policy "Achievements are viewable by everyone"
  on public.achievements for select
  using (true);

-- Only service role can modify achievements
create policy "Only service role can modify achievements"
  on public.achievements for all
  using (auth.role() = 'service_role');


-- ────────────────────────────────────────────────────────────────────────────
-- 5. USER_ACHIEVEMENTS  (unlocked badges per user)
-- ────────────────────────────────────────────────────────────────────────────

create table public.user_achievements (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references public.profiles(id) on delete cascade,
  achievement_id uuid not null references public.achievements(id) on delete cascade,
  unlocked_at    timestamptz not null default now(),
  unique(user_id, achievement_id)
);

-- RLS
alter table public.user_achievements enable row level security;

-- Users can read their own achievements
create policy "Users can view own achievements"
  on public.user_achievements for select
  using (auth.uid() = user_id);

-- NOTE: Users cannot manually award themselves achievements.
-- The security definer trigger bypasses RLS, so inserts from the trigger
-- work without a user-facing insert policy.

-- Service role can read all
create policy "Service role can read all user achievements"
  on public.user_achievements for select
  using (auth.role() = 'service_role');


-- ────────────────────────────────────────────────────────────────────────────
-- 6. COMMUNITY_GOALS  (global progress targets)
-- ────────────────────────────────────────────────────────────────────────────

create table public.community_goals (
  id             uuid primary key default gen_random_uuid(),
  title          text not null,
  target_count   int not null,
  current_count  int not null default 0,
  start_date     date not null,
  end_date       date,
  is_active      boolean not null default true,
  created_at     timestamptz not null default now()
);

-- RLS
alter table public.community_goals enable row level security;

-- Anyone can read community goals
create policy "Community goals are viewable by everyone"
  on public.community_goals for select
  using (true);

-- Only service role can modify community goals
create policy "Only service role can modify community goals"
  on public.community_goals for all
  using (auth.role() = 'service_role');


-- ============================================================================
-- TRIGGERS & FUNCTIONS
-- ============================================================================

-- ────────────────────────────────────────────────────────────────────────────
-- On completion: update profile XP, level, rank_title, and streak
-- ────────────────────────────────────────────────────────────────────────────

create or replace function public.update_profile_on_completion()
returns trigger
language plpgsql
security definer set search_path = public
as $$
declare
  v_new_xp int;
  v_level  int;
  v_rank   text;
begin
  -- Compute new XP total
  select total_xp into v_new_xp from public.profiles where id = new.user_id;
  v_new_xp := v_new_xp + new.points_earned;

  -- Level formula: each level requires progressively more XP
  -- Level = floor(sqrt(total_xp / 50)) + 1
  -- e.g. 0 XP → L1, 50 XP → L2, 200 XP → L3, 5000 XP → L11, 12400 XP → L16
  v_level := floor(sqrt(v_new_xp / 50.0)) + 1;

  -- Rank title based on level thresholds
  v_rank := case
    when v_level >= 50 then 'LEGEND'
    when v_level >= 40 then 'CHAMPION'
    when v_level >= 30 then 'IMPACT LEADER'
    when v_level >= 24 then 'ECO-WARRIOR'
    when v_level >= 18 then 'GUARDIAN'
    when v_level >= 12 then 'ADVOCATE'
    when v_level >= 6  then 'EXPLORER'
    else 'BEGINNER'
  end;

  -- Single UPDATE: XP + level + rank all at once
  update public.profiles
  set total_xp   = v_new_xp,
      level      = v_level,
      rank_title = v_rank,
      updated_at = now()
  where id = new.user_id;

  return new;
end;
$$;

-- Recalculate streak whenever a completion is inserted
-- Streak = consecutive days with ≥1 completion, counting backwards from today.
-- Optimized: fetches all completion dates in a single query, then computes in PL/pgSQL.
create or replace function public.recalculate_streak()
returns trigger
language plpgsql
security definer set search_path = public
as $$
declare
  v_streak      int := 0;
  v_best_streak int;
  v_user_id     uuid;
  v_day         date;
  v_prev_day    date;
  completion_dates date[];
begin
  v_user_id := new.user_id;

  -- Fetch all completion dates for this user in a single query (most recent first)
  select array_agg(d order by d desc) into completion_dates
    from (
      select distinct verified_at::date as d
      from public.completed_challenges
      where user_id = v_user_id
    ) sub;

  -- Compute streak: count consecutive days from today backwards
  v_prev_day := current_date;

  if completion_dates is not null then
    for idx in array_lower(completion_dates, 1)..array_upper(completion_dates, 1) loop
      v_day := completion_dates[idx];

      -- Skip dates in the future (shouldn't happen, but safety)
      if v_day > current_date then
        continue;
      end if;

      -- If this date is the expected next day in the streak
      if v_day = v_prev_day then
        v_streak := v_streak + 1;
        v_prev_day := v_prev_day - 1;
      elsif v_day < v_prev_day then
        -- Gap found — streak is broken
        exit;
      end if;
    end loop;
  end if;

  -- Update best_streak if current is higher
  select best_streak into v_best_streak from public.profiles where id = v_user_id;
  if v_streak > coalesce(v_best_streak, 0) then
    v_best_streak := v_streak;
  end if;

  -- Write back
  update public.profiles
  set streak      = v_streak,
      best_streak = v_best_streak,
      updated_at  = now()
  where id = v_user_id;

  return new;
end;
$$;

-- Attach triggers to completed_challenges
-- IMPORTANT: PostgreSQL fires same-timing triggers in alphabetical order by name.
-- Prefix with a/b/c/z to guarantee correct execution order:
--   1. XP & level update  (a_)
--   2. Streak update      (b_)
--   3. Community goal     (c_)
--   4. Achievement check  (z_) — must run LAST so it reads fresh XP/streak
create trigger a_on_completion_xp_level
  after insert on public.completed_challenges
  for each row execute procedure public.update_profile_on_completion();

create trigger b_on_completion_streak
  after insert on public.completed_challenges
  for each row execute procedure public.recalculate_streak();

-- ────────────────────────────────────────────────────────────────────────────
-- On completion: update community_goals.current_count
-- ────────────────────────────────────────────────────────────────────────────

create or replace function public.update_community_goal_progress()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  update public.community_goals
  set current_count = current_count + 1
  where is_active = true
    and start_date <= current_date
    and (end_date is null or end_date >= current_date);
  return new;
end;
$$;

create trigger c_on_completion_community
  after insert on public.completed_challenges
  for each row execute procedure public.update_community_goal_progress();

-- ────────────────────────────────────────────────────────────────────────────
-- On completion: auto-award achievements based on criteria
-- ────────────────────────────────────────────────────────────────────────────

create or replace function public.check_and_award_achievements()
returns trigger
language plpgsql
security definer set search_path = public
as $$
declare
  ach record;
  criteria_type text;
  criteria_value int;
  v_count int;
  v_streak int;
  already_has boolean;
begin
  -- Iterate over all achievements
  for ach in select id, key, criteria from public.achievements loop
    -- Check if user already has this achievement
    select exists(
      select 1 from public.user_achievements
      where user_id = new.user_id and achievement_id = ach.id
    ) into already_has;

    if already_has then
      continue;
    end if;

    criteria_type  := ach.criteria ->> 'type';
    criteria_value := coalesce((ach.criteria ->> 'value')::int, 0);

    case criteria_type
      -- Streak-based achievement
      when 'streak' then
        select streak into v_streak from public.profiles where id = new.user_id;
        if v_streak >= criteria_value then
          insert into public.user_achievements (user_id, achievement_id)
          values (new.user_id, ach.id)
          on conflict (user_id, achievement_id) do nothing;
        end if;

      -- Total completions achievement
      when 'completions' then
        select count(*)::int into v_count
        from public.completed_challenges
        where user_id = new.user_id;
        if v_count >= criteria_value then
          insert into public.user_achievements (user_id, achievement_id)
          values (new.user_id, ach.id)
          on conflict (user_id, achievement_id) do nothing;
        end if;

      -- Category-specific completions
      when 'category_completions' then
        if ach.criteria ->> 'category' = 'all' then
          -- Special case: user must have completions in ALL categories
          select count(distinct c.category)::int into v_count
          from public.completed_challenges cc
          join public.challenges c on c.id = cc.challenge_id
          where cc.user_id = new.user_id;
          -- Count of distinct challenge categories in the system
          if v_count >= (select count(distinct category) from public.challenges) then
            insert into public.user_achievements (user_id, achievement_id)
            values (new.user_id, ach.id)
            on conflict (user_id, achievement_id) do nothing;
          end if;
        else
          select count(*)::int into v_count
          from public.completed_challenges cc
          join public.challenges c on c.id = cc.challenge_id
          where cc.user_id = new.user_id
            and c.category = ach.criteria ->> 'category';
          if v_count >= criteria_value then
            insert into public.user_achievements (user_id, achievement_id)
            values (new.user_id, ach.id)
            on conflict (user_id, achievement_id) do nothing;
          end if;
        end if;

      -- XP threshold achievement
      when 'xp' then
        select total_xp into v_count from public.profiles where id = new.user_id;
        if v_count >= criteria_value then
          insert into public.user_achievements (user_id, achievement_id)
          values (new.user_id, ach.id)
          on conflict (user_id, achievement_id) do nothing;
        end if;

      else
        -- Unknown criteria type, skip
        null;
    end case;
  end loop;

  return new;
end;
$$;

create trigger z_on_completion_achievements
  after insert on public.completed_challenges
  for each row execute procedure public.check_and_award_achievements();


-- ============================================================================
-- UTILITY FUNCTIONS (called from Flutter app)
-- ============================================================================

-- ────────────────────────────────────────────────────────────────────────────
-- Global rank: what percentage of users this user outranks
-- ────────────────────────────────────────────────────────────────────────────

create or replace function public.get_global_rank(p_user_id uuid)
returns int
language plpgsql
security definer set search_path = public
as $$
declare
  v_rank int;
begin
  select count(*)::int + 1 into v_rank
  from public.profiles
  where total_xp > (select total_xp from public.profiles where id = p_user_id);

  -- Return as percentage: top X% (lower is better)
  -- e.g. rank 5 out of 100 users → 5%
  select round((v_rank::numeric / nullif(count(*)::numeric, 0)) * 100) into v_rank
  from public.profiles;

  return coalesce(v_rank, 50);
end;
$$;

-- ────────────────────────────────────────────────────────────────────────────
-- Impact breakdown: category distribution for a user
-- ────────────────────────────────────────────────────────────────────────────

create or replace function public.get_impact_breakdown(p_user_id uuid)
returns table (category text, count int, percentage numeric)
language plpgsql
security definer set search_path = public
as $$
declare
  v_total int;
begin
  select count(*)::int into v_total
  from public.completed_challenges
  where user_id = p_user_id;

  return query
    select
      c.category,
      count(*)::int as count,
      case when v_total > 0
        then round(count(*)::numeric / v_total * 100, 1)
        else 0
      end as percentage
    from public.completed_challenges cc
    join public.challenges c on c.id = cc.challenge_id
    where cc.user_id = p_user_id
    group by c.category
    order by count(*) desc;
end;
$$;

-- ────────────────────────────────────────────────────────────────────────────
-- Contribution heatmap: completions per day for last N days
-- ────────────────────────────────────────────────────────────────────────────

create or replace function public.get_contribution_heatmap(p_user_id uuid, p_days int default 70)
returns table (day date, count int)
language plpgsql
security definer set search_path = public
as $$
begin
  return query
    select
      d::date as day,
      coalesce(cc.cnt, 0)::int as count
    from generate_series(
      current_date - (p_days - 1),
      current_date,
      '1 day'::interval
    ) d
    left join lateral (
      select count(*)::int as cnt
      from public.completed_challenges
      where user_id = p_user_id
        and verified_at::date = d::date
    ) cc on true
    order by d;
end;
$$;


-- ============================================================================
-- SEED DATA
-- ============================================================================

-- ────────────────────────────────────────────────────────────────────────────
-- Seed achievements (matching the badges shown in Profile & Impact pages)
-- ────────────────────────────────────────────────────────────────────────────

insert into public.achievements (key, title, description, icon_name, color_hex, bg_color_hex, criteria) values
  ('early_bird',       'Early Bird',        'Complete a challenge before 9 AM',               'wb_sunny_rounded',           '#C2410C', '#FFEDD5', '{"type":"completions","value":1}'),
  ('weekend_warrior',  'Weekend Warrior',    'Complete challenges on 4 different weekends',     'fitness_center_rounded',     '#6D28D9', '#F3E8FF', '{"type":"completions","value":4}'),
  ('green_thumb',      'Green Thumb',        'Complete 3 environment challenges',               'eco_rounded',                '#15803D', '#DCFCE7', '{"type":"category_completions","value":3,"category":"environment"}'),
  ('streak_7',         '7-Day Streak',       'Maintain a 7-day streak',                         'local_fire_department_rounded','#B91C1C','#FEE2E2', '{"type":"streak","value":7}'),
  ('streak_30',        '30-Day Streak',      'Maintain a 30-day streak',                        'emoji_events_rounded',       '#B91C1C', '#FEE2E2', '{"type":"streak","value":30}'),
  ('verified_10',      'Getting Started',    'Complete 10 verified challenges',                 'verified_rounded',           '#28853D', '#DCFCE7', '{"type":"completions","value":10}'),
  ('verified_50',      'Half Century',       'Complete 50 verified challenges',                 'stars_rounded',              '#6A1B9A', '#F3E8FF', '{"type":"completions","value":50}'),
  ('verified_100',     'Century Club',       'Complete 100 verified challenges',                'military_tech_rounded',      '#B91C1C', '#FEE2E2', '{"type":"completions","value":100}'),
  ('xp_1000',          'Rising Star',        'Earn 1,000 total XP',                             'auto_awesome_rounded',       '#6A1B9A', '#F3E8FF', '{"type":"xp","value":1000}'),
  ('xp_5000',          'Force of Nature',    'Earn 5,000 total XP',                             'thunderstorm_rounded',       '#1E40AF', '#DBEAFE', '{"type":"xp","value":5000}'),
  ('community_spirit',  'Community Spirit',   'Complete a challenge in every category',           'volunteer_activism_rounded',  '#7B3AF2', '#EDE9FE', '{"type":"category_completions","value":1,"category":"all"}'),
  ('elder_ally',       'Elder Ally',         'Complete 5 elder-focused challenges',              'favorite_rounded',           '#C2410C', '#FFEDD5', '{"type":"category_completions","value":5,"category":"elders"}');

-- ────────────────────────────────────────────────────────────────────────────
-- Seed challenges (matching the mock data in MockChallengeRepository)
-- ────────────────────────────────────────────────────────────────────────────

insert into public.challenges (id, title, description, category, image_url, impact_points, verification_keywords, active_date) values
  -- Today's challenges (matching the 3 mock challenges)
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd38aaf1', 'Plant a Tree',
   'Plant a native tree in your backyard or community park.',
   'environment',
   'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09',
   50,
   array['tree', 'planting', 'soil', 'sapling', 'digging'],
   current_date),

  ('b1eebc99-9c0b-4ef8-bb6d-6bb9bd38aaf2', 'Visit an Elder',
   'Spend 30 minutes talking with an elderly neighbor.',
   'elders',
   'https://images.unsplash.com/photo-1581579438747-1dc8d17bbce4',
   30,
   array['elderly', 'senior', 'conversation', 'visiting', 'talking'],
   current_date),

  ('c2eebc99-9c0b-4ef8-bb6d-6bb9bd38aaf3', 'Street Cleanup',
   'Pick up litter on your street for 15 minutes.',
   'cleanliness',
   'https://images.unsplash.com/photo-1563132332-1e0214b80021',
   20,
   array['litter', 'trash', 'cleanup', 'street', 'garbage', 'bag'],
   current_date);

-- Additional challenges for future days (7 days ahead)
insert into public.challenges (title, description, category, image_url, impact_points, verification_keywords, active_date) values
  ('Read to a Child',        'Read a storybook to a child for 20 minutes.',                'education',
   'https://images.unsplash.com/photo-1503676329202-8e5bedb4c070', 40,
   array['book', 'reading', 'child', 'story'], current_date + 1),

  ('Water a Community Garden', 'Help water plants at a local community garden.',            'farming',
   'https://images.unsplash.com/photo-1416879595652-2cc7e1b23e49', 35,
   array['garden', 'watering', 'plants', 'hose'], current_date + 1),

  ('Conserve Water',         'Use 50% less water today — shorter showers, turn off taps.',  'water',
   'https://images.unsplash.com/photo-1548839146-29f7f6aaf2d3', 25,
   array['water', 'faucet', 'tap', 'shower'], current_date + 1),

  ('Clean a Public Space',   'Sweep and tidy a shared courtyard or hallway.',               'cleanliness',
   'https://images.unsplash.com/photo-1581578731548-c9969c4b1604', 30,
   array['sweeping', 'broom', 'clean', 'tidy'], current_date + 2),

  ('Help a Neighbor Farm',   'Assist a neighbor with their small farm plot for 30 min.',    'farming',
   'https://images.unsplash.com/photo-1500937380127-0462a1c7f3f4', 45,
   array['farm', 'planting', 'harvest', 'field'], current_date + 2),

  ('Collect Rainwater',      'Set up a rainwater collection system or fill containers.',    'water',
   'https://images.unsplash.com/photo-1516762689617-5892e5da0646', 40,
   array['rainwater', 'bucket', 'collection', 'container'], current_date + 2),

  ('Tutor a Student',        'Help a student with homework for 30 minutes.',                'education',
   'https://images.unsplash.com/photo-1509062522246-375da6319ad0', 50,
   array['tutoring', 'student', 'homework', 'studying'], current_date + 3),

  ('Plant Vegetables',       'Plant vegetable seeds in a garden or container.',             'farming',
   'https://images.unsplash.com/photo-1464226184393-6c6b2a7d7bd4', 45,
   array['vegetables', 'seeds', 'planting', 'garden'], current_date + 3),

  ('Visit a Senior Center',  'Spend an hour chatting with residents at a senior center.',   'elders',
   'https://images.unsplash.com/photo-1559203208-bd8a50a2c2c6', 35,
   array['senior', 'elderly', 'center', 'talking', 'smiling'], current_date + 4),

  ('Organize a Cleanup',     'Lead a group of 3+ people to clean a local area.',            'cleanliness',
   'https://images.unsplash.com/photo-1532996129627-623e4c416f0a', 60,
   array['group', 'cleanup', 'team', 'litter', 'bags'], current_date + 4),

  ('Build a Birdhouse',      'Build and install a birdhouse in your neighborhood.',          'environment',
   'https://images.unsplash.com/photo-1605606230935-49cf3f6c11e0', 55,
   array['birdhouse', 'bird', 'wood', 'hammer', 'building'], current_date + 5),

  ('Fix a Leak',             'Find and fix a water leak at home or in your community.',      'water',
   'https://images.unsplash.com/photo-1585703920448-6cc393c4555e', 30,
   array['leak', 'pipe', 'wrench', 'water', 'fix'], current_date + 5),

  ('Donate School Supplies',  'Give notebooks or pens to a student in need.',               'education',
   'https://images.unsplash.com/photo-1503676329202-8e5bedb4c070', 25,
   array['supplies', 'notebook', 'pen', 'donation'], current_date + 6),

  ('Compost Organic Waste',  'Start a compost pile with kitchen scraps.',                   'environment',
   'https://images.unsplash.com/photo-1558618666-fcd25c85cd64', 40,
   array['compost', 'organic', 'waste', 'kitchen', 'scraps'], current_date + 6);

-- ────────────────────────────────────────────────────────────────────────────
-- Seed community goal
-- ────────────────────────────────────────────────────────────────────────────

insert into public.community_goals (title, target_count, current_count, start_date, end_date, is_active) values
  ('10K Community Tasks', 10000, 7200, current_date - interval '60 days', current_date + interval '30 days', true);

-- ────────────────────────────────────────────────────────────────────────────
-- Storage bucket for challenge proof images (already exists, just documenting)
-- ────────────────────────────────────────────────────────────────────────────
-- The 'challenge_proofs' storage bucket is already created and used by
-- the VerificationBloc. No SQL needed here — managed via Supabase Dashboard
-- or: insert into storage.buckets (id, name, public) values ('challenge_proofs', 'challenge_proofs', true);

-- ============================================================================
-- SAFE CLIENT-SIDE FUNCTIONS
-- ============================================================================
-- Since RLS blocks direct user inserts into completed_challenges (to prevent
-- arbitrary points_earned), we provide a security_definer function that the
-- Flutter app calls after AI verification succeeds. This function enforces
-- that points_earned always matches the challenge's impact_points.
-- ============================================================================

create or replace function public.complete_challenge(
  p_challenge_id uuid,
  p_proof_image_url text default null
)
returns uuid
language plpgsql
security definer set search_path = public
as $$
declare
  v_id           uuid;
  v_points       int;
  v_user_id      uuid;
begin
  -- Get the current user
  v_user_id := auth.uid();
  if v_user_id is null then
    raise exception 'Not authenticated';
  end if;

  -- Look up the challenge's impact_points (enforced, not client-supplied)
  select impact_points into v_points
  from public.challenges
  where id = p_challenge_id;

  if not found then
    raise exception 'Challenge not found';
  end if;

  -- Check for duplicate first (same user + same challenge + same day)
  if exists (
    select 1 from public.completed_challenges
    where user_id = v_user_id
      and challenge_id = p_challenge_id
      and public.date_immutable(verified_at) = public.date_immutable(now())
  ) then
    -- Already completed today — return sentinel UUID
    return '00000000-0000-0000-0000-000000000000'::uuid;
  end if;

  -- Insert the completion with the correct points
  insert into public.completed_challenges (user_id, challenge_id, proof_image_url, points_earned)
  values (v_user_id, p_challenge_id, p_proof_image_url, v_points)
  returning id into v_id;

  return v_id;
end;
$$;

-- ============================================================================
-- STORAGE (already configured in Supabase Dashboard)
-- ============================================================================
-- The 'challenge_proofs' storage bucket is already created and used by
-- the VerificationBloc. Users can upload to it via the existing storage policy.
-- If you need to create it manually:
-- insert into storage.buckets (id, name, public) values ('challenge_proofs', 'challenge_proofs', true);
-- create policy "Users can upload own proofs"
--   on storage.objects for insert
--   with check (bucket_id = 'challenge_proofs' and auth.uid()::text = (storage.foldername(name))[1]);
