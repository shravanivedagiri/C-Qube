"use client";

import { Check, Inbox, X } from "lucide-react";
import { useCallback, useEffect, useState } from "react";
import { toast } from "sonner";
import { PageHeader } from "@/components/layout/page-header";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Dialog, DialogContent } from "@/components/ui/dialog";
import { EmptyState } from "@/components/ui/empty-state";
import { Textarea } from "@/components/ui/input";
import { CardSkeleton } from "@/components/ui/skeleton";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { formatDate } from "@/lib/utils";
import { AdminService, type ClubRegistrationRequest } from "@/services/admin-service";

const STATUS_VARIANT = {
  pending: "warning",
  approved: "success",
  rejected: "danger",
} as const;

export default function ClubRequestsPage() {
  const [requests, setRequests] = useState<ClubRegistrationRequest[]>([]);
  const [loading, setLoading] = useState(true);
  const [detail, setDetail] = useState<ClubRegistrationRequest | null>(null);
  const [rejecting, setRejecting] = useState<ClubRegistrationRequest | null>(null);
  const [rejectionReason, setRejectionReason] = useState("");
  const [busy, setBusy] = useState(false);

  const load = useCallback(async () => {
    const { data, error } = await AdminService.listClubRequests();
    if (error) toast.error(error);
    setRequests(data ?? []);
    setLoading(false);
  }, []);

  useEffect(() => {
    load();
  }, [load]);

  async function approve(req: ClubRegistrationRequest) {
    setBusy(true);
    const { error } = await AdminService.approveClubRequest(req.id);
    setBusy(false);
    if (error) {
      toast.error(error);
      return;
    }
    toast.success(`${req.club_name} approved.`);
    setDetail(null);
    load();
  }

  async function reject() {
    if (!rejecting) return;
    setBusy(true);
    const { error } = await AdminService.rejectClubRequest(rejecting.id, rejectionReason || undefined);
    setBusy(false);
    if (error) {
      toast.error(error);
      return;
    }
    toast.success(`${rejecting.club_name} rejected.`);
    setRejecting(null);
    setRejectionReason("");
    setDetail(null);
    load();
  }

  if (loading) return <CardSkeleton />;

  const pending = requests.filter((r) => r.status === "pending");
  const processed = requests.filter((r) => r.status !== "pending");

  return (
    <div>
      <PageHeader title="Club Requests" description="Review and process club registration requests." />

      <Tabs defaultValue="pending">
        <TabsList>
          <TabsTrigger value="pending">Pending ({pending.length})</TabsTrigger>
          <TabsTrigger value="processed">Processed</TabsTrigger>
        </TabsList>

        <TabsContent value="pending" className="mt-5">
          {pending.length === 0 ? (
            <EmptyState icon={Inbox} title="No pending club requests." />
          ) : (
            <RequestList requests={pending} onOpen={setDetail} />
          )}
        </TabsContent>

        <TabsContent value="processed" className="mt-5">
          {processed.length === 0 ? (
            <EmptyState icon={Inbox} title="No club registration requests have been processed yet." />
          ) : (
            <RequestList requests={processed} onOpen={setDetail} />
          )}
        </TabsContent>
      </Tabs>

      <Dialog open={!!detail} onOpenChange={(o) => !o && setDetail(null)}>
        {detail && (
          <DialogContent title={detail.club_name} description={`Submitted ${formatDate(detail.created_at)}`}>
            <div className="space-y-3 text-sm">
              <Field label="Club email" value={detail.club_email} />
              <Field label="Coordinator" value={`${detail.coordinator_name} — ${detail.coordinator_email}`} />
              <Field label="Department" value={detail.department ?? "—"} />
              <Field label="Description" value={detail.description ?? "—"} />
              <Field label="Reason" value={detail.reason ?? "—"} />
              <div className="flex items-center gap-2 pt-1">
                <span className="text-xs font-medium text-muted">Status</span>
                <Badge variant={STATUS_VARIANT[detail.status]}>{detail.status}</Badge>
              </div>
              {detail.status === "rejected" && detail.rejection_reason && (
                <Field label="Rejection reason" value={detail.rejection_reason} />
              )}
            </div>
            {detail.status === "pending" && (
              <div className="mt-5 flex justify-end gap-2">
                <Button
                  variant="danger"
                  icon={<X className="h-4 w-4" />}
                  onClick={() => {
                    setRejecting(detail);
                  }}
                >
                  Reject
                </Button>
                <Button loading={busy} icon={<Check className="h-4 w-4" />} onClick={() => approve(detail)}>
                  Approve
                </Button>
              </div>
            )}
          </DialogContent>
        )}
      </Dialog>

      <Dialog open={!!rejecting} onOpenChange={(o) => !o && setRejecting(null)}>
        {rejecting && (
          <DialogContent title={`Reject ${rejecting.club_name}?`} description="Optionally explain why — the coordinator will see this.">
            <Textarea
              rows={3}
              placeholder="Rejection reason (optional)"
              value={rejectionReason}
              onChange={(e) => setRejectionReason(e.target.value)}
            />
            <div className="mt-4 flex justify-end gap-2">
              <Button variant="secondary" onClick={() => setRejecting(null)}>
                Cancel
              </Button>
              <Button variant="danger" loading={busy} onClick={reject}>
                Confirm rejection
              </Button>
            </div>
          </DialogContent>
        )}
      </Dialog>
    </div>
  );
}

function RequestList({
  requests,
  onOpen,
}: {
  requests: ClubRegistrationRequest[];
  onOpen: (r: ClubRegistrationRequest) => void;
}) {
  return (
    <div className="space-y-3">
      {requests.map((r) => (
        <Card key={r.id}>
          <button onClick={() => onOpen(r)} className="flex w-full items-center justify-between gap-4 p-5 text-left">
            <div>
              <div className="flex items-center gap-2">
                <h3 className="font-semibold">{r.club_name}</h3>
                <Badge variant={STATUS_VARIANT[r.status]}>{r.status}</Badge>
              </div>
              <p className="mt-1 text-xs text-muted">
                {r.coordinator_name} · {r.coordinator_email} · {formatDate(r.created_at)}
              </p>
            </div>
          </button>
        </Card>
      ))}
    </div>
  );
}

function Field({ label, value }: { label: string; value: string }) {
  return (
    <div>
      <p className="text-xs font-medium text-muted">{label}</p>
      <p className="mt-0.5 text-foreground">{value}</p>
    </div>
  );
}
