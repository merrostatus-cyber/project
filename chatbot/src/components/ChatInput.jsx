import React, { useState, useRef } from 'react';

export default function ChatInput({ onSend, disabled }) {
  const [message, setMessage] = useState('');
  const textareaRef = useRef(null);

  const handleSend = () => {
    const trimmed = message.trim();
    if (!trimmed || disabled) return;
    onSend(trimmed);
    setMessage('');
    // Reset textarea height
    if (textareaRef.current) {
      textareaRef.current.style.height = 'auto';
    }
  };

  const handleKeyDown = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  const handleInput = (e) => {
    setMessage(e.target.value);
    // Auto-resize textarea
    const textarea = textareaRef.current;
    if (textarea) {
      textarea.style.height = 'auto';
      textarea.style.height = Math.min(textarea.scrollHeight, 120) + 'px';
    }
  };

  return (
    <div className="glass border-t border-dark-600/50 p-3 md:p-4">
      <div className="flex items-end gap-3 max-w-4xl mx-auto">
        <textarea
          ref={textareaRef}
          id="chat-input"
          value={message}
          onChange={handleInput}
          onKeyDown={handleKeyDown}
          disabled={disabled}
          placeholder="Ask about workouts, exercises, or fitness..."
          rows={1}
          className="flex-1 resize-none bg-dark-800/80 border border-dark-500/40 rounded-xl px-4 py-3
                     text-sm text-white placeholder-dark-300
                     focus:outline-none focus:border-neon-green/40 focus:ring-1 focus:ring-neon-green/20
                     transition-all duration-200 disabled:opacity-40"
          style={{ maxHeight: '120px' }}
        />
        <button
          id="send-button"
          onClick={handleSend}
          disabled={disabled || !message.trim()}
          className="send-btn w-11 h-11 rounded-xl bg-neon-green/90 hover:bg-neon-green
                     flex items-center justify-center flex-shrink-0
                     transition-all duration-200 disabled:bg-dark-600 disabled:cursor-not-allowed"
        >
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" className="text-dark-950">
            <path d="M22 2L11 13" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
            <path d="M22 2L15 22L11 13L2 9L22 2Z" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        </button>
      </div>
      <p className="text-[10px] text-dark-400 text-center mt-2">
        Fitify answers fitness questions only • Press Enter to send
      </p>
    </div>
  );
}
