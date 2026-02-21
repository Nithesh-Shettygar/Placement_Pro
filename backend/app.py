import os
from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename
import requests
import json

app = Flask(__name__)
CORS(app)

# --- DATABASE CONFIG ---
DB_USER = 'root'
DB_PASSWORD = '' # Change to your MySQL password
DB_NAME = 'placement_pro_db'
DB_HOST = 'localhost'

app.config['SQLALCHEMY_DATABASE_URI'] = f'mysql+mysqlconnector://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['UPLOAD_FOLDER'] = 'uploads'

db = SQLAlchemy(app)

# --- TABLES ---

class Student(db.Model):
    __tablename__ = 'students'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    phone = db.Column(db.String(20))
    password = db.Column(db.String(255), nullable=False)
    campus_id = db.Column(db.String(50), unique=True)
    specialization = db.Column(db.String(50))
    gender = db.Column(db.String(10))
    current_sem = db.Column(db.String(5))
    dob = db.Column(db.String(20))
    photo_path = db.Column(db.String(255))
    resume_path = db.Column(db.String(255))

class Alumni(db.Model):
    __tablename__ = 'alumni'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    phone = db.Column(db.String(20))
    password = db.Column(db.String(255), nullable=False)
    campus_id = db.Column(db.String(50))
    batch = db.Column(db.String(20))
    employment_status = db.Column(db.String(50))
    organization_name = db.Column(db.String(100))
    designation = db.Column(db.String(100))

class Officer(db.Model):
    __tablename__ = 'officers'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), default="Admin Officer")
    email = db.Column(db.String(120), unique=True, nullable=False)
    password = db.Column(db.String(255), nullable=False)

class Company(db.Model):
    __tablename__ = 'companies'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False, unique=True)
    category = db.Column(db.String(100), nullable=False)
    posted_by_alumni = db.Column(db.Boolean, default=False)
    created_at = db.Column(db.DateTime, default=db.func.now())

class Application(db.Model):
    __tablename__ = 'applications'
    id = db.Column(db.Integer, primary_key=True)
    student_email = db.Column(db.String(120), nullable=False)
    student_name = db.Column(db.String(100), nullable=False)
    company_name = db.Column(db.String(100), nullable=False)
    role = db.Column(db.String(100), nullable=False)
    status = db.Column(db.String(50), default='Applied')  # Applied, Accepted, Rejected
    applied_at = db.Column(db.DateTime, default=db.func.now())

# --- DATABASE INITIALIZATION ---
def init_database():
    """Add missing columns to existing tables"""
    try:
        with db.engine.connect() as conn:
            # Check if posted_by_alumni column exists in companies table
            result = conn.execute(db.text("""
                SELECT COUNT(*) 
                FROM information_schema.COLUMNS 
                WHERE TABLE_SCHEMA = :schema 
                AND TABLE_NAME = 'companies' 
                AND COLUMN_NAME = 'posted_by_alumni'
            """), {"schema": DB_NAME})
            
            if result.scalar() == 0:
                # Add the column if it doesn't exist
                conn.execute(db.text("""
                    ALTER TABLE companies 
                    ADD COLUMN posted_by_alumni BOOLEAN DEFAULT FALSE
                """))
                conn.commit()
                print("✓ Added posted_by_alumni column to companies table")
            else:
                print("✓ Database schema is up to date")
    except Exception as e:
        print(f"Database initialization error: {e}")

# Initialize database on startup
with app.app_context():
    init_database()

# --- ROUTES ---

@app.route('/register', methods=['POST'])
def register():
    # Detect if request is from Student (Multipart) or Alumni (JSON)
    is_multipart = request.content_type and 'multipart/form-data' in request.content_type
    data = request.form if is_multipart else request.get_json()
    role_type = data.get('roleType')

    # Check existence in appropriate table
    if role_type == 'student':
        if Student.query.filter_by(email=data.get('email')).first():
            return jsonify({"error": "Email already registered"}), 400
        
        photo = request.files.get('photo')
        filename = None
        if photo:
            filename = secure_filename(f"std_{data.get('email')}_{photo.filename}")
            photo.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))

        new_user = Student(
            name=data.get('name'), email=data.get('email'), phone=data.get('phone'),
            password=generate_password_hash(data.get('password'), method='pbkdf2:sha256'),
            campus_id=data.get('campusId'), specialization=data.get('specialization'),
            gender=data.get('gender'), current_sem=data.get('currentSem'),
            dob=data.get('dob'), photo_path=filename
        )
    
    elif role_type == 'alumni':
        if Alumni.query.filter_by(email=data.get('email')).first():
            return jsonify({"error": "Email already registered"}), 400
            
        new_user = Alumni(
            name=data.get('name'), email=data.get('email'), phone=data.get('phone'),
            password=generate_password_hash(data.get('password'), method='pbkdf2:sha256'),
            campus_id=data.get('campusId'), batch=data.get('batch'),
            employment_status=data.get('employmentStatus'),
            organization_name=data.get('organizationName'), designation=data.get('designation')
        )
    else:
        return jsonify({"error": "Invalid role"}), 400

    db.session.add(new_user)
    db.session.commit()
    return jsonify({"message": "Registration successful"}), 201

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "ok"}), 200

@app.route('/stats', methods=['GET'])
def stats():
    '''Return dashboard statistics for admin panel'''
    try:
        student_count = Student.query.count()
        alumni_count = Alumni.query.count()
        # These are placeholder counts; add more tables as needed
        companies_count = 156  # Placeholder
        active_drives = 12     # Placeholder
        pending_approvals = 28 # Placeholder
        placed_count = 856     # Placeholder
        return jsonify({
            "students": student_count,
            "alumni": alumni_count,
            "companies": companies_count,
            "drives": active_drives,
            "approvals": pending_approvals,
            "placed": placed_count,
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    # Search across all tables
    user = Student.query.filter_by(email=email).first()
    role = 'student'
    
    if not user:
        user = Alumni.query.filter_by(email=email).first()
        role = 'alumni'
    
    if not user:
        user = Officer.query.filter_by(email=email).first()
        role = 'officer'

    if user and check_password_hash(user.password, password):
        return jsonify({
            "user": {"name": user.name, "email": user.email, "roleType": role}
        }), 200
    
    return jsonify({"error": "Invalid credentials"}), 401

@app.route('/upload-resume', methods=['POST'])
def upload_resume():
    try:
        email = request.form.get('email')
        resume = request.files.get('resume')
        
        if not email or not resume:
            return jsonify({"error": "Email and resume file required"}), 400
        
        # Find student
        student = Student.query.filter_by(email=email).first()
        if not student:
            return jsonify({"error": "Student not found"}), 404
        
        # Save resume file
        filename = secure_filename(f"resume_{email}_{resume.filename}")
        resume_folder = os.path.join(app.config['UPLOAD_FOLDER'], 'resumes')
        if not os.path.exists(resume_folder):
            os.makedirs(resume_folder)
        
        resume_path = os.path.join(resume_folder, filename)
        resume.save(resume_path)
        
        # Update student record
        student.resume_path = filename
        db.session.commit()
        
        # Call resume parser API
        parser_url = 'http://127.0.0.1:5001/api/parse'
        try:
            # Open the saved file and send to parser
            with open(resume_path, 'rb') as f:
                files = {'resume': (resume.filename, f, resume.content_type)}
                parser_response = requests.post(parser_url, files=files, timeout=30)
            
            if parser_response.status_code == 200:
                parsed_data = parser_response.json()
                return jsonify({
                    "message": "Resume uploaded and parsed successfully",
                    "filename": filename,
                    "parsed_data": parsed_data
                }), 200
            else:
                # If parser fails, still return success for upload
                return jsonify({
                    "message": "Resume uploaded successfully (parsing failed)",
                    "filename": filename,
                    "parser_error": parser_response.text
                }), 200
                
        except requests.exceptions.RequestException as e:
            # If parser service is not running, still return success for upload
            return jsonify({
                "message": "Resume uploaded successfully (parser service unavailable)",
                "filename": filename,
                "parser_error": str(e)
            }), 200
            
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/companies', methods=['GET'])
def get_companies():
    '''Fetch companies from database, optionally filter by alumni_only'''
    try:
        alumni_only = request.args.get('alumni_only', '').lower() == 'true'
        
        if alumni_only:
            companies = Company.query.filter_by(posted_by_alumni=True).all()
        else:
            companies = Company.query.all()
            
        return jsonify([{
            "id": c.id,
            "name": c.name,
            "category": c.category,
            "posted_by_alumni": c.posted_by_alumni,
        } for c in companies]), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/companies', methods=['POST'])
def add_company():
    '''Add a new company to database'''
    try:
        data = request.get_json()
        name = data.get('name', '').strip()
        category = data.get('category', '').strip()
        posted_by_alumni = data.get('posted_by_alumni', False)
        
        if not name or not category:
            return jsonify({"error": "Name and category required"}), 400
        
        # Check if already exists
        if Company.query.filter_by(name=name).first():
            return jsonify({"error": "Company already exists"}), 409
        
        new_company = Company(name=name, category=category, posted_by_alumni=posted_by_alumni)
        db.session.add(new_company)
        db.session.commit()
        
        return jsonify({
            "message": "Company added successfully",
            "id": new_company.id,
            "name": new_company.name,
            "category": new_company.category,
            "posted_by_alumni": new_company.posted_by_alumni,
        }), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

@app.route('/companies/<int:company_id>', methods=['DELETE'])
def delete_company(company_id):
    '''Delete a company from database'''
    try:
        company = Company.query.get(company_id)
        if not company:
            return jsonify({"error": "Company not found"}), 404
        
        db.session.delete(company)
        db.session.commit()
        return jsonify({"message": "Company deleted"}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

# --- APPLICATION ENDPOINTS ---

@app.route('/applications', methods=['POST'])
def submit_application():
    '''Student submits a job application'''
    try:
        data = request.get_json()
        application = Application(
            student_email=data.get('student_email'),
            student_name=data.get('student_name'),
            company_name=data.get('company_name'),
            role=data.get('role'),
            status='Applied'
        )
        db.session.add(application)
        db.session.commit()
        return jsonify({"message": "Application submitted", "id": application.id}), 201
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

@app.route('/applications', methods=['GET'])
def get_applications():
    '''Get all applications (optionally filtered by student_email/student_name)'''
    try:
        student_email = (request.args.get('student_email') or '').strip().lower()
        student_name = (request.args.get('student_name') or '').strip().lower()

        applications = Application.query.order_by(Application.applied_at.desc()).all()

        if student_email or student_name:
            filtered = []
            for app in applications:
                app_email = (app.student_email or '').strip().lower()
                app_name = (app.student_name or '').strip().lower()
                email_match = bool(student_email) and app_email == student_email
                name_match = bool(student_name) and app_name == student_name
                if email_match or name_match:
                    filtered.append(app)
            applications = filtered

        return jsonify([{
            'id': app.id,
            'student_email': app.student_email,
            'student_name': app.student_name,
            'company_name': app.company_name,
            'role': app.role,
            'status': app.status,
            'applied_at': app.applied_at.strftime('%Y-%m-%d %H:%M:%S')
        } for app in applications]), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/applications/<int:app_id>', methods=['PATCH'])
def update_application_status(app_id):
    '''Update application status'''
    try:
        data = request.get_json()
        application = Application.query.get(app_id)
        if not application:
            return jsonify({"error": "Application not found"}), 404
        
        application.status = data.get('status', application.status)
        db.session.commit()
        return jsonify({"message": "Application updated"}), 200
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

# --- DB SETUP & DEFAULT OFFICER ---
def setup_database():
    import mysql.connector
    # Create DB
    conn = mysql.connector.connect(host=DB_HOST, user=DB_USER, password=DB_PASSWORD)
    cursor = conn.cursor()
    cursor.execute(f"CREATE DATABASE IF NOT EXISTS {DB_NAME}")
    cursor.close()
    conn.close()
    
    with app.app_context():
        db.create_all()
        # Create Default Officer if not exists
        if not Officer.query.filter_by(email='admin@placement.com').first():
            default_officer = Officer(
                email='admin@placement.com',
                password=generate_password_hash('admin123', method='pbkdf2:sha256')
            )
            db.session.add(default_officer)
            db.session.commit()
            print("Default Officer created: admin@placement.com / admin123")

# --- CHATBOT ENDPOINTS ---

# Chatbot configuration
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "AIzaSyCd8yiB3hwlI4O1QS39qr6dUOwgjQChiSc")
GOOGLE_SEARCH_API_KEY = os.getenv("GOOGLE_SEARCH_API_KEY", GEMINI_API_KEY).strip()
GOOGLE_SEARCH_CX = os.getenv("GOOGLE_SEARCH_CX", "EVofSQZJBKGi52tTarA91chs").strip()

DEFAULT_CONFIG = {
    "institution_name": "Our Institution",
    "general_cutoff": "60% across all boards",
    "mandatory_documents": ["Resume", "ID Card"],
    "upcoming_visits": [],
    "dress_code": "Formal",
    "placement_officer": "TPO Head",
    "venue": "TPO Office"
}

def load_chatbot_config():
    try:
        config_path = os.path.join(os.path.dirname(__file__), "institution_config.json")
        with open(config_path, "r") as f:
            return json.load(f)
    except FileNotFoundError:
        return DEFAULT_CONFIG

def _google_search_context(query: str, max_results: int = 3):
    """Fetch live search snippets from Google Custom Search API.
    Returns: (context_text_or_none, status_message)
    """
    if not query:
        return None, "empty_query"

    if not GOOGLE_SEARCH_API_KEY:
        return None, "missing_google_search_api_key"

    if not GOOGLE_SEARCH_CX:
        return None, "missing_google_search_cx"

    try:
        response = requests.get(
            "https://www.googleapis.com/customsearch/v1",
            params={
                "key": GOOGLE_SEARCH_API_KEY,
                "cx": GOOGLE_SEARCH_CX,
                "q": query,
                "num": max_results,
            },
            timeout=8,
        )

        if response.status_code != 200:
            try:
                error_payload = response.json()
                error_message = error_payload.get("error", {}).get("message", "unknown_error")
            except Exception:
                error_message = "unknown_error"
            return None, f"google_http_{response.status_code}: {error_message}"

        payload = response.json()
        items = payload.get("items", [])
        if not items:
            return None, "no_results"

        lines = []
        for item in items[:max_results]:
            title = item.get("title", "Untitled")
            snippet = item.get("snippet", "")
            link = item.get("link", "")
            lines.append(f"- {title}\n  {snippet}\n  Source: {link}")

        return "\n".join(lines), "ok"
    except Exception as error:
        return None, f"exception: {str(error)}"

# In-memory chat sessions
chat_sessions = {}

def _humanize_key(key: str) -> str:
    return (key or '').replace('_', ' ').strip().title()

def _format_config_value(value, indent: int = 0) -> str:
    prefix = '  ' * indent

    if isinstance(value, dict):
        lines = []
        for k, v in value.items():
            if isinstance(v, (dict, list)):
                lines.append(f"{prefix}- {_humanize_key(k)}:")
                lines.append(_format_config_value(v, indent + 1))
            else:
                lines.append(f"{prefix}- {_humanize_key(k)}: {v}")
        return '\n'.join(lines)

    if isinstance(value, list):
        if not value:
            return f"{prefix}- None"

        lines = []
        for item in value:
            if isinstance(item, (dict, list)):
                lines.append(f"{prefix}-")
                lines.append(_format_config_value(item, indent + 1))
            else:
                lines.append(f"{prefix}- {item}")
        return '\n'.join(lines)

    return f"{prefix}- {value}"

def _format_all_college_details(chatbot_config: dict) -> str:
    institution_name = chatbot_config.get('institution_name', 'Institution')
    body = _format_config_value(chatbot_config)
    return f"College details for {institution_name}:\n{body}"

def _build_fallback_reply(user_message: str, chatbot_config: dict, web_context: str = None) -> str:
    message = (user_message or '').lower()

    if web_context:
        return f"Here are live results from Google search:\n{web_context}"

    if any(word in message for word in ['college', 'institute', 'institution', 'about', 'details', 'full details']):
        return _format_all_college_details(chatbot_config)

    for key, value in chatbot_config.items():
        key_text = (key or '').lower().replace('_', ' ')
        if key_text in message or any(token in message for token in key_text.split() if len(token) > 2):
            if isinstance(value, (dict, list)):
                return f"{_humanize_key(key)}:\n{_format_config_value(value)}"
            return f"{_humanize_key(key)}: {value}"

    return (
        f"I can answer from your current institution_config.json for "
        f"{chatbot_config.get('institution_name', 'your institution')}. "
        "Ask about college details, cutoff, documents, visits, officer, venue, or any configured field."
    )

@app.route('/chatbot/message', methods=['POST'])
def chatbot_message():
    """Handle chatbot messages using Google Gemini API"""
    try:
        data = request.get_json()
        user_message = data.get('message', '').strip()
        session_id = data.get('session_id', 'default')
        
        if not user_message:
            return jsonify({"error": "Message cannot be empty"}), 400
        
        chatbot_config = load_chatbot_config()
        web_context, web_status = _google_search_context(user_message)

        # Initialize session history if not exists
        if session_id not in chat_sessions:
            chat_sessions[session_id] = []
        
        # Call Gemini API
        import google.generativeai as genai
        genai.configure(api_key=GEMINI_API_KEY)
        
        # Create fully dynamic system prompt from config + live web context
        config_json = json.dumps(chatbot_config, ensure_ascii=False, indent=2)
        web_context_text = web_context if web_context else f"No live Google results available ({web_status})."
        system_prompt = f"""
You are "PlacementBot", the 24/7 Virtual Career Assistant for the Training and Placement Office (TPO) at {chatbot_config['institution_name']}.

Your primary goals are:
1. Instant Query Resolution: Answer questions about cutoffs, schedules, and eligibility based on the institution's specific data.
2. Mock Prep: Help students prepare for interviews with practice sessions and feedback.

    Institution Specific Data (dynamic, use this source of truth):
    {config_json}

    Live Google Search Results for current query:
    {web_context_text}

Instructions:
- Use clear, concise language to structure your answers.
    - If asked about the college/institution details, provide all relevant configured details.
    - If a company is not present in configured visits, tell them to check official notice updates.
    - If live Google results are available, use them to provide current information and cite the source links.
- Stay professional, helpful, and institutional in your tone.
"""
        
        generation_config = {
            "temperature": 0.5,
            "top_p": 0.95,
            "top_k": 40,
            "max_output_tokens": 2048,
        }
        
        model = genai.GenerativeModel(
            model_name="gemini-1.5-flash",
            generation_config=generation_config,
            system_instruction=system_prompt
        )

        # Build simple text history to avoid provider object incompatibilities
        history = chat_sessions.get(session_id, [])
        chat = model.start_chat(history=history)
        response = chat.send_message(user_message)

        chat_sessions[session_id].append({"role": "user", "parts": [user_message]})
        chat_sessions[session_id].append({"role": "model", "parts": [response.text]})

        return jsonify({
            "response": response.text,
            "session_id": session_id,
            "google_search": {
                "status": web_status,
                "used": bool(web_context)
            }
        }), 200
        
    except Exception as e:
        print(f"Chatbot error: {e}")
        latest_config = load_chatbot_config()
        latest_web_context, latest_web_status = _google_search_context(user_message if 'user_message' in locals() else '')
        fallback = _build_fallback_reply(
            user_message if 'user_message' in locals() else '',
            latest_config,
            latest_web_context
        )
        return jsonify({
            "response": fallback,
            "session_id": session_id if 'session_id' in locals() else 'default',
            "fallback": True,
            "google_search": {
                "status": latest_web_status,
                "used": bool(latest_web_context)
            }
        }), 200

@app.route('/chatbot/clear', methods=['POST'])
def clear_chat_session():
    """Clear a specific chat session"""
    try:
        data = request.get_json()
        session_id = data.get('session_id', 'default')
        
        if session_id in chat_sessions:
            del chat_sessions[session_id]
        
        return jsonify({"message": "Session cleared"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    if not os.path.exists(app.config['UPLOAD_FOLDER']):
        os.makedirs(app.config['UPLOAD_FOLDER'])
    setup_database()
    app.run(host='0.0.0.0', port=5000, debug=True)