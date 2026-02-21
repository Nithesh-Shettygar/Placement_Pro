import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from sentence_transformers import SentenceTransformer
import re

class JobMatcher:
    def __init__(self):
        # Load sentence transformer for semantic matching
        try:
            self.model = SentenceTransformer('all-MiniLM-L6-v2')
        except Exception as e:
            print(f"Warning: could not load SentenceTransformer model: {e}")
            self.model = None
        self.tfidf = TfidfVectorizer(max_features=1000, stop_words='english')
        
        # Load job database
        self.jobs_db = self.load_jobs_database()
        
        # ATS scoring weights
        self.ats_weights = {
            'keywords': 0.4,
            'formatting': 0.2,
            'experience': 0.25,
            'education': 0.15
        }
    
    def load_jobs_database(self):
        """Load sample job database"""
        return [
            {
                'id': 1,
                'title': 'Senior Software Engineer',
                'company': 'Google',
                'description': 'Looking for experienced software engineer with Python, Java, and cloud expertise',
                'skills': ['python', 'java', 'aws', 'docker', 'kubernetes'],
                'experience': '5+ years',
                'location': 'Bengaluru',
                'salary': '₹32 LPA',
                'type': 'Full-time'
            },
            {
                'id': 2,
                'title': 'Data Scientist',
                'company': 'Netflix',
                'description': 'Data scientist with ML, Python, and statistical analysis skills',
                'skills': ['python', 'machine learning', 'statistics', 'sql', 'tensorflow'],
                'experience': '3+ years',
                'location': 'Mumbai',
                'salary': '₹45 LPA',
                'type': 'Full-time'
            },
            {
                'id': 3,
                'title': 'Product Manager',
                'company': 'Zomato',
                'description': 'Product manager with agile experience and technical background',
                'skills': ['agile', 'scrum', 'product strategy', 'roadmap planning', 'stakeholder management'],
                'experience': '4+ years',
                'location': 'Gurugram',
                'salary': '₹18 LPA',
                'type': 'Remote'
            },
            {
                'id': 4,
                'title': 'DevOps Engineer',
                'company': 'Tesla',
                'description': 'DevOps engineer with CI/CD, containerization, and cloud experience',
                'skills': ['docker', 'kubernetes', 'jenkins', 'aws', 'terraform', 'linux'],
                'experience': '3+ years',
                'location': 'Remote',
                'salary': '₹28 LPA',
                'type': 'Hybrid'
            },
            {
                'id': 5,
                'title': 'Frontend Developer',
                'company': 'Adobe',
                'description': 'Frontend developer with React, TypeScript, and modern CSS',
                'skills': ['react', 'typescript', 'javascript', 'html', 'css', 'redux'],
                'experience': '2+ years',
                'location': 'Noida',
                'salary': '₹22 LPA',
                'type': 'On-site'
            },
            {
                'id': 6,
                'title': 'Backend Developer',
                'company': 'Microsoft',
                'description': 'Backend developer with Node.js, databases, and microservices',
                'skills': ['nodejs', 'express', 'mongodb', 'postgresql', 'microservices', 'rest api'],
                'experience': '3+ years',
                'location': 'Hyderabad',
                'salary': '₹35 LPA',
                'type': 'Full-time'
            },
            {
                'id': 7,
                'title': 'Mobile App Developer',
                'company': 'Swiggy',
                'description': 'Mobile developer with Flutter, React Native or native development',
                'skills': ['flutter', 'dart', 'react native', 'android', 'ios', 'firebase'],
                'experience': '2+ years',
                'location': 'Bengaluru',
                'salary': '₹20 LPA',
                'type': 'Full-time'
            },
            {
                'id': 8,
                'title': 'UI/UX Designer',
                'company': 'Figma',
                'description': 'Designer with strong UI/UX skills and prototyping experience',
                'skills': ['figma', 'sketch', 'adobe xd', 'prototyping', 'user research', 'wireframing'],
                'experience': '2+ years',
                'location': 'Remote',
                'salary': '₹18 LPA',
                'type': 'Remote'
            },
            {
                'id': 9,
                'title': 'Cybersecurity Analyst',
                'company': 'Cisco',
                'description': 'Cybersecurity analyst with experience in threat detection, penetration testing, and security protocols',
                'skills': ['cybersecurity', 'penetration testing', 'network security', 'ethical hacking', 'siem', 'firewall'],
                'experience': '3+ years',
                'location': 'Bengaluru',
                'salary': '₹30 LPA',
                'type': 'Full-time'
            },
            {
                'id': 10,
                'title': 'Information Security Engineer',
                'company': 'IBM',
                'description': 'Security engineer specializing in vulnerability assessment and security architecture',
                'skills': ['cybersecurity', 'vulnerability assessment', 'security architecture', 'compliance', 'incident response'],
                'experience': '4+ years',
                'location': 'Pune',
                'salary': '₹35 LPA',
                'type': 'Full-time'
            },
            {
                'id': 11,
                'title': 'Cloud Security Specialist',
                'company': 'Amazon',
                'description': 'Cloud security specialist with AWS/Azure security expertise',
                'skills': ['cloud security', 'aws security', 'azure security', 'iam', 'encryption', 'compliance'],
                'experience': '3+ years',
                'location': 'Hyderabad',
                'salary': '₹38 LPA',
                'type': 'Full-time'
            },
            {
                'id': 12,
                'title': 'Full Stack Developer',
                'company': 'Flipkart',
                'description': 'Full stack developer with expertise in MERN/MEAN stack',
                'skills': ['react', 'nodejs', 'mongodb', 'express', 'javascript', 'typescript', 'rest api'],
                'experience': '3+ years',
                'location': 'Bengaluru',
                'salary': '₹25 LPA',
                'type': 'Full-time'
            },
            {
                'id': 13,
                'title': 'AI/ML Engineer',
                'company': 'OpenAI',
                'description': 'AI/ML engineer working on deep learning and NLP projects',
                'skills': ['machine learning', 'deep learning', 'python', 'tensorflow', 'pytorch', 'nlp', 'computer vision'],
                'experience': '4+ years',
                'location': 'Remote',
                'salary': '₹50 LPA',
                'type': 'Remote'
            },
            {
                'id': 14,
                'title': 'Blockchain Developer',
                'company': 'Coinbase',
                'description': 'Blockchain developer with smart contract and DApp development experience',
                'skills': ['blockchain', 'solidity', 'ethereum', 'smart contracts', 'web3', 'cryptocurrency'],
                'experience': '2+ years',
                'location': 'Remote',
                'salary': '₹40 LPA',
                'type': 'Remote'
            },
            {
                'id': 15,
                'title': 'QA Automation Engineer',
                'company': 'Salesforce',
                'description': 'QA automation engineer with Selenium, API testing experience',
                'skills': ['selenium', 'automation testing', 'api testing', 'python', 'java', 'ci/cd', 'jenkins'],
                'experience': '3+ years',
                'location': 'Hyderabad',
                'salary': '₹22 LPA',
                'type': 'Full-time'
            },
            {
                'id': 16,
                'title': 'Python Developer',
                'company': 'TechCorp',
                'description': 'Backend developer focused on Python applications and APIs',
                'skills': ['python', 'django', 'flask', 'rest api', 'sql'],
                'experience': '1+ years',
                'location': 'Remote',
                'salary': '₹12 LPA',
                'type': 'Full-time'
            },
            {
                'id': 17,
                'title': 'Java Developer',
                'company': 'EnterpriseSoft',
                'description': 'Java developer experienced with Spring and backend systems',
                'skills': ['java', 'spring', 'maven', 'sql'],
                'experience': '2+ years',
                'location': 'Pune',
                'salary': '₹14 LPA',
                'type': 'Full-time'
            },
            {
                'id': 18,
                'title': 'C Developer',
                'company': 'EmbeddedSystems Inc',
                'description': 'Developer for embedded C projects and low-level systems',
                'skills': ['c', 'embedded', 'rtos', 'firmware'],
                'experience': '2+ years',
                'location': 'Chennai',
                'salary': '₹11 LPA',
                'type': 'On-site'
            },
            {
                'id': 19,
                'title': 'C++ Developer',
                'company': 'GraphicsLabs',
                'description': 'C++ developer for high-performance and systems programming',
                'skills': ['c++', 'stl', 'multithreading', 'performance'],
                'experience': '2+ years',
                'location': 'Bengaluru',
                'salary': '₹16 LPA',
                'type': 'Full-time'
            },
        ]
    
    def calculate_ats_score(self, parsed_data, mode='General'):
        """Calculate ATS score for resume"""
        
        # Calculate individual scores
        keywords_score = self.calculate_keywords_score(parsed_data)
        format_score = self.calculate_format_score(parsed_data)
        experience_score = self.calculate_experience_score(parsed_data)
        education_score = self.calculate_education_score(parsed_data)
        
        # Weighted total score
        total_score = (
            keywords_score * self.ats_weights['keywords'] +
            format_score * self.ats_weights['formatting'] +
            experience_score * self.ats_weights['experience'] +
            education_score * self.ats_weights['education']
        )
        
        # Determine grade
        if total_score >= 90:
            grade = "Excellent! Your resume is highly optimized"
        elif total_score >= 75:
            grade = "Good - Minor improvements needed"
        elif total_score >= 60:
            grade = "Average - Several improvements recommended"
        else:
            grade = "Needs significant improvement"
        
        # Generate recommendations
        recommendations = self.generate_recommendations(
            parsed_data, keywords_score, format_score, experience_score
        )
        
        # Identify missing keywords
        missing_keywords = self.identify_missing_keywords(parsed_data, mode)
        
        return {
            'score': round(total_score),
            'grade': grade,
            'keywords_score': round(keywords_score),
            'format_score': round(format_score),
            'experience_score': round(experience_score),
            'education_score': round(education_score),
            'missing_keywords': missing_keywords,
            'recommendations': recommendations
        }
    
    def calculate_keywords_score(self, parsed_data):
        """Calculate keyword matching score"""
        skills = parsed_data.get('skills', [])
        if not skills:
            return 30
        
        # Check for industry-relevant keywords
        keywords_found = len(skills)
        
        # Score based on number and quality of skills
        if keywords_found >= 15:
            return 95
        elif keywords_found >= 10:
            return 85
        elif keywords_found >= 7:
            return 75
        elif keywords_found >= 5:
            return 65
        elif keywords_found >= 3:
            return 50
        else:
            return 30
    
    def calculate_format_score(self, parsed_data):
        """Calculate formatting score"""
        score = 70  # Base score
        
        # Check for clear sections
        if parsed_data.get('summary'):
            score += 5
        if parsed_data.get('experience'):
            score += 5
        if parsed_data.get('education'):
            score += 5
        
        # Check for contact information
        if parsed_data.get('email') and parsed_data['email'] != "Email not found":
            score += 5
        if parsed_data.get('phone') and parsed_data['phone'] != "Phone not found":
            score += 5
        
        return min(score, 100)
    
    def calculate_experience_score(self, parsed_data):
        """Calculate experience relevance score"""
        experience = parsed_data.get('experience', [])
        if not experience:
            return 30
        
        # Score based on number of experiences and descriptions
        num_experiences = len(experience)
        if num_experiences >= 3:
            base_score = 80
        elif num_experiences == 2:
            base_score = 70
        elif num_experiences == 1:
            base_score = 60
        else:
            base_score = 40
        
        # Check for detailed descriptions
        has_descriptions = any(len(exp.get('description', '')) > 50 for exp in experience)
        if has_descriptions:
            base_score += 15
        
        return min(base_score, 100)
    
    def calculate_education_score(self, parsed_data):
        """Calculate education score"""
        education = parsed_data.get('education', [])
        if not education:
            return 30
        
        # Check for degree level
        degree_text = ' '.join([edu.get('degree', '') for edu in education])
        
        if 'PhD' in degree_text or 'Doctor' in degree_text:
            return 95
        elif 'Master' in degree_text or 'M.' in degree_text:
            return 90
        elif 'Bachelor' in degree_text or 'B.' in degree_text:
            return 85
        else:
            return 70
    
    def identify_missing_keywords(self, parsed_data, mode):
        """Identify important missing keywords"""
        current_skills = set(s.lower() for s in parsed_data.get('skills', []))
        
        # Industry-specific keywords
        industry_keywords = {
            'Technical': ['python', 'java', 'javascript', 'sql', 'aws', 'docker', 'react', 'node.js', 'mongodb', 'git'],
            'Management': ['leadership', 'strategy', 'budget', 'team', 'project', 'agile', 'scrum', 'stakeholder', 'roadmap'],
            'Creative': ['design', 'creative', 'photoshop', 'illustrator', 'ui/ux', 'figma', 'adobe', 'sketch', 'prototype'],
            'General': ['communication', 'teamwork', 'problem solving', 'deadline', 'organization', 'time management', 'adaptability']
        }
        
        # Get keywords for selected mode
        target_keywords = industry_keywords.get(mode, industry_keywords['General'])
        
        # Find missing keywords
        missing = [kw for kw in target_keywords if kw not in current_skills]
        
        return missing[:10]  # Return top 10 missing
    
    def generate_recommendations(self, parsed_data, keywords_score, format_score, experience_score):
        """Generate improvement recommendations"""
        recommendations = []
        
        if keywords_score < 70:
            recommendations.append("Add more industry-specific keywords and skills")
            recommendations.append("Include both technical and soft skills")
            recommendations.append("Use action verbs like 'developed', 'implemented', 'led'")
        
        if format_score < 70:
            recommendations.append("Improve resume formatting with clear sections")
            recommendations.append("Ensure contact information is prominently displayed")
            recommendations.append("Use bullet points for better readability")
            recommendations.append("Keep consistent font sizes and styles")
        
        if experience_score < 70:
            recommendations.append("Add more quantifiable achievements in experience")
            recommendations.append("Include specific metrics and results (e.g., 'increased sales by 20%')")
            recommendations.append("Use action verbs to describe responsibilities")
            recommendations.append("Focus on accomplishments rather than just duties")
        
        if not parsed_data.get('summary'):
            recommendations.append("Add a professional summary at the top")
        
        if len(parsed_data.get('skills', [])) < 10:
            recommendations.append("Expand skills section with more relevant technologies")
        
        return recommendations[:5]
    
    def get_job_recommendations(self, parsed_data, preferences=None, experience_level=None):
        """Get job recommendations based on resume"""
        
        # Extract resume features - include all text
        resume_skills = set(s.lower() for s in parsed_data.get('skills', []) if isinstance(s, str))
        
        # Extract keywords from all sections
        all_text = []
        if parsed_data.get('summary'):
            all_text.append(parsed_data['summary'])
        if parsed_data.get('experience'):
            for exp in parsed_data.get('experience', []):
                if isinstance(exp, dict):
                    all_text.append(exp.get('description', ''))
                else:
                    all_text.append(str(exp))
        
        # Combine all text for better matching (include filename/raw_text as fallback)
        filename_text = str(parsed_data.get('filename', '') or '')
        raw_text = str(parsed_data.get('raw_text', '') or '')
        resume_text = ' '.join([
            ' '.join(all_text),
            ' '.join(resume_skills),
            filename_text,
            raw_text
        ]).lower()

        # If no skills were found by the parser, do a simple keyword scan in raw_text/filename
        # to pick up common language keywords (python, java, c, c++, javascript, etc.)
        if not resume_skills:
            scan_keywords = ['python', 'java', 'javascript', 'c++', 'c', 'c#', 'go', 'golang', 'rust', 'sql', 'php', 'ruby']
            for kw in scan_keywords:
                if kw in resume_text:
                    resume_skills.add(kw)

        # Also normalize c++ -> cpp in matching if needed
        if 'c++' in resume_skills and 'cpp' not in resume_skills:
            resume_skills.add('cpp')
        
        # Calculate match scores for each job
        job_scores = []
        
        for job in self.jobs_db:
            # Skill match - check both exact and partial matches
            job_skills = set(s.lower() for s in job['skills'])
            
            # Direct skill match
            skill_match = len(resume_skills.intersection(job_skills))
            
            # Partial keyword match - check if job skills appear in resume text
            keyword_matches = sum(1 for skill in job_skills if skill in resume_text)
            
            total_skills = len(job_skills)
            skill_score = ((skill_match + keyword_matches * 0.5) / total_skills) * 100 if total_skills > 0 else 0
            skill_score = min(skill_score, 100)  # Cap at 100
            
            # Semantic similarity
            job_text = f"{job['title']} {job['description']} {' '.join(job['skills'])}".lower()
            
            semantic_score = 0.0
            if self.model is not None:
                try:
                    resume_embedding = self.model.encode([resume_text])
                    job_embedding = self.model.encode([job_text])
                    # Calculate similarity
                    similarity = cosine_similarity(resume_embedding, job_embedding)[0][0]
                    semantic_score = float(similarity) * 100
                except Exception as e:
                    print(f"Warning: semantic encoding failed: {e}")
                    semantic_score = 0.0
            
            # Combined score with emphasis on skill matching
            final_score = (skill_score * 0.7 + semantic_score * 0.3)
            
            # Apply filters
            if preferences and job['type'] not in preferences:
                final_score *= 0.7
            
            job_scores.append({
                **job,
                'match_score': round(final_score),
                'matched_skills': list(resume_skills.intersection(job_skills))
            })
        
        # Sort by match score
        job_scores.sort(key=lambda x: x['match_score'], reverse=True)
        
        # Return top matches (minimum score of 10 to show variety)
        return [job for job in job_scores if job['match_score'] >= 10]
    
    def categorize_skills(self, skills):
        """Categorize skills for visualization"""
        categories = {
            'Technical': [],
            'Soft': [],
            'Domain': []
        }
        
        skill_db = {
            'technical': ['python', 'java', 'javascript', 'sql', 'aws', 'docker', 'react', 'node', 'html', 'css', 'c++', 'ruby'],
            'soft': ['communication', 'leadership', 'teamwork', 'problem solving', 'critical thinking', 'adaptability', 'creativity'],
            'domain': ['machine learning', 'data science', 'cloud computing', 'devops', 'agile', 'scrum', 'project management']
        }
        
        for skill in skills:
            skill_lower = skill.lower()
            categorized = False
            
            for tech in skill_db['technical']:
                if tech in skill_lower:
                    categories['Technical'].append(skill)
                    categorized = True
                    break
            
            if not categorized:
                for soft in skill_db['soft']:
                    if soft in skill_lower:
                        categories['Soft'].append(skill)
                        categorized = True
                        break
            
            if not categorized:
                for domain in skill_db['domain']:
                    if domain in skill_lower:
                        categories['Domain'].append(skill)
                        categorized = True
                        break
            
            if not categorized:
                categories['Domain'].append(skill)  # Default to domain
        
        return categories
    
    def calculate_experience_years(self, experience):
        """Calculate total years of experience"""
        total_years = 0
        
        for exp in experience:
            duration = exp.get('duration', '')
            
            # Extract years from duration string
            years_match = re.search(r'(\d+)\s*years?', duration)
            if years_match:
                years = int(years_match.group(1))
                total_years += years
            else:
                # If no years found, estimate 2 years per role
                total_years += 2
        
        return total_years if total_years > 0 else 0
    
    def suggest_career_paths(self, parsed_data):
        """Suggest career paths based on resume"""
        skills = parsed_data.get('skills', [])
        experience = parsed_data.get('experience', [])
        
        career_paths = []
        
        # Analyze current profile
        skills_lower = [s.lower() for s in skills]
        has_technical = any(skill in ['python', 'java', 'javascript', 'sql', 'react', 'node'] for skill in skills_lower)
        has_management = any('leadership' in skill or 'management' in skill for skill in skills_lower)
        has_creative = any('design' in skill or 'creative' in skill or 'ui' in skill or 'ux' in skill for skill in skills_lower)
        has_data = any('data' in skill or 'analytics' in skill or 'machine learning' in skill for skill in skills_lower)
        
        if has_technical:
            career_paths.extend([
                {'role': 'Technical Lead', 'demand': 5, 'growth': 15, 
                 'description': 'Lead technical teams and architecture decisions'},
                {'role': 'Solutions Architect', 'demand': 4, 'growth': 12,
                 'description': 'Design and oversee complex technical solutions'},
                {'role': 'Engineering Manager', 'demand': 4, 'growth': 10,
                 'description': 'Manage engineering teams and drive technical strategy'}
            ])
        
        if has_management:
            career_paths.extend([
                {'role': 'Project Manager', 'demand': 4, 'growth': 10,
                 'description': 'Manage project timelines and team coordination'},
                {'role': 'Product Manager', 'demand': 5, 'growth': 18,
                 'description': 'Drive product strategy and development'},
                {'role': 'Program Manager', 'demand': 3, 'growth': 12,
                 'description': 'Oversee multiple related projects and initiatives'}
            ])
        
        if has_creative:
            career_paths.extend([
                {'role': 'Creative Director', 'demand': 3, 'growth': 8,
                 'description': 'Lead creative vision and design strategy'},
                {'role': 'UX Lead', 'demand': 4, 'growth': 15,
                 'description': 'Guide user experience design and research'},
                {'role': 'Art Director', 'demand': 3, 'growth': 10,
                 'description': 'Direct visual design and creative projects'}
            ])
        
        if has_data:
            career_paths.extend([
                {'role': 'Data Scientist', 'demand': 5, 'growth': 20,
                 'description': 'Analyze complex data and build predictive models'},
                {'role': 'Data Engineer', 'demand': 4, 'growth': 18,
                 'description': 'Build and maintain data infrastructure'},
                {'role': 'ML Engineer', 'demand': 5, 'growth': 25,
                 'description': 'Develop and deploy machine learning models'}
            ])
        
        # Add default paths if none found
        if not career_paths:
            career_paths = [
                {'role': 'Senior Specialist', 'demand': 4, 'growth': 10,
                 'description': 'Advance in your current field with deeper expertise'},
                {'role': 'Team Lead', 'demand': 3, 'growth': 8,
                 'description': 'Move into leadership and mentoring roles'},
                {'role': 'Consultant', 'demand': 3, 'growth': 12,
                 'description': 'Provide expert advice in your domain'}
            ]
        
        return career_paths