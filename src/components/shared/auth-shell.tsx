import { ArrowLeft } from "lucide-react";
import Link from "next/link";
import type { ReactNode } from "react";
import { ThemeToggle } from "@/components/shared/theme-toggle";
import { Wordmark } from "@/components/shared/wordmark";

export function AuthShell({
  children,
  backHref = "/",
  eyebrow,
  title,
  description,
}: {
  children: ReactNode;
  backHref?: string;
  eyebrow: string;
  title: string;
  description?: string;
}) {
  return (
    <div className="flex min-h-screen flex-col bg-background">
      <header className="mx-auto flex w-full max-w-6xl items-center justify-between px-6 py-6">
        <Wordmark className="text-lg" />
        <ThemeToggle />
      </header>

      <main className="flex flex-1 items-center justify-center px-6 py-10">
        <div className="w-full max-w-md">
          <Link
            href={backHref}
            className="mb-6 inline-flex items-center gap-1.5 text-sm text-muted transition hover:text-foreground"
          >
            <ArrowLeft className="h-3.5 w-3.5" />
            Back
          </Link>

          <p className="font-mono text-[11px] uppercase tracking-[0.18em] text-muted">
            {eyebrow}
          </p>
          <h1 className="mt-1.5 font-display text-2xl font-semibold tracking-tight sm:text-3xl">
            {title}
          </h1>
          {description && (
            <p className="mt-2 text-sm leading-relaxed text-muted">{description}</p>
          )}

          <div className="mt-8 rounded-2xl border border-border bg-surface p-6 shadow-sm sm:p-7">
            {children}
          </div>
        </div>
      </main>
    </div>
  );
}
