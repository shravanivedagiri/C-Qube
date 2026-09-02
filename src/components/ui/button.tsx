import { Loader2 } from "lucide-react";
import Link from "next/link";
import type { ButtonHTMLAttributes, ReactNode } from "react";
import { cn } from "@/lib/utils";

const variants = {
  primary:
    "bg-brand text-brand-foreground hover:opacity-90 shadow-sm",
  secondary:
    "bg-surface border border-border text-foreground hover:bg-border/40",
  ghost: "text-foreground hover:bg-border/40",
  danger: "bg-danger text-white hover:opacity-90",
  accent: "bg-accent text-accent-foreground hover:opacity-90",
} as const;

const sizes = {
  sm: "h-8 px-3 text-sm rounded-lg gap-1.5",
  md: "h-10 px-4 text-sm rounded-xl gap-2",
  lg: "h-12 px-6 text-base rounded-xl gap-2",
} as const;

interface BaseProps {
  variant?: keyof typeof variants;
  size?: keyof typeof sizes;
  loading?: boolean;
  icon?: ReactNode;
  fullWidth?: boolean;
}

type ButtonProps = BaseProps &
  ButtonHTMLAttributes<HTMLButtonElement> & { href?: undefined };
type LinkButtonProps = BaseProps & {
  href: string;
  children?: ReactNode;
  className?: string;
};

export function Button({
  variant = "primary",
  size = "md",
  loading,
  icon,
  fullWidth,
  className,
  children,
  disabled,
  ...props
}: ButtonProps) {
  return (
    <button
      className={cn(
        "inline-flex items-center justify-center font-medium transition disabled:opacity-50 disabled:pointer-events-none cursor-pointer",
        variants[variant],
        sizes[size],
        fullWidth && "w-full",
        className
      )}
      disabled={disabled || loading}
      {...props}
    >
      {loading ? <Loader2 className="h-4 w-4 animate-spin" /> : icon}
      {children}
    </button>
  );
}

export function LinkButton({
  variant = "primary",
  size = "md",
  icon,
  fullWidth,
  className,
  children,
  href,
}: LinkButtonProps) {
  return (
    <Link
      href={href}
      className={cn(
        "inline-flex items-center justify-center font-medium transition cursor-pointer",
        variants[variant],
        sizes[size],
        fullWidth && "w-full",
        className
      )}
    >
      {icon}
      {children}
    </Link>
  );
}
