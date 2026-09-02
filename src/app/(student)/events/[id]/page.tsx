"use client";

import { CalendarPlus, Check, Clock, MapPin, Users } from "lucide-react";
import Image from "next/image";
import { use, useCallback, useEffect, useState } from "react";
import { toast } from "sonner";
import { Avatar } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { CardSkeleton } from "@/components/ui/skeleton";
import { useCurrentProfile } from "@/hooks/use-current-profile";
import { formatDate, formatTime } from "@/lib/utils";
import { EventService, type EventWithClub } from "@/services/event-service";

export default function EventDetailsPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const { user } = useCurrentProfile();
  const [event, setEvent] = useState<EventWithClub | null>(null);
  const [count, setCount] = useState(0);
  const [registered, setRegistered] = useState(false);
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState(false);

  const load = useCallback(async () => {
    const { data } = await EventService.getById(id);
    setEvent(data);
    if (data) {
      setCount(await EventService.registrationCount(data.id));
      if (user) setRegistered(await EventService.isRegistered(data.id, user.id));
    }
    setLoading(false);
  }, [id, user]);

  useEffect(() => {
    load();
  }, [load]);

  async function register() {
    if (!user) {
      toast.info("Log in as a student to register.");
      return;
    }
    setBusy(true);
    const { error } = await EventService.register(id);
    setBusy(false);
    if (error) {
      toast.error(error);
      return;
    }
    setRegistered(true);
    setCount((c) => c + 1);
    toast.success("You're registered!");
  }

  function addToCalendar() {
    if (!event) return;
    const start = `${event.date.replace(/-/g, "")}T${event.start_time.replace(":", "")}00`;
    const url = `https://calendar.google.com/calendar/render?action=TEMPLATE&text=${encodeURIComponent(
      event.title
    )}&dates=${start}/${start}&details=${encodeURIComponent(event.description ?? "")}&location=${encodeURIComponent(
      event.location ?? ""
    )}`;
    window.open(url, "_blank");
  }

  if (loading) return <CardSkeleton />;
  if (!event) return <p className="text-sm text-muted">Event not found.</p>;

  const seatsLeft = event.capacity ? Math.max(0, event.capacity - count) : null;
  const deadlinePassed =
    !!event.registration_deadline && new Date(event.registration_deadline) < new Date();

  return (
    <div className="mx-auto max-w-3xl">
      <div className="relative aspect-[21/9] w-full overflow-hidden rounded-2xl border border-border bg-brand-soft">
        {event.banner_url && <Image src={event.banner_url} alt="" fill className="object-cover" />}
        <Badge variant="brand" className="absolute left-4 top-4 bg-surface/90">
          {event.category}
        </Badge>
      </div>

      <div className="mt-6 flex flex-wrap items-start justify-between gap-4">
        <div>
          <div className="flex items-center gap-2">
            <Avatar src={event.clubs?.logo_url} name={event.clubs?.name ?? "Club"} size={28} />
            <span className="text-sm font-medium text-brand">{event.clubs?.name}</span>
          </div>
          <h1 className="mt-2 font-display text-2xl font-semibold tracking-tight sm:text-3xl">
            {event.title}
          </h1>
        </div>
        <div className="flex gap-2">
          <Button variant="secondary" icon={<CalendarPlus className="h-4 w-4" />} onClick={addToCalendar}>
            Add to Calendar
          </Button>
          {registered ? (
            <Button variant="secondary" icon={<Check className="h-4 w-4" />} disabled>
              Registered ✓
            </Button>
          ) : (
            <Button
              loading={busy}
              disabled={deadlinePassed || seatsLeft === 0}
              onClick={register}
            >
              {deadlinePassed ? "Registration closed" : seatsLeft === 0 ? "Full" : "Register"}
            </Button>
          )}
        </div>
      </div>

      {event.description && (
        <p className="mt-6 whitespace-pre-line text-sm leading-relaxed text-foreground/90">
          {event.description}
        </p>
      )}

      <div className="mt-8 grid gap-4 rounded-2xl border border-border bg-surface p-6 sm:grid-cols-2">
        <Detail icon={Clock} label="Date & time" value={`${formatDate(event.date)} · ${formatTime(event.start_time)}${event.end_time ? ` – ${formatTime(event.end_time)}` : ""}`} />
        <Detail icon={MapPin} label="Location" value={event.is_online ? "Online" : event.location ?? "TBA"} />
        <Detail icon={Users} label="Registered" value={`${count}${event.capacity ? ` / ${event.capacity}` : ""}`} />
        {event.registration_deadline && (
          <Detail icon={Clock} label="Registration deadline" value={formatDate(event.registration_deadline)} />
        )}
      </div>
    </div>
  );
}

function Detail({ icon: Icon, label, value }: { icon: typeof Clock; label: string; value: string }) {
  return (
    <div className="flex items-start gap-3">
      <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-brand-soft">
        <Icon className="h-4 w-4 text-brand" />
      </div>
      <div>
        <p className="text-xs text-muted">{label}</p>
        <p className="text-sm font-medium">{value}</p>
      </div>
    </div>
  );
}
