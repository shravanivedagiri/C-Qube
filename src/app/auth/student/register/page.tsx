"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { toast } from "sonner";
import { AuthShell } from "@/components/shared/auth-shell";
import { Button } from "@/components/ui/button";
import { FieldError, Input, Label, Select } from "@/components/ui/input";
import { ALLOWED_EMAIL_DOMAIN, DEPARTMENTS, YEARS, isAllowedCampusEmail } from "@/lib/constants";
import { AuthService } from "@/services/auth-service";

export default function StudentRegisterPage() {
  const router = useRouter();
  const [form, setForm] = useState({
    name: "",
    email: "",
    password: "",
    confirm: "",
    department: DEPARTMENTS[0],
    year: YEARS[0],
  });
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [emailSent, setEmailSent] = useState(false);

  function set<K extends keyof typeof form>(key: K, value: (typeof form)[K]) {
    setForm((f) => ({ ...f, [key]: value }));
  }

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);

    if (!form.name || !form.email || !form.password) {
      setError("Fill in your name, email, and password.");
      return;
    }
    if (!isAllowedCampusEmail(form.email)) {
      setError(`Use your campus email — it must end in @${ALLOWED_EMAIL_DOMAIN}.`);
      return;
    }
    if (form.password.length < 8) {
      setError("Password must be at least 8 characters.");
      return;
    }
    if (form.password !== form.confirm) {
      setError("Passwords don't match.");
      return;
    }

    setLoading(true);
    const { data, error } = await AuthService.signUpStudent({
      name: form.name,
      email: form.email,
      password: form.password,
      department: form.department,
      year: form.year,
    });
    setLoading(false);

    if (error) {
      setError(error);
      return;
    }
    if (data?.needsEmailConfirm) {
      setEmailSent(true);
      return;
    }
    toast.success("Account created — let's set up your profile.");
    router.push("/profile/setup");
    router.refresh();
  }

  if (emailSent) {
    return (
      <AuthShell eyebrow="Student" title="Check your inbox">
        <p className="text-sm leading-relaxed text-muted">
          We sent a confirmation link to <strong className="text-foreground">{form.email}</strong>.
          Confirm your email, then log in to finish setting up your profile.
        </p>
        <Link
          href="/auth/student/login"
          className="mt-6 inline-flex h-10 w-full items-center justify-center rounded-xl bg-brand text-sm font-medium text-brand-foreground transition hover:opacity-90"
        >
          Go to login
        </Link>
      </AuthShell>
    );
  }

  return (
    <AuthShell
      eyebrow="Student"
      title="Create your account"
      description="You'll add interests, skills, and a photo right after this."
    >
      <form onSubmit={onSubmit} className="space-y-4" noValidate>
        <div>
          <Label htmlFor="name">Full name</Label>
          <Input
            id="name"
            placeholder="Ananya Rao"
            value={form.name}
            onChange={(e) => set("name", e.target.value)}
          />
        </div>
        <div>
          <Label htmlFor="email">College email</Label>
          <Input
            id="email"
            type="email"
            placeholder="you@bmsce.ac.in"
            value={form.email}
            onChange={(e) => set("email", e.target.value)}
          />
        </div>
        <div className="grid grid-cols-2 gap-3">
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
            <Label htmlFor="year">Year</Label>
            <Select id="year" value={form.year} onChange={(e) => set("year", e.target.value)}>
              {YEARS.map((y) => (
                <option key={y}>{y}</option>
              ))}
            </Select>
          </div>
        </div>
        <div className="grid grid-cols-2 gap-3">
          <div>
            <Label htmlFor="password">Password</Label>
            <Input
              id="password"
              type="password"
              placeholder="••••••••"
              value={form.password}
              onChange={(e) => set("password", e.target.value)}
            />
          </div>
          <div>
            <Label htmlFor="confirm">Confirm</Label>
            <Input
              id="confirm"
              type="password"
              placeholder="••••••••"
              value={form.confirm}
              onChange={(e) => set("confirm", e.target.value)}
            />
          </div>
        </div>
        <FieldError>{error ?? undefined}</FieldError>
        <Button type="submit" fullWidth loading={loading}>
          Create account
        </Button>
      </form>

      <p className="mt-6 text-center text-sm text-muted">
        Already have an account?{" "}
        <Link href="/auth/student/login" className="font-medium text-brand hover:underline">
          Log in
        </Link>
      </p>
    </AuthShell>
  );
}
