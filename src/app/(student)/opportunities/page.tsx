"use client";

import { Check, UserPlus } from "lucide-react";
import { useCallback, useEffect, useState } from "react";
import { toast } from "sonner";
import { PageHeader } from "@/components/layout/page-header";
import { Avatar } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Dialog, DialogContent } from "@/components/ui/dialog";
import { EmptyState } from "@/components/ui/empty-state";
import { FieldError, Input, Label } from "@/components/ui/input";
import { CardSkeleton } from "@/components/ui/skeleton";
import { useCurrentProfile } from "@/hooks/use-current-profile";
import { formatDate } from "@/lib/utils";
import { RecruitmentService, type DriveWithClub } from "@/services/recruitment-service";

export default function OpportunitiesPage() {
  const { user } = useCurrentProfile();
  const [drives, setDrives] = useState<DriveWithClub[]>([]);
  const [applied, setApplied] = useState<Set<string>>(new Set());
  const [loading, setLoading] = useState(true);
  const [activeDrive, setActiveDrive] = useState<DriveWithClub | null>(null);

  const load = useCallback(async () => {
    const { data } = await RecruitmentService.listOpen();
    setDrives(data ?? []);
    if (user && data) {
      const results = await Promise.all(
        data.map(async (d) => [d.id, await RecruitmentService.hasApplied(d.id, user.id)] as const)
      );
      setApplied(new Set(results.filter(([, has]) => has).map(([id]) => id)));
    }
    setLoading(false);
  }, [user]);

  useEffect(() => {
    load();
  }, [load]);

  function onApplied(driveId: string) {
    setApplied((prev) => new Set(prev).add(driveId));
    setActiveDrive(null);
  }

  return (
    <div>
      <PageHeader
        title="Recruitment"
        description="Open drives from clubs across campus — apply straight from here."
      />

      {loading ? (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {[1, 2, 3].map((i) => (
            <CardSkeleton key={i} />
          ))}
        </div>
      ) : drives.length === 0 ? (
        <EmptyState icon={UserPlus} title="No open recruitment drives right now" description="Check back soon." />
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {drives.map((d) => {
            const deadlinePassed = new Date(d.deadline) < new Date();
            const hasApplied = applied.has(d.id);
            return (
              <Card key={d.id} className="p-5">
                <div className="flex items-center gap-2.5">
                  <Avatar src={d.clubs?.logo_url} name={d.clubs?.name ?? "Club"} size={32} />
                  <span className="text-sm font-medium text-brand">{d.clubs?.name}</span>
                </div>
                <h3 className="mt-3 font-semibold">{d.title}</h3>
                {d.description && (
                  <p className="mt-1 line-clamp-2 text-xs text-muted">{d.description}</p>
                )}
                <div className="mt-3 flex flex-wrap gap-1.5">
                  {d.positions.map((p) => (
                    <Badge key={p} variant="accent">
                      {p}
                    </Badge>
                  ))}
                </div>
                <p className="mt-3 text-xs text-muted">Apply by {formatDate(d.deadline)}</p>
                {hasApplied ? (
                  <Button variant="secondary" fullWidth className="mt-4" icon={<Check className="h-4 w-4" />} disabled>
                    Applied
                  </Button>
                ) : (
                  <Button
                    fullWidth
                    className="mt-4"
                    disabled={deadlinePassed}
                    onClick={() => setActiveDrive(d)}
                  >
                    {deadlinePassed ? "Closed" : "Apply"}
                  </Button>
                )}
              </Card>
            );
          })}
        </div>
      )}

      <Dialog open={!!activeDrive} onOpenChange={(o) => !o && setActiveDrive(null)}>
        {activeDrive && (
          <DialogContent
            title={`Apply — ${activeDrive.title}`}
            description={activeDrive.clubs?.name ?? undefined}
          >
            <ApplyForm drive={activeDrive} studentId={user?.id} onApplied={() => onApplied(activeDrive.id)} />
          </DialogContent>
        )}
      </Dialog>
    </div>
  );
}

function ApplyForm({
  drive,
  studentId,
  onApplied,
}: {
  drive: DriveWithClub;
  studentId?: string;
  onApplied: () => void;
}) {
  const [answers, setAnswers] = useState<Record<string, string>>({});
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  async function submit() {
    if (!studentId) {
      toast.info("Log in as a student to apply.");
      return;
    }
    setError(null);
    const missing = drive.questions.find((q) => q.required && !answers[q.id]?.trim());
    if (missing) {
      setError(`"${missing.question}" is required.`);
      return;
    }
    setSubmitting(true);
    const { error: applyError } = await RecruitmentService.apply(drive.id, studentId, answers);
    setSubmitting(false);
    if (applyError) {
      setError(applyError);
      return;
    }
    toast.success("Application submitted!");
    onApplied();
  }

  return (
    <div className="space-y-4">
      {drive.questions.length === 0 ? (
        <p className="text-sm text-muted">This drive has no extra questions — just confirm to apply.</p>
      ) : (
        drive.questions.map((q) => (
          <div key={q.id}>
            <Label htmlFor={q.id}>
              {q.question}
              {q.required && <span className="text-danger"> *</span>}
            </Label>
            <Input
              id={q.id}
              value={answers[q.id] ?? ""}
              onChange={(e) => setAnswers((a) => ({ ...a, [q.id]: e.target.value }))}
            />
          </div>
        ))
      )}
      <FieldError>{error ?? undefined}</FieldError>
      <Button fullWidth loading={submitting} onClick={submit}>
        Submit application
      </Button>
    </div>
  );
}
