import React from 'react';
import WorkoutCard from './WorkoutCard';

// Simple markdown-like parser for bot messages
function parseMarkdown(text) {
  if (!text) return '';

  // Process line by line
  const lines = text.split('\n');
  let html = '';
  let inList = false;
  let listType = null;

  lines.forEach((line, i) => {
    const trimmed = line.trim();

    // Headers
    if (trimmed.startsWith('### ')) {
      if (inList) { html += listType === 'ol' ? '</ol>' : '</ul>'; inList = false; }
      html += `<h3>${parseInline(trimmed.substring(4))}</h3>`;
      return;
    }

    // Unordered list
    if (trimmed.startsWith('• ') || trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
      if (!inList || listType !== 'ul') {
        if (inList) html += listType === 'ol' ? '</ol>' : '</ul>';
        html += '<ul>';
        inList = true;
        listType = 'ul';
      }
      html += `<li>${parseInline(trimmed.substring(2))}</li>`;
      return;
    }

    // Ordered list
    const olMatch = trimmed.match(/^(\d+)\.\s(.+)/);
    if (olMatch) {
      if (!inList || listType !== 'ol') {
        if (inList) html += listType === 'ol' ? '</ol>' : '</ul>';
        html += '<ol>';
        inList = true;
        listType = 'ol';
      }
      html += `<li>${parseInline(olMatch[2])}</li>`;
      return;
    }

    // Close any open list
    if (inList && trimmed === '') {
      html += listType === 'ol' ? '</ol>' : '</ul>';
      inList = false;
      listType = null;
    }

    // Table row
    if (trimmed.startsWith('|') && trimmed.endsWith('|')) {
      // Skip separator rows
      if (trimmed.match(/^\|[\s-|:]+\|$/)) return;
      const cells = trimmed.split('|').filter(c => c.trim() !== '');
      const isHeader = i < lines.length - 1 && lines[i + 1]?.trim().match(/^\|[\s-|:]+\|$/);
      const tag = isHeader ? 'th' : 'td';
      html += '<tr>';
      cells.forEach(cell => {
        html += `<${tag} style="padding:6px 10px;border:1px solid rgba(255,255,255,0.08);text-align:left;font-size:12px">${parseInline(cell.trim())}</${tag}>`;
      });
      html += '</tr>';
      return;
    }

    // Empty line
    if (trimmed === '') {
      if (!inList) html += '<br/>';
      return;
    }

    // Normal paragraph
    if (inList) { html += listType === 'ol' ? '</ol>' : '</ul>'; inList = false; }
    html += `<p>${parseInline(trimmed)}</p>`;
  });

  if (inList) html += listType === 'ol' ? '</ol>' : '</ul>';
  return html;
}

function parseInline(text) {
  return text
    .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
    .replace(/_(.+?)_/g, '<em>$1</em>')
    .replace(/`(.+?)`/g, '<code style="background:rgba(0,230,118,0.1);padding:1px 5px;border-radius:4px;font-size:12px;color:#00e676">$1</code>');
}

export default function ChatBubble({ message }) {
  const isUser = message.role === 'user';
  const isBot = message.role === 'bot';

  // Render structured data (workout plans, HIIT, etc.)
  if (isBot && message.type === 'weekly_plan' && message.data) {
    return (
      <div className="flex items-start gap-3 px-4 py-2 animate-slide-left">
        <div className="bot-avatar w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 text-sm font-bold text-dark-950">
          F
        </div>
        <div className="max-w-[85%] md:max-w-[70%]">
          <WeeklyPlanCard plan={message.data} />
        </div>
      </div>
    );
  }

  if (isBot && message.type === 'muscle_workout' && message.data) {
    return (
      <div className="flex items-start gap-3 px-4 py-2 animate-slide-left">
        <div className="bot-avatar w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 text-sm font-bold text-dark-950">
          F
        </div>
        <div className="max-w-[85%] md:max-w-[70%]">
          <MuscleWorkoutCard workout={message.data} />
        </div>
      </div>
    );
  }

  if (isBot && message.type === 'hiit' && message.data) {
    return (
      <div className="flex items-start gap-3 px-4 py-2 animate-slide-left">
        <div className="bot-avatar w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 text-sm font-bold text-dark-950">
          F
        </div>
        <div className="max-w-[85%] md:max-w-[70%]">
          <HIITCard hiit={message.data} />
        </div>
      </div>
    );
  }

  // User message
  if (isUser) {
    return (
      <div className="flex items-start justify-end gap-3 px-4 py-2 animate-slide-right">
        <div className="max-w-[85%] md:max-w-[70%] bg-neon-green/15 border border-neon-green/20 rounded-2xl rounded-tr-sm px-4 py-3">
          <p className="text-sm text-white leading-relaxed">{message.content}</p>
          <span className="text-[10px] text-dark-300 mt-1 block text-right">
            {new Date(message.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
          </span>
        </div>
      </div>
    );
  }

  // Bot text message
  if (isBot) {
    const html = parseMarkdown(message.content);
    return (
      <div className="flex items-start gap-3 px-4 py-2 animate-slide-left">
        <div className="bot-avatar w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 text-sm font-bold text-dark-950">
          F
        </div>
        <div className="max-w-[85%] md:max-w-[70%] glass-light rounded-2xl rounded-tl-sm px-4 py-3">
          <div
            className="bot-content text-sm text-dark-100 leading-relaxed"
            dangerouslySetInnerHTML={{ __html: html }}
          />
          <span className="text-[10px] text-dark-300 mt-1 block">
            {new Date(message.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
          </span>
        </div>
      </div>
    );
  }

  return null;
}

// ===== Structured Data Cards =====
function WeeklyPlanCard({ plan }) {
  return (
    <div className="glass-light rounded-2xl rounded-tl-sm p-4 space-y-3">
      <div className="flex items-center justify-between">
        <h3 className="text-neon-green font-bold text-base">📋 {plan.name}</h3>
        <span className="badge badge-intermediate">{plan.daysPerWeek} days/week</span>
      </div>
      <p className="text-xs text-dark-200">
        Goal: <strong className="text-white">{plan.goal}</strong> | Level: <strong className="text-white">{plan.difficulty}</strong>
      </p>

      {plan.days.map((day, di) => (
        <div key={di} className="border-t border-dark-500/20 pt-3">
          <div className="flex items-center gap-2 mb-2">
            <span className="text-xs font-bold text-electric-blue">{day.day}</span>
            <span className="text-xs text-dark-200">— {day.label}</span>
          </div>
          {day.exercises.map((ex, ei) => (
            <WorkoutCard key={ei} exercise={ex} index={ei} />
          ))}
        </div>
      ))}

      <div className="border-t border-dark-500/20 pt-3">
        <p className="text-xs text-dark-200">
          😴 <strong className="text-white">Rest Days:</strong> {plan.restDays.join(', ')}
        </p>
      </div>
    </div>
  );
}

function MuscleWorkoutCard({ workout }) {
  return (
    <div className="glass-light rounded-2xl rounded-tl-sm p-4 space-y-3">
      <div className="flex items-center justify-between">
        <h3 className="text-neon-green font-bold text-base">
          💪 {workout.muscleGroup.charAt(0).toUpperCase() + workout.muscleGroup.slice(1)} Workout
        </h3>
        <span className="badge badge-intermediate">{workout.difficulty}</span>
      </div>

      {workout.exercises.map((ex, i) => (
        <WorkoutCard key={i} exercise={ex} index={i} />
      ))}

      {workout.tips && workout.tips.length > 0 && (
        <div className="border-t border-dark-500/20 pt-3">
          <p className="text-xs font-semibold text-accent-cyan mb-1">💡 Pro Tips:</p>
          <ul className="text-xs text-dark-200 space-y-1 pl-4 list-disc">
            {workout.tips.map((tip, i) => (
              <li key={i}>{tip}</li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}

function HIITCard({ hiit }) {
  return (
    <div className="glass-light rounded-2xl rounded-tl-sm p-4 space-y-3">
      <div className="flex items-center justify-between">
        <h3 className="text-neon-green font-bold text-base">🔥 {hiit.type}</h3>
        <span className="badge badge-advanced">{hiit.difficulty}</span>
      </div>
      <div className="flex gap-3 text-xs text-dark-200">
        <span>⏱️ {hiit.format}</span>
        <span>⌛ {hiit.totalTime}</span>
      </div>

      {hiit.exercises.map((ex, i) => (
        <WorkoutCard key={i} exercise={ex} index={i} />
      ))}

      {hiit.tips && (
        <div className="border-t border-dark-500/20 pt-3">
          <p className="text-xs font-semibold text-accent-orange mb-1">⚠️ Important:</p>
          <ul className="text-xs text-dark-200 space-y-1 pl-4 list-disc">
            {hiit.tips.map((tip, i) => (
              <li key={i}>{tip}</li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}
