import { useState, useEffect, useRef, useCallback } from 'react';
import {
  Camera, Bell, Shield, HelpCircle, ChevronRight,
  User, Flame, Trophy, Star, BadgeCheck, Leaf, Heart,
  Sparkles,
} from 'lucide-react';
import type { UserProfile as ProfileType, UserAchievement } from '../types';
import { getCurrentUserProfile, getAllWithStatus, getGlobalRank, getVerifiedCount, updateProfile, uploadAvatar } from '../lib/api';

import { formatXp, displayRankTitle, mapToRedGreen, iconNameToLucide } from '../lib/utils';

const settingsItems = [
  { icon: <User size={20} />, label: 'Personal Information' },
  { icon: <Bell size={20} />, label: 'Notification Preferences' },
  { icon: <Shield size={20} />, label: 'Privacy & Security' },
  { icon: <HelpCircle size={20} />, label: 'Help & Support' },
];

export default function Profile() {
  const avatarInputRef = useRef<HTMLInputElement>(null);

  const [profile, setProfile] = useState<ProfileType | null>(null);
  const [achievements, setAchievements] = useState<UserAchievement[]>([]);
  const [globalRank, setGlobalRank] = useState(0);
  const [verifiedCount, setVerifiedCount] = useState(0);
  const [loading, setLoading] = useState(true);
  const [toast, setToast] = useState<{ message: string; type: 'success' | 'error' } | null>(null);

  const loadData = useCallback(async () => {
    try {
      const [p, a, r, v] = await Promise.all([
        getCurrentUserProfile(),
        getAllWithStatus(),
        getGlobalRank(),
        getVerifiedCount(),
      ]);
      setProfile(p);
      setAchievements(a);
      setGlobalRank(r);
      setVerifiedCount(v);
    } catch (err) {
      console.error('Profile data load error:', err);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { loadData(); }, [loadData]);

  const showToast = (message: string, type: 'success' | 'error' = 'success') => {
    setToast({ message, type });
    setTimeout(() => setToast(null), 3000);
  };

  const handleAvatarUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file || !profile) return;

    try {
      showToast('Uploading avatar...');
      const url = await uploadAvatar(file, profile.id);
      await updateProfile({ avatarUrl: url });
      await loadData();
      showToast('Avatar updated!');
    } catch (err) {
      showToast('Failed to upload avatar', 'error');
    }
  };



  if (loading) {
    return <div className="loading-page"><div className="spinner spinner-lg" /></div>;
  }

  const level = profile?.level ?? 1;
  const totalXp = profile?.totalXp ?? 0;
  const streak = profile?.streak ?? 0;
  const rank = profile ? displayRankTitle(profile.rankTitle) : 'BEGINNER';
  const avatarUrl = profile?.avatarUrl ?? 'https://i.pravatar.cc/150?img=11';
  const fullName = profile?.fullName ?? 'Loading...';

  return (
    <div className="page-container" style={{ paddingTop: 16 }}>
      {/* Profile Header */}
      <div className="profile-header animate-in">
        <input
          ref={avatarInputRef}
          type="file"
          accept="image/*"
          style={{ display: 'none' }}
          onChange={handleAvatarUpload}
        />
        <div className="profile-avatar-wrap" onClick={() => avatarInputRef.current?.click()}>
          <img src={avatarUrl} alt="" className="profile-avatar-inner" style={{ borderRadius: '50%' }} />
          <div className="profile-avatar-cam"><Camera /></div>
          <div className="profile-rank-badge">
            <Leaf size={14} />
            {rank}
          </div>
        </div>
        <div className="profile-name">{fullName}</div>
        <div className="profile-level-badge">LEVEL {level} • {rank}</div>
      </div>

      {/* Metrics Grid */}
      <div className="profile-metrics animate-in animate-delay-1">
        <div className="profile-metric-card" style={{ background: 'var(--surface)', boxShadow: 'var(--shadow-sm)' }}>
          <div className="profile-metric-title" style={{ color: 'var(--text-secondary)' }}>TOTAL XP</div>
          <div className="profile-metric-value">
            {formatXp(totalXp).replace(/K$/, '')}
            {totalXp >= 10000 && <span style={{ fontSize: 20, color: 'var(--primary-red)' }}>K</span>}
          </div>
        </div>
        <div className="profile-metric-card" style={{ background: 'var(--pale-green)' }}>
          <div className="profile-metric-title" style={{ color: 'var(--primary-green)' }}>VERIFIED</div>
          <div className="profile-metric-value" style={{ color: 'var(--primary-green)' }}>{verifiedCount}</div>
          <div className="profile-metric-subtitle" style={{ color: 'var(--primary-green)' }}>Challenges Completed</div>
        </div>
        <div className="profile-metric-card" style={{ background: 'var(--primary-red)', boxShadow: 'var(--shadow-red)', color: 'white' }}>
          <div className="profile-metric-title" style={{ color: 'rgba(255,255,255,0.7)' }}>STREAK</div>
          <div className="profile-metric-value" style={{ color: 'white', display: 'flex', alignItems: 'baseline', gap: 4 }}>
            <Flame size={28} color="white" />
            {streak}
            <span style={{ fontSize: 12, fontWeight: 700, color: 'rgba(255,255,255,0.7)', paddingTop: 8 }}>DAYS</span>
          </div>
        </div>
        <div className="profile-metric-card" style={{ background: 'var(--light-green)' }}>
          <div className="profile-metric-title" style={{ color: 'var(--dark-green)' }}>GLOBAL RANK</div>
          <div className="profile-metric-value" style={{ color: 'var(--dark-green)' }}>
            {globalRank}<span style={{ fontSize: 20 }}>%</span>
          </div>
          <div className="profile-metric-subtitle" style={{ color: 'var(--dark-green)' }}>Top Tier Impact</div>
        </div>
      </div>

      {/* Achievement Wardrobe */}
      <div className="animate-in animate-delay-2" style={{ marginBottom: 32 }}>
        <div className="section-header">
          <span className="section-title" style={{ fontSize: 20 }}>Achievement Wardrobe</span>
          <span className="section-link">VIEW ALL</span>
        </div>
        {achievements.filter(a => a.id).length === 0 ? (
          <div className="empty-state">Complete challenges to earn badges!</div>
        ) : (
          <div className="achievement-scroll">
            {achievements.filter(a => a.id).slice(0, 5).map((ua) => {
              const ach = ua.achievement;
              const color = ach ? mapToRedGreen(ach.colorHex) : 'var(--primary-green)';
              const IconMap: Record<string, React.FC<{ size?: number; color?: string }>> = {
                sun: ({ size, color }) => <Sparkles size={size} color={color} />,
                dumbbell: ({ size, color }) => <Flame size={size} color={color} />,
                leaf: Leaf, heart: Heart, flame: Flame, trophy: Trophy,
                star: Star, 'badge-check': BadgeCheck, sparkles: Sparkles,
                'cloud-lightning': ({ size, color }) => <Flame size={size} color={color} />,
                'hand-heart': ({ size, color }) => <Heart size={size} color={color} />,
                medal: ({ size, color }) => <Trophy size={size} color={color} />,
              };
              const iconKey = ach ? iconNameToLucide(ach.iconName) : 'star';
              const IconComp = IconMap[iconKey] ?? Star;
              return (
                <div key={ua.achievementId} className="achievement-item">
                  <div className="achievement-icon-wrap" style={{ background: `${color}1F` }}>
                    <IconComp size={28} color={color} />
                  </div>
                  <div className="achievement-label">{ach?.title ?? 'Badge'}</div>
                </div>
              );
            })}
          </div>
        )}
      </div>

      {/* Account Settings */}
      <div className="animate-in animate-delay-3" style={{ marginBottom: 32 }}>
        <h3 style={{ fontSize: 20, fontWeight: 700, marginBottom: 16 }}>Account Settings</h3>
        <div className="settings-card">
          {settingsItems.map((item, i) => (
            <div key={i} className="settings-row">
              <div className="settings-icon-wrap">{item.icon}</div>
              <div className="settings-label">{item.label}</div>
              <div className="settings-chevron"><ChevronRight size={20} color="var(--text-light)" /></div>
            </div>
          ))}
        </div>
      </div>

      <div style={{ height: 40 }} />

      {/* Toast */}
      {toast && <div className={`toast toast-${toast.type}`}>{toast.message}</div>}
    </div>
  );
}
