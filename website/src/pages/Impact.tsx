import { useState, useEffect, useCallback } from 'react';
import {
  Flame, Trophy, Star, BadgeCheck,
  Leaf, Heart, BookOpen, Sparkles, Wheat, Droplets,
} from 'lucide-react';
import type { UserProfile, UserAchievement, CompletedChallenge, ImpactBreakdownEntry, ContributionDay, CommunityGoal } from '../types';
import {
  getCurrentUserProfile, getAllWithStatus, getUserCompletions,
  getImpactBreakdown, getContributionHeatmap, getActiveCommunityGoals, getCompletionsCount,
} from '../lib/api';
import { formatXp, formatCount, formatTimeLabel, categoryColor, categoryIcon, displayRankTitle, mapToRedGreen, iconNameToLucide, xpForLevel, xpProgress } from '../lib/utils';

function getIcon(name: string, size = 24) {
  const key = iconNameToLucide(name);
  const IconComponent = ({ leaf: Leaf, heart: Heart, 'book-open': BookOpen, sparkles: Sparkles, wheat: Wheat, droplets: Droplets, flame: Flame, trophy: Trophy, star: Star, 'badge-check': BadgeCheck } as Record<string, React.FC<{ size?: number }>>)[key];
  if (IconComponent) return <IconComponent size={size} />;
  return <Star size={size} />;
}

const heatmapColors = ['var(--heatmap-0)', 'var(--heatmap-1)', 'var(--heatmap-2)', 'var(--heatmap-3)', 'var(--heatmap-4)'];

export default function Impact() {
  const [profile, setProfile] = useState<UserProfile | null>(null);
  const [achievements, setAchievements] = useState<UserAchievement[]>([]);
  const [completions, setCompletions] = useState<CompletedChallenge[]>([]);
  const [breakdown, setBreakdown] = useState<ImpactBreakdownEntry[]>([]);
  const [heatmap, setHeatmap] = useState<ContributionDay[]>([]);
  const [communityGoals, setCommunityGoals] = useState<CommunityGoal[]>([]);
  const [verifiedCount, setVerifiedCount] = useState(0);
  const [loading, setLoading] = useState(true);

  const loadData = useCallback(async () => {
    try {
      const [p, a, c, b, h, g, v] = await Promise.all([
        getCurrentUserProfile(),
        getAllWithStatus(),
        getUserCompletions(10),
        getImpactBreakdown(),
        getContributionHeatmap(70),
        getActiveCommunityGoals(),
        getCompletionsCount(),
      ]);
      setProfile(p);
      setAchievements(a);
      setCompletions(c);
      setBreakdown(b);
      setHeatmap(h);
      setCommunityGoals(g);
      setVerifiedCount(v);
    } catch (err) {
      console.error('Impact data load error:', err);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { loadData(); }, [loadData]);

  if (loading) {
    return <div className="loading-page"><div className="spinner spinner-lg" /></div>;
  }

  const level = profile?.level ?? 1;
  const totalXp = profile?.totalXp ?? 0;
  const streak = profile?.streak ?? 0;
  const bestStreak = profile?.bestStreak ?? 0;
  const rank = profile ? displayRankTitle(profile.rankTitle) : 'BEGINNER';
  const avatarUrl = profile?.avatarUrl ?? 'https://i.pravatar.cc/150?img=60';
  const progressPct = xpProgress(level, totalXp);
  const flexProgress = Math.min(Math.max(progressPct, 1), 99);
  const nextLevelXp = xpForLevel(level);

  return (
    <div className="page-container" style={{ paddingTop: 16 }}>
      {/* Hero Level Card */}
      <div className="impact-hero-card animate-in">
        <div className="impact-hero-avatar-wrap">
          <img src={avatarUrl} alt="" className="impact-hero-avatar-inner" style={{ borderRadius: '50%' }} />
          <div className="impact-hero-rank-badge">{rank}</div>
        </div>
        <div className="impact-hero-title">Keep pushing,{'\n'}Champion!</div>
        <div className="impact-xp-row">
          <span className="impact-xp-level">LVL {level}</span>
          <span>
            <span className="impact-xp-value">{formatXp(totalXp)}</span>
            <span className="impact-xp-max"> / {formatXp(nextLevelXp)} pts</span>
          </span>
        </div>
        <div className="progress-bar">
          <div className="progress-fill progress-fill-red" style={{ width: `${flexProgress}%` }} />
        </div>
      </div>

      {/* Metrics Grid */}
      <div className="metrics-grid animate-in animate-delay-1">
        <div className="metric-card metric-card-red">
          <div className="metric-icon"><Flame size={24} color="white" /></div>
          <div className="metric-value" style={{ color: 'white' }}>{streak} Day</div>
          <div className="metric-label">STREAK</div>
        </div>
        <div className="metric-card metric-card-white">
          <div className="metric-icon"><Trophy size={24} color="var(--primary-red)" /></div>
          <div className="metric-value">{bestStreak}</div>
          <div className="metric-label">BEST STREAK</div>
        </div>
        <div className="metric-card metric-card-white">
          <div className="metric-icon"><Star size={24} color="var(--dark-red)" /></div>
          <div className="metric-value">{formatXp(totalXp)}</div>
          <div className="metric-label">TOTAL XP</div>
        </div>
        <div className="metric-card metric-card-white">
          <div className="metric-icon"><BadgeCheck size={24} color="var(--primary-green)" /></div>
          <div className="metric-value" style={{ color: 'var(--primary-green)' }}>{verifiedCount}</div>
          <div className="metric-label">VERIFIED</div>
        </div>
      </div>

      {/* Impact Breakdown */}
      <div className="breakdown-card animate-in animate-delay-2">
        <h3>Impact Breakdown</h3>
        {breakdown.length === 0 ? (
          <div className="empty-state">Complete challenges to see your impact breakdown!</div>
        ) : (
          breakdown.map((entry) => {
            const color = categoryColor(entry.category);
            const flex = Math.min(Math.max(Math.round(entry.percentage), 1), 99);
            return (
              <div key={entry.category} className="breakdown-row">
                <div className="breakdown-row-header">
                  <span>{entry.category.toUpperCase()}</span>
                  <span>{Math.round(entry.percentage)}%</span>
                </div>
                <div className="breakdown-row-bar" style={{ background: `${color}22` }}>
                  <div className="breakdown-row-fill" style={{ width: `${flex}%`, background: color }} />
                </div>
              </div>
            );
          })
        )}
      </div>

      {/* Contribution Heatmap */}
      <div className="breakdown-card animate-in animate-delay-3">
        <h3>Contribution Grid</h3>
        {heatmap.length === 0 ? (
          <div className="empty-state">Complete challenges to build your contribution grid!</div>
        ) : (
          <>
            <div className="heatmap-grid">
              {(() => {
                const now = new Date();
                const gridData = Array(70).fill(0);
                for (const day of heatmap) {
                  const d = new Date(day.day);
                  const diff = Math.floor((now.getTime() - d.getTime()) / 86400000);
                  if (diff >= 0 && diff < 70) {
                    const level = day.count === 0 ? 0 : day.count === 1 ? 1 : day.count === 2 ? 2 : day.count === 3 ? 3 : 4;
                    gridData[69 - diff] = level;
                  }
                }
                return gridData.map((lvl, i) => (
                  <div
                    key={i}
                    className="heatmap-cell"
                    style={{ background: heatmapColors[lvl] }}
                  />
                ));
              })()}
            </div>
            <div className="heatmap-legend">
              <span>LESS IMPACT</span>
              <div className="heatmap-legend-colors">
                {heatmapColors.map((c, i) => (
                  <div key={i} className="heatmap-legend-box" style={{ background: c }} />
                ))}
              </div>
              <span>MORE IMPACT</span>
            </div>
          </>
        )}
      </div>

      {/* Community Goal */}
      {communityGoals.length > 0 && (() => {
        const goal = communityGoals[0];
        const pct = goal.targetCount > 0 ? Math.round((goal.currentCount / goal.targetCount) * 100) : 0;
        const flexGoal = Math.min(Math.max(pct, 1), 99);
        return (
          <div className="community-goal-card animate-in animate-delay-4">
            <div className="community-goal-header">
              <div className="community-goal-title">{'Global\nCommunity\nGoal'}</div>
              <div className="community-goal-cta">{'Join the\neffort!'}</div>
            </div>
            <div className="community-goal-desc">{goal.title}</div>
            <div className="community-goal-progress-header">
              <span>Current Progress</span>
              <span>{formatCount(goal.currentCount)} / {formatCount(goal.targetCount)}</span>
            </div>
            <div className="community-goal-bar">
              <div className="community-goal-fill" style={{ width: `${flexGoal}%` }}>
                <span className="community-goal-fill-text">{pct}%</span>
              </div>
            </div>
          </div>
        );
      })()}

      {/* Achievements */}
      <div className="animate-in animate-delay-4" style={{ marginBottom: 24 }}>
        <div className="section-header">
          <span className="section-title">Your Achievements</span>
          <span className="section-link">View All</span>
        </div>
        {achievements.filter(a => a.id).length === 0 ? (
          <div className="empty-state">Complete challenges to unlock achievements!</div>
        ) : (
          <div className="achievement-scroll">
            {achievements.filter(a => a.id).slice(0, 5).map((ua) => {
              const ach = ua.achievement;
              const color = ach ? mapToRedGreen(ach.colorHex) : 'var(--primary-green)';
              return (
                <div key={ua.achievementId} className="achievement-item">
                  <div className="achievement-icon-wrap" style={{ background: `${color}1F` }}>
                    {ach ? getIcon(ach.iconName, 28) : <Star size={28} style={{ color }} />}
                  </div>
                  <div className="achievement-label">{ach?.title ?? 'Badge'}</div>
                </div>
              );
            })}
          </div>
        )}
      </div>

      {/* Recent Activity */}
      <div className="animate-in" style={{ marginBottom: 24 }}>
        <div className="section-header">
          <span className="section-title">Recent Activity</span>
        </div>
        {completions.length === 0 ? (
          <div className="empty-state">No recent activity yet. Complete a challenge to get started!</div>
        ) : (
          completions.slice(0, 3).map((c) => {
            const cat = c.challenge?.category ?? 'environment';
            const color = categoryColor(cat);
            return (
              <div key={c.id} className="activity-card">
                <div className="activity-card-inner" style={{ borderLeftColor: color }}>
                  <div className="activity-icon-wrap" style={{ background: `${color}1F` }}>
                    {getIcon(categoryIcon(cat), 24)}
                  </div>
                  <div className="activity-info">
                    <div className="activity-time">{formatTimeLabel(c.verifiedAt)}</div>
                    <div className="activity-title">{c.challenge?.title ?? 'Challenge'}</div>
                  </div>
                  <div className="activity-points" style={{ color }}>+{c.pointsEarned} pts</div>
                </div>
              </div>
            );
          })
        )}
      </div>

      <div style={{ height: 40 }} />
    </div>
  );
}
