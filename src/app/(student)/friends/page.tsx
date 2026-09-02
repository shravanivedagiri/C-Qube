"use client";

import { Check, Search, Users, X } from "lucide-react";
import { useCallback, useEffect, useState } from "react";
import { toast } from "sonner";
import { PageHeader } from "@/components/layout/page-header";
import { Avatar } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { EmptyState } from "@/components/ui/empty-state";
import { Input } from "@/components/ui/input";
import { CardSkeleton } from "@/components/ui/skeleton";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useCurrentProfile } from "@/hooks/use-current-profile";
import {
  FriendService,
  type FriendshipWithProfiles,
} from "@/services/friend-service";
import type { Database } from "@/types/database";

type Profile = Database["public"]["Tables"]["profiles"]["Row"];

export default function FriendsPage() {
  const { user } = useCurrentProfile();
  const [friends, setFriends] = useState<FriendshipWithProfiles[]>([]);
  const [pending, setPending] = useState<FriendshipWithProfiles[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [results, setResults] = useState<Profile[]>([]);
  const [searching, setSearching] = useState(false);
  const [sentTo, setSentTo] = useState<Set<string>>(new Set());

  const load = useCallback(async () => {
    if (!user) return;
    const [{ data: f }, { data: p }] = await Promise.all([
      FriendService.listFriends(user.id),
      FriendService.listPendingReceived(user.id),
    ]);
    setFriends(f ?? []);
    setPending(p ?? []);
    setLoading(false);
  }, [user]);

  useEffect(() => {
    load();
  }, [load]);

  async function doSearch(q: string) {
    setSearch(q);
    if (!user || q.trim().length < 2) {
      setResults([]);
      return;
    }
    setSearching(true);
    const { data } = await FriendService.searchStudents(q, user.id);
    setResults(data ?? []);
    setSearching(false);
  }

  async function sendRequest(studentId: string) {
    if (!user) return;
    setSentTo((s) => new Set(s).add(studentId));
    const { error } = await FriendService.sendRequest(user.id, studentId);
    if (error) {
      toast.error(error);
      setSentTo((s) => {
        const next = new Set(s);
        next.delete(studentId);
        return next;
      });
    }
  }

  async function respond(id: string, status: "accepted" | "rejected") {
    setPending((p) => p.filter((r) => r.id !== id));
    const { error } = await FriendService.respond(id, status);
    if (error) {
      toast.error(error);
      return;
    }
    if (status === "accepted") {
      toast.success("You're now connected.");
      load();
    }
  }

  if (loading) return <CardSkeleton />;

  return (
    <div>
      <PageHeader title="Friends" description="Your campus network." />

      <div className="relative mb-6">
        <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted" />
        <Input
          placeholder="Search students by name..."
          className="pl-9"
          value={search}
          onChange={(e) => doSearch(e.target.value)}
        />
        {search.length >= 2 && (
          <div className="absolute z-10 mt-2 w-full rounded-xl border border-border bg-surface p-2 shadow-lg">
            {searching ? (
              <p className="p-3 text-sm text-muted">Searching…</p>
            ) : results.length === 0 ? (
              <p className="p-3 text-sm text-muted">No students found.</p>
            ) : (
              results.map((r) => (
                <div key={r.id} className="flex items-center gap-3 rounded-lg p-2 hover:bg-border/30">
                  <Avatar src={r.avatar_url} name={r.name} size={32} />
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-sm font-medium">{r.name}</p>
                    <p className="truncate text-xs text-muted">{r.department}</p>
                  </div>
                  <Button size="sm" variant={sentTo.has(r.id) ? "secondary" : "primary"} disabled={sentTo.has(r.id)} onClick={() => sendRequest(r.id)}>
                    {sentTo.has(r.id) ? "Request Sent" : "Add Friend"}
                  </Button>
                </div>
              ))
            )}
          </div>
        )}
      </div>

      <Tabs defaultValue="friends">
        <TabsList>
          <TabsTrigger value="friends">Friends ({friends.length})</TabsTrigger>
          <TabsTrigger value="requests">
            Requests {pending.length > 0 && `(${pending.length})`}
          </TabsTrigger>
        </TabsList>

        <TabsContent value="friends" className="mt-5">
          {friends.length === 0 ? (
            <EmptyState
              icon={Users}
              title="Your campus network starts here."
              description="Search for classmates above to send your first friend request."
            />
          ) : (
            <div className="grid gap-3 sm:grid-cols-2">
              {friends.map((f) => {
                const other = f.sender_id === user?.id ? f.receiver : f.sender;
                if (!other) return null;
                return (
                  <div key={f.id} className="flex items-center gap-3 rounded-xl border border-border bg-surface p-3">
                    <Avatar src={other.avatar_url} name={other.name} size={40} />
                    <div className="min-w-0">
                      <p className="truncate text-sm font-medium">{other.name}</p>
                      <p className="truncate text-xs text-muted">{other.department}</p>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </TabsContent>

        <TabsContent value="requests" className="mt-5">
          {pending.length === 0 ? (
            <p className="text-sm text-muted">No pending requests.</p>
          ) : (
            <div className="space-y-3">
              {pending.map((r) => (
                <div key={r.id} className="flex items-center gap-3 rounded-xl border border-border bg-surface p-3">
                  <Avatar src={r.sender?.avatar_url} name={r.sender?.name ?? "Student"} size={40} />
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-sm font-medium">{r.sender?.name}</p>
                    <p className="truncate text-xs text-muted">wants to connect</p>
                  </div>
                  <button onClick={() => respond(r.id, "accepted")} className="rounded-lg bg-success-soft p-2 text-success hover:opacity-80">
                    <Check className="h-4 w-4" />
                  </button>
                  <button onClick={() => respond(r.id, "rejected")} className="rounded-lg bg-danger-soft p-2 text-danger hover:opacity-80">
                    <X className="h-4 w-4" />
                  </button>
                </div>
              ))}
            </div>
          )}
        </TabsContent>
      </Tabs>
    </div>
  );
}
