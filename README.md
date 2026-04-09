# 🎓 Smart Campus AI Platform

An intelligent **Flutter-based mobile application** designed to improve campus life by integrating **academic support, communication, navigation, safety, career guidance, and student well-being** into a single smart platform.

---

## 📖 Project Description

The **Smart Campus AI Platform** is a unified campus assistance application developed to help **students, faculty, and administrators** manage day-to-day academic and campus-related activities more efficiently.

In many colleges, students often face problems such as:

- Difficulty in finding classrooms and campus facilities
- Lack of centralized study resources
- Delayed event and notice updates
- Limited communication with faculty
- No unified emergency support system
- Lack of AI-based academic assistance
- Need for career guidance and student wellness support

This project solves those issues by combining all essential campus services into **one intelligent mobile application**.

The platform uses:

- **Flutter** for frontend development
- **Firebase** for backend and real-time data services
- **Groq AI API** for intelligent academic assistance

It creates a **smart, connected, user-friendly, and scalable campus ecosystem**.

---

# 🚀 Key Highlights

- 📱 **Cross-platform mobile app**
- 🔐 **Secure authentication**
- 🧠 **AI-powered student assistant**
- 🗺️ **Smart campus navigation**
- 📚 **Study material sharing**
- 📅 **Real-time event updates**
- 🚨 **Emergency alert system**
- 🔎 **Lost & Found support**
- 👩‍🏫 **Faculty availability tracking**
- 💼 **Career guidance**
- ❤️ **Mental health support**
- 👨‍💼 **Role-based dashboards**

---

# 🎯 Objectives

The major objectives of this project are:

- To build a **centralized smart campus platform**
- To simplify student life using **mobile and AI technologies**
- To provide **academic support and smart assistance**
- To improve **student-faculty communication**
- To offer **campus safety and emergency features**
- To support **career development and mental well-being**
- To ensure **secure, scalable, and efficient campus management**

---

# ✨ Features

## 👨‍🎓 Student Features

- Secure Login & Registration
- Student Dashboard
- Student Profile Management
- Study Materials Access
- AI Study Assistant
- Campus Navigation
- Event Viewing
- Lost & Found
- Faculty Availability
- Career Guidance
- Mental Health Support
- Emergency Alert Button

---

## 👩‍🏫 Faculty Features

- Faculty Dashboard
- Upload Study Materials
- Faculty Profile Management
- Manage Availability
- View Campus Events
- Lost & Found Access
- Campus Navigation
- Emergency Access

---

## 🛡️ Admin Features

- Admin Dashboard
- Monitor Emergency Alerts
- Post Campus Events
- Send Notifications
- Manage Administrative Updates

---

# 🧠 AI-Based Functionalities

The project includes AI-powered student assistance features such as:

- **AI Study Assistant**
- **Academic Question Answering**
- **Concept Explanation**
- **Smart Educational Support**
- **AI Response Generation**
- **Learning Assistance for Students**

The AI module is connected using the **Groq API**, enabling students to ask educational questions and receive quick intelligent responses.

---

# 🏗️ System Modules

The Smart Campus AI Platform is divided into the following modules:

1. **Authentication Module**
2. **Student Dashboard Module**
3. **Faculty Dashboard Module**
4. **Admin Dashboard Module**
5. **Study Material Module**
6. **AI Study Assistant Module**
7. **Campus Navigation Module**
8. **Event Management Module**
9. **Emergency Alert Module**
10. **Lost & Found Module**
11. **Faculty Availability Module**
12. **Career Guidance Module**
13. **Mental Health Support Module**
14. **Profile Management Module**
15. **Notification Management Module**

---

# 🛠️ Technology Stack

## Frontend
- **Flutter**
- **Dart**

## Backend / Cloud Services
- **Firebase Authentication**
- **Cloud Firestore**
- **Firebase Storage**

## AI / API Integration
- **Groq API**
- **NLP-based AI Assistance**

## Development Tools
- **Android Studio**
- **VS Code**

## Supported Platforms
- Android
- Windows
- Web
- Linux
- macOS
- iOS

---

# 📂 Project Structure

```bash
Smart-Campus-AI-Platform/
│
├── lib/
│   ├── main.dart
│   ├── login_page.dart
│   ├── register_page.dart
│   ├── splash_screen.dart
│   ├── student_dashboard.dart
│   ├── faculty_dashboard.dart
│   ├── admin_dashboard.dart
│   ├── profile_page.dart
│   ├── faculty_profile_page.dart
│   ├── ai_study_assistant.dart
│   ├── navigation_page.dart
│   ├── events.dart
│   ├── post_event.dart
│   ├── emergency.dart
│   ├── lost_found.dart
│   ├── study_materials.dart
│   ├── faculty_upload.dart
│   ├── faculty_availability.dart
│   ├── student_faculty_availability.dart
│   ├── career_page.dart
│   ├── mental_health_page.dart
│   ├── highlight_slider.dart
│   ├── admin_alerts.dart
│   ├── admin_notifications.dart
│   ├── groq_service.dart
│   └── firebase_options.dart
│
├── assets/
├── android/
├── ios/
├── web/
├── windows/
├── linux/
├── macos/
├── test/
├── pubspec.yaml
├── pubspec.lock
└── README.md
🔐 Authentication & Security

The system uses Firebase Authentication to provide secure login and role-based access.

Supported Roles
Student
Faculty
Admin
Security Features
Secure login and registration
Role-based dashboard access
Firebase-based authentication
Cloud data storage
Controlled access to modules
📱 Screens / UI Modules

The application contains the following important user interfaces:

Login Screen
Register Screen
Role Selection Screen
Student Dashboard
Faculty Dashboard
Admin Dashboard
Student Profile Screen
Faculty Profile Screen
Study Material Upload Screen
Study Materials View Screen
AI Assistant Screen
Navigation Screen
Event Upload Screen
Event Display Screen
Emergency Screen
Admin Emergency Screen
Lost & Found Screen
Faculty Availability Screen
Career Assistant Screen
Mental Health Screen
⚙️ System Workflow

The general working flow of the system is:

User launches the app
User logs in securely using Firebase Authentication
Dashboard is displayed based on user role
User selects a required module
Data is fetched or stored using Firebase services
AI features process educational queries where required
Real-time updates are shown instantly
User can continue using modules until logout
🧭 Functional Overview
1. Authentication Module

Handles secure login and registration for students, faculty, and admin users.

2. Student Dashboard

Provides quick access to:

Study Materials
AI Assistant
Navigation
Events
Career Guidance
Lost & Found
Faculty Availability
Mental Health Support
3. Faculty Dashboard

Provides faculty access to:

Upload academic materials
Manage availability
View events
Use navigation
Access emergency support
4. Admin Dashboard

Provides administrative controls such as:

Monitoring emergency alerts
Posting events
Sending notifications
5. AI Study Assistant

Allows students to ask academic questions and receive intelligent responses.

6. Navigation Module

Helps users locate classrooms, labs, and campus facilities.

7. Event Module

Displays campus events and allows event posting.

8. Emergency Module

Allows users to send emergency alerts during urgent situations.

9. Lost & Found Module

Allows reporting and searching of lost/found items.

10. Faculty Availability Module

Allows students to check faculty schedules and availability.

11. Career Guidance Module

Supports students with career-related suggestions and guidance.

12. Mental Health Module

Provides basic wellness and emotional support resources.

💻 Important Code Components

Some important implementation files in the project include:

main.dart → App entry point
student_dashboard.dart → Student module interface
faculty_dashboard.dart → Faculty module interface
admin_dashboard.dart → Admin module interface
groq_service.dart → AI integration service
firebase_options.dart → Firebase configuration
🧪 Testing

Testing was performed to verify the functionality, reliability, and usability of the application.

Types of Testing Considered
Application Testing
System Testing
GUI Testing
Authentication Testing
Database Testing
Performance Testing
Usability Testing
Boundary Testing
Security Testing
Integration Testing
Sample Test Scenarios
Test ID	Scenario	Input	Expected Output	Status
TC001	User Login	Valid credentials	User logged in successfully	Pass
TC002	User Registration	Valid details	Account created successfully	Pass
TC003	View Profile	Open profile page	User details displayed	Pass
TC004	Campus Navigation	Select location	Route guidance displayed	Pass
TC005	View Events	Click events section	Event list displayed	Pass
TC006	AI Assistant	Enter query	AI response generated	Pass
TC007	Study Materials	Open module	Notes/resources displayed	Pass
TC008	Lost & Found	Upload item details	Item stored and matched	Pass
TC009	Notification	Send alert	Notification received	Pass
TC010	Safety Alert	Press panic button	Alert sent to admin	Pass
TC011	Faculty Availability	Check schedule	Timings displayed	Pass
TC012	Logout	Click logout	User logged out successfully	Pass
📷 Output Screens

The project includes output interfaces such as:

Smart Campus AI Platform running in emulator
Login Screen
Register Screen
Role Selection Screen
Dashboard Screen
Study Material Upload Screen
Lost & Found Screen
Emergency Screen
Timetable Upload Screen
Event Upload Screen
Student Profile Screen
Admin Emergency Screen
AI Assistant Screen
Navigation Screen
Career Assistant Screen
Mental Health Screen

You can add screenshots here later for a more attractive GitHub repository.

📌 Advantages of the Project
Centralized access to multiple campus services
Improves academic and campus communication
Supports students using AI-based assistance
Reduces dependency on manual processes
Enhances safety and emergency communication
Improves student support and well-being
Provides scalable and modern campus management
⚠️ Limitations

Although the project is functional and useful, it has some limitations:

Requires stable internet connection
AI-generated responses may not always be perfectly accurate
Performance may vary on low-end devices
Security depends on proper Firebase configuration
Some advanced navigation features can be improved further
Scalability for large campuses may require optimization
🔮 Future Enhancements

Future improvements planned for the system include:

Google Maps Integration
Face Recognition Attendance
Voice-Based Navigation
Push Notifications
Online Appointment Booking
Advanced AI Chatbot Expansion
Better Lost & Found Image Matching
Multilingual Support
Improved Indoor Navigation
Smarter Recommendation Features
🧾 Academic Information

Project Title: Smart Campus AI Platform
Project Type: Major Project
Degree: Bachelor of Technology
Branch: Computer Science and Engineering (Artificial Intelligence and Machine Learning)
Institution: Nalla Narasimha Reddy Education Society’s Group of Institutions
Academic Year: 2025–2026

👩‍💻 Author

Lodi Tharuni
B.Tech – CSE (AI & ML)

📌 GitHub: tharuni2503

📚 References

This project is based on concepts, tools, and technologies referenced in:

Flutter Official Documentation
Firebase Official Documentation
Dart Official Documentation
Groq AI Platform
AI in Education & Smart Campus Systems
Cloud-based Student Information Systems
Mobile Application Frameworks
📜 License

This project is developed for academic and educational purposes only.
