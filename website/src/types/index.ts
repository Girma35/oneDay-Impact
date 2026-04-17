// ── Challenge ──────────────────────────────────────────────────────
export type ChallengeCategory =
  | 'environment'
  | 'elders'
  | 'education'
  | 'cleanliness'
  | 'farming'
  | 'water';

export interface Challenge {
  id: string;
  title: string;
  description: string;
  category: ChallengeCategory;
  imageUrl: string;
  impactPoints: number;
  verificationKeywords: string[];
}

// ── Completed Challenge ────────────────────────────────────────────
export interface CompletedChallenge {
  id: string;
  userId: string;
  challengeId: string;
  proofImageUrl?: string | null;
  pointsEarned: number;
  verifiedAt: string;
  challenge?: Challenge | null;
}

// ── User Profile ──────────────────────────────────────────────────
export interface UserProfile {
  id: string;
  username: string;
  fullName: string;
  avatarUrl?: string | null;
  level: number;
  totalXp: number;
  streak: number;
  bestStreak: number;
  rankTitle: string;
  createdAt: string;
  updatedAt: string;
}

// ── Achievement ───────────────────────────────────────────────────
export interface Achievement {
  id: string;
  key: string;
  title: string;
  description: string;
  iconName: string;
  colorHex: string;
  bgColorHex: string;
  criteria: Record<string, unknown>;
}

export interface UserAchievement {
  id: string;
  userId: string;
  achievementId: string;
  unlockedAt: string;
  achievement?: Achievement | null;
}

// ── Community Goal ────────────────────────────────────────────────
export interface CommunityGoal {
  id: string;
  title: string;
  targetCount: number;
  currentCount: number;
  startDate: string;
  endDate?: string | null;
  isActive: boolean;
  createdAt: string;
}

// ── Impact ─────────────────────────────────────────────────────────
export interface ImpactBreakdownEntry {
  category: string;
  count: number;
  percentage: number;
}

export interface ContributionDay {
  day: string;
  count: number;
}
