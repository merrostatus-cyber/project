// ===== Chat Storage (LocalStorage) =====

const STORAGE_KEY = 'fitify_chats';
const FAVORITES_KEY = 'fitify_favorites';

// Generate unique ID
function generateId() {
  return `chat_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`;
}

// Get all chats
export function getAllChats() {
  try {
    const data = localStorage.getItem(STORAGE_KEY);
    return data ? JSON.parse(data) : [];
  } catch {
    return [];
  }
}

// Save all chats
function saveAllChats(chats) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(chats));
}

// Create a new chat
export function createChat(firstMessage = null) {
  const chat = {
    id: generateId(),
    title: 'New Chat',
    createdAt: Date.now(),
    updatedAt: Date.now(),
    messages: [],
    favorite: false,
  };

  if (firstMessage) {
    chat.messages.push({
      role: 'user',
      content: firstMessage,
      timestamp: Date.now(),
    });
    // Auto-title from first message
    chat.title = firstMessage.length > 40
      ? firstMessage.substring(0, 40) + '...'
      : firstMessage;
  }

  const chats = getAllChats();
  chats.unshift(chat); // Add to top
  saveAllChats(chats);
  return chat;
}

// Get a specific chat by ID
export function getChat(chatId) {
  const chats = getAllChats();
  return chats.find(c => c.id === chatId) || null;
}

// Add a message to a chat
export function addMessage(chatId, role, content, type = 'text', data = null) {
  const chats = getAllChats();
  const chatIndex = chats.findIndex(c => c.id === chatId);

  if (chatIndex === -1) return null;

  const message = {
    id: `msg_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`,
    role,
    content,
    type,
    data,
    timestamp: Date.now(),
  };

  chats[chatIndex].messages.push(message);
  chats[chatIndex].updatedAt = Date.now();

  // Auto-title from first user message if still "New Chat"
  if (chats[chatIndex].title === 'New Chat' && role === 'user') {
    chats[chatIndex].title = content.length > 40
      ? content.substring(0, 40) + '...'
      : content;
  }

  saveAllChats(chats);
  return message;
}

// Delete a chat
export function deleteChat(chatId) {
  const chats = getAllChats();
  const filtered = chats.filter(c => c.id !== chatId);
  saveAllChats(filtered);
  return filtered;
}

// Rename a chat
export function renameChat(chatId, newTitle) {
  const chats = getAllChats();
  const chat = chats.find(c => c.id === chatId);
  if (chat) {
    chat.title = newTitle;
    chat.updatedAt = Date.now();
    saveAllChats(chats);
  }
  return chat;
}

// Toggle favorite
export function toggleFavorite(chatId) {
  const chats = getAllChats();
  const chat = chats.find(c => c.id === chatId);
  if (chat) {
    chat.favorite = !chat.favorite;
    chat.updatedAt = Date.now();
    saveAllChats(chats);
  }
  return chat;
}

// Search chats
export function searchChats(query) {
  const chats = getAllChats();
  const q = query.toLowerCase();
  return chats.filter(chat =>
    chat.title.toLowerCase().includes(q) ||
    chat.messages.some(msg => msg.content.toLowerCase().includes(q))
  );
}

// Export a chat as text
export function exportChat(chatId) {
  const chat = getChat(chatId);
  if (!chat) return null;

  let text = `=== Fitify Chat Export ===\n`;
  text += `Title: ${chat.title}\n`;
  text += `Date: ${new Date(chat.createdAt).toLocaleDateString()}\n`;
  text += `${'='.repeat(40)}\n\n`;

  chat.messages.forEach(msg => {
    const time = new Date(msg.timestamp).toLocaleTimeString();
    const sender = msg.role === 'user' ? 'You' : 'Fitify';
    text += `[${time}] ${sender}:\n${msg.content}\n\n`;
  });

  return text;
}

// Clear all chats
export function clearAllChats() {
  localStorage.removeItem(STORAGE_KEY);
}

export default {
  getAllChats,
  createChat,
  getChat,
  addMessage,
  deleteChat,
  renameChat,
  toggleFavorite,
  searchChats,
  exportChat,
  clearAllChats,
};
