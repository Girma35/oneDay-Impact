import { supabase } from './supabase';
import type {
  Challenge,
  CompletedChallenge,
  UserProfile,
  UserAchievement,
  CommunityGoal,
  ImpactBreakdownEntry,
  ContributionDay,
} from '../types';

// ── Challenge API ──────────────────────────────────────────────────

export async function getDailyChallenges(): Promise<Challenge[]> {
  const today = new Date().toISOString().split('T')[0];

  let { data, error } = await supabase
    .from('challenges')
    .select()
    .eq('active_date', today)
    .order('impact_points', { ascending: false });

  if (error) throw error;

  // Fallback: if no challenges for today, fetch all active challenges
  if (!data || data.length === 0) {
    const fallback = await supabase
      .from('challenges')
      .select()
      .order('impact_points', { ascending: false })
      .limit(10);
    if (fallback.error) throw fallback.error;
    data = fallback.data;
  }

  return data.map(mapChallenge);
}

export async function getChallengeById(id: string): Promise<Challenge | null> {
  const { data, error } = await supabase
    .from('challenges')
    .select()
    .eq('id', id)
    .maybeSingle();

  if (error) throw error;
  if (!data) return null;
  return mapChallenge(data);
}

// ── Completed Challenge API ────────────────────────────────────────

export async function getUserCompletions(limit = 10): Promise<CompletedChallenge[]> {
  const userId = (await supabase.auth.getUser()).data.user?.id;
  if (!userId) return [];

  const { data, error } = await supabase
    .from('completed_challenges')
    .select('*, challenges(*)')
    .eq('user_id', userId)
    .order('verified_at', { ascending: false })
    .limit(limit);

  if (error) throw error;
  return (data ?? []).map(mapCompletedChallenge);
}

export async function getCompletionsCount(): Promise<number> {
  const userId = (await supabase.auth.getUser()).data.user?.id;
  if (!userId) return 0;

  const { count, error } = await supabase
    .from('completed_challenges')
    .select('id', { count: 'exact', head: true })
    .eq('user_id', userId);

  if (error) throw error;
  return count ?? 0;
}

export async function completeChallenge(
  challengeId: string,
  proofImageUrl?: string | null
): Promise<string> {
  const { data, error } = await supabase.rpc('complete_challenge', {
    p_challenge_id: challengeId,
    p_proof_image_url: proofImageUrl ?? null,
  });

  if (error) throw error;
  return data as string;
}

// ── Profile API ────────────────────────────────────────────────────

export async function getCurrentUserProfile(): Promise<UserProfile | null> {
  const userId = (await supabase.auth.getUser()).data.user?.id;
  if (!userId) return null;

  const { data, error } = await supabase
    .from('profiles')
    .select()
    .eq('id', userId)
    .maybeSingle();

  if (error) throw error;
  if (!data) return null;
  return mapProfile(data);
}

export async function updateProfile(updates: {
  fullName?: string;
  avatarUrl?: string;
  username?: string;
}): Promise<void> {
  const updateData: Record<string, unknown> = {};
  if (updates.fullName !== undefined) updateData['full_name'] = updates.fullName;
  if (updates.avatarUrl !== undefined) updateData['avatar_url'] = updates.avatarUrl;
  if (updates.username !== undefined) updateData['username'] = updates.username;

  if (Object.keys(updateData).length > 0) {
    const { error } = await supabase.from('profiles').update(updateData).eq('id', (await supabase.auth.getUser()).data.user?.id ?? '');
    if (error) throw error;
  }
}

export async function getGlobalRank(): Promise<number> {
  const { data, error } = await supabase.rpc('get_global_rank', {
    p_user_id: (await supabase.auth.getUser()).data.user?.id,
  });
  if (error) throw error;
  return (data as number) ?? 50;
}

/** Alias for getCompletionsCount — same query, semantic name for profile page */
export async function getVerifiedCount(): Promise<number> {
  return getCompletionsCount();
}

// ── Achievement API ────────────────────────────────────────────────

export async function getAllAchievements() {
  const { data, error } = await supabase
    .from('achievements')
    .select()
    .order('title');
  if (error) throw error;
  return (data ?? []).map(mapAchievement);
}

export async function getUserAchievements(): Promise<UserAchievement[]> {
  const { data, error } = await supabase
    .from('user_achievements')
    .select('*, achievements(*)')
    .order('unlocked_at', { ascending: false });
  if (error) throw error;
  return (data ?? []).map(mapUserAchievement);
}

export async function getAllWithStatus(): Promise<UserAchievement[]> {
  const [allAchievements, unlocked] = await Promise.all([
    getAllAchievements(),
    getUserAchievements(),
  ]);

  const userId = (await supabase.auth.getUser()).data.user?.id ?? '';

  return allAchievements.map((ach) => {
    const existing = unlocked.find((ua) => ua.achievementId === ach.id);
    if (existing) return existing;
    return {
      id: '',
      userId,
      achievementId: ach.id,
      unlockedAt: new Date(0).toISOString(),
      achievement: ach,
    };
  });
}

// ── Impact API ─────────────────────────────────────────────────────

export async function getImpactBreakdown(): Promise<ImpactBreakdownEntry[]> {
  const userId = (await supabase.auth.getUser()).data.user?.id;
  if (!userId) return [];

  const { data, error } = await supabase.rpc('get_impact_breakdown', {
    p_user_id: userId,
  });
  if (error) throw error;
  return (data ?? []).map((d: Record<string, unknown>) => ({
    category: d.category as string,
    count: d.count as number,
    percentage: Number(d.percentage),
  }));
}

export async function getContributionHeatmap(days = 70): Promise<ContributionDay[]> {
  const userId = (await supabase.auth.getUser()).data.user?.id;
  if (!userId) return [];

  const { data, error } = await supabase.rpc('get_contribution_heatmap', {
    p_user_id: userId,
    p_days: days,
  });
  if (error) throw error;
  return (data ?? []).map((d: Record<string, unknown>) => ({
    day: d.day as string,
    count: d.count as number,
  }));
}

export async function getActiveCommunityGoals(): Promise<CommunityGoal[]> {
  const { data, error } = await supabase
    .from('community_goals')
    .select()
    .eq('is_active', true)
    .order('created_at', { ascending: false });
  if (error) throw error;
  return (data ?? []).map(mapCommunityGoal);
}

// ── Storage ────────────────────────────────────────────────────────

export async function uploadProofImage(file: File): Promise<string> {
  const ext = file.name.split('.').pop() ?? 'jpg';
  const fileName = `proof_${Date.now()}.${ext}`;
  const { error } = await supabase.storage
    .from('challenge_proofs')
    .upload(fileName, file, {
      cacheControl: '3600',
      upsert: true,
      contentType: file.type,
    });
  if (error) throw error;

  const { data: urlData } = supabase.storage
    .from('challenge_proofs')
    .getPublicUrl(fileName);
  return urlData.publicUrl;
}

export async function uploadAvatar(file: File, userId: string): Promise<string> {
  const ext = file.name.split('.').pop() ?? 'jpg';
  const storagePath = `avatars/${userId}/avatar_${Date.now()}.${ext}`;
  const { error } = await supabase.storage
    .from('avatars')
    .upload(storagePath, file, {
      cacheControl: '3600',
      upsert: true,
      contentType: file.type,
    });
  if (error) throw error;

  const { data: urlData } = supabase.storage
    .from('avatars')
    .getPublicUrl(storagePath);
  return `${urlData.publicUrl}?t=${Date.now()}`;
}

// ── Mappers ────────────────────────────────────────────────────────

function mapChallenge(json: Record<string, unknown>): Challenge {
  return {
    id: json.id as string,
    title: json.title as string,
    description: json.description as string,
    category: json.category as Challenge['category'],
    imageUrl: json.image_url as string,
    impactPoints: json.impact_points as number,
    verificationKeywords: (json.verification_keywords as string[]) ?? [],
  };
}

function mapCompletedChallenge(json: Record<string, unknown>): CompletedChallenge {
  let challenge: Challenge | null = null;
  if (json.challenges) {
    challenge = mapChallenge(json.challenges as Record<string, unknown>);
  }
  return {
    id: json.id as string,
    userId: json.user_id as string,
    challengeId: json.challenge_id as string,
    proofImageUrl: json.proof_image_url as string | null,
    pointsEarned: json.points_earned as number,
    verifiedAt: json.verified_at as string,
    challenge,
  };
}

function mapProfile(json: Record<string, unknown>): UserProfile {
  return {
    id: json.id as string,
    username: json.username as string,
    fullName: json.full_name as string,
    avatarUrl: json.avatar_url as string | null,
    level: json.level as number,
    totalXp: json.total_xp as number,
    streak: json.streak as number,
    bestStreak: json.best_streak as number,
    rankTitle: json.rank_title as string,
    createdAt: json.created_at as string,
    updatedAt: json.updated_at as string,
  };
}

function mapAchievement(json: Record<string, unknown>) {
  return {
    id: json.id as string,
    key: json.key as string,
    title: json.title as string,
    description: json.description as string,
    iconName: json.icon_name as string,
    colorHex: json.color_hex as string,
    bgColorHex: json.bg_color_hex as string,
    criteria: json.criteria as Record<string, unknown>,
  };
}

function mapUserAchievement(json: Record<string, unknown>): UserAchievement {
  let achievement = null;
  if (json.achievements) {
    achievement = mapAchievement(json.achievements as Record<string, unknown>);
  }
  return {
    id: json.id as string,
    userId: json.user_id as string,
    achievementId: json.achievement_id as string,
    unlockedAt: json.unlocked_at as string,
    achievement,
  };
}

function mapCommunityGoal(json: Record<string, unknown>): CommunityGoal {
  return {
    id: json.id as string,
    title: json.title as string,
    targetCount: json.target_count as number,
    currentCount: json.current_count as number,
    startDate: json.start_date as string,
    endDate: json.end_date as string | null,
    isActive: json.is_active as boolean,
    createdAt: json.created_at as string,
  };
}
