"use client";

import { Flag } from "lucide-react";
import { useCallback, useEffect, useState } from "react";
import { toast } from "sonner";
import { PageHeader } from "@/components/layout/page-header";
import { Avatar } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Dialog, DialogContent } from "@/components/ui/dialog";
import { EmptyState } from "@/components/ui/empty-state";
import { Textarea } from "@/components/ui/input";
import { CardSkeleton } from "@/components/ui/skeleton";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { relativeTime } from "@/lib/utils";
import { AdminService, type ContentReport } from "@/services/admin-service";

const STATUS_VARIANT = {
  open: "danger",
  under_review: "warning",
  resolved: "success",
  dismissed: "neutral",
} as const;

export default function AdminReportsPage() {
  const [reports, setReports] = useState<ContentReport[]>([]);
  const [loading, setLoading] = useState(true);
  const [detail, setDetail] = useState<ContentReport | null>(null);
  const [note, setNote] = useState("");
  const [busy, setBusy] = useState(false);

  const load = useCallback(async () => {
    const { data, error } = await AdminService.listReports();
    if (error) toast.error(error);
    setReports(data ?? []);
    setLoading(false);
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  useEffect(() => {
    setNote(detail?.admin_note ?? "");
  }, [detail]);

  async function updateStatus(status: ContentReport["status"]) {
    if (!detail) return;
    setBusy(true);
    const { error, data } = await AdminService.updateReport(detail.id, { status, admin_note: note || undefined });
    setBusy(false);
    if (error) {
      toast.error(error);
      return;
    }
    toast.success(`Report marked ${status.replace("_", " ")}.`);
    setDetail(data);
    load();
  }

  if (loading) return <CardSkeleton />;

  const open = reports.filter((r) => r.status === "open" || r.status === "under_review");
  const closed = reports.filter((r) => r.status === "resolved" || r.status === "dismissed");

  return (
    <div>
      <PageHeader title="Reports" description="Review reported club content and decide what action to take." />

      <Tabs defaultValue="open">
        <TabsList>
          <TabsTrigger value="open">Needs review ({open.length})</TabsTrigger>
          <TabsTrigger value="closed">Resolved</TabsTrigger>
        </TabsList>

        <TabsContent value="open" className="mt-5">
          {open.length === 0 ? (
            <EmptyState icon={Flag} title="You&rsquo;re all caught up. No reports need your attention." />
          ) : (
            <ReportList reports={open} onOpen={setDetail} />
          )}
        </TabsContent>

        <TabsContent value="closed" className="mt-5">
          {closed.length === 0 ? (
            <EmptyState icon={Flag} title="No reports have been resolved yet." />
          ) : (
            <ReportList reports={closed} onOpen={setDetail} />
          )}
        </TabsContent>
      </Tabs>

      <Dialog open={!!detail} onOpenChange={(o) => !o && setDetail(null)}>
        {detail && (
          <DialogContent title="Report details" description={relativeTime(detail.created_at)}>
            <div className="space-y-4 text-sm">
              <div className="flex items-center gap-2">
                <Badge variant={STATUS_VARIANT[detail.status]}>{detail.status.replace("_", " ")}</Badge>
                <Badge variant="neutral" className="capitalize">{detail.reason.replace(/_/g, " ")}</Badge>
              </div>

              {detail.club && (
                <div className="flex items-center gap-2 rounded-lg border border-border p-2.5">
                  <Avatar src={detail.club.logo_url} name={detail.club.name} size={28} />
                  <span className="font-medium">{detail.club.name}</span>
                </div>
              )}

              {detail.post && (
                <div className="rounded-lg border border-border p-3">
                  <p className="text-xs font-medium uppercase text-muted">Reported content</p>
                  {detail.post.title && <p className="mt-1 font-medium">{detail.post.title}</p>}
                  {detail.post.content && <p className="mt-1 text-foreground/90">{detail.post.content}</p>}
                </div>
              )}

              {detail.reporter && (
                <p className="text-xs text-muted">Reported by {detail.reporter.name} ({detail.reporter.email})</p>
              )}
              {detail.description && (
                <div>
                  <p className="text-xs font-medium text-muted">Reporter&rsquo;s details</p>
                  <p className="mt-0.5">{detail.description}</p>
                </div>
              )}

              <div>
                <p className="mb-1.5 text-xs font-medium text-muted">Moderation note</p>
                <Textarea rows={2} value={note} onChange={(e) => setNote(e.target.value)} placeholder="Internal note (optional)" />
              </div>
            </div>

            <div className="mt-5 flex flex-wrap justify-end gap-2">
              {detail.status === "open" && (
                <Button variant="secondary" loading={busy} onClick={() => updateStatus("under_review")}>
                  Mark under review
                </Button>
              )}
              {detail.status !== "dismissed" && detail.status !== "resolved" && (
                <Button variant="secondary" loading={busy} onClick={() => updateStatus("dismissed")}>
                  Dismiss
                </Button>
              )}
              {detail.status !== "resolved" && (
                <Button loading={busy} onClick={() => updateStatus("resolved")}>
                  Resolve
                </Button>
              )}
            </div>
          </DialogContent>
        )}
      </Dialog>
    </div>
  );
}

function ReportList({ reports, onOpen }: { reports: ContentReport[]; onOpen: (r: ContentReport) => void }) {
  return (
    <div className="space-y-3">
      {reports.map((r) => (
        <Card key={r.id}>
          <button onClick={() => onOpen(r)} className="flex w-full items-center justify-between gap-4 p-5 text-left">
            <div className="min-w-0">
              <div className="flex items-center gap-2">
                <h3 className="truncate font-semibold">{r.club?.name ?? "Unknown club"}</h3>
                <Badge variant={STATUS_VARIANT[r.status]}>{r.status.replace("_", " ")}</Badge>
              </div>
              <p className="mt-1 truncate text-xs capitalize text-muted">
                {r.reason.replace(/_/g, " ")} · {relativeTime(r.created_at)}
              </p>
            </div>
          </button>
        </Card>
      ))}
    </div>
  );
}
