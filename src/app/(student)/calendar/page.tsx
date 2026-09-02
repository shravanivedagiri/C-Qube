"use client";

import { ChevronLeft, ChevronRight, LayoutGrid, List } from "lucide-react";
import { useEffect, useMemo, useState } from "react";
import { PageHeader } from "@/components/layout/page-header";
import { EventCard } from "@/components/shared/event-card";
import { EmptyState } from "@/components/ui/empty-state";
import { LinkButton } from "@/components/ui/button";
import { CardSkeleton } from "@/components/ui/skeleton";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useCurrentProfile } from "@/hooks/use-current-profile";
import { cn, formatDate } from "@/lib/utils";
import { EventService, type EventWithClub } from "@/services/event-service";
import { Calendar as CalendarIcon } from "lucide-react";

const WEEKDAYS = ["S", "M", "T", "W", "T", "F", "S"];

function sameDay(a: Date, b: Date) {
  return a.toDateString() === b.toDateString();
}

export default function CalendarPage() {
  const { user } = useCurrentProfile();
  const [allEvents, setAllEvents] = useState<EventWithClub[]>([]);
  const [myEvents, setMyEvents] = useState<EventWithClub[]>([]);
  const [loading, setLoading] = useState(true);
  const [view, setView] = useState<"month" | "agenda">("month");
  const [month, setMonth] = useState(() => new Date());
  const [selectedDate, setSelectedDate] = useState<Date | null>(null);

  useEffect(() => {
    EventService.listUpcoming().then(({ data }) => {
      setAllEvents(data ?? []);
      setLoading(false);
    });
  }, []);

  useEffect(() => {
    if (!user) return;
    EventService.myRegistrations(user.id).then(({ data }) => setMyEvents(data ?? []));
  }, [user]);

  function eventsFor(list: EventWithClub[], date: Date) {
    return list.filter((e) => sameDay(new Date(e.date), date));
  }

  const grid = useMemo(() => {
    const first = new Date(month.getFullYear(), month.getMonth(), 1);
    const startOffset = first.getDay();
    const daysInMonth = new Date(month.getFullYear(), month.getMonth() + 1, 0).getDate();
    const cells: (Date | null)[] = Array(startOffset).fill(null);
    for (let d = 1; d <= daysInMonth; d++) cells.push(new Date(month.getFullYear(), month.getMonth(), d));
    return cells;
  }, [month]);

  function renderMonth(list: EventWithClub[]) {
    return (
      <div>
        <div className="mb-4 flex items-center justify-between">
          <button onClick={() => setMonth(new Date(month.getFullYear(), month.getMonth() - 1, 1))} className="rounded-lg p-2 hover:bg-border/40">
            <ChevronLeft className="h-4 w-4" />
          </button>
          <p className="text-sm font-semibold">
            {month.toLocaleDateString("en-US", { month: "long", year: "numeric" })}
          </p>
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
            const dayEvents = eventsFor(list, date);
            const isSelected = selectedDate && sameDay(selectedDate, date);
            const isToday = sameDay(date, new Date());
            return (
              <button
                key={i}
                onClick={() => setSelectedDate(isSelected ? null : date)}
                className={cn(
                  "flex aspect-square flex-col items-center justify-start gap-1 rounded-lg border border-transparent p-1.5 text-xs transition hover:border-border",
                  isSelected && "border-brand bg-brand-soft",
                  isToday && !isSelected && "font-semibold text-brand"
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
            <>
              <h3 className="mb-3 text-sm font-semibold">{formatDate(selectedDate.toISOString())}</h3>
              <EventList events={eventsFor(list, selectedDate)} registeredIds={new Set(myEvents.map((e) => e.id))} />
            </>
          ) : (
            <p className="text-center text-xs text-muted">Tap a date to see what&rsquo;s on.</p>
          )}
        </div>
      </div>
    );
  }

  function renderAgenda(list: EventWithClub[]) {
    if (list.length === 0) return null;
    const grouped = new Map<string, EventWithClub[]>();
    for (const e of [...list].sort((a, b) => a.date.localeCompare(b.date))) {
      grouped.set(e.date, [...(grouped.get(e.date) ?? []), e]);
    }
    return (
      <div className="space-y-6">
        {Array.from(grouped.entries()).map(([date, evs]) => (
          <div key={date}>
            <h3 className="mb-3 text-sm font-semibold">{formatDate(date)}</h3>
            <EventList events={evs} registeredIds={new Set(myEvents.map((e) => e.id))} />
          </div>
        ))}
      </div>
    );
  }

  if (loading) return <CardSkeleton />;

  return (
    <div>
      <PageHeader
        title="Calendar"
        description="Every event on campus, plus what you're registered for."
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

      <Tabs defaultValue="all">
        <TabsList>
          <TabsTrigger value="all">All Events</TabsTrigger>
          <TabsTrigger value="mine">My Registrations</TabsTrigger>
        </TabsList>

        <TabsContent value="all" className="mt-5">
          {view === "month" ? renderMonth(allEvents) : renderAgenda(allEvents)}
        </TabsContent>

        <TabsContent value="mine" className="mt-5">
          {myEvents.length === 0 ? (
            <EmptyState
              icon={CalendarIcon}
              title="You haven't registered for any events yet."
              action={
                <LinkButton href="/events" className="mt-5">
                  Discover Events
                </LinkButton>
              }
            />
          ) : view === "month" ? (
            renderMonth(myEvents)
          ) : (
            renderAgenda(myEvents)
          )}
        </TabsContent>
      </Tabs>
    </div>
  );
}

function EventList({ events, registeredIds }: { events: EventWithClub[]; registeredIds: Set<string> }) {
  if (events.length === 0) return <p className="text-sm text-muted">Nothing scheduled.</p>;
  return (
    <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
      {events.map((e) => (
        <EventCard key={e.id} event={e} registered={registeredIds.has(e.id)} />
      ))}
    </div>
  );
}
