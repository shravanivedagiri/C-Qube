"use client";

/** Minimal, dependency-free bar + line charts built for the analytics
 * dashboards. Single-series, brand-colored, with direct value labels —
 * deliberately simple rather than a generic charting library. */

export function BarChart({
  data,
  height = 160,
}: {
  data: { label: string; value: number }[];
  height?: number;
}) {
  const max = Math.max(1, ...data.map((d) => d.value));
  return (
    <div className="flex items-end gap-3" style={{ height }}>
      {data.map((d) => (
        <div key={d.label} className="flex flex-1 flex-col items-center gap-2">
          <span className="text-xs font-medium text-foreground">{d.value}</span>
          <div className="flex w-full flex-1 items-end">
            <div
              className="w-full rounded-t-md bg-brand transition-all"
              style={{ height: `${Math.max(4, (d.value / max) * 100)}%` }}
            />
          </div>
          <span className="max-w-[4.5rem] truncate text-[11px] text-muted">{d.label}</span>
        </div>
      ))}
    </div>
  );
}

export function LineChart({
  data,
  height = 160,
}: {
  data: { label: string; value: number }[];
  height?: number;
}) {
  const width = 320;
  const pad = 12;
  const max = Math.max(1, ...data.map((d) => d.value));
  const step = data.length > 1 ? (width - pad * 2) / (data.length - 1) : 0;
  const points = data.map((d, i) => {
    const x = pad + i * step;
    const y = height - pad - (d.value / max) * (height - pad * 2);
    return { x, y, ...d };
  });
  const path = points.map((p, i) => `${i === 0 ? "M" : "L"}${p.x},${p.y}`).join(" ");
  const area = `${path} L${points[points.length - 1]?.x ?? 0},${height - pad} L${pad},${height - pad} Z`;

  return (
    <svg viewBox={`0 0 ${width} ${height}`} className="w-full" style={{ height }} preserveAspectRatio="none">
      <defs>
        <linearGradient id="lineFill" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor="var(--brand)" stopOpacity="0.25" />
          <stop offset="100%" stopColor="var(--brand)" stopOpacity="0" />
        </linearGradient>
      </defs>
      <path d={area} fill="url(#lineFill)" />
      <path d={path} fill="none" stroke="var(--brand)" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
      {points.map((p) => (
        <circle key={p.label} cx={p.x} cy={p.y} r={3} fill="var(--brand)" />
      ))}
    </svg>
  );
}

export function HBarList({ data }: { data: { label: string; value: number }[] }) {
  const max = Math.max(1, ...data.map((d) => d.value));
  return (
    <div className="space-y-3">
      {data.map((d) => (
        <div key={d.label}>
          <div className="mb-1 flex items-center justify-between text-xs">
            <span className="font-medium text-foreground">{d.label}</span>
            <span className="text-muted">{d.value}</span>
          </div>
          <div className="h-2 w-full overflow-hidden rounded-full bg-border/50">
            <div
              className="h-full rounded-full bg-accent"
              style={{ width: `${Math.max(4, (d.value / max) * 100)}%` }}
            />
          </div>
        </div>
      ))}
    </div>
  );
}
