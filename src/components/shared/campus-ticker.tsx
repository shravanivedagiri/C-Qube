// Generic, non-specific flavor text — deliberately makes no claims about
// real events/numbers for these clubs, since only their identity (name,
// about, logo, banner) comes from real data; their activity feeds are
// genuinely empty until real coordinators start posting.
const ACTIVITY = [
  "Protocol — Computer Science & Engineering Dept. Club",
  "OSCode BMSCE — a student-led tech community",
  "IEEE BMSCE — technical community",
  "Rotaract BMSCE — service, leadership, and community",
  "Pentagram — mathematical aptitude and logic",
  "Panache — BMSCE's fashion team",
  "Danceaddix — dance at BMSCE",
  "Mountaineering — adventure and outdoor activities",
];

export function CampusTicker() {
  const items = [...ACTIVITY, ...ACTIVITY];
  return (
    <div
      className="relative overflow-hidden border-y border-border bg-surface/60"
      aria-hidden="true"
    >
      <div className="flex w-max animate-marquee py-3">
        {items.map((text, i) => (
          <div key={i} className="flex items-center px-6 text-sm text-muted whitespace-nowrap">
            <span className="mr-2 font-display text-accent">×</span>
            {text}
          </div>
        ))}
      </div>
    </div>
  );
}
