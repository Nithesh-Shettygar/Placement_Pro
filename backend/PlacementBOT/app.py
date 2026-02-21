import os
import socket
from flask import Flask, render_template, request, jsonify
from flask_cors import CORS
from google.generativeai import configure, GenerativeModel
from dotenv import load_dotenv

# Load .env file
load_dotenv()

app = Flask(__name__)
CORS(app)

import json

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
CONFIG_PATH = os.path.join(BASE_DIR, "institution_config.json")

# Setup default config if file doesn't exist
DEFAULT_CONFIG = {
    "institution_name": "Our Institution",
    "general_cutoff": "60% across all boards",
    "mandatory_documents": ["Resume", "ID Card"],
    "upcoming_visits": [],
    "dress_code": "Formal",
    "placement_officer": "TPO Head",
    "venue": "TPO Office"
}

def load_config():
    try:
        with open(CONFIG_PATH, "r", encoding="utf-8") as f:
            loaded_config = json.load(f)
            merged_config = DEFAULT_CONFIG.copy()
            merged_config.update(loaded_config)
            return merged_config
    except (FileNotFoundError, json.JSONDecodeError):
        return DEFAULT_CONFIG.copy()

config = load_config()

# Define refined system prompt with dynamic configuration
SYSTEM_PROMPT = f"""
You are "PlacementBot", the 24/7 Virtual Career Assistant for the Training and Placement Office (TPO) at {config['institution_name']}.

Your primary goals are:
1. Instant Query Resolution: Answer questions about cutoffs, schedules, and eligibility based on the institution's specific data.
2. Mock Prep: Help students prepare for interviews with practice sessions and feedback.

Institution Specific Data:
- General Cutoff: {config['general_cutoff']}
- Mandatory Documents: {', '.join(config['mandatory_documents'])}
- Upcoming Visits: {json.dumps(config['upcoming_visits'])}
- Dress Code: {config['dress_code']}
- Placement Officer: {config['placement_officer']}
- Venue: {config['venue']}

Instructions:
- Use Markdown to structure your answers (use bolding, lists, and tables for clarity).
- If a student asks about a specific company not in the upcoming visits, tell them to check the official notice board for the latest updates.
- Stay professional, helpful, and institutional in your tone.
"""

generation_config = {
    "temperature": 0.5, # Slightly lower for more factual consistency
    "top_p": 0.95,
    "top_k": 40,
    "max_output_tokens": 2048,
}

model = GenerativeModel(
    model_name="gemini-2.5-flash",
    generation_config=generation_config,
    system_instruction=SYSTEM_PROMPT
)

# In-memory chat history (for demonstration purposes, could be session-based)
chat_sessions = {}

def get_lan_ip():
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
            sock.connect(("8.8.8.8", 80))
            return sock.getsockname()[0]
    except Exception:
        try:
            return socket.gethostbyname(socket.gethostname())
        except Exception:
            return "127.0.0.1"

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/chat", methods=["POST"])
def chat():
    data = request.json
    user_message = data.get("message")
    session_id = data.get("session_id", "default")

    if session_id not in chat_sessions:
        chat_sessions[session_id] = model.start_chat(history=[])
    
    chat_session = chat_sessions[session_id]
    
    try:
        response = chat_session.send_message(user_message)
        return jsonify({"response": response.text})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/chatbot/message", methods=["POST"])
def chatbot_message():
    data = request.json or {}
    user_message = data.get("message", "")
    session_id = data.get("session_id", "default")

    if not user_message.strip():
        return jsonify({"error": "Message is required"}), 400

    if session_id not in chat_sessions:
        chat_sessions[session_id] = model.start_chat(history=[])

    chat_session = chat_sessions[session_id]

    try:
        response = chat_session.send_message(user_message)
        return jsonify({"response": response.text})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/chatbot/clear", methods=["POST"])
def chatbot_clear():
    data = request.json or {}
    session_id = data.get("session_id", "default")
    chat_sessions.pop(session_id, None)
    return jsonify({"message": "Session cleared", "session_id": session_id})

if __name__ == "__main__":
    port = int(os.getenv("PORT", "5000"))
    host = os.getenv("HOST", "0.0.0.0")
    lan_ip = get_lan_ip()
    network_ip = os.getenv("NETWORK_IP", "192.168.56.1")

    print(f"Local endpoint:   http://127.0.0.1:{port}")
    print(f"Detected LAN IP:  http://{lan_ip}:{port}")
    print(f"Network endpoint: http://{network_ip}:{port}")
    print(f"Loaded config from: {CONFIG_PATH}")
    print(f"Institution: {config['institution_name']}")

    app.run(debug=True, host=host, port=port)
