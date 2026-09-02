import {
  BarChart3,
  Bell,
  Calendar,
  Compass,
  Flag,
  Home,
  Image as ImageIcon,
  Inbox,
  LayoutDashboard,
  Settings,
  Sparkles,
  UserCircle,
  UserPlus,
  Users,
} from "lucide-react";

export const STUDENT_NAV = [
  { href: "/home", label: "Home", icon: Home },
  { href: "/discover", label: "Discover", icon: Compass },
  { href: "/events", label: "Events", icon: Calendar },
  { href: "/calendar", label: "Calendar", icon: Calendar },
  { href: "/friends", label: "Friends", icon: Users },
  { href: "/notifications", label: "Notifications", icon: Bell },
  { href: "/genie", label: "Ask Genie", icon: Sparkles },
  { href: "/profile", label: "Profile", icon: UserCircle },
] as const;

/** Compact set shown in the mobile bottom nav. */
export const STUDENT_MOBILE_NAV = [
  { href: "/home", label: "Home", icon: Home },
  { href: "/discover", label: "Discover", icon: Compass },
  { href: "/calendar", label: "Calendar", icon: Calendar },
  { href: "/genie", label: "Genie", icon: Sparkles },
  { href: "/profile", label: "Profile", icon: UserCircle },
] as const;

export const ADMIN_NAV = [
  { href: "/admin/dashboard", label: "Dashboard", icon: LayoutDashboard },
  { href: "/admin/club-requests", label: "Club Requests", icon: Inbox },
  { href: "/admin/calendar", label: "Calendar", icon: Calendar },
  { href: "/admin/reports", label: "Reports", icon: Flag },
  { href: "/admin/settings", label: "Settings", icon: Settings },
] as const;

export const CLUB_NAV = [
  { href: "/dashboard", label: "Dashboard", icon: LayoutDashboard },
  { href: "/club-profile", label: "Club Profile", icon: UserCircle },
  { href: "/club-events", label: "Events", icon: Calendar },
  { href: "/gallery", label: "Gallery", icon: ImageIcon },
  { href: "/recruitment", label: "Recruitment", icon: UserPlus },
  { href: "/analytics", label: "Analytics", icon: BarChart3 },
  { href: "/settings", label: "Settings", icon: Settings },
] as const;
