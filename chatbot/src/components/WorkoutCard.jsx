import React, { useState } from 'react';

export default function WorkoutCard({ exercise, index }) {
  const [expanded, setExpanded] = useState(false);

  const difficultyBadge = {
    beginner: 'badge-beginner',
    intermediate: 'badge-intermediate',
    advanced: 'badge-advanced',
  };

  return (
    <div
      className="workout-card p-4 mb-3 cursor-pointer"
      onClick={() => setExpanded(!expanded)}
    >
      <div className="flex items-center justify-between mb-2">
        <div className="flex items-center gap-2">
          {index !== undefined && (
            <span className="w-6 h-6 rounded-full bg-neon-green/15 text-neon-green text-xs font-bold flex items-center justify-center">
              {index + 1}
            </span>
          )}
          <h4 className="font-semibold text-white text-sm">{exercise.name}</h4>
        </div>
        <span className={`badge ${difficultyBadge[exercise.difficulty] || 'badge-beginner'}`}>
          {exercise.difficulty}
        </span>
      </div>

      <div className="flex flex-wrap gap-3 text-xs text-dark-200 mb-2">
        <span>🎯 {exercise.muscle}</span>
        <span>📦 {exercise.sets} sets × {exercise.reps}</span>
        <span>⏱️ Rest: {exercise.rest}</span>
        <span>🏋️ {exercise.equipment}</span>
      </div>

      {exercise.secondary && exercise.secondary.length > 0 && (
        <div className="flex gap-1.5 flex-wrap mb-2">
          {exercise.secondary.map((m, i) => (
            <span key={i} className="text-[10px] px-2 py-0.5 rounded-full bg-dark-600/60 text-dark-200">
              {m}
            </span>
          ))}
        </div>
      )}

      {expanded && exercise.instructions && (
        <div className="mt-3 pt-3 border-t border-dark-500/30 animate-fade-up">
          <p className="text-xs font-semibold text-neon-green mb-2">Step-by-step:</p>
          <ol className="text-xs text-dark-100 space-y-1.5 pl-4 list-decimal">
            {exercise.instructions.map((step, i) => (
              <li key={i}>{step}</li>
            ))}
          </ol>
        </div>
      )}

      <div className="text-[10px] text-dark-300 mt-2 text-right">
        {expanded ? '▲ tap to collapse' : '▼ tap for details'}
      </div>
    </div>
  );
}
