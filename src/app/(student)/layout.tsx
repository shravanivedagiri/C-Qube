"use client";

import { AppShell } from "@/components/layout/app-shell";
import { NotificationBell } from "@/components/shared/notification-bell";
import { STUDENT_MOBILE_NAV, STUDENT_NAV } from "@/lib/nav-config";

export default function StudentLayout({ children }: { children: React.ReactNode }) {
  return (
    <AppShell navItems={STUDENT_NAV} mobileNavItems={STUDENT_MOBILE_NAV} headerActions={<NotificationBell />}>
      {children}
    </AppShell>
  );
}
