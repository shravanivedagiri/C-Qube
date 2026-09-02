"use client";

import { Calendar as CalendarIcon, ChevronLeft, ChevronRight, LayoutGrid, List, MapPin } from "lucide-react";
import { useEffect, useMemo, useState } from "react";
import { PageHeader } from "@/components/layout/page-header";
import { Avatar } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { EmptyState } from "@/components/ui/empty-state";
import { CardSkeleton } from "@/components/ui/skeleton";
import { cn, formatDate, formatTime } from "@/lib/utils";
import { AdminService, type CampusCalendarEvent } from "@/services/admin-service";

const WEEKDAYS = ["S", "M", "T", "W", "T", "F", "S"];

function sameDay(a: Date, b: Date) {
  return a.toDateString() === b.toDateString();
}

export default function AdminCalendarPage() {
  const [events, setEvents] = useState<CampusCalendarEvent[]>([]);
  const [loading, setLoading] = useState(true);
  const [view, setView] = useState<"month" | "agenda">("month");
  const [month, setMonth] = useState(() => new Date());
  const [selectedDate, setSelectedDate] = useState<Date | null>(null);

  useEffect(() => {
    AdminService.getCalendar().then(({ data }) => {
      setEvents(data ?? []);
      setLoading(false);
    });
  }, []);

  const grid = useMemo(() => {
    const first = new Date(month.getFullYear(), month.getMonth(), 1);
    const startOffset = first.getDay();
    const daysInMonth = new Date(month.getFullYear(), month.getMonth() + 1, 0).getDate();
    const cells: (Date | null)[] = Array(startOffset).fill(null);
    for (let d = 1; d <= daysInMonth; d++) cells.push(new Date(month.getFullYear(), month.getMonth(), d));
    return cells;
  }, [month]);

  function eventsFor(date: Date) {
    return events.filter((e) => sameDay(new Date(e.date), date));
  }

  if (loading) return <CardSkeleton />;

  if (events.length === 0) {
    return (
      <div>
        <PageHeader title="Calendar" description="Every event from approved clubs, campus-wide." />
        <EmptyState icon={CalendarIcon} title="No upcoming campus events." />
      </div>
    );
  }

  return (
    <div>
      <PageHeader
        title="Calendar"
        description="Every event from approved clubs — spot overlaps at a glance."
        actions={
          <div className="flex items-center gap-1 rounded-xl bg-border/40 p-1">
            <button
              onClick={() => setView("month")}
              className={cn("rounded-lg p-1.5 transition", view === "month" ? "bg-surface shadow-sm" : "text-muted")}
              aria-label="Month view"
            >
              <LayoutGrid className="h-4 w-4" />
            </button>
            <button
              onClick={() => setView("agenda")}
              className={cn("rounded-lg p-1.5 transition", view === "agenda" ? "bg-surface shadow-sm" : "text-muted")}
              aria-label="Agenda view"
            >
              <List className="h-4 w-4" />
            </button>
          </div>
        }
      />

      {view === "month" ? (
        <div>
          <div className="mb-4 flex items-center justify-between">
            <button onClick={() => setMonth(new Date(month.getFullYear(), month.getMonth() - 1, 1))} className="rounded-lg p-2 hover:bg-border/40">
              <ChevronLeft className="h-4 w-4" />
            </button>
            <p className="text-sm font-semibold">{month.toLocaleDateString("en-US", { month: "long", year: "numeric" })}</p>
            <button onClick={() => setMonth(new Date(month.getFullYear(), month.getMonth() + 1, 1))} className="rounded-lg p-2 hover:bg-border/40">
              <ChevronRight className="h-4 w-4" />
            </button>
          </div>
          <div className="grid grid-cols-7 gap-1 text-center text-xs text-muted">
            {WEEKDAYS.map((d, i) => (
              <div key={i} className="py-1">{d}</div>
            ))}
          </div>
          <div className="grid grid-cols-7 gap-1">
            {grid.map((date, i) => {
              if (!date) return <div key={i} />;
              const dayEvents = eventsFor(date);
              const isSelected = selectedDate && sameDay(selectedDate, date);
              return (
                <button
                  key={i}
                  onClick={() => setSelectedDate(isSelected ? null : date)}
                  className={cn(
                    "flex aspect-square flex-col items-center justify-start gap-1 rounded-lg border border-transparent p-1.5 text-xs transition hover:border-border",
                    isSelected && "border-brand bg-brand-soft",
                    dayEvents.length > 1 && "font-semibold"
                  )}
                >
                  {date.getDate()}
                  <div className="flex gap-0.5">
                    {dayEvents.slice(0, 3).map((_, idx) => (
                      <span key={idx} className="h-1 w-1 rounded-full bg-brand" />
                    ))}
                  </div>
                </button>
              );
            })}
          </div>
          <div className="mt-6">
            {selectedDate ? (
              <EventList events={eventsFor(selectedDate)} />
            ) : (
              <p className="text-center text-xs text-muted">Tap a date to see what&rsquo;s scheduled.</p>
            )}
          </div>
        </div>
      ) : (
        <EventList events={[...events].sort((a, b) => a.date.localeCompare(b.date))} showDate />
      )}
    </div>
  );
}

function EventList({ events, showDate }: { events: CampusCalendarEvent[]; showDate?: boolean }) {
  if (events.length === 0) return <p className="text-sm text-muted">Nothing scheduled.</p>;
  return (
    <div className="space-y-3">
      {events.map((e) => (
        <div key={e.id} className="flex items-center gap-3 rounded-xl border border-border bg-surface p-3.5">
          <Avatar src={e.clubs.logo_url} name={e.clubs.name} size={36} />
          <div className="min-w-0 flex-1">
            <p className="truncate text-sm font-medium">{e.title}</p>
            <p className="truncate text-xs text-muted">
              {e.clubs.name} · {showDate && `${formatDate(e.date)} · `}
              {formatTime(e.start_time)}
              {e.end_time ? ` – ${formatTime(e.end_time)}` : ""}
            </p>
          </div>
          {e.location && (
            <span className="hidden shrink-0 items-center gap-1 text-xs text-muted sm:flex">
              <MapPin className="h-3.5 w-3.5" />
              {e.location}
            </span>
          )}
          <Badge variant="brand">{e.category}</Badge>
        </div>
      ))}
    </div>
  );
}
