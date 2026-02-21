import os
import json
from flask import Flask, request, jsonify
from flask_cors import CORS
from werkzeug.utils import secure_filename
import PyPDF2
from resume_parser import ResumeParser
from job_matcher import JobMatcher

app = Flask(__name__)
CORS(app)

app.config['UPLOAD_FOLDER'] = 'uploads'
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024

os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

# Initialize parsers
resume_parser = ResumeParser()
job_matcher = JobMatcher()

ALLOWED_EXTENSIONS = {'pdf', 'docx', 'txt'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def extract_text_from_pdf(file_path):
    """Extract text from PDF file"""
    try:
        text = ""
        with open(file_path, 'rb') as file:
            pdf_reader = PyPDF2.PdfReader(file)
            for page_num in range(len(pdf_reader.pages)):
                page = pdf_reader.pages[page_num]
                try:
                    page_text = page.extract_text()
                except Exception:
                    page_text = ''
                if page_text:
                    text += page_text
        return text
    except Exception as e:
        print(f"Error extracting PDF: {e}")
        # Try pdfminer.six as a fallback for PDFs PyPDF2 can't extract (e.g., some layouts)
        try:
            from pdfminer.high_level import extract_text as pm_extract_text
            try:
                pm_text = pm_extract_text(file_path)
                if pm_text and len(pm_text.strip()) > 0:
                    return pm_text
            except Exception as e2:
                print(f"pdfminer extraction failed: {e2}")
        except Exception:
            print("pdfminer not installed or unavailable")

        return ""

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({'status': 'Resume Parser Service Running'}), 200

@app.route('/api/parse', methods=['POST'])
def parse_resume():
    """Parse resume from PDF and recommend jobs"""
    try:
        if 'resume' not in request.files:
            return jsonify({'error': 'No file provided'}), 400
        
        file = request.files['resume']
        
        if file.filename == '':
            return jsonify({'error': 'No file selected'}), 400
        
        if not allowed_file(file.filename):
            return jsonify({'error': 'Invalid file type. Only PDF, DOCX, TXT allowed'}), 400
        
        # Save file temporarily
        filename = secure_filename(file.filename)
        file_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(file_path)
        
        # Extract text based on file type
        file_ext = filename.rsplit('.', 1)[1].lower()
        
        if file_ext == 'pdf':
            text = extract_text_from_pdf(file_path)
        elif file_ext == 'txt':
            with open(file_path, 'r', encoding='utf-8') as f:
                text = f.read()
        else:
            text = file.read().decode('utf-8')
        
        if not text or len(text.strip()) < 10:
            print("Warning: Could not extract text from file. Proceeding with empty text for ATS scoring.")
            # proceed with empty text so we can still compute ATS and return useful feedback
            text = ""
        
        # Parse resume
        try:
            parsed_data = resume_parser.parse(text)
            # Attach raw text and filename to parsed_data to help matching when extraction failed
            parsed_data['raw_text'] = text or ''
            parsed_data['filename'] = filename
            print(f"Successfully parsed resume. Data keys: {parsed_data.keys()}")
        except Exception as parse_error:
            print(f"Error parsing resume: {parse_error}")
            import traceback
            traceback.print_exc()
            return jsonify({'error': f'Failed to parse resume: {str(parse_error)}'}), 500
        
        # Calculate ATS score
        try:
            ats_results = job_matcher.calculate_ats_score(parsed_data)
        except Exception as ats_error:
            print(f"Error calculating ATS score: {ats_error}")
            import traceback
            traceback.print_exc()
            return jsonify({'error': f'Failed to calculate ATS score: {str(ats_error)}'}), 500
        
        # Get job recommendations
        try:
            job_recommendations = job_matcher.get_job_recommendations(parsed_data)
        except Exception as rec_error:
            print(f"Error getting job recommendations: {rec_error}")
            import traceback
            traceback.print_exc()
            job_recommendations = []
        
        # Clean up
        try:
            os.remove(file_path)
        except:
            pass
        
        return jsonify({
            'success': True,
            'parsed_data': parsed_data,
            'ats_score': ats_results,
            'job_recommendations': job_recommendations[:10] if job_recommendations else []
        }), 200
    
    except Exception as e:
        print(f"General Error: {e}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001)
