import re
from typing import List, Dict, Any

class ResumeParser:
    """Parse resume content and extract key information"""
    
    def __init__(self):
        # Common skill keywords
        self.skill_keywords = {
            'programming': ['python', 'java', 'javascript', 'c++', 'c#', 'html', 'css', 'ruby', 'php', 'golang', 'rust', 'swift', 'kotlin'],
            'web': ['react', 'angular', 'vue', 'nodejs', 'express', 'django', 'flask', 'spring', 'laravel', 'asp.net', 'fastapi'],
            'mobile': ['flutter', 'dart', 'react native', 'android', 'ios', 'xamarin', 'swift'],
            'data': ['python', 'r', 'sql', 'mysql', 'postgresql', 'mongodb', 'nosql', 'hadoop', 'spark', 'tableau', 'power bi'],
            'ml_ai': ['machine learning', 'deep learning', 'tensorflow', 'pytorch', 'keras', 'scikit-learn', 'nlp', 'computer vision', 'artificial intelligence'],
            'cloud': ['aws', 'azure', 'gcp', 'google cloud', 'docker', 'kubernetes', 'jenkins', 'ci/cd', 'terraform'],
            'security': ['cybersecurity', 'security', 'penetration testing', 'network security', 'ethical hacking', 'firewall', 'siem', 'encryption'],
            'blockchain': ['blockchain', 'solidity', 'ethereum', 'web3', 'smart contracts', 'cryptocurrency'],
            'devops': ['devops', 'docker', 'kubernetes', 'jenkins', 'ansible', 'terraform', 'linux', 'git'],
            'database': ['sql', 'mongodb', 'postgresql', 'mysql', 'oracle', 'dynamodb', 'redis', 'cassandra'],
            'soft_skills': ['leadership', 'communication', 'teamwork', 'problem solving', 'critical thinking', 'project management', 'agile', 'scrum']
        }
    
    def parse(self, text: str) -> Dict[str, Any]:
        """Parse resume text and extract information"""
        text = text.lower()
        
        parsed_data = {
            'name': self._extract_name(text),
            'email': self._extract_email(text),
            'phone': self._extract_phone(text),
            'linkedin': self._extract_linkedin(text),
            'summary': self._extract_summary(text),
            'skills': self._extract_skills(text),
            'experience': self._extract_experience(text),
            'education': self._extract_education(text),
            'certifications': self._extract_certifications(text),
            'languages': self._extract_languages(text),
        }
        
        return parsed_data
    
    def _extract_name(self, text: str) -> str:
        """Extract person's name"""
        # Look for name patterns at the beginning
        lines = text.split('\n')
        for line in lines[:5]:
            line = line.strip()
            if len(line) > 3 and len(line) < 50 and not any(char.isdigit() for char in line):
                words = line.split()
                if len(words) >= 2:
                    return ' '.join(words[:2]).title()
        return "Name not found"
    
    def _extract_email(self, text: str) -> str:
        """Extract email address"""
        email_pattern = r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
        match = re.search(email_pattern, text)
        return match.group(0) if match else "Email not found"
    
    def _extract_phone(self, text: str) -> str:
        """Extract phone number"""
        # Various phone formats
        phone_patterns = [
            r'\+?91[-.\s]?\d{10}',  # India
            r'\+\d{1,3}[-.\s]?\d{9,}',  # International
            r'\b\d{3}[-.\s]?\d{3}[-.\s]?\d{4}\b',  # US format
        ]
        
        for pattern in phone_patterns:
            match = re.search(pattern, text)
            if match:
                return match.group(0)
        
        return "Phone not found"
    
    def _extract_linkedin(self, text: str) -> str:
        """Extract LinkedIn profile"""
        linkedin_pattern = r'linkedin\.com/in/[\w-]+'
        match = re.search(linkedin_pattern, text)
        return match.group(0) if match else ""
    
    def _extract_summary(self, text: str) -> str:
        """Extract professional summary"""
        # Look for professional summary section
        patterns = [
            r'(professional summary|summary|objective)[\s\S]{0,500}?(?=\n(?:experience|skills|education|expertise))',
            r'(about|about me)[\s\S]{0,500}?(?=\n)',
        ]
        
        for pattern in patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                summary = match.group(0)
                # Clean up
                summary = re.sub(r'professional summary|summary|objective|about|about me', '', summary, flags=re.IGNORECASE)
                summary = ' '.join(summary.split())
                if len(summary) > 20:
                    return summary[:300]
        
        return ""
    
    def _extract_skills(self, text: str) -> List[str]:
        """Extract skills from resume"""
        found_skills = set()
        
        # Search for all skill keywords
        for category, skills in self.skill_keywords.items():
            for skill in skills:
                if skill in text:
                    found_skills.add(skill)
        
        # Look for skills section
        skills_pattern = r'(skills|technical skills|competencies)[\s\S]{0,1000}?(?=\n(?:experience|education|projects|certifications)|\Z)'
        match = re.search(skills_pattern, text, re.IGNORECASE)
        
        if match:
            skills_section = match.group(0)
            # Extract individual skills from the section
            skill_items = re.split(r'[,•|–-]|\n', skills_section)
            for item in skill_items:
                item = item.strip()
                if len(item) > 2 and len(item) < 50:
                    # Check if it matches any keyword
                    item_lower = item.lower()
                    if any(keyword in item_lower for keyword in sum(self.skill_keywords.values(), [])):
                        found_skills.add(item_lower)
        
        return list(found_skills)
    
    def _extract_experience(self, text: str) -> List[Dict[str, str]]:
        """Extract work experience"""
        experience = []
        
        # Look for experience section
        pattern = r'(experience|work experience|professional experience)[\s\S]{0,3000}?(?=\n(?:education|skills|projects|certifications)|\Z)'
        match = re.search(pattern, text, re.IGNORECASE)
        
        if match:
            exp_section = match.group(0)
            # Simple extraction - split by lines with job titles
            lines = exp_section.split('\n')
            
            current_exp = {}
            for line in lines:
                line = line.strip()
                if re.search(r'\d{4}', line):  # Has year
                    if current_exp:
                        experience.append(current_exp)
                    current_exp = {'description': line}
                elif line and current_exp:
                    current_exp['description'] += ' ' + line
            
            if current_exp:
                experience.append(current_exp)
        
        return experience if experience else [{'description': 'Experience information extracted'}]
    
    def _extract_education(self, text: str) -> List[Dict[str, str]]:
        """Extract education details"""
        education = []
        
        # Look for education section
        pattern = r'(education|academic|qualifications)[\s\S]{0,1000}?(?=\n(?:experience|skills|projects)|\Z)'
        match = re.search(pattern, text, re.IGNORECASE)
        
        if match:
            edu_section = match.group(0)
            
            # Look for degree types
            degree_patterns = ['bachelor', 'master', 'phd', 'mba', 'b.tech', 'm.tech', 'bsc', 'msc', 'diploma']
            
            for degree in degree_patterns:
                if degree in edu_section.lower():
                    education.append({
                        'degree': degree.upper(),
                        'description': edu_section[:200]
                    })
                    break
        
        return education if education else [{'degree': 'Graduate', 'description': 'Education details extracted'}]
    
    def _extract_certifications(self, text: str) -> List[str]:
        """Extract certifications"""
        certifications = []
        
        pattern = r'(certificates|certifications|training)[\s\S]{0,500}?(?=\n(?:experience|skills|education)|\Z)'
        match = re.search(pattern, text, re.IGNORECASE)
        
        if match:
            cert_section = match.group(0)
            # Extract certification names
            cert_items = re.split(r'[,•|–-]|\n', cert_section)
            for item in cert_items[:5]:
                item = item.strip()
                if len(item) > 3:
                    certifications.append(item)
        
        return certifications
    
    def _extract_languages(self, text: str) -> List[str]:
        """Extract languages known"""
        languages = []
        language_keywords = ['english', 'hindi', 'spanish', 'french', 'german', 'mandarin', 'japanese', 'arabic', 'portuguese']
        
        for lang in language_keywords:
            if lang in text:
                languages.append(lang.capitalize())
        
        return languages if languages else ['English']
