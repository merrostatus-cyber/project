import React, { useRef, useEffect } from 'react';
import ChatBubble from './ChatBubble';
import TypingIndicator from './TypingIndicator';
import QuickActions from './QuickActions';

export default function ChatWindow({ messages, isTyping, onQuickAction, showWelcome }) {
  const bottomRef = useRef(null);
  const containerRef = useRef(null);

  // Auto-scroll to bottom
  useEffect(() => {
    if (bottomRef.current) {
      bottomRef.current.scrollIntoView({ behavior: 'smooth' });
    }
  }, [messages, isTyping]);

  return (
    <div ref={containerRef} className="flex-1 overflow-y-auto" id="chat-window">
      {/* Welcome screen */}
      {showWelcome && messages.length === 0 && (
        <div className="flex flex-col items-center justify-center min-h-full px-4 py-12">
          {/* Logo */}
          <div className="w-20 h-20 rounded-2xl bg-gradient-to-br from-neon-green/20 to-electric-blue/20 border border-neon-green/20 flex items-center justify-center mb-6 glow-green">
            <span className="text-4xl font-black bg-gradient-to-r from-neon-green to-electric-blue bg-clip-text text-transparent">F</span>
          </div>

          <h1 className="text-2xl md:text-3xl font-bold text-white mb-2 text-center">
            Welcome to <span className="bg-gradient-to-r from-neon-green to-electric-blue bg-clip-text text-transparent">Fitify</span>
          </h1>
          <p className="text-dark-200 text-sm md:text-base text-center max-w-md mb-8">
            Your personal AI fitness coach. Ask me about workouts, exercises, training plans, and everything fitness!
          </p>

          {/* Feature cards */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-3 max-w-2xl w-full mb-8">
            {[
              { icon: '🏋️', title: 'Workout Plans', desc: 'Custom weekly programs' },
              { icon: '💪', title: 'Exercise Guide', desc: 'Step-by-step form' },
              { icon: '🎯', title: 'Goal Based', desc: 'Lose fat or build muscle' },
              { icon: '⏱️', title: 'Quick Sessions', desc: '15-60 min workouts' },
            ].map((feature, i) => (
              <div key={i} className="glass-light rounded-xl p-3 text-center animate-fade-up" style={{ animationDelay: `${i * 0.1}s` }}>
                <span className="text-xl">{feature.icon}</span>
                <p className="text-xs font-semibold text-white mt-1.5">{feature.title}</p>
                <p className="text-[10px] text-dark-300 mt-0.5">{feature.desc}</p>
              </div>
            ))}
          </div>

          {/* Quick actions */}
          <div className="w-full max-w-2xl">
            <p className="text-xs text-dark-300 mb-2 text-center">Quick start — tap any option:</p>
            <QuickActions onAction={onQuickAction} compact />
          </div>
        </div>
      )}

      {/* Messages */}
      {messages.length > 0 && (
        <div className="pt-4 pb-4 max-w-4xl mx-auto">
          {messages.map((msg, i) => (
            <ChatBubble key={msg.id || i} message={msg} />
          ))}

          {/* Typing indicator */}
          {isTyping && <TypingIndicator />}

          <div ref={bottomRef} />
        </div>
      )}

      {/* Typing indicator when no messages yet */}
      {messages.length === 0 && isTyping && (
        <div className="pt-4 pb-4 max-w-4xl mx-auto">
          <TypingIndicator />
          <div ref={bottomRef} />
        </div>
      )}
    </div>
  );
}
