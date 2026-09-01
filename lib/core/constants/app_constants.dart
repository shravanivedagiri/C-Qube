enum UserRole { student, club }

enum EventCategory {
  technical,
  cultural,
  sports,
  workshop,
  competition,
  seminar,
  social,
  other,
}

enum ClubCategory {
  technical,
  cultural,
  sports,
  entrepreneurship,
  arts,
  social,
  academic,
}

enum PostType {
  announcement,
  generalUpdate,
  achievement,
  recruitment,
  eventAnnouncement,
}

enum ApplicationStatus {
  applied,
  underReview,
  shortlisted,
  selected,
  rejected,
}

enum NotificationType {
  friend,
  event,
  club,
  friendActivity,
}

enum MediaType {
  photo,
  video,
}

class AppConstants {
  static const List<String> departments = [
    'Computer Science & Engineering',
    'Information Technology',
    'Electronics & Communication',
    'Mechanical Engineering',
    'Electrical & Electronics',
    'Civil Engineering',
    'Biotechnology',
    'Design & Architecture',
    'Management Studies',
  ];

  static const List<String> years = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    'Postgraduate / Masters',
  ];

  static const List<String> allInterests = [
    'AI/ML',
    'Web Development',
    'App Development',
    'Robotics',
    'Cybersecurity',
    'Finance',
    'Entrepreneurship',
    'Music',
    'Dance',
    'Photography',
    'Sports',
    'Design',
    'Literature',
    'Gaming',
    'Cloud Computing',
  ];

  static const List<String> allSkills = [
    'Flutter & Dart',
    'Python',
    'React',
    'Node.js',
    'Figma UI/UX',
    'Event Management',
    'Public Speaking',
    'Content Writing',
    'Video Editing',
    'Guitar / Vocals',
    'Cinematography',
    'Data Science',
    'Arduino & IoT',
  ];
}
