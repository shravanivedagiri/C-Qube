"use client";

import { Bell, Calendar, CheckCheck, UserPlus, Users } from "lucide-react";
import { useCallback, useEffect, useState } from "react";
import Link from "next/link";
import { PageHeader } from "@/components/layout/page-header";
import { Button } from "@/components/ui/button";
import { EmptyState } from "@/components/ui/empty-state";
import { CardSkeleton } from "@/components/ui/skeleton";
import { useCurrentProfile } from "@/hooks/use-current-profile";
import { cn, relativeTime } from "@/lib/utils";
import { NotificationService } from "@/services/notification-service";
import type { Database, NotificationType } from "@/types/database";

type Notification = Database["public"]["Tables"]["notifications"]["Row"];

const ICONS: Record<NotificationType, typeof Bell> = {
  friend: Users,
  event: Calendar,
  club: Bell,
  friend_activity: Users,
  recruitment: UserPlus,
  system: Bell,
};

function targetHref(n: Notification): string {
  if (n.reference_type === "event" && n.reference_id) return `/events/${n.reference_id}`;
  if (n.type === "friend") return "/friends";
  return "/notifications";
}

export default function NotificationsPage() {
  const { user } = useCurrentProfile();
  const [items, setItems] = useState<Notification[]>([]);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    if (!user) return;
    const { data } = await NotificationService.list(user.id);
    setItems(data ?? []);
    setLoading(false);
  }, [user]);

  useEffect(() => {
    load();
  }, [load]);

  async function markAllRead() {
    if (!user) return;
    setItems((prev) => prev.map((n) => ({ ...n, is_read: true })));
    await NotificationService.markAllRead(user.id);
  }

  async function open(n: Notification) {
    if (!n.is_read) {
      setItems((prev) => prev.map((x) => (x.id === n.id ? { ...x, is_read: true } : x)));
      NotificationService.markRead(n.id);
    }
  }

  if (loading) return <CardSkeleton />;

  const unread = items.filter((n) => !n.is_read).length;

  return (
    <div>
      <PageHeader
        title="Notifications"
        description={unread > 0 ? `${unread} unread` : "You're all caught up."}
        actions={
          unread > 0 && (
            <Button variant="secondary" size="sm" icon={<CheckCheck className="h-4 w-4" />} onClick={markAllRead}>
              Mark all read
            </Button>
          )
        }
      />

      {items.length === 0 ? (
        <EmptyState icon={Bell} title="You're all caught up." description="New activity will show up here." />
      ) : (
        <div className="space-y-2">
          {items.map((n) => {
            const Icon = ICONS[n.type] ?? Bell;
            return (
              <Link
                key={n.id}
                href={targetHref(n)}
                onClick={() => open(n)}
                className={cn(
                  "flex items-start gap-3 rounded-xl border p-4 transition",
                  n.is_read ? "border-border bg-surface" : "border-brand/30 bg-brand-soft/40"
                )}
              >
                <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-brand-soft">
                  <Icon className="h-4 w-4 text-brand" />
                </div>
                <div className="min-w-0 flex-1">
                  <p className="text-sm font-medium">{n.title}</p>
                  {n.body && <p className="mt-0.5 text-xs text-muted">{n.body}</p>}
                  <p className="mt-1 text-[11px] text-muted">{relativeTime(n.created_at)}</p>
                </div>
                {!n.is_read && <span className="mt-1.5 h-2 w-2 shrink-0 rounded-full bg-brand" />}
              </Link>
            );
          })}
        </div>
      )}
    </div>
  );
}
