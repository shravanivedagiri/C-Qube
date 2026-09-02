import { GraduationCap, Users2 } from "lucide-react";
import { CampusTicker } from "@/components/shared/campus-ticker";
import { RoleCard } from "@/components/shared/role-card";
import { ThemeToggle } from "@/components/shared/theme-toggle";
import { Wordmark } from "@/components/shared/wordmark";

export default function LandingPage() {
  return (
    <div className="flex min-h-screen flex-col bg-background">
      <header className="mx-auto flex w-full max-w-6xl items-center justify-between px-6 py-6">
        <Wordmark className="text-lg" />
        <ThemeToggle />
      </header>

      <main className="relative flex flex-1 flex-col items-center justify-center overflow-hidden px-6 py-16 text-center">
        <div
          aria-hidden
          className="bg-campus-grid pointer-events-none absolute inset-0 -z-10 [mask-image:radial-gradient(ellipse_60%_50%_at_50%_0%,black,transparent)]"
        />

        <span className="mb-6 inline-flex items-center gap-2 rounded-full border border-border bg-surface px-3.5 py-1.5 font-mono text-[11px] uppercase tracking-[0.18em] text-muted">
          Your campus, one platform
        </span>

        <h1 className="font-display text-4xl font-semibold tracking-tight sm:text-5xl md:text-6xl">
          <Wordmark />
        </h1>

        <p className="mt-5 font-display text-xl font-medium text-foreground/80 sm:text-2xl">
          Campus <span className="text-brand">×</span> Club{" "}
          <span className="text-brand">×</span> Connect
        </p>

        <p className="mx-auto mt-4 max-w-xl text-balance text-base leading-relaxed text-muted sm:text-lg">
          Everything happening on your campus, connected in one place —
          clubs, events, recruitment drives, and the people you&rsquo;ll meet
          along the way.
        </p>

        <div className="mt-12 flex w-full flex-col items-center justify-center gap-6 sm:flex-row sm:items-stretch">
          <RoleCard
            icon={GraduationCap}
            eyebrow="For students"
            title="Student"
            description="Discover clubs, register for events, build your campus network, and track everything you're part of."
            loginHref="/auth/student/login"
            registerHref="/auth/student/register"
            registerLabel="Register"
            accent="brand"
          />
          <RoleCard
            icon={Users2}
            eyebrow="For clubs"
            title="Club"
            description="Run your club's presence — post updates, host events, open recruitment, and see who's engaging."
            loginHref="/auth/club/login"
            registerHref="/auth/club/register-request"
            registerLabel="Request access"
            accent="accent"
          />
        </div>
      </main>

      <CampusTicker />

      <footer className="px-6 py-5 text-center font-mono text-xs text-muted">
        C-QUBE — built for campus communities
      </footer>
    </div>
  );
}
