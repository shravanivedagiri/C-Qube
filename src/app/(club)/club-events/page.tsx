"use client";

import { Calendar, MapPin, Users, XCircle } from "lucide-react";
import { useCallback, useEffect, useState } from "react";
import { CreateActivityDialog } from "@/components/club/create-activity-dialog";
import { PageHeader } from "@/components/layout/page-header";
import { Badge } from "@/components/ui/badge";
import { Card } from "@/components/ui/card";
import { useConfirm } from "@/components/ui/confirm-dialog";
import { EmptyState } from "@/components/ui/empty-state";
import { CardSkeleton } from "@/components/ui/skeleton";
import { useCurrentProfile } from "@/hooks/use-current-profile";
import { formatDate, formatTime } from "@/lib/utils";
import { ClubService } from "@/services/club-service";
import { EventService } from "@/services/event-service";
import { toast } from "sonner";
import type { Database } from "@/types/database";

type Event = Database["public"]["Tables"]["events"]["Row"];

export default function ClubEventsPage() {
  const { user } = useCurrentProfile();
  const [clubId, setClubId] = useState<string | null>(null);
  const [events, setEvents] = useState<(Event & { registration_count: number })[]>([]);
  const [loading, setLoading] = useState(true);
  const { confirm, confirmDialog } = useConfirm();

  const load = useCallback(async () => {
    if (!user) return;
    const { data: club } = await ClubService.getMyClub(user.id);
    if (!club) {
      setLoading(false);
      return;
    }
    setClubId(club.id);
    const { data } = await EventService.listByClub(club.id);
    const withCounts = await Promise.all(
      (data ?? []).map(async (e) => ({
        ...e,
        registration_count: await EventService.registrationCount(e.id),
      }))
    );
    setEvents(withCounts);
    setLoading(false);
  }, [user]);

  useEffect(() => {
    load();
  }, [load]);

  async function cancelEvent(event: Event) {
    const ok = await confirm({
      title: `Cancel "${event.title}"?`,
      description: "Registered students will no longer see this event as active. This can't be undone.",
      confirmLabel: "Cancel event",
      danger: true,
    });
    if (!ok) return;
    const { error } = await EventService.update(event.id, { status: "cancelled" });
    if (error) {
      toast.error(error);
      return;
    }
    toast.success("Event cancelled.");
    load();
  }

  if (loading) {
    return (
      <div className="space-y-4">
        <PageHeader title="Events" />
        <CardSkeleton />
        <CardSkeleton />
      </div>
    );
  }

  const now = new Date();
  const upcoming = events.filter((e) => new Date(e.date) >= now && e.status === "published");
  const past = events.filter((e) => new Date(e.date) < now && e.status !== "draft");
  const drafts = events.filter((e) => e.status === "draft");
  const cancelled = events.filter((e) => e.status === "cancelled");

  return (
    <div>
      <PageHeader
        title="Events"
        description="Manage everything your club is hosting."
        actions={clubId && <CreateActivityDialog clubId={clubId} onCreated={load} />}
      />

      {confirmDialog}

      <Section title="Upcoming" events={upcoming} onCancel={cancelEvent} />
      <Section title="Drafts" events={drafts} onCancel={cancelEvent} />
      <Section title="Past" events={past} onCancel={cancelEvent} muted />
      {cancelled.length > 0 && <Section title="Cancelled" events={cancelled} onCancel={cancelEvent} muted />}

      {events.length === 0 && (
        <EmptyState
          icon={Calendar}
          title="No events yet"
          description="Use Create Activity → Host Event to get your first one on the calendar."
        />
      )}
    </div>
  );
}

function Section({
  title,
  events,
  onCancel,
  muted,
}: {
  title: string;
  events: (Event & { registration_count: number })[];
  onCancel: (e: Event) => void;
  muted?: boolean;
}) {
  if (events.length === 0) return null;
  return (
    <div className="mb-8">
      <h2 className="mb-3 text-sm font-semibold uppercase tracking-wide text-muted">{title}</h2>
      <div className="space-y-3">
        {events.map((event) => (
          <Card key={event.id} className={muted ? "opacity-70" : undefined}>
            <div className="flex flex-wrap items-center justify-between gap-4 p-5">
              <div>
                <div className="flex items-center gap-2">
                  <h3 className="font-semibold">{event.title}</h3>
                  <Badge variant="brand">{event.category}</Badge>
                  {event.status === "cancelled" && <Badge variant="danger">Cancelled</Badge>}
                  {event.status === "draft" && <Badge variant="warning">Draft</Badge>}
                </div>
                <div className="mt-1.5 flex flex-wrap items-center gap-3 text-xs text-muted">
                  <span className="flex items-center gap-1">
                    <Calendar className="h-3.5 w-3.5" />
                    {formatDate(event.date)} · {formatTime(event.start_time)}
                  </span>
                  {event.location && (
                    <span className="flex items-center gap-1">
                      <MapPin className="h-3.5 w-3.5" />
                      {event.location}
                    </span>
                  )}
                  <span className="flex items-center gap-1">
                    <Users className="h-3.5 w-3.5" />
                    {event.registration_count}
                    {event.capacity ? ` / ${event.capacity}` : ""} registered
                  </span>
                </div>
              </div>
              {event.status === "published" && new Date(event.date) >= new Date() && (
                <button
                  onClick={() => onCancel(event)}
                  className="flex items-center gap-1.5 rounded-lg px-3 py-1.5 text-xs font-medium text-danger transition hover:bg-danger-soft"
                >
                  <XCircle className="h-3.5 w-3.5" />
                  Cancel
                </button>
              )}
            </div>
          </Card>
        ))}
      </div>
    </div>
  );
}
