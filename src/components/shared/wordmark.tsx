import { cn } from "@/lib/utils";

/**
 * The C-QUBE wordmark: the hyphen is replaced by a small rotated square
 * ("the cube") in the accent color — a literal, recurring signature mark
 * used again on role cards and section dividers.
 */
export function Wordmark({ className }: { className?: string }) {
  return (
    <span
      className={cn(
        "inline-flex items-center gap-[0.14em] font-display font-semibold tracking-tight",
        className
      )}
    >
      C
      <span
        aria-hidden
        className="inline-block h-[0.32em] w-[0.32em] shrink-0 translate-y-[-0.05em] rotate-45 bg-accent"
      />
      QUBE
    </span>
  );
}
