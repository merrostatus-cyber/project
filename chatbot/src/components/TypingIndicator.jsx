import React from 'react';

export default function TypingIndicator() {
  return (
    <div className="flex items-start gap-3 px-4 py-2 animate-fade-up">
      {/* Bot avatar */}
      <div className="bot-avatar w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 text-sm font-bold text-dark-950">
        F
      </div>
      {/* Typing bubble */}
      <div className="glass-light rounded-2xl rounded-tl-sm px-5 py-3.5">
        <div className="flex items-center gap-1.5">
          <div className="typing-dot"></div>
          <div className="typing-dot"></div>
          <div className="typing-dot"></div>
        </div>
      </div>
    </div>
  );
}
