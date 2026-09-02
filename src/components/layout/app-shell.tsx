"use client";

import { LogOut, type LucideIcon } from "lucide-react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import type { ReactNode } from "react";
import { toast } from "sonner";
import { Avatar } from "@/components/ui/avatar";
import { Skeleton } from "@/components/ui/skeleton";
import { useCurrentProfile } from "@/hooks/use-current-profile";
import { cn } from "@/lib/utils";
import { AuthService } from "@/services/auth-service";
import { ThemeToggle } from "@/components/shared/theme-toggle";
import { Wordmark } from "@/components/shared/wordmark";

type NavItem = { href: string; label: string; icon: LucideIcon };

function isActive(pathname: string, href: string) {
  return pathname === href || pathname.startsWith(href + "/");
}

export function AppShell({
  navItems,
  mobileNavItems,
  children,
  headerActions,
}: {
  navItems: readonly NavItem[];
  mobileNavItems?: readonly NavItem[];
  children: ReactNode;
  headerActions?: ReactNode;
}) {
  const pathname = usePathname();
  const router = useRouter();
  const { profile, loading } = useCurrentProfile();
  const mobileItems = mobileNavItems ?? navItems.slice(0, 5);

  async function handleLogout() {
    await AuthService.signOut();
    toast.success("Logged out.");
    router.push("/");
    router.refresh();
  }

  return (
    <div className="flex min-h-screen bg-background">
      {/* Desktop sidebar */}
      <aside className="sticky top-0 hidden h-screen w-64 shrink-0 flex-col border-r border-border bg-surface px-4 py-6 sm:flex">
        <Link href="/" className="px-2">
          <Wordmark className="text-base" />
        </Link>

        <nav className="mt-8 flex flex-1 flex-col gap-1">
          {navItems.map((item) => {
            const active = isActive(pathname, item.href);
            return (
              <Link
                key={item.href}
                href={item.href}
                className={cn(
                  "flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-medium transition",
                  active
                    ? "bg-brand text-brand-foreground"
                    : "text-muted hover:bg-border/40 hover:text-foreground"
                )}
              >
                <item.icon className="h-4.5 w-4.5" />
                {item.label}
              </Link>
            );
          })}
        </nav>

        <div className="mt-4 flex items-center gap-3 rounded-xl border border-border p-3">
          {loading ? (
            <Skeleton className="h-9 w-9 rounded-full" />
          ) : (
            <Avatar src={profile?.avatar_url} name={profile?.name ?? "You"} size={36} />
          )}
          <div className="min-w-0 flex-1">
            {loading ? (
              <Skeleton className="h-3 w-20" />
            ) : (
              <p className="truncate text-sm font-medium">{profile?.name ?? "—"}</p>
            )}
            <p className="truncate text-xs text-muted">
              {profile?.role === "club"
                ? "Club account"
                : profile?.role === "admin"
                  ? "Admin"
                  : "Student"}
            </p>
          </div>
          <button
            aria-label="Log out"
            onClick={handleLogout}
            className="rounded-lg p-1.5 text-muted transition hover:bg-danger-soft hover:text-danger"
          >
            <LogOut className="h-4 w-4" />
          </button>
        </div>
      </aside>

      <div className="flex min-h-screen flex-1 flex-col">
        {/* Top bar */}
        <header className="sticky top-0 z-30 flex h-16 items-center justify-between border-b border-border bg-surface/80 px-4 backdrop-blur sm:px-8">
          <Link href="/" className="sm:hidden">
            <Wordmark className="text-base" />
          </Link>
          <div className="hidden flex-1 sm:block" />
          <div className="flex items-center gap-3">
            {headerActions}
            <ThemeToggle />
          </div>
        </header>

        <main className="flex-1 px-4 pb-24 pt-6 sm:px-8 sm:pb-10">{children}</main>
      </div>

      {/* Mobile bottom nav */}
      <nav className="fixed inset-x-0 bottom-0 z-30 flex items-center justify-around border-t border-border bg-surface/95 py-2 backdrop-blur sm:hidden">
        {mobileItems.map((item) => {
          const active = isActive(pathname, item.href);
          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                "flex flex-col items-center gap-0.5 rounded-lg px-3 py-1.5 text-[11px] font-medium transition",
                active ? "text-brand" : "text-muted"
              )}
            >
              <item.icon className="h-5 w-5" />
              {item.label}
            </Link>
          );
        })}
      </nav>
    </div>
  );
}
