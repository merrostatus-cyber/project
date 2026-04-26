import React, { useState } from 'react';

export default function Sidebar({
  chats,
  activeChatId,
  onSelectChat,
  onNewChat,
  onDeleteChat,
  onRenameChat,
  onExportChat,
  isOpen,
  onClose,
  searchQuery,
  onSearchChange,
}) {
  const [editingId, setEditingId] = useState(null);
  const [editTitle, setEditTitle] = useState('');
  const [menuOpenId, setMenuOpenId] = useState(null);

  const handleStartRename = (chat) => {
    setEditingId(chat.id);
    setEditTitle(chat.title);
    setMenuOpenId(null);
  };

  const handleSaveRename = (chatId) => {
    if (editTitle.trim()) {
      onRenameChat(chatId, editTitle.trim());
    }
    setEditingId(null);
  };

  const handleKeyDown = (e, chatId) => {
    if (e.key === 'Enter') handleSaveRename(chatId);
    if (e.key === 'Escape') setEditingId(null);
  };

  const formatDate = (timestamp) => {
    const date = new Date(timestamp);
    const now = new Date();
    const diff = now - date;
    const days = Math.floor(diff / (1000 * 60 * 60 * 24));

    if (days === 0) return 'Today';
    if (days === 1) return 'Yesterday';
    if (days < 7) return `${days} days ago`;
    return date.toLocaleDateString();
  };

  return (
    <>
      {/* Mobile overlay */}
      {isOpen && (
        <div
          className="sidebar-overlay fixed inset-0 bg-black/50 z-40 md:hidden"
          onClick={onClose}
        />
      )}

      {/* Sidebar */}
      <aside
        className={`
          fixed md:relative top-0 left-0 h-full z-50 md:z-0
          w-72 md:w-72 flex-shrink-0
          bg-dark-900 border-r border-dark-600/40
          flex flex-col
          transform transition-transform duration-300 ease-out
          ${isOpen ? 'translate-x-0' : '-translate-x-full md:translate-x-0'}
        `}
      >
        {/* Header */}
        <div className="p-4 border-b border-dark-600/40">
          <div className="flex items-center justify-between mb-3">
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 rounded-lg bg-neon-green/15 flex items-center justify-center">
                <span className="text-neon-green font-bold text-sm">F</span>
              </div>
              <div>
                <h2 className="font-bold text-white text-sm">Fitify Chat</h2>
                <p className="text-[10px] text-dark-300">AI Fitness Coach</p>
              </div>
            </div>
            <button
              onClick={onClose}
              className="md:hidden w-8 h-8 rounded-lg flex items-center justify-center text-dark-300 hover:text-white hover:bg-dark-700 transition-colors"
            >
              ✕
            </button>
          </div>

          {/* New Chat button */}
          <button
            id="new-chat-btn"
            onClick={() => { onNewChat(); onClose(); }}
            className="w-full py-2.5 rounded-xl bg-neon-green/10 border border-neon-green/20
                       text-neon-green text-sm font-medium
                       hover:bg-neon-green/20 hover:border-neon-green/30
                       transition-all duration-200 flex items-center justify-center gap-2 cursor-pointer"
          >
            <span>+</span> New Chat
          </button>
        </div>

        {/* Search */}
        <div className="px-4 py-3">
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => onSearchChange(e.target.value)}
            placeholder="Search chats..."
            className="w-full px-3 py-2 rounded-lg bg-dark-800 border border-dark-600/40
                       text-sm text-white placeholder-dark-400
                       focus:outline-none focus:border-neon-green/30 transition-colors"
          />
        </div>

        {/* Chat list */}
        <div className="flex-1 overflow-y-auto px-2 pb-4">
          {chats.length === 0 ? (
            <div className="text-center py-8">
              <p className="text-dark-400 text-sm">No chats yet</p>
              <p className="text-dark-500 text-xs mt-1">Start a new conversation!</p>
            </div>
          ) : (
            chats.map((chat) => (
              <div
                key={chat.id}
                className={`sidebar-item group relative rounded-lg px-3 py-2.5 mb-1 cursor-pointer ${
                  chat.id === activeChatId ? 'active' : ''
                }`}
                onClick={() => { onSelectChat(chat.id); onClose(); }}
              >
                {editingId === chat.id ? (
                  <input
                    type="text"
                    value={editTitle}
                    onChange={(e) => setEditTitle(e.target.value)}
                    onBlur={() => handleSaveRename(chat.id)}
                    onKeyDown={(e) => handleKeyDown(e, chat.id)}
                    autoFocus
                    className="w-full bg-dark-700 border border-neon-green/30 rounded px-2 py-1 text-sm text-white focus:outline-none"
                    onClick={(e) => e.stopPropagation()}
                  />
                ) : (
                  <>
                    <div className="flex items-center justify-between">
                      <p className="text-sm text-dark-100 truncate pr-6 font-medium">{chat.title}</p>

                      {/* Action menu toggle */}
                      <button
                        className="absolute right-2 top-2.5 opacity-0 group-hover:opacity-100 transition-opacity
                                   w-6 h-6 rounded flex items-center justify-center text-dark-300 hover:text-white hover:bg-dark-600"
                        onClick={(e) => {
                          e.stopPropagation();
                          setMenuOpenId(menuOpenId === chat.id ? null : chat.id);
                        }}
                      >
                        ⋯
                      </button>
                    </div>
                    <p className="text-[10px] text-dark-400 mt-0.5">
                      {formatDate(chat.updatedAt)} • {chat.messages.length} messages
                    </p>

                    {/* Dropdown menu */}
                    {menuOpenId === chat.id && (
                      <div
                        className="absolute right-0 top-10 z-50 w-36 bg-dark-700 border border-dark-500/50 rounded-lg shadow-xl py-1 animate-slide-down"
                        onClick={(e) => e.stopPropagation()}
                      >
                        <button
                          className="w-full text-left px-3 py-1.5 text-xs text-dark-100 hover:bg-dark-600 transition-colors"
                          onClick={() => handleStartRename(chat)}
                        >
                          ✏️ Rename
                        </button>
                        <button
                          className="w-full text-left px-3 py-1.5 text-xs text-dark-100 hover:bg-dark-600 transition-colors"
                          onClick={() => {
                            onExportChat(chat.id);
                            setMenuOpenId(null);
                          }}
                        >
                          📥 Export
                        </button>
                        <button
                          className="w-full text-left px-3 py-1.5 text-xs text-error-red hover:bg-dark-600 transition-colors"
                          onClick={() => {
                            onDeleteChat(chat.id);
                            setMenuOpenId(null);
                          }}
                        >
                          🗑️ Delete
                        </button>
                      </div>
                    )}
                  </>
                )}
              </div>
            ))
          )}
        </div>

        {/* Footer */}
        <div className="p-3 border-t border-dark-600/40">
          <a
            href="index.html"
            className="flex items-center gap-2 px-3 py-2 rounded-lg text-xs text-dark-300 hover:text-white hover:bg-dark-700/50 transition-colors"
          >
            ← Back to Home
          </a>
        </div>
      </aside>
    </>
  );
}
