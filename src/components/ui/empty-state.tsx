import type { LucideIcon } from "lucide-react";
import Link from "next/link";
import type { ReactNode } from "react";

export function EmptyState({
  icon: Icon,
  title,
  description,
  actionLabel,
  actionHref,
  action,
}: {
  icon: LucideIcon;
  title: string;
  description?: string;
  actionLabel?: string;
  actionHref?: string;
  action?: ReactNode;
}) {
  return (
    <div className="flex flex-col items-center justify-center rounded-2xl border border-dashed border-border bg-surface/50 px-6 py-14 text-center">
      <div className="mb-4 flex h-14 w-14 items-center justify-center rounded-full bg-brand-soft">
        <Icon className="h-6 w-6 text-brand" />
      </div>
      <h3 className="text-base font-semibold">{title}</h3>
      {description && (
        <p className="mt-1.5 max-w-sm text-sm text-muted">{description}</p>
      )}
      {actionLabel && actionHref && (
        <Link
          href={actionHref}
          className="mt-5 inline-flex h-10 items-center justify-center rounded-xl bg-brand px-5 text-sm font-medium text-brand-foreground transition hover:opacity-90"
        >
          {actionLabel}
        </Link>
      )}
      {action}
    </div>
  );
}
