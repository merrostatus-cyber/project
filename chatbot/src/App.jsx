import React, { useState, useEffect, useCallback } from 'react';
import Sidebar from './components/Sidebar';
import ChatWindow from './components/ChatWindow';
import ChatInput from './components/ChatInput';
import QuickActions from './components/QuickActions';
import { generateResponse } from './engine/fitnessAI';
import {
  getAllChats,
  createChat,
  getChat,
  addMessage,
  deleteChat,
  renameChat,
  searchChats,
  exportChat,
} from './storage/chatStorage';

export default function App() {
  const [chats, setChats] = useState([]);
  const [activeChatId, setActiveChatId] = useState(null);
  const [messages, setMessages] = useState([]);
  const [isTyping, setIsTyping] = useState(false);
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');

  // Load chats on mount
  useEffect(() => {
    const saved = getAllChats();
    setChats(saved);
    if (saved.length > 0) {
      setActiveChatId(saved[0].id);
      setMessages(saved[0].messages);
    }
  }, []);

  // Refresh chat list
  const refreshChats = useCallback(() => {
    const updated = searchQuery ? searchChats(searchQuery) : getAllChats();
    setChats(updated);
  }, [searchQuery]);

  // Select a chat
  const handleSelectChat = useCallback((chatId) => {
    const chat = getChat(chatId);
    if (chat) {
      setActiveChatId(chatId);
      setMessages(chat.messages);
    }
  }, []);

  // Create new chat
  const handleNewChat = useCallback(() => {
    const chat = createChat();
    setActiveChatId(chat.id);
    setMessages([]);
    refreshChats();
  }, [refreshChats]);

  // Delete chat
  const handleDeleteChat = useCallback((chatId) => {
    deleteChat(chatId);
    const remaining = getAllChats();
    setChats(remaining);

    if (chatId === activeChatId) {
      if (remaining.length > 0) {
        setActiveChatId(remaining[0].id);
        setMessages(remaining[0].messages);
      } else {
        setActiveChatId(null);
        setMessages([]);
      }
    }
  }, [activeChatId]);

  // Rename chat
  const handleRenameChat = useCallback((chatId, newTitle) => {
    renameChat(chatId, newTitle);
    refreshChats();
  }, [refreshChats]);

  // Export chat
  const handleExportChat = useCallback((chatId) => {
    const text = exportChat(chatId);
    if (text) {
      const blob = new Blob([text], { type: 'text/plain' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `fitify-chat-${chatId}.txt`;
      a.click();
      URL.revokeObjectURL(url);
    }
  }, []);

  // Send message
  const handleSendMessage = useCallback(async (content) => {
    let chatId = activeChatId;

    // Create new chat if none active
    if (!chatId) {
      const chat = createChat();
      chatId = chat.id;
      setActiveChatId(chatId);
    }

    // Add user message
    const userMsg = addMessage(chatId, 'user', content);
    setMessages(prev => [...prev, userMsg]);
    refreshChats();

    // Show typing indicator
    setIsTyping(true);

    // Simulate AI thinking delay
    const delay = 400 + Math.random() * 800;
    await new Promise(resolve => setTimeout(resolve, delay));

    // Generate AI response
    const chat = getChat(chatId);
    const response = generateResponse(content, chat?.messages || []);

    // Add bot message
    const botMsg = addMessage(chatId, 'bot', response.text, response.type, response.data);
    setMessages(prev => [...prev, botMsg]);
    setIsTyping(false);
    refreshChats();
  }, [activeChatId, refreshChats]);

  // Handle quick action
  const handleQuickAction = useCallback((message) => {
    handleSendMessage(message);
  }, [handleSendMessage]);

  // Handle search
  const handleSearchChange = useCallback((query) => {
    setSearchQuery(query);
    if (query) {
      setChats(searchChats(query));
    } else {
      setChats(getAllChats());
    }
  }, []);

  const showWelcome = !activeChatId || messages.length === 0;

  return (
    <div className="h-screen flex overflow-hidden bg-dark-950">
      {/* Sidebar */}
      <Sidebar
        chats={chats}
        activeChatId={activeChatId}
        onSelectChat={handleSelectChat}
        onNewChat={handleNewChat}
        onDeleteChat={handleDeleteChat}
        onRenameChat={handleRenameChat}
        onExportChat={handleExportChat}
        isOpen={sidebarOpen}
        onClose={() => setSidebarOpen(false)}
        searchQuery={searchQuery}
        onSearchChange={handleSearchChange}
      />

      {/* Main Chat Area */}
      <div className="flex-1 flex flex-col min-w-0">
        {/* Top Bar */}
        <header className="glass border-b border-dark-600/40 px-4 py-3 flex items-center justify-between flex-shrink-0">
          <div className="flex items-center gap-3">
            {/* Mobile menu button */}
            <button
              id="menu-toggle"
              onClick={() => setSidebarOpen(true)}
              className="md:hidden w-9 h-9 rounded-lg flex items-center justify-center text-dark-200 hover:text-white hover:bg-dark-700 transition-colors"
            >
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <line x1="3" y1="6" x2="21" y2="6"/>
                <line x1="3" y1="12" x2="21" y2="12"/>
                <line x1="3" y1="18" x2="21" y2="18"/>
              </svg>
            </button>

            <div className="flex items-center gap-2">
              <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-neon-green to-electric-blue flex items-center justify-center">
                <span className="text-dark-950 font-bold text-sm">F</span>
              </div>
              <div>
                <h1 className="font-bold text-white text-sm">Fitify</h1>
                <div className="flex items-center gap-1">
                  <span className="w-1.5 h-1.5 rounded-full bg-neon-green animate-pulse"></span>
                  <span className="text-[10px] text-neon-green">Online • Fitness AI</span>
                </div>
              </div>
            </div>
          </div>

          <div className="flex items-center gap-2">
            {activeChatId && messages.length > 0 && (
              <QuickActions onAction={handleQuickAction} />
            )}
          </div>
        </header>

        {/* Chat Window */}
        <ChatWindow
          messages={messages}
          isTyping={isTyping}
          onQuickAction={handleQuickAction}
          showWelcome={showWelcome}
        />

        {/* Input */}
        <ChatInput onSend={handleSendMessage} disabled={isTyping} />
      </div>
    </div>
  );
}
