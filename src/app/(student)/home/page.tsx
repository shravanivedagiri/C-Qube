"use client";

import { Compass, Sparkles, Users } from "lucide-react";
import { useEffect, useState } from "react";
import { LinkButton } from "@/components/ui/button";
import { ClubCard } from "@/components/shared/club-card";
import { EventCard } from "@/components/shared/event-card";
import { PostCard } from "@/components/shared/post-card";
import { CardSkeleton } from "@/components/ui/skeleton";
import { Avatar } from "@/components/ui/avatar";
import { useCurrentProfile } from "@/hooks/use-current-profile";
import { createClient } from "@/lib/supabase/client";
import { relativeTime } from "@/lib/utils";
import { ClubService } from "@/services/club-service";
import { EventService, type EventWithClub } from "@/services/event-service";
import { FriendService } from "@/services/friend-service";
import { PointsService } from "@/services/points-service";
import { PostService, type PostWithClub } from "@/services/post-service";
import type { Database } from "@/types/database";

type Club = Database["public"]["Tables"]["clubs"]["Row"];
type FriendActivity = { name: string; avatar: string | null; action: string; at: string };

export default function StudentHomePage() {
  const { user, profile } = useCurrentProfile();
  const [recommended, setRecommended] = useState<Club[]>([]);
  const [events, setEvents] = useState<EventWithClub[]>([]);
  const [feed, setFeed] = useState<PostWithClub[]>([]);
  const [friendActivity, setFriendActivity] = useState<FriendActivity[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!user) return;
    let active = true;

    (async () => {
      const supabase = createClient();

      const [{ data: studentProfile }, { data: allClubs }, { data: upcoming }, { data: postFeed }] =
        await Promise.all([
          PointsService.getStudentProfile(user.id),
          ClubService.listApproved(),
          EventService.listUpcoming(),
          PostService.listFeed(10, user.id),
        ]);

      if (!active) return;

      const interests = new Set(studentProfile?.interests ?? []);
      const ranked = [...(allClubs ?? [])].sort((a, b) => {
        const aMatch = a.category && interests.has(a.category) ? 1 : 0;
        const bMatch = b.category && interests.has(b.category) ? 1 : 0;
        return bMatch - aMatch || b.member_count - a.member_count;
      });
      setRecommended(ranked.slice(0, 3));
      setEvents((upcoming ?? []).slice(0, 3));
      setFeed(postFeed ?? []);

      const { data: friends } = await FriendService.listFriends(user.id);
      const friendIds = (friends ?? [])
        .map((f) => (f.sender_id === user.id ? f.receiver_id : f.sender_id))
        .slice(0, 15);

      if (friendIds.length) {
        const [{ data: regs }, { data: joins }] = await Promise.all([
          supabase
            .from("event_registrations")
            .select("registered_at, student_id, profiles(name, avatar_url), events(title)")
            .in("student_id", friendIds)
            .order("registered_at", { ascending: false })
            .limit(5),
          supabase
            .from("club_members")
            .select("joined_at, student_id, profiles(name, avatar_url), clubs(name)")
            .in("student_id", friendIds)
            .order("joined_at", { ascending: false })
            .limit(5),
        ]);

        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const regActivity: FriendActivity[] = ((regs ?? []) as any[]).map((r) => ({
          name: r.profiles?.name ?? "Someone",
          avatar: r.profiles?.avatar_url ?? null,
          action: `registered for ${r.events?.title ?? "an event"}`,
          at: r.registered_at,
        }));
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const joinActivity: FriendActivity[] = ((joins ?? []) as any[]).map((j) => ({
          name: j.profiles?.name ?? "Someone",
          avatar: j.profiles?.avatar_url ?? null,
          action: `joined ${j.clubs?.name ?? "a club"}`,
          at: j.joined_at,
        }));
        if (active) {
          setFriendActivity(
            [...regActivity, ...joinActivity].sort((a, b) => b.at.localeCompare(a.at)).slice(0, 6)
          );
        }
      }

      setLoading(false);
    })();

    return () => {
      active = false;
    };
  }, [user]);

  if (loading) {
    return (
      <div className="space-y-6">
        <CardSkeleton />
        <CardSkeleton />
      </div>
    );
  }

  return (
    <div>
      <h1 className="font-display text-2xl font-semibold tracking-tight sm:text-3xl">
        Welcome back{profile?.name ? `, ${profile.name.split(" ")[0]}` : ""}
      </h1>
      <p className="mt-1.5 text-sm text-muted">Here&rsquo;s what&rsquo;s happening on your campus.</p>

      <div className="mt-8 grid gap-8 lg:grid-cols-3">
        <div className="space-y-8 lg:col-span-2">
          <Section title="Recommended Clubs" href="/discover" icon={Compass}>
            {recommended.length === 0 ? (
              <p className="text-sm text-muted">Set your interests in Profile to get better picks.</p>
            ) : (
              <div className="grid gap-4 sm:grid-cols-2">
                {recommended.map((c) => (
                  <ClubCard key={c.id} club={c} />
                ))}
              </div>
            )}
          </Section>

          <Section title="Upcoming Events" href="/events" icon={Sparkles}>
            {events.length === 0 ? (
              <p className="text-sm text-muted">No upcoming events yet — check back soon.</p>
            ) : (
              <div className="grid gap-4 sm:grid-cols-2">
                {events.map((e) => (
                  <EventCard key={e.id} event={e} />
                ))}
              </div>
            )}
          </Section>

          <Section title="Recent Club Activity" href="/discover">
            {feed.length === 0 ? (
              <p className="text-sm text-muted">No activity yet — follow some clubs to see their posts here.</p>
            ) : (
              <div className="space-y-4">
                {feed.map((p) => (
                  <PostCard key={p.id} post={p} currentStudentId={user?.id} />
                ))}
              </div>
            )}
          </Section>
        </div>

        <div>
          <h2 className="mb-3 flex items-center gap-1.5 text-sm font-semibold uppercase tracking-wide text-muted">
            <Users className="h-4 w-4" />
            Friend Activity
          </h2>
          {friendActivity.length === 0 ? (
            <div className="rounded-2xl border border-dashed border-border p-5 text-center">
              <p className="text-sm text-muted">
                Connect with classmates to see what they&rsquo;re up to.
              </p>
              <LinkButton href="/friends" size="sm" variant="secondary" className="mt-3">
                Find Students
              </LinkButton>
            </div>
          ) : (
            <div className="space-y-4 rounded-2xl border border-border bg-surface p-4 shadow-sm">
              {friendActivity.map((a, i) => (
                <div key={i} className="flex items-start gap-3">
                  <Avatar src={a.avatar} name={a.name} size={32} />
                  <div className="min-w-0">
                    <p className="text-sm">
                      <span className="font-medium">{a.name}</span> {a.action}
                    </p>
                    <p className="text-xs text-muted">{relativeTime(a.at)}</p>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

function Section({
  title,
  href,
  icon: Icon,
  children,
}: {
  title: string;
  href: string;
  icon?: typeof Compass;
  children: React.ReactNode;
}) {
  return (
    <section>
      <div className="mb-3 flex items-center justify-between">
        <h2 className="flex items-center gap-1.5 text-sm font-semibold uppercase tracking-wide text-muted">
          {Icon && <Icon className="h-4 w-4" />}
          {title}
        </h2>
        <a href={href} className="text-xs font-medium text-brand hover:underline">
          See all
        </a>
      </div>
      {children}
    </section>
  );
}
