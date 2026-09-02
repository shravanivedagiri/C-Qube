"use client";

import { AppShell } from "@/components/layout/app-shell";
import { NotificationBell } from "@/components/shared/notification-bell";
import { CLUB_NAV } from "@/lib/nav-config";

export default function ClubLayout({ children }: { children: React.ReactNode }) {
  return (
    <AppShell navItems={CLUB_NAV} headerActions={<NotificationBell href="/club-notifications" />}>
      {children}
    </AppShell>
  );
}
