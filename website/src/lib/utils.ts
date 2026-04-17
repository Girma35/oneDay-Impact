// ── XP Formatting ──────────────────────────────────────────────────
export function formatXp(xp: number): string {
  if (xp >= 10000) {
    const k = xp / 1000;
    return `${k % 1 === 0 ? k.toFixed(0) : k.toFixed(1)}K`;
  }
  return xp.toString();
}

// ── Count Formatting ───────────────────────────────────────────────
export function formatCount(count: number): string {
  if (count >= 1000000) return `${(count / 1000000).toFixed(1)}M`;
  if (count >= 1000) return `${(count / 1000).toFixed(1)}K`;
  return count.toString();
}

// ── Time Label Formatting ──────────────────────────────────────────
export function formatTimeLabel(dateStr: string): string {
  const date = new Date(dateStr);
  const now = new Date();
  const diffMs = now.getTime() - date.getTime();
  const diffMins = Math.floor(diffMs / 60000);
  const diffHours = Math.floor(diffMs / 3600000);
  const diffDays = Math.floor(diffMs / 86400000);

  if (diffMins < 1) return 'JUST NOW';
  if (diffMins < 60) return `${diffMins}M AGO`;
  if (diffHours < 24) return `${diffHours}H AGO`;
  if (diffDays < 7) return `${diffDays}D AGO`;
  return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }).toUpperCase();
}

// ── Category Color Mapping ─────────────────────────────────────────
const categoryColors: Record<string, string> = {
  ENVIRONMENT: '#28853D',
  ELDERS: '#C02A24',
  EDUCATION: '#6D28D9',
  CLEANLINESS: '#0369A1',
  FARMING: '#A16207',
  WATER: '#1D4ED8',
};

export function categoryColor(category: string): string {
  return categoryColors[category.toUpperCase()] ?? '#28853D';
}

// ── Category Icon Name Mapping ─────────────────────────────────────
const categoryIcons: Record<string, string> = {
  ENVIRONMENT: 'leaf',
  ELDERS: 'heart',
  EDUCATION: 'book-open',
  CLEANLINESS: 'sparkles',
  FARMING: 'wheat',
  WATER: 'droplets',
};

export function categoryIcon(category: string): string {
  return categoryIcons[category.toUpperCase()] ?? 'circle';
}

// ── Display Rank Title ─────────────────────────────────────────────
export function displayRankTitle(rankTitle: string): string {
  return rankTitle.replace(/-/g, ' ').toUpperCase();
}

// ── Map to Red/Green Palette ───────────────────────────────────────
export function mapToRedGreen(hex: string): string {
  const r = parseInt(hex.slice(1, 3), 16);
  const g = parseInt(hex.slice(3, 5), 16);
  const b = parseInt(hex.slice(5, 7), 16);
  if (r > g && r > b) return '#C02A24'; // primaryRed
  return '#28853D'; // primaryGreen
}

// ── Level / XP Calculations ────────────────────────────────────────
export function xpForLevel(level: number): number {
  return level * level * 50;
}

export function xpProgress(level: number, totalXp: number): number {
  const xpForCurrent = xpForLevel(level - 1);
  const xpForNext = xpForLevel(level);
  const xpInLevel = totalXp - xpForCurrent;
  const xpNeeded = xpForNext - xpForCurrent;
  if (xpNeeded <= 0) return 100;
  return Math.min(Math.max(Math.round((xpInLevel / xpNeeded) * 100), 0), 100);
}

// ── Icon name mapping for achievements ─────────────────────────────
const lucideIconMap: Record<string, string> = {
  'wb_sunny_rounded': 'sun',
  'fitness_center_rounded': 'dumbbell',
  'eco_rounded': 'leaf',
  'local_fire_department_rounded': 'flame',
  'emoji_events_rounded': 'trophy',
  'verified_rounded': 'badge-check',
  'stars_rounded': 'star',
  'military_tech_rounded': 'medal',
  'auto_awesome_rounded': 'sparkles',
  'thunderstorm_rounded': 'cloud-lightning',
  'volunteer_activism_rounded': 'hand-heart',
  'favorite_rounded': 'heart',
  'star': 'star',
};

export function iconNameToLucide(name: string): string {
  return lucideIconMap[name] ?? name.replace('_rounded', '').replace(/_/g, '-');
}
