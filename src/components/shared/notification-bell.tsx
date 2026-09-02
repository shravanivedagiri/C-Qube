"use client";

import { Bell } from "lucide-react";
import Link from "next/link";
import { useEffect, useState } from "react";
import { useCurrentProfile } from "@/hooks/use-current-profile";
import { NotificationService } from "@/services/notification-service";

export function NotificationBell({ href = "/notifications" }: { href?: string }) {
  const { user } = useCurrentProfile();
  const [count, setCount] = useState(0);

  useEffect(() => {
    if (!user) return;
    NotificationService.unreadCount(user.id).then(setCount);
    const interval = setInterval(() => {
      NotificationService.unreadCount(user.id).then(setCount);
    }, 30000);
    return () => clearInterval(interval);
  }, [user]);

  return (
    <Link
      href={href}
      aria-label="Notifications"
      className="relative inline-flex h-9 w-9 items-center justify-center rounded-full border border-border bg-surface text-foreground/70 transition hover:text-foreground hover:border-brand/40"
    >
      <Bell className="h-4 w-4" />
      {count > 0 && (
        <span className="absolute -right-0.5 -top-0.5 flex h-4 min-w-4 items-center justify-center rounded-full bg-danger px-1 text-[10px] font-semibold text-white">
          {count > 9 ? "9+" : count}
        </span>
      )}
    </Link>
  );
}
