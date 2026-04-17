import { useState, useEffect } from 'react';
import { Routes, Route, NavLink, Navigate } from 'react-router-dom';
import { Compass, BarChart3, User, Leaf } from 'lucide-react';
import { useAuth } from './contexts/AuthContext';
import { getCurrentUserProfile } from './lib/api';
import { displayRankTitle } from './lib/utils';
import type { UserProfile } from './types';
import ChallengeFeed from './pages/ChallengeFeed';
import ChallengeDetails from './pages/ChallengeDetails';
import Impact from './pages/Impact';
import Profile from './pages/Profile';

function AppLayout() {
  const { user } = useAuth();
  const [profile, setProfile] = useState<UserProfile | null>(null);

  useEffect(() => {
    if (user) {
      getCurrentUserProfile().then(setProfile).catch(() => {});
    }
  }, [user]);

  const displayName = profile?.fullName ?? 'Explorer';
  const avatarUrl = profile?.avatarUrl ?? 'https://i.pravatar.cc/150?img=11';
  const rank = profile ? displayRankTitle(profile.rankTitle) : 'BEGINNER';

  return (
    <div className="app-layout">
      {/* Desktop Sidebar */}
      <aside className="sidebar">
        <div className="sidebar-brand">
          <Leaf size={28} />
          OneDay
        </div>
        <nav className="sidebar-nav">
          <NavLink to="/explore" className={({ isActive }) => `sidebar-link ${isActive ? 'active' : ''}`}>
            <Compass /> Explore
          </NavLink>
          <NavLink to="/impact" className={({ isActive }) => `sidebar-link ${isActive ? 'active' : ''}`}>
            <BarChart3 /> Impact
          </NavLink>
          <NavLink to="/profile" className={({ isActive }) => `sidebar-link ${isActive ? 'active' : ''}`}>
            <User /> Profile
          </NavLink>
        </nav>
        <div className="sidebar-user">
          <img
            src={avatarUrl}
            alt=""
            className="sidebar-user-avatar"
          />
          <div>
            <div className="sidebar-user-name">{displayName}</div>
            <div className="sidebar-user-rank">{rank}</div>
          </div>
        </div>
      </aside>

      {/* Main Content Area */}
      <main className="main-content">
        {/* Mobile Header */}
        <div className="mobile-header">
          <div className="mobile-header-title">
            <Leaf size={18} /> OneDay
          </div>
          <div className="mobile-header-right">
            <img
              src={avatarUrl}
              alt=""
              className="mobile-header-avatar"
            />
          </div>
        </div>

        <Routes>
          <Route path="/explore" element={<ChallengeFeed />} />
          <Route path="/challenge/:id" element={<ChallengeDetails />} />
          <Route path="/impact" element={<Impact />} />
          <Route path="/profile" element={<Profile />} />
          <Route path="*" element={<Navigate to="/explore" replace />} />
        </Routes>
      </main>

      {/* Mobile Bottom Nav */}
      <nav className="mobile-nav">
        <div className="mobile-nav-inner">
          <NavLink to="/explore" className={({ isActive }) => `mobile-nav-link ${isActive ? 'active' : ''}`}>
            <Compass size={22} />
            Explore
          </NavLink>
          <NavLink to="/impact" className={({ isActive }) => `mobile-nav-link ${isActive ? 'active' : ''}`}>
            <BarChart3 size={22} />
            Impact
          </NavLink>
          <NavLink to="/profile" className={({ isActive }) => `mobile-nav-link ${isActive ? 'active' : ''}`}>
            <User size={22} />
            Profile
          </NavLink>
        </div>
      </nav>
    </div>
  );
}

export default function App() {
  const { loading } = useAuth();

  if (loading) {
    return <div className="loading-page"><div className="spinner spinner-lg" /></div>;
  }

  return (
    <Routes>
      <Route path="/*" element={<AppLayout />} />
    </Routes>
  );
}
