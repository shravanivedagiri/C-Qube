"use client";

import { Calendar, CheckCircle2, Flag, Inbox, ShieldCheck, Users } from "lucide-react";
import Link from "next/link";
import { useEffect, useState } from "react";
import { PageHeader } from "@/components/layout/page-header";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent } from "@/components/ui/card";
import { CardSkeleton } from "@/components/ui/skeleton";
import { formatDate, relativeTime } from "@/lib/utils";
import { AdminService, type AdminDashboardStats } from "@/services/admin-service";

export default function AdminDashboardPage() {
  const [stats, setStats] = useState<AdminDashboardStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    AdminService.getDashboard().then(({ data, error }) => {
      setStats(data);
      setError(error);
      setLoading(false);
    });
  }, []);

  if (loading) {
    return (
      <div className="grid gap-4 sm:grid-cols-3">
        {[1, 2, 3, 4, 5, 6].map((i) => (
          <CardSkeleton key={i} />
        ))}
      </div>
    );
  }

  if (error || !stats) {
    return (
      <div>
        <PageHeader title="Dashboard" description="Campus-wide administration." />
        <p className="text-sm text-danger">{error ?? "Couldn't load the dashboard."}</p>
      </div>
    );
  }

  return (
    <div>
      <PageHeader title="Dashboard" description="Campus-wide administration." />

      <div className="grid gap-4 sm:grid-cols-3">
        <Stat icon={ShieldCheck} label="Approved clubs" value={stats.totalApprovedClubs} />
        <Stat icon={Inbox} label="Pending requests" value={stats.pendingClubRequests} />
        <Stat icon={Calendar} label="Upcoming events" value={stats.totalUpcomingEvents} />
        <Stat icon={Flag} label="Open reports" value={stats.openReports} />
        <Stat icon={CheckCircle2} label="Resolved reports" value={stats.resolvedReports} />
        <Stat icon={Users} label="Active clubs" value={stats.totalApprovedClubs} />
      </div>

      <div className="mt-8 grid gap-6 lg:grid-cols-2">
        <Section title="Pending club requests" href="/admin/club-requests">
          {stats.pendingRequestsPreview.length === 0 ? (
            <p className="text-sm text-muted">No pending club requests.</p>
          ) : (
            <div className="space-y-2">
              {stats.pendingRequestsPreview.map((r) => (
                <Row key={r.id} title={r.club_name} subtitle={r.coordinator_email} meta={relativeTime(r.created_at)} />
              ))}
            </div>
          )}
        </Section>

        <Section title="Recent reports" href="/admin/reports">
          {stats.recentReports.length === 0 ? (
            <p className="text-sm text-muted">You&rsquo;re all caught up. No reports need your attention.</p>
          ) : (
            <div className="space-y-2">
              {stats.recentReports.map((r) => (
                <Row
                  key={r.id}
                  title={r.club?.name ?? "Unknown club"}
                  subtitle={r.reason.replace(/_/g, " ")}
                  meta={<Badge variant={r.status === "open" ? "danger" : "neutral"}>{r.status.replace("_", " ")}</Badge>}
                />
              ))}
            </div>
          )}
        </Section>

        <Section title="Recently approved clubs" href="/admin/club-requests?status=approved">
          {stats.recentlyApprovedClubs.length === 0 ? (
            <p className="text-sm text-muted">No club registration requests have been processed yet.</p>
          ) : (
            <div className="space-y-2">
              {stats.recentlyApprovedClubs.map((r) => (
                <Row key={r.id} title={r.club_name} subtitle={r.department ?? ""} meta={r.reviewed_at ? formatDate(r.reviewed_at) : ""} />
              ))}
            </div>
          )}
        </Section>

        <Section title="Global calendar" href="/admin/calendar">
          <p className="text-sm text-muted">
            Monitor every approved club&rsquo;s events for campus-wide scheduling conflicts.
          </p>
        </Section>
      </div>
    </div>
  );
}

function Stat({ icon: Icon, label, value }: { icon: typeof Users; label: string; value: number }) {
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

function Section({ title, href, children }: { title: string; href: string; children: React.ReactNode }) {
  return (
    <Card>
      <CardContent className="p-5">
        <div className="mb-3 flex items-center justify-between">
          <h2 className="text-sm font-semibold uppercase tracking-wide text-muted">{title}</h2>
          <Link href={href} className="text-xs font-medium text-brand hover:underline">
            View all
          </Link>
        </div>
        {children}
      </CardContent>
    </Card>
  );
}

function Row({ title, subtitle, meta }: { title: string; subtitle: string; meta: React.ReactNode }) {
  return (
    <div className="flex items-center justify-between gap-3 rounded-lg border border-border px-3 py-2">
      <div className="min-w-0">
        <p className="truncate text-sm font-medium">{title}</p>
        <p className="truncate text-xs capitalize text-muted">{subtitle}</p>
      </div>
      <span className="shrink-0 text-xs text-muted">{meta}</span>
    </div>
  );
}
