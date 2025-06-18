# 🚨 Smart Unmanned Store: YOLO AI Abnormal Behavior Detection & Alert App

**Development Period**
* **Overall Development Period**: 2025.04.29 - 2025.06.20
* **UI Implementation**: 2025.05.02 - 2025.05.15
* **Feature Implementation**: 2025.05.13 - 2025.06.20


## 1. Project Introduction
---

This project is an unmanned store abnormal behavior detection application based on YOLO.

### YOLO-based Abnormal Behavior Detection & Alert
* The YOLO model analyzes CCTV footage from unmanned stores in real-time to detect abnormal behavior.
* When abnormal behavior is detected, the application's notification window displays the time of occurrence and the details of the abnormal behavior.
* Target Abnormal Behaviors: Falling, Theft, Smoking, Fighting.

### CCTV Video Storage & Provision
* CCTV clips and screenshots from the moment abnormal behavior is detected are automatically saved.
* These saved clips and screenshots allow for quick understanding of the abnormal behavior and facilitate prompt follow-up actions.


## 2. Development Environment
---

<img alt="Figma"src="https://img.shields.io/badge/Figma-F24E1E.svg?style=for-the-badge&logo=Figma&logoColor=white" height="20"/> <img alt="Flutter"src="https://img.shields.io/badge/Flutter-02569B.svg?style=for-the-badge&logo=Flutter&logoColor=white" height="20"/>

* Design: Figma
* Front-End: Flutter
* Back-End: FastAPI
* Database: SQLite
* Collaboration Tools: GitHub, Notion


## 3. Technology Stack Selection Rationale
---

### Flutter
Our team chose the Flutter framework for front-end development. The primary reason was its ability to maximize development efficiency by supporting various platforms such as web, Android, and iOS from a single codebase. Beyond this, Flutter offered the following technical strengths that contributed to achieving our project goals:

* **High Development Productivity (Hot Reload & Hot Restart)**
Flutter's Hot Reload instantly reflects code changes without needing to restart the app, accelerating development for UI adjustments or bug fixes. Additionally, Hot Restart provides quick restarts while resetting the app's state, saving significant development time.
* **Consistent UI/UX (Customizable Widgets & Skia Engine)**
Flutter offers a rich widget library based on Google's Material Design and Apple's Cupertino design systems. This enabled us to build a consistent UI across all platforms. Furthermore, by using its own rendering engine, Skia, Flutter directly draws the UI independently of the OS, resulting in fewer compatibility issues across different OS versions or device types and providing an excellent user experience (UX).
* **Outstanding Performance (Native Compiled Code)**
Flutter apps compile Dart code directly into ARM or Intel machine code. This delivers high performance comparable to native apps, enabling the implementation of fast and responsive applications.
* **Considering Team Proficiency**
For team members with limited prior front-end development experience, Flutter's intuitive widget structure and clear documentation significantly lowered the learning curve, enabling efficient development within a short period.

### FastAPI
Our team selected FastAPI as the backend framework. We determined that FastAPI, as a modern Python web framework, was well-suited for our project requirements due to its fast development speed, high performance, and intuitive code structure.

* **Team's Python Proficiency and High Productivity**
All our team members were familiar with Python, allowing us to quickly begin development without spending much time learning a new framework. FastAPI seamlessly integrates Python's syntax and type hints, enabling us to naturally apply existing Python knowledge to backend development.
* **Fast Development Speed & Automatic Documentation**
FastAPI declares APIs based on Python's type hints, which provides automatic documentation features via Swagger UI and ReDoc. This was highly useful during API testing and client integration, playing a significant role in boosting development productivity.
* **High Performance (Asynchronous Processing Support)**
Built on Starlette, FastAPI actively supports Python's `async`/`await` syntax. This allowed for efficient handling of I/O-bound tasks and demonstrated excellent performance in concurrent user processing.
* **Concise and Clear Code Structure**
FastAPI enables more structured code than Flask and lighter, more concise code than Django. This significantly improved the maintainability and readability of our backend code.
* **Automatic Data Validation and Serialization (Pydantic-based)**
FastAPI automatically handles input data validation and serialization through Pydantic. This was advantageous for managing complex data structures and effectively preventing user input errors.
* **Excellent Documentation and Community Support**
FastAPI boasts well-organized official documentation and an active open-source community, which allowed for quick problem-solving when issues arose.


## 4. Project Setup and Execution
---

### Required Tools
* Flutter SDK: 3.32.0
* Git: Required for repository cloning
* IDE: VSCode (other options available)

### Project Installation

**1. Clone the Repository**
Clone the project repository to your local machine:
```bash
git clone https://github.com/embedded-final-project-group-A/CCTV_FE.git
cd CCTV_FE
```

**2. Install Dependencies**
Navigate into the project folder and install all necessary Flutter packages and dependencies:
```bash
flutter pub get
```

**3. Check Available Devices**
You can check the list of currently available devices or platforms:
```bash
flutter devices
```

### Running the Application
Select a ready device or platform and execute the following command to run the application:
```bash
flutter run
```

### Web Browser Execution (Recommended)
This project was developed with the assumption of being run in a web browser.
```bash
flutter run -d chrome
```

If you wish to run it on an Android emulator, connect a physical Android device with USB debugging enabled and use the `flutter run` command. Please note that some features may be limited when running on an Android emulator.
iOS simulator is not supported.

