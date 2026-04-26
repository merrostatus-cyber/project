import React from 'react';

const quickActions = [
  { label: '💪 Chest Workout', message: 'Give me a chest workout' },
  { label: '🏠 Home Workout', message: 'Home workout no equipment' },
  { label: '🌟 Beginner Plan', message: "I'm a beginner, help me start" },
  { label: '🦵 Leg Day', message: 'Leg day workout' },
  { label: '🔥 HIIT Session', message: 'Give me a HIIT workout' },
  { label: '📋 Weekly Plan', message: 'Create a weekly workout plan' },
  { label: '💪 Build Muscle', message: 'How to build muscle' },
  { label: '🏃 Lose Weight', message: 'Workout plan for weight loss' },
  { label: '🎯 Back & Biceps', message: 'Back and biceps workout' },
  { label: '⏱️ Quick 15 Min', message: '15 minute quick workout' },
];

export default function QuickActions({ onAction, compact = false }) {
  return (
    <div className={`flex gap-2 ${compact ? 'flex-wrap' : 'overflow-x-auto pb-2'}`}>
      {quickActions.map((action, index) => (
        <button
          key={index}
          onClick={() => onAction(action.message)}
          className="quick-btn flex-shrink-0 px-4 py-2 rounded-full text-sm font-medium
                     bg-dark-700/60 border border-dark-500/40 text-dark-100
                     hover:border-neon-green/30 hover:text-neon-green hover:bg-dark-600/60
                     transition-all duration-200 whitespace-nowrap cursor-pointer"
        >
          {action.label}
        </button>
      ))}
    </div>
  );
}
