# 🚀 C-QUBE (Campus × Club × Connect)

**C-QUBE** is a modern, cross-platform Flutter application designed to bridge the gap between campus students and student-led clubs. It provides an all-in-one platform for managing club activities, hosting campus events, conducting recruitment drives, uploading gallery media, and handling student club membership claims.

---

## ✨ Key Features

### 🏢 For Club Leads & Coordinators
- **Simplified Club Dashboard**: Easy navigation, top-right profile avatar, and instant session logout.
- **Clean Activity Feed**: Post announcements and achievements with image attachments (no clutter from likes or comments).
- **Native Gallery & Media Upload**: Pick photos and videos directly from device gallery with pre-upload previews.
- **Event Hosting & Calendar Sync**: Create campus events with venue, time, capacity, and category details that automatically sync to the shared campus calendar.
- **Streamlined Open Recruitment**: Create recruitment drives with title, positions, eligibility, skills, and deadlines (no length questionnaire forms needed).
- **Membership Claim Approvals**: Review and approve or reject student membership claim requests with instant notification delivery.

### 🎓 For Campus Students
- **Campus Activity Feed**: Stay updated with recent club announcements, achievements, and notices across campus.
- **Campus Events Calendar**: Discover upcoming workshops, hackathons, and seminars. Filter between all campus events and registered events.
- **Club Discovery & Public Profiles**: Follow clubs, view detailed club profiles, active recruitment drives, and media galleries.
- **Membership Claim Request**: Submit a membership claim request to join your respective club with status tracking (`Pending ⏳`, `Approved ✓`, `Rejected`).
- **Session Persistence & Profile Management**: Persistent login session using local storage (`SharedPreferences`) for seamless login/logout.

---

## 🎨 Design System
- **Pastel Color Palette**: Soft slate blue, warm amber, soft violet, sage green, and clean card borders designed for maximum visual appeal and low eye-strain.
- **Typography & Responsive UI**: Clean Google Fonts typography with smooth dark and light mode support.

---

## 🛠️ Technology Stack

- **Frontend Framework**: [Flutter](https://flutter.dev/) (Dart)
- **State Management**: [Provider](https://pub.dev/packages/provider) (`AuthState`, `ClubState`, `StudentState`, `ThemeProvider`)
- **Device Integration**: [`image_picker`](https://pub.dev/packages/image_picker) for device photo & video selection
- **Calendar & Formatting**: [`table_calendar`](https://pub.dev/packages/table_calendar), [`intl`](https://pub.dev/packages/intl)
- **Local Session Persistence**: [`shared_preferences`](https://pub.dev/packages/shared_preferences)
- **Backend Architecture**: Designed for [Supabase](https://supabase.com/) Auth & Storage integration with repository abstraction layer.

---

## 📁 Project Architecture & Directory Structure

```text
lib/
├── core/
│   ├── constants/       # AppColors, AppTypography, AppConstants
│   ├── theme/           # Light & Dark theme definitions, ThemeProvider
│   └── utils/           # DateFormatter, ValidatorUtils
├── models/              # ClubModel, EventModel, PostModel, UserModel, etc.
├── repositories/        # Repository interfaces & Mock implementations
├── services/            # MockDataStore & Data providers
├── shared/              # Reusable UI widgets (CustomButton, CustomTextField, TagChip)
├── state/               # AuthState, ClubState, StudentState
└── features/
    ├── auth/            # Login, Registration, Forgot Password, Club Approval Request
    ├── club/            # Dashboard, Activity, Calendar, Gallery, Recruitment, Claims
    ├── student/         # Home Feed, Discover Clubs, Calendar, Profile, Genie Assistant
    └── welcome/         # Role Selection Screen
