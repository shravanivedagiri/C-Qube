"use client";

import { AppShell } from "@/components/layout/app-shell";
import { ADMIN_NAV } from "@/lib/nav-config";

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  return <AppShell navItems={ADMIN_NAV}>{children}</AppShell>;
}
