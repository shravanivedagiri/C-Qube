"use client";

import { Suspense, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { toast } from "sonner";
import { AuthShell } from "@/components/shared/auth-shell";
import { Button } from "@/components/ui/button";
import { FieldError, Input, Label } from "@/components/ui/input";
import { ALLOWED_EMAIL_DOMAIN, isAllowedCampusEmail } from "@/lib/constants";
import { AuthService } from "@/services/auth-service";

function ActivateClubForm() {
  const router = useRouter();
  const params = useSearchParams();
  const [clubEmail, setClubEmail] = useState(params.get("email") ?? "");
  const [coordinatorEmail, setCoordinatorEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirm, setConfirm] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    if (!clubEmail || !coordinatorEmail) {
      setError("Enter the club email and the coordinator email on file.");
      return;
    }
    if (!isAllowedCampusEmail(clubEmail) || !isAllowedCampusEmail(coordinatorEmail)) {
      setError(`Both emails must be @${ALLOWED_EMAIL_DOMAIN} addresses.`);
      return;
    }
    if (password.length < 8) {
      setError("Password must be at least 8 characters.");
      return;
    }
    if (password !== confirm) {
      setError("Passwords don't match.");
      return;
    }
    setLoading(true);
    const { error: activateError } = await AuthService.activateClub({
      club_email: clubEmail,
      coordinator_email: coordinatorEmail,
      password,
    });
    if (activateError) {
      setLoading(false);
      setError(activateError);
      return;
    }
    const { error: signInError } = await AuthService.signInClub(clubEmail, password);
    setLoading(false);
    if (signInError) {
      toast.success("Password set — log in to continue.");
      router.push("/auth/club/login");
      return;
    }
    toast.success("Account activated!");
    router.push("/dashboard");
    router.refresh();
  }

  return (
    <AuthShell
      eyebrow="Club"
      title="Set up your club account"
      description="Your club was approved, but no password has been set yet — create one below."
    >
      <form onSubmit={onSubmit} className="space-y-4" noValidate>
        <div>
          <Label htmlFor="club_email">Club email</Label>
          <Input
            id="club_email"
            type="email"
            placeholder="club@bmsce.ac.in"
            value={clubEmail}
            onChange={(e) => setClubEmail(e.target.value)}
          />
        </div>
        <div>
          <Label htmlFor="coordinator_email">Coordinator email on file</Label>
          <Input
            id="coordinator_email"
            type="email"
            placeholder="rahul@bmsce.ac.in"
            value={coordinatorEmail}
            onChange={(e) => setCoordinatorEmail(e.target.value)}
          />
        </div>
        <div>
          <Label htmlFor="password">New password</Label>
          <Input
            id="password"
            type="password"
            placeholder="••••••••"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
        </div>
        <div>
          <Label htmlFor="confirm">Confirm password</Label>
          <Input
            id="confirm"
            type="password"
            placeholder="••••••••"
            value={confirm}
            onChange={(e) => setConfirm(e.target.value)}
          />
        </div>
        <FieldError>{error ?? undefined}</FieldError>
        <Button type="submit" fullWidth loading={loading}>
          Activate account
        </Button>
      </form>
    </AuthShell>
  );
}

export default function ActivateClubPage() {
  return (
    <Suspense>
      <ActivateClubForm />
    </Suspense>
  );
}
