# Resume Parser Integration

## Overview
The resume upload feature is now integrated with an AI-powered resume parser that provides:
- ATS (Applicant Tracking System) score analysis
- Skills extraction
- Experience and education parsing
- Job recommendations based on resume content

## Architecture
- **Main Backend** (Port 5000): Handles authentication, file uploads, database operations
- **Resume Parser** (Port 5001): AI-powered resume analysis service

## Setup Instructions

### 1. Start Backend Services

#### Option A: Using the batch script (Windows)
```bash
cd backend
start_servers.bat
```

#### Option B: Manual start
Open two separate terminals:

**Terminal 1 - Main Backend:**
```bash
cd backend
python app.py
```

**Terminal 2 - Resume Parser:**
```bash
cd backend/resumeparser
python app.py
```

### 2. Install Resume Parser Dependencies
```bash
cd backend/resumeparser
pip install -r requirement.txt
```

This will install:
- spaCy (NLP framework)
- transformers (AI models)
- NLTK (Natural language toolkit)

### 3. Run Flutter App
```bash
cd placementpro
flutter run
```

## User Flow

1. **Login** as a student
2. Navigate to **Profile** page
3. Click **"Upload Resume"** button
4. **Select PDF** file from file picker
5. Click **"Upload & Parse Resume"**
6. View **analysis results** including:
   - ATS Score (0-100)
   - Extracted personal information
   - Skills detected
   - Work experience
   - Education history
   - Job recommendations

## API Endpoints

### Main Backend (Port 5000)
- `POST /upload-resume` - Upload resume and trigger parsing
  - Parameters: `email`, `resume` (file)
  - Returns: Upload status + parsed data

### Resume Parser (Port 5001)
- `POST /api/parse` - Parse resume file
  - Parameters: `resume` (file)
  - Returns: Parsed data, ATS score, job recommendations

## Files Modified

### Backend
- `backend/app.py` - Added parser integration
- `backend/resumeparser/app.py` - Changed port to 5001
- `backend/add_resume_column.py` - Database migration script
- `backend/start_servers.bat` - Server startup script

### Flutter
- `lib/screens/student/profile/resume_parser.dart` - Upload UI with results navigation
- `lib/screens/student/profile/resume_results.dart` - Results display page
- `lib/services/api_service.dart` - Added upload methods for web/mobile

## Troubleshooting

### Resume Parser not responding
- Check if both servers are running
- Verify port 5001 is not blocked
- Check terminal output for errors

### File upload fails on web
- Ensure CORS is enabled on backend
- Check browser console for errors
- Verify file size < 16MB

### ATS Score shows 0
- Parser service may need model downloads (first run)
- Check resume parser terminal for errors
- Ensure resume contains text (not just images)

## Notes
- First run may take longer as AI models download
- PDF files with images may have limited parsing
- Best results with text-based PDF resumes
