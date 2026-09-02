"use client";

import { Calendar, Search } from "lucide-react";
import { useEffect, useMemo, useState } from "react";
import { PageHeader } from "@/components/layout/page-header";
import { EventCard } from "@/components/shared/event-card";
import { EmptyState } from "@/components/ui/empty-state";
import { Input, Select } from "@/components/ui/input";
import { CardSkeleton } from "@/components/ui/skeleton";
import { useCurrentProfile } from "@/hooks/use-current-profile";
import { EVENT_CATEGORIES } from "@/lib/constants";
import { createClient } from "@/lib/supabase/client";
import { EventService, type EventWithClub } from "@/services/event-service";

export default function EventsPage() {
  const { user } = useCurrentProfile();
  const [events, setEvents] = useState<EventWithClub[]>([]);
  const [registered, setRegistered] = useState<Set<string>>(new Set());
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [category, setCategory] = useState("");
  const [sort, setSort] = useState<"date" | "name">("date");

  useEffect(() => {
    EventService.listUpcoming().then(({ data }) => {
      setEvents(data ?? []);
      setLoading(false);
    });
  }, []);

  useEffect(() => {
    if (!user) return;
    createClient()
      .from("event_registrations")
      .select("event_id")
      .eq("student_id", user.id)
      .eq("status", "registered")
      .then(({ data }) => setRegistered(new Set((data ?? []).map((r) => r.event_id))));
  }, [user]);

  const filtered = useMemo(() => {
    let list = events.filter((e) => {
      if (search && !e.title.toLowerCase().includes(search.toLowerCase())) return false;
      if (category && e.category !== category) return false;
      return true;
    });
    if (sort === "name") list = [...list].sort((a, b) => a.title.localeCompare(b.title));
    return list;
  }, [events, search, category, sort]);

  return (
    <div>
      <PageHeader title="Events" description="Everything happening on campus, in one place." />

      <div className="mb-6 flex flex-col gap-3 sm:flex-row">
        <div className="relative flex-1">
          <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted" />
          <Input placeholder="Search events..." className="pl-9" value={search} onChange={(e) => setSearch(e.target.value)} />
        </div>
        <Select value={category} onChange={(e) => setCategory(e.target.value)} className="sm:w-48">
          <option value="">All categories</option>
          {EVENT_CATEGORIES.map((c) => (
            <option key={c}>{c}</option>
          ))}
        </Select>
        <Select value={sort} onChange={(e) => setSort(e.target.value as "date" | "name")} className="sm:w-40">
          <option value="date">Soonest first</option>
          <option value="name">Name (A–Z)</option>
        </Select>
      </div>

      {loading ? (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {[1, 2, 3, 4, 5, 6].map((i) => (
            <CardSkeleton key={i} />
          ))}
        </div>
      ) : filtered.length === 0 ? (
        <EmptyState icon={Calendar} title="No events match those filters" />
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {filtered.map((event) => (
            <EventCard key={event.id} event={event} registered={registered.has(event.id)} />
          ))}
        </div>
      )}
    </div>
  );
}
