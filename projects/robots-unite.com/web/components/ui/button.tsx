import { cn } from "@/lib/utils";
import { ButtonHTMLAttributes, forwardRef } from "react";

type ButtonVariant =
  | "primary"
  | "secondary"
  | "ghost"
  | "destructive"
  | "tournament";

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
  size?: "sm" | "md" | "lg";
}

const variants: Record<ButtonVariant, string> = {
  primary:
    "bg-orange text-text-on-accent border border-transparent hover:bg-orange-hover active:bg-orange-active focus-visible:outline-orange",
  secondary:
    "bg-transparent text-text-primary border border-border-default hover:bg-bg-elevated hover:border-border-strong active:bg-bg-inset",
  ghost:
    "bg-transparent text-text-secondary border border-transparent hover:text-text-primary hover:bg-bg-elevated active:bg-bg-inset",
  destructive:
    "bg-transparent text-error border border-error hover:bg-error-muted active:bg-[rgba(248,113,113,0.20)] focus-visible:outline-error",
  tournament:
    "bg-cyan text-text-on-accent border border-transparent font-semibold shadow-cyan-glow hover:bg-cyan-hover hover:shadow-[0_0_28px_var(--ru-cyan-glow)] active:bg-cyan-active active:shadow-[0_0_12px_var(--ru-cyan-glow)] focus-visible:outline-cyan",
};

const sizes = {
  sm: "px-3 py-2 text-sm min-h-11",
  md: "px-5 py-3 text-sm min-h-11",
  lg: "px-7 py-4 text-base font-semibold min-h-11",
};

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant = "primary", size = "md", ...props }, ref) => (
    <button
      ref={ref}
      className={cn(
        "inline-flex items-center justify-center gap-2 rounded-md font-medium leading-none whitespace-nowrap select-none transition-all duration-100 cursor-pointer",
        "focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-cyan",
        "disabled:opacity-40 disabled:cursor-not-allowed disabled:pointer-events-none",
        variants[variant],
        sizes[size],
        className
      )}
      {...props}
    />
  )
);
Button.displayName = "Button";
