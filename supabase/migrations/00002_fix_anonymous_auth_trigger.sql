-- ============================================================================
-- Fix handle_new_user() trigger to support anonymous sign-ins
-- ============================================================================
-- Anonymous users have no email, so split_part(new.email, '@', 1) returns NULL
-- which violates the NOT NULL constraint on username/full_name.
-- This migration updates the trigger to provide fallback values for anonymous users.
-- ============================================================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, username, full_name, avatar_url)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'username', split_part(coalesce(new.email, ''), '@', 1), 'explorer_' || substr(new.id::text, 1, 8)),
    coalesce(new.raw_user_meta_data ->> 'full_name', split_part(coalesce(new.email, ''), '@', 1), 'Explorer'),
    coalesce(new.raw_user_meta_data ->> 'avatar_url', null)
  );
  return new;
end;
$$;
