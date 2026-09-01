import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../models/club_model.dart';
import '../models/event_model.dart';
import '../models/post_model.dart';
import '../models/gallery_item_model.dart';
import '../models/recruitment_model.dart';
import '../models/friend_model.dart';
import '../models/notification_model.dart';
import '../models/genie_message_model.dart';
import '../models/club_join_request_model.dart';

class MockDataStore {
  static final MockDataStore _instance = MockDataStore._internal();
  factory MockDataStore() => _instance;
  MockDataStore._internal() {
    _initData();
  }

  // Collections
  List<UserModel> students = [];
  List<ClubModel> clubs = [];
  List<ClubRegistrationRequest> clubRequests = [];
  List<ClubJoinRequest> clubJoinRequests = [];
  List<EventModel> events = [];
  List<PostModel> posts = [];
  List<GalleryItemModel> galleryItems = [];
  List<RecruitmentDrive> recruitmentDrives = [];
  List<RecruitmentApplication> recruitmentApplications = [];
  List<Friendship> friendships = [];
  List<FriendActivityItem> friendActivities = [];
  List<NotificationModel> notifications = [];
  List<GenieMessageModel> genieMessages = [];

  // Active Current User
  UserModel? currentUser;
  ClubModel? currentClub;

  void _initData() {
    final now = DateTime.now();

    // 1. Initial Students
    students = [
      UserModel(
        id: 'student_1',
        name: 'Rahul Sharma',
        email: 'rahul.sharma@campus.edu',
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=400&q=80',
        role: UserRole.student,
        department: 'Computer Science & Engineering',
        year: '3rd Year',
        bio: 'Passionate about Flutter, AI & building student communities. GDSC Core Team Member.',
        interests: ['AI/ML', 'App Development', 'Web Development', 'Robotics'],
        skills: ['Flutter & Dart', 'Python', 'Figma UI/UX'],
        goals: 'Win Smart India Hackathon & launch an open-source campus tool.',
        points: 420,
        joinedClubIds: ['club_1', 'club_2'],
        registeredEventIds: ['event_1', 'event_2'],
        friendIds: ['student_2', 'student_3'],
      ),
      UserModel(
        id: 'student_2',
        name: 'Ananya Sen',
        email: 'ananya.sen@campus.edu',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80',
        role: UserRole.student,
        department: 'Information Technology',
        year: '2nd Year',
        bio: 'Visual designer and aspiring photographer. Always with a camera around campus.',
        interests: ['Photography', 'Design', 'Literature', 'Music'],
        skills: ['Figma UI/UX', 'Video Editing', 'Cinematography'],
        goals: 'Lead the college media team and publish a campus photo-book.',
        points: 360,
        joinedClubIds: ['club_3'],
        registeredEventIds: ['event_3'],
        friendIds: ['student_1', 'student_4'],
      ),
      UserModel(
        id: 'student_3',
        name: 'Arjun Patel',
        email: 'arjun.patel@campus.edu',
        avatarUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=400&q=80',
        role: UserRole.student,
        department: 'Electronics & Communication',
        year: '3rd Year',
        bio: 'Hardware geek, IoT enthusiast and Robotics head. Building smart campus devices.',
        interests: ['Robotics', 'AI/ML', 'Cybersecurity', 'Gaming'],
        skills: ['Arduino & IoT', 'Python', 'Data Science'],
        goals: 'Build an autonomous campus delivery rover.',
        points: 510,
        joinedClubIds: ['club_2', 'club_4'],
        registeredEventIds: ['event_1', 'event_4'],
        friendIds: ['student_1'],
      ),
      UserModel(
        id: 'student_4',
        name: 'Priya Verma',
        email: 'priya.verma@campus.edu',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
        role: UserRole.student,
        department: 'Management Studies',
        year: '2nd Year',
        bio: 'Startup enthusiast & event manager. Passionate about youth leadership and dance.',
        interests: ['Entrepreneurship', 'Dance', 'Finance', 'Sports'],
        skills: ['Event Management', 'Public Speaking', 'Content Writing'],
        goals: 'Found a campus incubator chapter and host TEDx.',
        points: 290,
        joinedClubIds: ['club_4', 'club_5'],
        registeredEventIds: ['event_4', 'event_5'],
        friendIds: ['student_2'],
      ),
    ];

    currentUser = students[0];

    // 2. Clubs (At least 6 distinct clubs)
    clubs = [
      ClubModel(
        id: 'club_1',
        name: 'GDSC (Developer Student Club)',
        email: 'gdsc@campus.edu',
        logoUrl: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=200&q=80',
        bannerUrl: 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=1200&q=80',
        about: 'Google Developer Student Clubs are university based community groups for students interested in Google developer technologies, mobile app development, and cloud computing.',
        category: ClubCategory.technical,
        department: 'Computer Science & Engineering',
        coordinatorName: 'Vikram Mehta',
        coordinatorEmail: 'vikram.mehta@campus.edu',
        contactInfo: '+91 98765 43210 | gdsc@campus.edu',
        socialLinks: {
          'GitHub': 'https://github.com/gdsc-campus',
          'LinkedIn': 'https://linkedin.com/company/gdsc-campus',
          'Instagram': 'https://instagram.com/gdsc_campus'
        },
        memberCount: 248,
        isBeginnerFriendly: true,
        followerStudentIds: ['student_1', 'student_2', 'student_3', 'student_4'],
        memberStudentIds: ['student_1'],
      ),
      ClubModel(
        id: 'club_2',
        name: 'AIRS (AI & Robotics Society)',
        email: 'airs@campus.edu',
        logoUrl: 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?auto=format&fit=crop&w=200&q=80',
        bannerUrl: 'https://images.unsplash.com/photo-1531746790731-6c087fecd65a?auto=format&fit=crop&w=1200&q=80',
        about: 'Pioneering artificial intelligence research, machine learning competitions, combat robotics, and autonomous systems at the college level.',
        category: ClubCategory.technical,
        department: 'Electronics & Communication',
        coordinatorName: 'Dr. S. Nair',
        coordinatorEmail: 'nair.airs@campus.edu',
        contactInfo: 'Lab 402, Tech Block | airs@campus.edu',
        socialLinks: {'Website': 'https://airs-robotics.org'},
        memberCount: 175,
        isBeginnerFriendly: true,
        followerStudentIds: ['student_1', 'student_3'],
        memberStudentIds: ['student_1', 'student_3'],
      ),
      ClubModel(
        id: 'club_3',
        name: 'Lumière Photography Club',
        email: 'lumiere@campus.edu',
        logoUrl: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&w=200&q=80',
        bannerUrl: 'https://images.unsplash.com/photo-1452784444945-3f422708ee5c?auto=format&fit=crop&w=1200&q=80',
        about: 'Capturing moments, creating stories. Lumière is the official photography and cinematography club covering campus events, photowalks, and exhibitions.',
        category: ClubCategory.arts,
        department: 'Design & Architecture',
        coordinatorName: 'Sanjay Rawat',
        coordinatorEmail: 'sanjay.lumiere@campus.edu',
        contactInfo: 'Studio 105, Arts Block | lumiere@campus.edu',
        socialLinks: {'Instagram': '@lumiere_captures'},
        memberCount: 130,
        isBeginnerFriendly: true,
        followerStudentIds: ['student_2'],
        memberStudentIds: ['student_2'],
      ),
      ClubModel(
        id: 'club_4',
        name: 'E-Cell (Entrepreneurship Cell)',
        email: 'ecell@campus.edu',
        logoUrl: 'https://images.unsplash.com/photo-1559136555-9303baea8ebd?auto=format&fit=crop&w=200&q=80',
        bannerUrl: 'https://images.unsplash.com/photo-1515187029135-18ee286d815b?auto=format&fit=crop&w=1200&q=80',
        about: 'Fostering the spirit of entrepreneurship and innovation. Organizing startup pitch days, founder talks, venture capital mixers, and incubator drives.',
        category: ClubCategory.entrepreneurship,
        department: 'Management Studies',
        coordinatorName: 'Rohan Deshmukh',
        coordinatorEmail: 'rohan.ecell@campus.edu',
        contactInfo: 'Incubation Hub | ecell@campus.edu',
        socialLinks: {'LinkedIn': 'https://linkedin.com/company/ecell-campus'},
        memberCount: 210,
        isBeginnerFriendly: false,
        followerStudentIds: ['student_3', 'student_4'],
        memberStudentIds: ['student_4'],
      ),
      ClubModel(
        id: 'club_5',
        name: 'Verve Dance & Cultural Crew',
        email: 'verve@campus.edu',
        logoUrl: 'https://images.unsplash.com/photo-1547153760-18fc86324498?auto=format&fit=crop&w=200&q=80',
        bannerUrl: 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?auto=format&fit=crop&w=1200&q=80',
        about: 'The premier college dance and performing arts troupe. Bringing high-energy hip-hop, classical fusion, and street choreography to national competitions.',
        category: ClubCategory.cultural,
        department: 'All Departments',
        coordinatorName: 'Kavita Joshi',
        coordinatorEmail: 'kavita.verve@campus.edu',
        contactInfo: 'Auditorium Hall | verve@campus.edu',
        socialLinks: {'Instagram': '@verve_dancecrew'},
        memberCount: 95,
        isBeginnerFriendly: true,
        followerStudentIds: ['student_4'],
        memberStudentIds: ['student_4'],
      ),
      ClubModel(
        id: 'club_6',
        name: 'Rotaract Youth Club',
        email: 'rotaract@campus.edu',
        logoUrl: 'https://images.unsplash.com/photo-1582213782179-e0d53f98f2ca?auto=format&fit=crop&w=200&q=80',
        bannerUrl: 'https://images.unsplash.com/photo-1593113598332-cd288d649433?auto=format&fit=crop&w=1200&q=80',
        about: 'Youth in action. Leading community welfare, tree plantation drives, blood donation camps, and youth empowerment seminars across the state.',
        category: ClubCategory.social,
        department: 'All Departments',
        coordinatorName: 'Aditya Mathur',
        coordinatorEmail: 'aditya.rotaract@campus.edu',
        contactInfo: 'SAC Room 12 | rotaract@campus.edu',
        socialLinks: {'Website': 'https://rotaractcampus.org'},
        memberCount: 160,
        isBeginnerFriendly: true,
        followerStudentIds: ['student_1'],
        memberStudentIds: [],
      ),
    ];

    currentClub = clubs[0];

    // 3. Events
    events = [
      EventModel(
        id: 'event_1',
        clubId: 'club_1',
        clubName: 'GDSC (Developer Student Club)',
        clubLogoUrl: clubs[0].logoUrl,
        title: 'HackCampus 2026: 36-Hour National Hackathon',
        description: 'Join 500+ innovators across the nation for an intensive 36-hour sprint. Build AI, Web3, or Mobile solutions with mentorship from top industry engineers and \$10,000 in prizes!',
        bannerUrl: 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=1200&q=80',
        date: now.add(const Duration(days: 3)),
        startTime: DateTime(now.year, now.month, now.day + 3, 9, 0),
        endTime: DateTime(now.year, now.month, now.day + 4, 21, 0),
        location: 'Campus Main Auditorium & Tech Lab 1',
        capacity: 250,
        registeredStudentIds: ['student_1', 'student_3'],
        registrationDeadline: now.add(const Duration(days: 2)),
        category: EventCategory.competition,
        department: 'Computer Science & Engineering',
        isOnline: false,
        isBeginnerFriendly: true,
        organizerName: 'GDSC Core Team',
      ),
      EventModel(
        id: 'event_2',
        clubId: 'club_2',
        clubName: 'AIRS (AI & Robotics Society)',
        clubLogoUrl: clubs[1].logoUrl,
        title: 'Generative AI & LLM Architecture Workshop',
        description: 'Hands-on deep dive into transformer architectures, prompt tuning, and fine-tuning open-source LLMs locally on GPU clusters.',
        bannerUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?auto=format&fit=crop&w=1200&q=80',
        date: now.add(const Duration(days: 5)),
        startTime: DateTime(now.year, now.month, now.day + 5, 14, 0),
        endTime: DateTime(now.year, now.month, now.day + 5, 18, 0),
        location: 'Seminar Hall B, Block 3',
        capacity: 120,
        registeredStudentIds: ['student_1'],
        registrationDeadline: now.add(const Duration(days: 4)),
        category: EventCategory.workshop,
        department: 'Electronics & Communication',
        isOnline: false,
        isBeginnerFriendly: true,
        organizerName: 'AIRS AI Division',
      ),
      EventModel(
        id: 'event_3',
        clubId: 'club_3',
        clubName: 'Lumière Photography Club',
        clubLogoUrl: clubs[2].logoUrl,
        title: 'Golden Hour Campus Photo-Walk & Editing Session',
        description: 'Explore the scenic architecture of the campus during golden hour, followed by a live Lightroom preset workshop in the design studio.',
        bannerUrl: 'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?auto=format&fit=crop&w=1200&q=80',
        date: now.add(const Duration(days: 1)),
        startTime: DateTime(now.year, now.month, now.day + 1, 16, 30),
        endTime: DateTime(now.year, now.month, now.day + 1, 19, 30),
        location: 'Clock Tower Courtyard',
        capacity: 45,
        registeredStudentIds: ['student_2'],
        registrationDeadline: now.add(const Duration(days: 1)),
        category: EventCategory.workshop,
        department: 'Design & Architecture',
        isOnline: false,
        isBeginnerFriendly: true,
        organizerName: 'Lumière Team',
      ),
      EventModel(
        id: 'event_4',
        clubId: 'club_4',
        clubName: 'E-Cell (Entrepreneurship Cell)',
        clubLogoUrl: clubs[3].logoUrl,
        title: 'Venture Pitch 2026: Angel Investor Showcase',
        description: 'Selected student startup teams pitch to real venture capitalists and angel networks. Total grant pool of \$25,000.',
        bannerUrl: 'https://images.unsplash.com/photo-1475721027785-f74eccf877e2?auto=format&fit=crop&w=1200&q=80',
        date: now.add(const Duration(days: 8)),
        startTime: DateTime(now.year, now.month, now.day + 8, 10, 0),
        endTime: DateTime(now.year, now.month, now.day + 8, 16, 0),
        location: 'Management Block Conference Center',
        capacity: 180,
        registeredStudentIds: ['student_3', 'student_4'],
        registrationDeadline: now.add(const Duration(days: 6)),
        category: EventCategory.competition,
        department: 'Management Studies',
        isOnline: false,
        isBeginnerFriendly: false,
        organizerName: 'E-Cell Executive Board',
      ),
      EventModel(
        id: 'event_5',
        clubId: 'club_5',
        clubName: 'Verve Dance & Cultural Crew',
        clubLogoUrl: clubs[4].logoUrl,
        title: 'Annual Inter-College Dance Fest Auditions',
        description: 'Auditions for the national touring team. Categories: Urban Hip-Hop, Contemporary, and Classical Fusion.',
        bannerUrl: 'https://images.unsplash.com/photo-1518834107812-67b0b7c58434?auto=format&fit=crop&w=1200&q=80',
        date: now.add(const Duration(days: 6)),
        startTime: DateTime(now.year, now.month, now.day + 6, 17, 0),
        endTime: DateTime(now.year, now.month, now.day + 6, 21, 0),
        location: 'Open Air Amphitheatre',
        capacity: 80,
        registeredStudentIds: ['student_4'],
        registrationDeadline: now.add(const Duration(days: 5)),
        category: EventCategory.cultural,
        department: 'All Departments',
        isOnline: false,
        isBeginnerFriendly: true,
        organizerName: 'Verve Captains',
      ),
      EventModel(
        id: 'event_6',
        clubId: 'club_6',
        clubName: 'Rotaract Youth Club',
        clubLogoUrl: clubs[5].logoUrl,
        title: 'Mega Campus Blood Donation & Health Camp',
        description: 'In association with Red Cross Society. Every donor receives an official certificate, goodie bag, and health report.',
        bannerUrl: 'https://images.unsplash.com/photo-1579154204601-01588f351e67?auto=format&fit=crop&w=1200&q=80',
        date: now.add(const Duration(days: 10)),
        startTime: DateTime(now.year, now.month, now.day + 10, 8, 30),
        endTime: DateTime(now.year, now.month, now.day + 10, 15, 0),
        location: 'Student Activity Center Ground Floor',
        capacity: 300,
        registeredStudentIds: [],
        registrationDeadline: now.add(const Duration(days: 9)),
        category: EventCategory.social,
        department: 'All Departments',
        isOnline: false,
        isBeginnerFriendly: true,
        organizerName: 'Rotaract Community Wing',
      ),
    ];

    // 4. Posts
    posts = [
      PostModel(
        id: 'post_1',
        clubId: 'club_1',
        clubName: 'GDSC (Developer Student Club)',
        clubLogoUrl: clubs[0].logoUrl,
        type: PostType.announcement,
        title: 'Registrations Open for HackCampus 2026!',
        content: 'We are thrilled to announce HackCampus 2026! Over \$10,000 in prize tracks, free food, swags and direct internship interviews with partner tech companies. Register before seats run out!',
        imageUrl: 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=800&q=80',
        eventReferenceId: 'event_1',
        likedStudentIds: ['student_1', 'student_2', 'student_3'],
        commentsCount: 24,
        sharesCount: 12,
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      PostModel(
        id: 'post_2',
        clubId: 'club_2',
        clubName: 'AIRS (AI & Robotics Society)',
        clubLogoUrl: clubs[1].logoUrl,
        type: PostType.achievement,
        title: 'AIRS Rover Team Takes 1st Place at State Robotics Cup!',
        content: 'Huge congratulations to our autonomous rover division for securing the Gold Trophy at the State Robotics Cup 2026! Proud moment for the college!',
        imageUrl: 'https://images.unsplash.com/photo-1531746790731-6c087fecd65a?auto=format&fit=crop&w=800&q=80',
        likedStudentIds: ['student_1', 'student_3', 'student_4'],
        commentsCount: 38,
        sharesCount: 19,
        createdAt: now.subtract(const Duration(hours: 18)),
      ),
      PostModel(
        id: 'post_3',
        clubId: 'club_3',
        clubName: 'Lumière Photography Club',
        clubLogoUrl: clubs[2].logoUrl,
        type: PostType.eventAnnouncement,
        title: 'Golden Hour Photo-Walk this Friday!',
        content: 'Grab your DSLRs, mirrorless cameras or smartphones and join us at the Clock Tower courtyard. Free presets and post-processing guide for all attendees.',
        imageUrl: 'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?auto=format&fit=crop&w=800&q=80',
        eventReferenceId: 'event_3',
        likedStudentIds: ['student_2', 'student_4'],
        commentsCount: 9,
        sharesCount: 5,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      PostModel(
        id: 'post_4',
        clubId: 'club_1',
        clubName: 'GDSC (Developer Student Club)',
        clubLogoUrl: clubs[0].logoUrl,
        type: PostType.recruitment,
        title: 'GDSC Core Team Recruitment 2026-2027 Open!',
        content: 'Are you passionate about Mobile, Web, AI, Design or Event PR? Join the core leadership team of GDSC. Apply via the Recruitment tab!',
        imageUrl: 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=800&q=80',
        likedStudentIds: ['student_1', 'student_2'],
        commentsCount: 15,
        sharesCount: 8,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];

    // 5. Gallery
    galleryItems = [
      GalleryItemModel(
        id: 'gal_1',
        clubId: 'club_1',
        title: 'Flutter Forward Hackathon 2025 Demo Day',
        mediaUrl: 'https://images.unsplash.com/photo-1531482615713-2afd69097998?auto=format&fit=crop&w=600&q=80',
        mediaType: MediaType.photo,
      ),
      GalleryItemModel(
        id: 'gal_2',
        clubId: 'club_1',
        title: 'Keynote by Google Developer Expert',
        mediaUrl: 'https://images.unsplash.com/photo-1475721027785-f74eccf877e2?auto=format&fit=crop&w=600&q=80',
        mediaType: MediaType.photo,
      ),
      GalleryItemModel(
        id: 'gal_3',
        clubId: 'club_1',
        title: 'Team Building & Icebreaker Session',
        mediaUrl: 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=600&q=80',
        mediaType: MediaType.photo,
      ),
      GalleryItemModel(
        id: 'gal_4',
        clubId: 'club_1',
        title: 'Hackathon Aftermovie 2025 (HD Highlight)',
        mediaUrl: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=600&q=80',
        mediaType: MediaType.video,
        thumbnailUrl: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?auto=format&fit=crop&w=600&q=80',
      ),
      GalleryItemModel(
        id: 'gal_5',
        clubId: 'club_1',
        title: 'Android & Jetpack Workshop in Lab 2',
        mediaUrl: 'https://images.unsplash.com/photo-1515187029135-18ee286d815b?auto=format&fit=crop&w=600&q=80',
        mediaType: MediaType.photo,
      ),
      GalleryItemModel(
        id: 'gal_6',
        clubId: 'club_1',
        title: 'Prize Distribution & Trophy Presentation',
        mediaUrl: 'https://images.unsplash.com/photo-1511578314322-379afb476865?auto=format&fit=crop&w=600&q=80',
        mediaType: MediaType.photo,
      ),
    ];

    // 6. Recruitment Drives
    recruitmentDrives = [
      RecruitmentDrive(
        id: 'rec_1',
        clubId: 'club_1',
        clubName: 'GDSC (Developer Student Club)',
        title: 'Core Leadership Team Recruitment 2026-27',
        description: 'We are recruiting domain leads and coordinators for the upcoming academic year. Open roles include App Development Lead, Web Lead, UI/UX Lead, and Event Operations Manager.',
        openPositions: ['Mobile Dev Lead (Flutter)', 'Web Dev Lead (React/Next)', 'UI/UX Design Lead', 'PR & Media Head'],
        eligibility: '1st, 2nd & 3rd Year Students from any branch',
        skillsRequired: ['Flutter/Dart', 'Figma', 'JavaScript/TypeScript', 'Leadership'],
        deadline: now.add(const Duration(days: 7)),
        questions: [
          'Why do you want to join the GDSC core leadership team?',
          'Share links to your GitHub / portfolio / previous projects.',
          'Describe a difficult technical problem you solved recently.'
        ],
        bannerUrl: 'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=800&q=80',
        applicantCount: 34,
      ),
      RecruitmentDrive(
        id: 'rec_2',
        clubId: 'club_2',
        clubName: 'AIRS (AI & Robotics Society)',
        title: 'Combat Robotics & Embedded Systems Division',
        description: 'Looking for builders with hands-on interest in PCB design, microcontrollers, ROS2, and 3D modeling for the upcoming National Robowars.',
        openPositions: ['Mechanical Designer (CAD)', 'Firmware Engineer (C++/Arduino)', 'ROS2 Perception Engineer'],
        eligibility: '2nd & 3rd Year Students',
        skillsRequired: ['SolidWorks/Fusion 360', 'C/C++', 'Arduino & ESP32'],
        deadline: now.add(const Duration(days: 12)),
        questions: [
          'What hardware projects or robots have you worked on?',
          'How comfortable are you with soldering and rapid prototyping?'
        ],
        bannerUrl: 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?auto=format&fit=crop&w=800&q=80',
        applicantCount: 19,
      ),
    ];

    // 7. Applications
    recruitmentApplications = [
      RecruitmentApplication(
        id: 'app_1',
        recruitmentId: 'rec_1',
        recruitmentTitle: 'Core Leadership Team Recruitment 2026-27',
        clubId: 'club_1',
        clubName: 'GDSC (Developer Student Club)',
        studentId: 'student_1',
        studentName: 'Rahul Sharma',
        studentEmail: 'rahul.sharma@campus.edu',
        studentDepartment: 'Computer Science & Engineering',
        studentYear: '3rd Year',
        positionApplied: 'Mobile Dev Lead (Flutter)',
        answers: {
          'Why do you want to join the GDSC core leadership team?': 'I love mentoring juniors in Flutter and want to scale campus app projects.',
          'Share links to your GitHub / portfolio / previous projects.': 'https://github.com/rahul-dev-campus',
          'Describe a difficult technical problem you solved recently.': 'Architected offline caching with SQLite and riverpod state sync.'
        },
        status: ApplicationStatus.shortlisted,
        notes: 'Strong portfolio and Flutter experience. Recommended for interview.',
      ),
      RecruitmentApplication(
        id: 'app_2',
        recruitmentId: 'rec_1',
        recruitmentTitle: 'Core Leadership Team Recruitment 2026-27',
        clubId: 'club_1',
        clubName: 'GDSC (Developer Student Club)',
        studentId: 'student_2',
        studentName: 'Ananya Sen',
        studentEmail: 'ananya.sen@campus.edu',
        studentDepartment: 'Information Technology',
        studentYear: '2nd Year',
        positionApplied: 'UI/UX Design Lead',
        answers: {
          'Why do you want to join the GDSC core leadership team?': 'To give our campus apps a cohesive and modern design system.',
          'Share links to your GitHub / portfolio / previous projects.': 'https://behance.net/ananya-design',
          'Describe a difficult technical problem you solved recently.': 'Designed complete design tokens for 15+ student screens.'
        },
        status: ApplicationStatus.underReview,
        notes: 'Impressive Figma portfolio.',
      ),
    ];

    // 8. Friendships
    friendships = [
      Friendship(id: 'fr_1', senderId: 'student_1', receiverId: 'student_2', status: 'accepted'),
      Friendship(id: 'fr_2', senderId: 'student_1', receiverId: 'student_3', status: 'accepted'),
      Friendship(id: 'fr_3', senderId: 'student_4', receiverId: 'student_1', status: 'pending'),
    ];

    // 9. Friend Activity Feed
    friendActivities = [
      FriendActivityItem(
        id: 'fa_1',
        studentId: 'student_3',
        studentName: 'Arjun Patel',
        studentAvatarUrl: students[2].avatarUrl,
        activityText: 'registered for HackCampus 2026',
        targetName: 'HackCampus 2026',
        activityType: 'registered_event',
        timestamp: now.subtract(const Duration(minutes: 45)),
      ),
      FriendActivityItem(
        id: 'fa_2',
        studentId: 'student_2',
        studentName: 'Ananya Sen',
        studentAvatarUrl: students[1].avatarUrl,
        activityText: 'joined Lumière Photography Club',
        targetName: 'Lumière Photography Club',
        activityType: 'joined_club',
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
      FriendActivityItem(
        id: 'fa_3',
        studentId: 'student_3',
        studentName: 'Arjun Patel',
        studentAvatarUrl: students[2].avatarUrl,
        activityText: 'won 1st Place in State Robotics Cup (+150 pts)',
        targetName: 'State Robotics Cup',
        activityType: 'achievement',
        timestamp: now.subtract(const Duration(hours: 19)),
      ),
      FriendActivityItem(
        id: 'fa_4',
        studentId: 'student_4',
        studentName: 'Priya Verma',
        studentAvatarUrl: students[3].avatarUrl,
        activityText: 'registered for Venture Pitch 2026',
        targetName: 'Venture Pitch 2026',
        activityType: 'registered_event',
        timestamp: now.subtract(const Duration(days: 1)),
      ),
    ];

    // 10. Notifications
    notifications = [
      NotificationModel(
        id: 'notif_1',
        userId: 'student_1',
        type: NotificationType.friend,
        title: 'Friend Request',
        body: 'Priya Verma sent you a friend request.',
        referenceId: 'student_4',
        isRead: false,
        actionStatus: 'pending',
        createdAt: now.subtract(const Duration(minutes: 15)),
      ),
      NotificationModel(
        id: 'notif_2',
        userId: 'student_1',
        type: NotificationType.event,
        title: 'Event Reminder',
        body: 'HackCampus 2026 begins in 3 days! Check your team registration.',
        referenceId: 'event_1',
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        id: 'notif_3',
        userId: 'student_1',
        type: NotificationType.club,
        title: 'Club Announcement',
        body: 'GDSC posted an update: Registrations Open for HackCampus 2026!',
        referenceId: 'post_1',
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      NotificationModel(
        id: 'notif_4',
        userId: 'student_1',
        type: NotificationType.friendActivity,
        title: 'Friend Activity',
        body: 'Arjun Patel registered for HackCampus 2026.',
        referenceId: 'event_1',
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
    ];

    // 11. Initial Genie Messages
    genieMessages = [
      GenieMessageModel(
        id: 'genie_welcome',
        text: "Hey Rahul! 👋 I'm **Genie**, your campus AI assistant.\n\nAsk me anything about upcoming events, club recruitments, beginner-friendly workshops, or what your friends are doing!",
        isUser: false,
        quickReplies: [
          'Which clubs match my AI/ML interest?',
          'What events are happening this weekend?',
          'Which clubs are beginner friendly?',
          'Which events are my friends registered for?'
        ],
      ),
    ];
  }
}
