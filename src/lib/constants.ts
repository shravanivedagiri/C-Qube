export const DEPARTMENTS = [
  "Computer Science",
  "Information Technology",
  "Electronics & Communication",
  "Electrical Engineering",
  "Mechanical Engineering",
  "Civil Engineering",
  "Business Administration",
  "Design",
  "Commerce",
  "Other",
];

export const YEARS = ["1st Year", "2nd Year", "3rd Year", "4th Year", "Postgraduate"];

export const INTERESTS = [
  "AI/ML",
  "Web Development",
  "App Development",
  "Robotics",
  "Cybersecurity",
  "Finance",
  "Entrepreneurship",
  "Music",
  "Dance",
  "Photography",
  "Sports",
  "Design",
  "Literature",
];

export const CLUB_CATEGORIES = [
  "Technical",
  "Cultural",
  "Sports",
  "Arts & Design",
  "Business",
  "Social Service",
  "Literary",
  "Other",
];

/**
 * Every C-QUBE account must use this email domain. This client-side
 * check is for fast inline feedback only — the backend re-validates it
 * (see backend/src/services/auth.service.ts) since a frontend-only
 * check is trivially bypassed.
 */
export const ALLOWED_EMAIL_DOMAIN = "bmsce.ac.in";

export function isAllowedCampusEmail(email: string): boolean {
  return email.trim().toLowerCase().endsWith(`@${ALLOWED_EMAIL_DOMAIN}`);
}

export const EVENT_CATEGORIES = [
  "Technical",
  "Cultural",
  "Sports",
  "Workshop",
  "Competition",
  "Seminar",
  "Social",
  "Other",
] as const;
