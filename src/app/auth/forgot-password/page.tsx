"use client";

import { MailCheck } from "lucide-react";
import { useState } from "react";
import { AuthShell } from "@/components/shared/auth-shell";
import { Button } from "@/components/ui/button";
import { FieldError, Input, Label } from "@/components/ui/input";
import { AuthService } from "@/services/auth-service";

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [sent, setSent] = useState(false);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    if (!email) {
      setError("Enter your email.");
      return;
    }
    setLoading(true);
    const { error } = await AuthService.requestPasswordReset(email);
    setLoading(false);
    if (error) {
      setError(error);
      return;
    }
    setSent(true);
  }

  if (sent) {
    return (
      <AuthShell eyebrow="Reset password" title="Check your inbox">
        <div className="flex flex-col items-center py-4 text-center">
          <div className="mb-4 flex h-14 w-14 items-center justify-center rounded-full bg-brand-soft">
            <MailCheck className="h-7 w-7 text-brand" />
          </div>
          <p className="text-sm leading-relaxed text-muted">
            If an account exists for <strong className="text-foreground">{email}</strong>,
            we&rsquo;ve sent a link to reset your password.
          </p>
        </div>
      </AuthShell>
    );
  }

  return (
    <AuthShell
      eyebrow="Reset password"
      title="Forgot your password?"
      description="We'll email you a link to set a new one."
    >
      <form onSubmit={onSubmit} className="space-y-4" noValidate>
        <div>
          <Label htmlFor="email">Email</Label>
          <Input
            id="email"
            type="email"
            placeholder="you@bmsce.ac.in"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
        </div>
        <FieldError>{error ?? undefined}</FieldError>
        <Button type="submit" fullWidth loading={loading}>
          Send reset link
        </Button>
      </form>
    </AuthShell>
  );
}
