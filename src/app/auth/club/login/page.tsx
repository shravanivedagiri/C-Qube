"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { toast } from "sonner";
import { AuthShell } from "@/components/shared/auth-shell";
import { Button } from "@/components/ui/button";
import { FieldError, Input, Label } from "@/components/ui/input";
import { AuthService } from "@/services/auth-service";

type Step = "email" | "password" | "not-registered" | "no-account-yet";

export default function ClubLoginPage() {
  const router = useRouter();
  const [step, setStep] = useState<Step>("email");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function checkEmail(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    if (!email) {
      setError("Enter your club's email.");
      return;
    }
    setLoading(true);
    const { data, error } = await AuthService.checkClubEmail(email);
    setLoading(false);
    if (error) {
      setError(error);
      return;
    }
    if (!data?.exists) {
      setStep("not-registered");
      return;
    }
    if (!data.hasAccount) {
      setStep("no-account-yet");
      return;
    }
    setStep("password");
  }

  async function signIn(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    if (!password) {
      setError("Enter your password.");
      return;
    }
    setLoading(true);
    const { error } = await AuthService.signInClub(email, password);
    setLoading(false);
    if (error) {
      setError(error);
      return;
    }
    toast.success("Welcome back!");
    router.push("/dashboard");
    router.refresh();
  }

  if (step === "not-registered") {
    return (
      <AuthShell eyebrow="Club" title="Your club isn&rsquo;t registered with C-QUBE yet">
        <p className="text-sm leading-relaxed text-muted">
          We couldn&rsquo;t find an approved club using{" "}
          <strong className="text-foreground">{email}</strong>. Submit a request and the
          college administration will review it.
        </p>
        <div className="mt-6 flex gap-3">
          <Button variant="secondary" fullWidth onClick={() => setStep("email")}>
            Try another email
          </Button>
          <Link
            href={`/auth/club/register-request?email=${encodeURIComponent(email)}`}
            className="inline-flex h-10 flex-1 items-center justify-center rounded-xl bg-brand text-sm font-medium text-brand-foreground transition hover:opacity-90"
          >
            Request registration
          </Link>
        </div>
      </AuthShell>
    );
  }

  if (step === "no-account-yet") {
    return (
      <AuthShell eyebrow="Club" title="Almost there">
        <p className="text-sm leading-relaxed text-muted">
          <strong className="text-foreground">{email}</strong> is an approved club, but no
          password has been set up yet. Set one now to finish activating the account.
        </p>
        <div className="mt-6 flex gap-3">
          <Button variant="secondary" fullWidth onClick={() => setStep("email")}>
            Try another email
          </Button>
          <Link
            href={`/auth/club/activate?email=${encodeURIComponent(email)}`}
            className="inline-flex h-10 flex-1 items-center justify-center rounded-xl bg-brand text-sm font-medium text-brand-foreground transition hover:opacity-90"
          >
            Set up password
          </Link>
        </div>
      </AuthShell>
    );
  }

  if (step === "password") {
    return (
      <AuthShell eyebrow="Club" title="Welcome back" description={email}>
        <form onSubmit={signIn} className="space-y-4" noValidate>
          <div>
            <div className="flex items-center justify-between">
              <Label htmlFor="password">Password</Label>
              <Link
                href="/auth/forgot-password"
                className="mb-1.5 text-xs font-medium text-brand hover:underline"
              >
                Forgot password?
              </Link>
            </div>
            <Input
              id="password"
              type="password"
              autoFocus
              placeholder="••••••••"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
          </div>
          <FieldError>{error ?? undefined}</FieldError>
          <Button type="submit" fullWidth loading={loading}>
            Log in
          </Button>
          <button
            type="button"
            onClick={() => setStep("email")}
            className="w-full text-center text-xs text-muted hover:text-foreground"
          >
            Use a different email
          </button>
        </form>
      </AuthShell>
    );
  }

  return (
    <AuthShell
      eyebrow="Club"
      title="Club sign in"
      description="Enter your club's registered email to continue."
    >
      <form onSubmit={checkEmail} className="space-y-4" noValidate>
        <div>
          <Label htmlFor="email">Club email</Label>
          <Input
            id="email"
            type="email"
            placeholder="club@bmsce.ac.in"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
        </div>
        <FieldError>{error ?? undefined}</FieldError>
        <Button type="submit" fullWidth loading={loading}>
          Continue
        </Button>
      </form>

      <p className="mt-6 text-center text-sm text-muted">
        Not registered yet?{" "}
        <Link href="/auth/club/register-request" className="font-medium text-brand hover:underline">
          Request club registration
        </Link>
      </p>
    </AuthShell>
  );
}
