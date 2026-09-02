"use client";

import { UserPlus, Users } from "lucide-react";
import { useCallback, useEffect, useState } from "react";
import { toast } from "sonner";
import { CreateActivityDialog } from "@/components/club/create-activity-dialog";
import { PageHeader } from "@/components/layout/page-header";
import { Avatar } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Card } from "@/components/ui/card";
import { Dialog, DialogContent } from "@/components/ui/dialog";
import { EmptyState } from "@/components/ui/empty-state";
import { Select } from "@/components/ui/input";
import { CardSkeleton } from "@/components/ui/skeleton";
import { useCurrentProfile } from "@/hooks/use-current-profile";
import { formatDate } from "@/lib/utils";
import { ClubService } from "@/services/club-service";
import {
  type ApplicationWithStudent,
  RecruitmentService,
} from "@/services/recruitment-service";
import type { Database } from "@/types/database";

type Drive = Database["public"]["Tables"]["recruitment_drives"]["Row"];
type ApplicationStatus = Database["public"]["Tables"]["recruitment_applications"]["Row"]["status"];

const STATUS_OPTIONS: ApplicationStatus[] = [
  "applied",
  "under_review",
  "shortlisted",
  "selected",
  "rejected",
];

const STATUS_VARIANT: Record<ApplicationStatus, "neutral" | "brand" | "accent" | "success" | "danger"> = {
  applied: "neutral",
  under_review: "brand",
  shortlisted: "accent",
  selected: "success",
  rejected: "danger",
};

export default function RecruitmentPage() {
  const { user } = useCurrentProfile();
  const [clubId, setClubId] = useState<string | null>(null);
  const [drives, setDrives] = useState<(Drive & { application_count: number })[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeDrive, setActiveDrive] = useState<Drive | null>(null);

  const load = useCallback(async () => {
    if (!user) return;
    const { data: club } = await ClubService.getMyClub(user.id);
    if (!club) {
      setLoading(false);
      return;
    }
    setClubId(club.id);
    const { data } = await RecruitmentService.listByClub(club.id);
    const withCounts = await Promise.all(
      (data ?? []).map(async (d) => {
        const { data: apps } = await RecruitmentService.listApplications(d.id);
        return { ...d, application_count: apps?.length ?? 0 };
      })
    );
    setDrives(withCounts);
    setLoading(false);
  }, [user]);

  useEffect(() => {
    load();
  }, [load]);

  if (loading) return <CardSkeleton />;

  return (
    <div>
      <PageHeader
        title="Recruitment"
        description="Open drives, manage applicants, track decisions."
        actions={clubId && <CreateActivityDialog clubId={clubId} onCreated={load} />}
      />

      {drives.length === 0 ? (
        <EmptyState
          icon={UserPlus}
          title="No recruitment drives yet"
          description="Use Create Activity → Open Recruitment to start one."
        />
      ) : (
        <div className="space-y-3">
          {drives.map((d) => (
            <Card key={d.id}>
              <div className="flex flex-wrap items-center justify-between gap-4 p-5">
                <div>
                  <div className="flex items-center gap-2">
                    <h3 className="font-semibold">{d.title}</h3>
                    <Badge variant={d.status === "open" ? "success" : "neutral"}>
                      {d.status === "open" ? "Open" : "Closed"}
                    </Badge>
                  </div>
                  <p className="mt-1 text-xs text-muted">
                    Deadline {formatDate(d.deadline)} · {d.positions.join(", ") || "General"}
                  </p>
                </div>
                <button
                  onClick={() => setActiveDrive(d)}
                  className="flex items-center gap-1.5 rounded-lg border border-border px-3 py-1.5 text-sm font-medium transition hover:bg-border/40"
                >
                  <Users className="h-4 w-4" />
                  {d.application_count} applicant{d.application_count === 1 ? "" : "s"}
                </button>
              </div>
            </Card>
          ))}
        </div>
      )}

      <Dialog open={!!activeDrive} onOpenChange={(o) => !o && setActiveDrive(null)}>
        {activeDrive && (
          <DialogContent title={activeDrive.title} description="Applicants" className="max-w-xl">
            <ApplicantList driveId={activeDrive.id} />
          </DialogContent>
        )}
      </Dialog>
    </div>
  );
}

function ApplicantList({ driveId }: { driveId: string }) {
  const [apps, setApps] = useState<ApplicationWithStudent[]>([]);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    const { data } = await RecruitmentService.listApplications(driveId);
    setApps(data ?? []);
    setLoading(false);
  }, [driveId]);

  useEffect(() => {
    load();
  }, [load]);

  async function updateStatus(id: string, status: ApplicationStatus) {
    setApps((prev) => prev.map((a) => (a.id === id ? { ...a, status } : a)));
    const { error } = await RecruitmentService.updateStatus(id, status);
    if (error) toast.error(error);
  }

  if (loading) return <CardSkeleton />;
  if (apps.length === 0) {
    return <p className="py-6 text-center text-sm text-muted">No applications yet.</p>;
  }

  return (
    <div className="max-h-[60vh] space-y-3 overflow-y-auto">
      {apps.map((a) => (
        <div key={a.id} className="flex items-center gap-3 rounded-xl border border-border p-3">
          <Avatar src={a.profiles?.avatar_url} name={a.profiles?.name ?? "Student"} size={36} />
          <div className="min-w-0 flex-1">
            <p className="truncate text-sm font-medium">{a.profiles?.name}</p>
            <p className="truncate text-xs text-muted">{a.profiles?.email}</p>
          </div>
          <Badge variant={STATUS_VARIANT[a.status]}>{a.status.replace("_", " ")}</Badge>
          <Select
            value={a.status}
            onChange={(e) => updateStatus(a.id, e.target.value as ApplicationStatus)}
            className="w-auto"
          >
            {STATUS_OPTIONS.map((s) => (
              <option key={s} value={s}>
                {s.replace("_", " ")}
              </option>
            ))}
          </Select>
        </div>
      ))}
    </div>
  );
}
