import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { Bell } from 'lucide-react';
import type { Challenge } from '../types';
import { getDailyChallenges } from '../lib/api';

export default function ChallengeFeed() {
  const [challenges, setChallenges] = useState<Challenge[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    loadChallenges();
  }, []);

  const loadChallenges = async () => {
    try {
      setLoading(true);
      setError('');
      const data = await getDailyChallenges();
      setChallenges(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load challenges');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="loading-page">
        <div className="spinner spinner-lg" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="page-container" style={{ paddingTop: 80 }}>
        <div className="empty-state">
          <p style={{ color: 'var(--primary-red)', marginBottom: 12 }}>Error: {error}</p>
          <button className="btn btn-secondary" onClick={loadChallenges}>Retry</button>
        </div>
      </div>
    );
  }

  return (
    <div className="page-container" style={{ paddingTop: 16 }}>
      {/* Header */}
      <div className="animate-in" style={{ marginBottom: 24 }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h1 style={{ fontSize: 24, fontWeight: 800 }}>Today's Challenges</h1>
          <button className="btn btn-ghost btn-sm" style={{ padding: 8 }}>
            <Bell size={20} />
          </button>
        </div>
      </div>

      {/* Challenge Grid */}
      <div className="challenge-grid">
        {challenges.map((challenge, i) => (
          <Link
            key={challenge.id}
            to={`/challenge/${challenge.id}`}
            className="challenge-card animate-in"
            style={{ animationDelay: `${i * 50}ms` }}
          >
            <img
              src={challenge.imageUrl}
              alt={challenge.title}
              className="challenge-card-img"
              loading="lazy"
            />
            <div className="challenge-card-overlay" />
            <div className="challenge-card-content">
              <div className="challenge-card-top">
                <span className="badge" style={{ background: 'rgba(255,255,255,0.2)', color: 'white' }}>
                  {challenge.category.toUpperCase()}
                </span>
                <span className="badge-red">+{challenge.impactPoints} pts</span>
              </div>
              <div className="challenge-card-title">{challenge.title}</div>
              <div className="challenge-card-desc">{challenge.description}</div>
            </div>
          </Link>
        ))}
      </div>

      {challenges.length === 0 && (
        <div className="empty-state" style={{ marginTop: 40 }}>
          No challenges available today. Check back later!
        </div>
      )}

      <div style={{ height: 40 }} />
    </div>
  );
}
