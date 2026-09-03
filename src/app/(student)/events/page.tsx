"use client";

import { Calendar, Search, Users } from "lucide-react";
import { useCallback, useEffect, useMemo, useState } from "react";
import { PageHeader } from "@/components/layout/page-header";
import { EventCard } from "@/components/shared/event-card";
import { Button } from "@/components/ui/button";
import { EmptyState } from "@/components/ui/empty-state";
import { Input, Select } from "@/components/ui/input";
import { CardSkeleton } from "@/components/ui/skeleton";
import { useCurrentProfile } from "@/hooks/use-current-profile";
import { EVENT_CATEGORIES } from "@/lib/constants";
import { createClient } from "@/lib/supabase/client";
import { EventService, type EventWithClub, type FriendGoing } from "@/services/event-service";
import { FriendService } from "@/services/friend-service";

export default function EventsPage() {
  const { user } = useCurrentProfile();
  const [events, setEvents] = useState<EventWithClub[]>([]);
  const [registered, setRegistered] = useState<Set<string>>(new Set());
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [category, setCategory] = useState("");
  const [sort, setSort] = useState<"date" | "name">("date");

  const [friendIds, setFriendIds] = useState<string[]>([]);
  const [friendsGoing, setFriendsGoing] = useState<Record<string, FriendGoing[]>>({});
  const [friendsOnly, setFriendsOnly] = useState(false);

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

  useEffect(() => {
    if (!user) return;
    FriendService.listFriendIds(user.id).then(({ data }) => setFriendIds(data ?? []));
  }, [user]);

  const refreshFriendsGoing = useCallback((ids: string[]) => {
    EventService.friendsGoing(ids).then(({ data }) => setFriendsGoing(data ?? {}));
  }, []);

  useEffect(() => {
    if (friendIds.length === 0) {
      setFriendsGoing({});
      return;
    }
    refreshFriendsGoing(friendIds);
  }, [friendIds, refreshFriendsGoing]);

  // Realtime: re-pull the friends-going map the moment any watched
  // friend registers for or cancels an event, so the "Friends" filter
  // and the per-card "N friends are going" line never go stale.
  useEffect(() => {
    if (friendIds.length === 0) return;
    const supabase = createClient();
    const channel = supabase
      .channel("events-friends-registrations")
      .on(
        "postgres_changes",
        { event: "*", schema: "public", table: "event_registrations" },
        (payload) => {
          const row = (payload.new ?? payload.old) as { student_id?: string } | null;
          if (row?.student_id && friendIds.includes(row.student_id)) {
            refreshFriendsGoing(friendIds);
          }
        }
      )
      .subscribe();
    return () => {
      supabase.removeChannel(channel);
    };
  }, [friendIds, refreshFriendsGoing]);

  const filtered = useMemo(() => {
    let list = events.filter((e) => {
      if (search && !e.title.toLowerCase().includes(search.toLowerCase())) return false;
      if (category && e.category !== category) return false;
      if (friendsOnly && !friendsGoing[e.id]?.length) return false;
      return true;
    });
    if (sort === "name") list = [...list].sort((a, b) => a.title.localeCompare(b.title));
    return list;
  }, [events, search, category, sort, friendsOnly, friendsGoing]);

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
        <Button
          type="button"
          variant={friendsOnly ? "primary" : "secondary"}
          icon={<Users className="h-4 w-4" />}
          onClick={() => setFriendsOnly((v) => !v)}
          disabled={friendIds.length === 0}
          title={friendIds.length === 0 ? "Add friends to filter by who's going" : undefined}
        >
          Friends
        </Button>
      </div>

      {loading ? (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {[1, 2, 3, 4, 5, 6].map((i) => (
            <CardSkeleton key={i} />
          ))}
        </div>
      ) : filtered.length === 0 ? (
        <EmptyState
          icon={friendsOnly ? Users : Calendar}
          title={friendsOnly ? "None of your friends are going to an upcoming event yet" : "No events match those filters"}
        />
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {filtered.map((event) => (
            <EventCard
              key={event.id}
              event={event}
              registered={registered.has(event.id)}
              friendsGoing={friendsGoing[event.id]}
            />
          ))}
        </div>
      )}
    </div>
  );
}
