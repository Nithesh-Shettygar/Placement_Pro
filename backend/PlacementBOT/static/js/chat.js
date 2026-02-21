const chatBox = document.getElementById('chat-box');
const userInput = document.getElementById('user-input');
const sendBtn = document.getElementById('send-btn');
const currentModeLabel = document.getElementById('current-mode');

let currentMode = 'general';
const sessionId = Math.random().toString(36).substring(7);

function setMode(mode) {
    currentMode = mode;
    currentModeLabel.innerText = mode === 'mock' ? 'Mock Prep' : 'Quick Queries';

    // Update UI active state
    document.querySelectorAll('.nav-item').forEach(btn => {
        btn.classList.remove('active');
        if (mode === 'mock' && btn.innerText.includes('Mock')) btn.classList.add('active');
        if (mode === 'general' && btn.innerText.includes('Queries')) btn.classList.add('active');
    });

    addMessage(`Switched to ${currentModeLabel.innerText} mode. How can I help?`, 'bot');
}

async function sendMessage() {
    const text = userInput.value.trim();
    if (!text) return;

    // Add user message to UI
    addMessage(text, 'user');
    userInput.value = '';

    // Show typing indicator
    const typingId = addTypingIndicator();

    try {
        const response = await fetch('/chat', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                message: text,
                session_id: sessionId,
                mode: currentMode
            })
        });

        const data = await response.json();
        removeTypingIndicator(typingId);

        if (data.response) {
            typeMessage(data.response, 'bot');
        } else {
            addMessage("Sorry, I encountered an error. Please try again.", 'bot');
        }
    } catch (error) {
        removeTypingIndicator(typingId);
        addMessage("Connection error. Is the server running?", 'bot');
    }
}

function addMessage(text, sender) {
    const msgDiv = document.createElement('div');
    msgDiv.className = `message ${sender}-message`;
    msgDiv.innerHTML = `<div class="message-content">${text}</div>`;
    chatBox.appendChild(msgDiv);
    chatBox.scrollTop = chatBox.scrollHeight;
    return msgDiv;
}

function typeMessage(text, sender) {
    const msgDiv = addMessage('', sender);
    const contentDiv = msgDiv.querySelector('.message-content');
    let i = 0;

    // For bot messages, we'll render once as Markdown then "type" the rendered HTML
    // However, typing raw HTML char-by-char is unstable. 
    // Better approach: Show typing indicator then reveal full formatted message.

    if (sender === 'bot') {
        contentDiv.innerHTML = marked.parse(text);
        chatBox.scrollTop = chatBox.scrollHeight;
    } else {
        contentDiv.innerText = text;
    }
}

function addTypingIndicator() {
    const id = 'typing-' + Date.now();
    const typingDiv = document.createElement('div');
    typingDiv.id = id;
    typingDiv.className = 'message bot-message typing';
    typingDiv.innerHTML = '<div class="message-content">Bot is thinking...</div>';
    chatBox.appendChild(typingDiv);
    chatBox.scrollTop = chatBox.scrollHeight;
    return id;
}

function removeTypingIndicator(id) {
    const el = document.getElementById(id);
    if (el) el.remove();
}

sendBtn.addEventListener('click', sendMessage);
userInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') sendMessage();
});
