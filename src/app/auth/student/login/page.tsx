"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { toast } from "sonner";
import { AuthShell } from "@/components/shared/auth-shell";
import { Button } from "@/components/ui/button";
import { FieldError, Input, Label } from "@/components/ui/input";
import { AuthService } from "@/services/auth-service";

export default function StudentLoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    if (!email || !password) {
      setError("Enter your email and password.");
      return;
    }
    setLoading(true);
    const { error } = await AuthService.signInStudent(email, password);
    setLoading(false);
    if (error) {
      setError(error);
      return;
    }
    toast.success("Welcome back!");
    router.push("/home");
    router.refresh();
  }

  return (
    <AuthShell
      eyebrow="Student"
      title="Log in to C-QUBE"
      description="Pick up where you left off — clubs, events, and your campus network."
    >
      <form onSubmit={onSubmit} className="space-y-4" noValidate>
        <div>
          <Label htmlFor="email">College email</Label>
          <Input
            id="email"
            type="email"
            autoComplete="email"
            placeholder="you@bmsce.ac.in"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
        </div>
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
            autoComplete="current-password"
            placeholder="••••••••"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
        </div>
        <FieldError>{error ?? undefined}</FieldError>
        <Button type="submit" fullWidth loading={loading}>
          Log in
        </Button>
      </form>

      <p className="mt-6 text-center text-sm text-muted">
        New to C-QUBE?{" "}
        <Link href="/auth/student/register" className="font-medium text-brand hover:underline">
          Create an account
        </Link>
      </p>
    </AuthShell>
  );
}
