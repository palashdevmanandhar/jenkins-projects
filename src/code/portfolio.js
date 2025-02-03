import { useState, useEffect } from 'react';
import '../index.css';

const Portfolio = () => {
    const [isMenuOpen, setIsMenuOpen] = useState(false);
    const [serverIP, setServerIP] = useState('Loading...');

     useEffect(() => {
        const fetchIP = async () => {
          try {
            const response = await fetch('/api/ip');
            const data = await response.json();
            setServerIP(data.ip);
          } catch (error) {
            setServerIP('Failed to load IP');
            console.error('Error fetching IP:', error);
          }
        };
        fetchIP();
      }, []);
  
    const personalInfo = {
      name: "Palash Dev Manandhar",
      title: "DevOps Engineer",
      bio: "AWS and Kubernetes certified DevOps Engineer with over seven years of experience in cloud, system, software and data engineering. Passionate about automating application deployment and designing secure and scalable cloud architectures.",
      email: "palash.manandhar@gmail.com",
      linkedin: "https://www.linkedin.com/in/palash-dev-manandhar-589367168",
      github: "https://github.com/palashdevmanandhar"
    };
  
    const experience = [
      {
        company: "Company Name",
        position: "Position",
        duration: "Duration",
        description: "Key responsibilities and achievements"
      }
    ];
  
    const skills = [
      "AWS", "Docker", "Bash", "GCP", "Terraform", "Ansible",
      "React", "JavaScript", "Jenkins", "Python", "Kubernetes"
    ];
  
    const projects = [
      {
        title: "Project Name",
        description: "Project description and key features",
        technologies: ["React", "Node.js", "MongoDB"],
        link: "https://project-link.com"
      }
    ];
  
    return (
      <div className="min-h-screen bg-gray-900 text-gray-100">
        {/* Navigation */}
        <nav className="bg-gray-800 shadow-lg">
          <div className="max-w-6xl mx-auto px-4">
            <div className="flex justify-between">
              <div className="flex space-x-7">
                <div className="flex items-center py-4">
                  <span className="font-semibold text-gray-100 text-lg">
                    {personalInfo.name}
                  </span>
                </div>
              </div>
              <div className="hidden md:flex items-center space-x-6">
                <a href="#about" className="py-4 px-2 text-gray-300 hover:text-blue-400 transition-colors">About</a>
                <a href="#experience" className="py-4 px-2 text-gray-300 hover:text-blue-400 transition-colors">Experience</a>
                <a href="#skills" className="py-4 px-2 text-gray-300 hover:text-blue-400 transition-colors">Skills</a>
                <a href="#projects" className="py-4 px-2 text-gray-300 hover:text-blue-400 transition-colors">Projects</a>
                <a href="#contact" className="py-4 px-2 text-gray-300 hover:text-blue-400 transition-colors">Contact</a>
                <div className="py-4 px-2 text-gray-300 hover:text-blue-400 transition-colors">Server IP: {serverIP}</div>
              </div>
              {/* Mobile menu button */}
              <div className="md:hidden flex items-center">
                <button 
                  className="outline-none mobile-menu-button"
                  onClick={() => setIsMenuOpen(!isMenuOpen)}
                >
                  <svg
                    className="w-6 h-6 text-gray-300"
                    fill="none"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="2"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path d="M4 6h16M4 12h16M4 18h16"></path>
                  </svg>
                </button>
              </div>
            </div>
          </div>
          {/* Mobile menu */}
          <div className={`${isMenuOpen ? 'block' : 'hidden'} md:hidden`}>
            <a href="#about" className="block py-2 px-4 text-sm text-gray-300 hover:bg-gray-700">About</a>
            <a href="#experience" className="block py-2 px-4 text-sm text-gray-300 hover:bg-gray-700">Experience</a>
            <a href="#skills" className="block py-2 px-4 text-sm text-gray-300 hover:bg-gray-700">Skills</a>
            <a href="#projects" className="block py-2 px-4 text-sm text-gray-300 hover:bg-gray-700">Projects</a>
            <a href="#contact" className="block py-2 px-4 text-sm text-gray-300 hover:bg-gray-700">Contact</a>
          </div>
        </nav>
  
        {/* Hero Section */}
        <section id="about" className="py-20 bg-gray-800">
          <div className="max-w-6xl mx-auto px-4">
            <div className="text-center">
              <h1 className="text-4xl font-bold text-gray-100 mb-4">
                {personalInfo.name}
              </h1>
              <h2 className="text-2xl text-gray-300 mb-8">
                {personalInfo.title}
              </h2>
              <p className="text-gray-400 max-w-2xl mx-auto">
                {personalInfo.bio}
              </p>
            </div>
          </div>
        </section>
  
        {/* Experience Section */}
        <section id="experience" className="py-20">
          <div className="max-w-6xl mx-auto px-4">
            <h2 className="text-3xl font-bold text-center mb-12 text-gray-100">Experience</h2>
            <div className="space-y-8">
              {experience.map((exp, index) => (
                <div key={index} className="bg-gray-800 p-6 rounded-lg shadow-lg border border-gray-700">
                  <h3 className="text-xl font-semibold text-gray-100">{exp.company}</h3>
                  <p className="text-gray-300">{exp.position}</p>
                  <p className="text-gray-400 text-sm">{exp.duration}</p>
                  <p className="mt-4 text-gray-300">{exp.description}</p>
                </div>
              ))}
            </div>
          </div>
        </section>
  
        {/* Skills Section */}
        <section id="skills" className="py-20 bg-gray-800">
          <div className="max-w-6xl mx-auto px-4">
            <h2 className="text-3xl font-bold text-center mb-12 text-gray-100">Skills</h2>
            <div className="flex flex-wrap justify-center gap-4">
              {skills.map((skill, index) => (
                <span
                  key={index}
                  className="px-4 py-2 bg-gray-700 rounded-full shadow-md text-gray-300 hover:bg-gray-600 transition-colors"
                >
                  {skill}
                </span>
              ))}
            </div>
          </div>
        </section>
  
        {/* Projects Section */}
        <section id="projects" className="py-20">
          <div className="max-w-6xl mx-auto px-4">
            <h2 className="text-3xl font-bold text-center mb-12 text-gray-100">Projects</h2>
            <div className="grid md:grid-cols-2 gap-8">
              {projects.map((project, index) => (
                <div key={index} className="bg-gray-800 p-6 rounded-lg shadow-lg border border-gray-700">
                  <h3 className="text-xl font-semibold mb-4 text-gray-100">{project.title}</h3>
                  <p className="text-gray-300 mb-4">{project.description}</p>
                  <div className="flex flex-wrap gap-2 mb-4">
                    {project.technologies.map((tech, techIndex) => (
                      <span
                        key={techIndex}
                        className="px-3 py-1 bg-blue-900 text-blue-300 rounded-full text-sm"
                      >
                        {tech}
                      </span>
                    ))}
                  </div>
                  <a
                    href={project.link}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-blue-400 hover:text-blue-300 transition-colors"
                  >
                    View Project →
                  </a>
                </div>
              ))}
            </div>
          </div>
        </section>
  
        {/* Contact Section */}
        <section id="contact" className="py-20 bg-gray-800">
          <div className="max-w-6xl mx-auto px-4">
            <h2 className="text-3xl font-bold text-center mb-12 text-gray-100">Get In Touch</h2>
            <div className="flex justify-center space-x-6">
              <a
                href={`mailto:${personalInfo.email}`}
                className="text-gray-300 hover:text-blue-400 transition-colors"
              >
                Email
              </a>
              <a
                href={personalInfo.linkedin}
                target="_blank"
                rel="noopener noreferrer"
                className="text-gray-300 hover:text-blue-400 transition-colors"
              >
                LinkedIn
              </a>
              <a
                href={personalInfo.github}
                target="_blank"
                rel="noopener noreferrer"
                className="text-gray-300 hover:text-blue-400 transition-colors"
              >
                GitHub
              </a>
            </div>
          </div>
        </section>
      </div>
    );
  };
  
  export default Portfolio;