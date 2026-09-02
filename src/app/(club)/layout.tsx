"use client";

import { AppShell } from "@/components/layout/app-shell";
import { CLUB_NAV } from "@/lib/nav-config";

export default function ClubLayout({ children }: { children: React.ReactNode }) {
  return <AppShell navItems={CLUB_NAV}>{children}</AppShell>;
}
