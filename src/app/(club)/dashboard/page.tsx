"use client";

import { Calendar, Check, Image as ImageIcon, UserPlus, Users, X } from "lucide-react";
import { useCallback, useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { toast } from "sonner";
import { CreateActivityDialog } from "@/components/club/create-activity-dialog";
import { PageHeader } from "@/components/layout/page-header";
import { PostCard } from "@/components/shared/post-card";
import { Avatar } from "@/components/ui/avatar";
import { Card, CardContent } from "@/components/ui/card";
import { CardSkeleton } from "@/components/ui/skeleton";
import { EmptyState } from "@/components/ui/empty-state";
import { useCurrentProfile } from "@/hooks/use-current-profile";
import { ClubService, MembershipService } from "@/services/club-service";
import { EventService } from "@/services/event-service";
import { PostService, type PostWithClub } from "@/services/post-service";
import { RecruitmentService } from "@/services/recruitment-service";
import type { Database } from "@/types/database";

type Club = Database["public"]["Tables"]["clubs"]["Row"];
type PendingRequest = Database["public"]["Tables"]["club_membership_requests"]["Row"] & {
  profiles: { id: string; name: string; avatar_url: string | null; department: string | null; year: string | null } | null;
};

export default function ClubDashboardPage() {
  const router = useRouter();
  const { user, loading: authLoading } = useCurrentProfile();
  const [club, setClub] = useState<Club | null>(null);
  const [posts, setPosts] = useState<PostWithClub[]>([]);
  const [stats, setStats] = useState({ upcomingEvents: 0, openRecruitment: 0 });
  const [pendingRequests, setPendingRequests] = useState<PendingRequest[]>([]);
  const [reviewingId, setReviewingId] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    if (!user) return;
    const { data: myClub } = await ClubService.getMyClub(user.id);
    setClub(myClub);
    if (!myClub) {
      setLoading(false);
      return;
    }
    if (!myClub.profile_complete) {
      router.replace("/setup");
      return;
    }
    const [{ data: clubPosts }, { data: events }, { data: drives }, { data: requests }] = await Promise.all([
      PostService.listByClub(myClub.id),
      EventService.listByClub(myClub.id),
      RecruitmentService.listByClub(myClub.id),
      MembershipService.listPendingForClub(myClub.id),
    ]);
    setPosts(clubPosts ?? []);
    setStats({
      upcomingEvents: (events ?? []).filter((e) => new Date(e.date) >= new Date() && e.status === "published").length,
      openRecruitment: (drives ?? []).filter((d) => d.status === "open").length,
    });
    setPendingRequests((requests ?? []) as PendingRequest[]);
    setLoading(false);
  }, [user, router]);

  async function respond(request: PendingRequest, status: "accepted" | "rejected") {
    if (!user) return;
    setReviewingId(request.id);
    const { error } = await MembershipService.respond(
      { id: request.id, club_id: request.club_id, student_id: request.student_id },
      status,
      user.id
    );
    setReviewingId(null);
    if (error) {
      toast.error(error);
      return;
    }
    toast.success(status === "accepted" ? `${request.profiles?.name ?? "Student"} added to the club.` : "Request rejected.");
    load();
  }

  useEffect(() => {
    load();
  }, [load]);

  if (authLoading || loading) {
    return (
      <div>
        <PageHeader title="Dashboard" />
        <div className="grid gap-4 sm:grid-cols-3">
          {[1, 2, 3].map((i) => (
            <CardSkeleton key={i} />
          ))}
        </div>
      </div>
    );
  }

  if (!club) {
    return (
      <EmptyState
        icon={Users}
        title="No club linked to this account"
        description="Contact the C-QUBE administrator if this looks wrong."
      />
    );
  }

  return (
    <div>
      <PageHeader
        title={`Welcome back, ${club.name}`}
        description="Here's what's happening with your club."
        actions={<CreateActivityDialog clubId={club.id} onCreated={load} />}
      />

      <div className="grid gap-4 sm:grid-cols-3">
        <StatCard icon={Users} label="Members" value={club.member_count} />
        <StatCard icon={Calendar} label="Upcoming events" value={stats.upcomingEvents} />
        <StatCard icon={UserPlus} label="Open recruitment" value={stats.openRecruitment} />
      </div>

      {pendingRequests.length > 0 && (
        <>
          <h2 className="mb-4 mt-8 text-sm font-semibold uppercase tracking-wide text-muted">
            Membership requests
          </h2>
          <div className="space-y-3">
            {pendingRequests.map((r) => (
              <Card key={r.id}>
                <CardContent className="flex items-center gap-3 p-4">
                  <Avatar src={r.profiles?.avatar_url} name={r.profiles?.name ?? "Student"} size={36} />
                  <div className="min-w-0 flex-1">
                    <p className="truncate text-sm font-medium">{r.profiles?.name ?? "Student"}</p>
                    <p className="truncate text-xs text-muted">
                      {[r.profiles?.department, r.profiles?.year].filter(Boolean).join(" · ")}
                    </p>
                  </div>
                  <button
                    onClick={() => respond(r, "rejected")}
                    disabled={reviewingId === r.id}
                    aria-label="Reject"
                    className="rounded-lg bg-danger-soft p-2 text-danger transition hover:opacity-80 disabled:opacity-40"
                  >
                    <X className="h-4 w-4" />
                  </button>
                  <button
                    onClick={() => respond(r, "accepted")}
                    disabled={reviewingId === r.id}
                    aria-label="Accept"
                    className="rounded-lg bg-success-soft p-2 text-success transition hover:opacity-80 disabled:opacity-40"
                  >
                    <Check className="h-4 w-4" />
                  </button>
                </CardContent>
              </Card>
            ))}
          </div>
        </>
      )}

      <h2 className="mb-4 mt-8 text-sm font-semibold uppercase tracking-wide text-muted">
        Recent activity
      </h2>

      {posts.length === 0 ? (
        <EmptyState
          icon={ImageIcon}
          title="This club hasn't posted anything yet."
          description="Use Create Activity to publish your first announcement, post, or event."
        />
      ) : (
        <div className="space-y-4">
          {posts.map((p) => (
            <PostCard key={p.id} post={p} canDelete onDeleted={load} />
          ))}
        </div>
      )}
    </div>
  );
}

function StatCard({
  icon: Icon,
  label,
  value,
}: {
  icon: typeof Users;
  label: string;
  value: number;
}) {
  return (
    <Card>
      <CardContent className="flex items-center gap-4 p-5">
        <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-brand-soft">
          <Icon className="h-5 w-5 text-brand" />
        </div>
        <div>
          <p className="text-2xl font-semibold tracking-tight">{value}</p>
          <p className="text-xs text-muted">{label}</p>
        </div>
      </CardContent>
    </Card>
  );
}
