"use client";

import { Sparkles } from "lucide-react";
import { useEffect, useState } from "react";
import { PageHeader } from "@/components/layout/page-header";
import { BarChart, HBarList, LineChart } from "@/components/shared/charts";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { CardSkeleton } from "@/components/ui/skeleton";
import { AnalyticsService, type ClubAnalytics } from "@/services/analytics-service";

function SourceBadge({ source }: { source: "mock" | "supabase" | "databricks" }) {
  if (source === "supabase") return null;
  if (source === "databricks") {
    return (
      <Badge variant="brand" className="ml-2">
        Databricks Delta
      </Badge>
    );
  }
  return (
    <Badge variant="warning" className="ml-2">
      Illustrative
    </Badge>
  );
}

export default function ClubAnalyticsPage() {
  const [data, setData] = useState<ClubAnalytics | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    AnalyticsService.getClubAnalytics().then((d) => {
      setData(d);
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

  if (!data) {
    return <p className="text-sm text-muted">Analytics aren&rsquo;t available right now.</p>;
  }

  return (
    <div>
      <PageHeader
        title="Analytics"
        description="How your club is performing across C-QUBE."
        actions={
          <span className="flex items-center gap-1.5 text-xs text-muted">
            <Sparkles className="h-3.5 w-3.5 text-brand" />
            Full pipeline lands via Databricks
          </span>
        }
      />

      <div className="grid gap-4 sm:grid-cols-3">
        <Stat label="Profile views" value={data.profileViews.value} source={data.profileViews.source} />
        <Stat label="Active members" value={data.activeMembers.value} source={data.activeMembers.source} />
        <Stat
          label="Recruitment applications"
          value={data.recruitmentApplications.value}
          source={data.recruitmentApplications.source}
        />
        <Stat
          label="Event attendance"
          value={`${data.eventAttendance.attended}/${data.eventAttendance.registered}`}
          source={data.eventAttendance.source}
        />
        <Stat label="Gallery items" value={data.galleryItemCount.value} source={data.galleryItemCount.source} />
        <Stat label="Gallery engagement" value={data.galleryEngagement.value} source={data.galleryEngagement.source} />
      </div>

      <div className="mt-6 grid gap-4 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>
              Event registrations
              <SourceBadge source={data.eventRegistrationTrend.source} />
            </CardTitle>
          </CardHeader>
          <CardContent>
            {data.eventRegistrationTrend.data.length ? (
              <LineChart data={data.eventRegistrationTrend.data} />
            ) : (
              <EmptyChart />
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>
              Post engagement by type
              <SourceBadge source={data.postEngagementByType.source} />
            </CardTitle>
          </CardHeader>
          <CardContent>
            {data.postEngagementByType.data.length ? (
              <BarChart data={data.postEngagementByType.data} />
            ) : (
              <EmptyChart />
            )}
          </CardContent>
        </Card>

        <Card className="lg:col-span-2">
          <CardHeader>
            <CardTitle>
              Student interests among followers
              <SourceBadge source={data.studentInterests.source} />
            </CardTitle>
          </CardHeader>
          <CardContent>
            {data.studentInterests.data.length ? (
              <HBarList data={data.studentInterests.data} />
            ) : (
              <EmptyChart />
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}

function Stat({
  label,
  value,
  source,
}: {
  label: string;
  value: number | string;
  source: "mock" | "supabase" | "databricks";
}) {
  return (
    <Card>
      <CardContent className="p-5">
        <div className="flex items-center">
          <p className="text-2xl font-semibold tracking-tight">{value}</p>
          <SourceBadge source={source} />
        </div>
        <p className="mt-1 text-xs text-muted">{label}</p>
      </CardContent>
    </Card>
  );
}

function EmptyChart() {
  return <p className="py-10 text-center text-sm text-muted">Not enough data yet.</p>;
}
