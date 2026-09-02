"use client";

import { CheckCircle2 } from "lucide-react";
import { Suspense, useState } from "react";
import { useSearchParams } from "next/navigation";
import { AuthShell } from "@/components/shared/auth-shell";
import { Button } from "@/components/ui/button";
import { FieldError, Input, Label, Select, Textarea } from "@/components/ui/input";
import { ALLOWED_EMAIL_DOMAIN, DEPARTMENTS, isAllowedCampusEmail } from "@/lib/constants";
import { ClubRequestService } from "@/services/club-service";

function ClubRegisterRequestForm() {
  const params = useSearchParams();
  const [form, setForm] = useState({
    club_name: "",
    club_email: params.get("email") ?? "",
    coordinator_name: "",
    coordinator_email: "",
    department: DEPARTMENTS[0],
    description: "",
    reason: "",
  });
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [submitted, setSubmitted] = useState(false);

  function set<K extends keyof typeof form>(key: K, value: (typeof form)[K]) {
    setForm((f) => ({ ...f, [key]: value }));
  }

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    if (!form.club_name || !form.club_email || !form.coordinator_name || !form.coordinator_email) {
      setError("Fill in the club name, club email, and coordinator details.");
      return;
    }
    if (!isAllowedCampusEmail(form.club_email) || !isAllowedCampusEmail(form.coordinator_email)) {
      setError(`Club and coordinator email must be @${ALLOWED_EMAIL_DOMAIN} addresses.`);
      return;
    }
    setLoading(true);
    const { error } = await ClubRequestService.submit(form);
    setLoading(false);
    if (error) {
      setError(error);
      return;
    }
    setSubmitted(true);
  }

  if (submitted) {
    return (
      <AuthShell eyebrow="Club" title="Request submitted">
        <div className="flex flex-col items-center py-4 text-center">
          <div className="mb-4 flex h-14 w-14 items-center justify-center rounded-full bg-success-soft">
            <CheckCircle2 className="h-7 w-7 text-success" />
          </div>
          <p className="text-sm leading-relaxed text-muted">
            Your request has been submitted. The college administration will review it and
            reach out to <strong className="text-foreground">{form.coordinator_email}</strong>{" "}
            once approved.
          </p>
        </div>
      </AuthShell>
    );
  }

  return (
    <AuthShell
      eyebrow="Club"
      title="Request club registration"
      description="Clubs aren't self-service — tell us about yours and the administration will review it."
    >
      <form onSubmit={onSubmit} className="space-y-4" noValidate>
        <div>
          <Label htmlFor="club_name">Club name</Label>
          <Input
            id="club_name"
            placeholder="Coding Club"
            value={form.club_name}
            onChange={(e) => set("club_name", e.target.value)}
          />
        </div>
        <div>
          <Label htmlFor="club_email">Club email</Label>
          <Input
            id="club_email"
            type="email"
            placeholder="club@bmsce.ac.in"
            value={form.club_email}
            onChange={(e) => set("club_email", e.target.value)}
          />
        </div>
        <div className="grid grid-cols-2 gap-3">
          <div>
            <Label htmlFor="coordinator_name">Coordinator name</Label>
            <Input
              id="coordinator_name"
              placeholder="Rahul Mehta"
              value={form.coordinator_name}
              onChange={(e) => set("coordinator_name", e.target.value)}
            />
          </div>
          <div>
            <Label htmlFor="coordinator_email">Coordinator email</Label>
            <Input
              id="coordinator_email"
              type="email"
              placeholder="rahul@bmsce.ac.in"
              value={form.coordinator_email}
              onChange={(e) => set("coordinator_email", e.target.value)}
            />
          </div>
        </div>
        <div>
          <Label htmlFor="department">Department</Label>
          <Select
            id="department"
            value={form.department}
            onChange={(e) => set("department", e.target.value)}
          >
            {DEPARTMENTS.map((d) => (
              <option key={d}>{d}</option>
            ))}
          </Select>
        </div>
        <div>
          <Label htmlFor="description">Short description</Label>
          <Textarea
            id="description"
            rows={3}
            placeholder="What does your club do?"
            value={form.description}
            onChange={(e) => set("description", e.target.value)}
          />
        </div>
        <div>
          <Label htmlFor="reason">Reason for requesting registration</Label>
          <Textarea
            id="reason"
            rows={3}
            placeholder="Why should this club be on C-QUBE?"
            value={form.reason}
            onChange={(e) => set("reason", e.target.value)}
          />
        </div>
        <FieldError>{error ?? undefined}</FieldError>
        <Button type="submit" fullWidth loading={loading}>
          Submit request
        </Button>
      </form>
    </AuthShell>
  );
}

export default function ClubRegisterRequestPage() {
  return (
    <Suspense>
      <ClubRegisterRequestForm />
    </Suspense>
  );
}
