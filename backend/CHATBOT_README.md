# Chatbot Backend Setup

## Installation

1. Install required Python packages:
```bash
cd backend
pip install -r requirements.txt
```

2. The backend already has the Gemini API key configured in app.py

3. Restart your Flask backend:
```bash
python app.py
```

## Features

- **AI-Powered Career Assistant**: Powered by Google Gemini 1.5 Flash
- **Institution-Specific Data**: Responds with cutoffs, upcoming visits, dress code, etc.
- **Session Management**: Maintains chat history per session
- **RESTful API**: Easy integration with Flutter frontend

## Endpoints

### POST /chatbot/message
Send a message to the chatbot
```json
{
  "message": "What are the upcoming company visits?",
  "session_id": "unique_session_id"
}
```

Response:
```json
{
  "response": "Here are the upcoming company visits...",
  "session_id": "unique_session_id"
}
```

### POST /chatbot/clear
Clear a chat session
```json
{
  "session_id": "unique_session_id"
}
```

## Configuration

Edit `institution_config.json` to customize:
- Institution name
- Cutoff criteria
- Mandatory documents
- Upcoming company visits
- Dress code
- Placement officer details
- Venue information
