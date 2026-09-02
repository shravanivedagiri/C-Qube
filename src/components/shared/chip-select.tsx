import { cn } from "@/lib/utils";

export function ChipSelect({
  options,
  value,
  onChange,
}: {
  options: readonly string[];
  value: string[];
  onChange: (value: string[]) => void;
}) {
  function toggle(option: string) {
    onChange(value.includes(option) ? value.filter((v) => v !== option) : [...value, option]);
  }

  return (
    <div className="flex flex-wrap gap-2">
      {options.map((o) => {
        const active = value.includes(o);
        return (
          <button
            key={o}
            type="button"
            onClick={() => toggle(o)}
            className={cn(
              "rounded-full border px-3.5 py-1.5 text-sm font-medium transition",
              active
                ? "border-brand bg-brand-soft text-brand"
                : "border-border text-muted hover:border-brand/40 hover:text-foreground"
            )}
          >
            {o}
          </button>
        );
      })}
    </div>
  );
}
