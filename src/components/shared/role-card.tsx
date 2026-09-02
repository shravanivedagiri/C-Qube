import Link from "next/link";

export function RoleCard({
  eyebrow,
  title,
  description,
  loginHref,
  registerHref,
  registerLabel,
}: {
  eyebrow: string;
  title: string;
  description: string;
  loginHref: string;
  registerHref: string;
  registerLabel: string;
}) {
  return (
    <div className="group relative w-full max-w-sm rounded-[1.75rem] border border-border bg-surface p-6 shadow-md transition hover:-translate-y-1 hover:shadow-lg">
      {/* punch mark, campus-ID style */}
      <span
        aria-hidden
        className="absolute right-6 top-6 h-3 w-3 rotate-45 border border-border"
      />

      <p className="font-mono text-[11px] uppercase tracking-[0.18em] text-muted">
        {eyebrow}
      </p>
      <h3 className="mt-1 font-display text-2xl font-semibold tracking-tight">
        {title}
      </h3>
      <p className="mt-2 text-sm leading-relaxed text-muted">{description}</p>

      {/* perforated divider, ticket-stub style */}
      <div className="relative my-6 border-t border-dashed border-border">
        <span className="absolute -left-9 -top-2.5 h-5 w-5 rounded-full bg-background" />
        <span className="absolute -right-9 -top-2.5 h-5 w-5 rounded-full bg-background" />
      </div>

      <div className="flex items-center gap-3">
        <Link
          href={loginHref}
          className="inline-flex h-10 flex-1 items-center justify-center rounded-xl bg-brand text-sm font-medium text-brand-foreground transition hover:opacity-90"
        >
          Log in
        </Link>
        <Link
          href={registerHref}
          className="inline-flex h-10 flex-1 items-center justify-center rounded-xl border border-border text-sm font-medium text-foreground transition hover:bg-border/40"
        >
          {registerLabel}
        </Link>
      </div>

      {/* barcode strip */}
      <div className="mt-6 flex h-4 items-end gap-[3px] opacity-40">
        {[3, 1, 2, 1, 4, 1, 1, 3, 2, 1, 1, 4, 2, 1, 3, 1, 2, 4, 1, 1].map((w, i) => (
          <span
            key={i}
            className="bg-foreground"
            style={{ width: 2, height: `${w * 3}px` }}
          />
        ))}
      </div>
    </div>
  );
}
