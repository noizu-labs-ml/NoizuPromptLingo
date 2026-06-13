import { cn } from "@/lib/utils";
import { InputHTMLAttributes, forwardRef } from "react";

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {}

export const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ className, ...props }, ref) => (
    <input
      ref={ref}
      className={cn(
        "w-full rounded-md border border-border-default bg-bg-inset px-4 py-3 text-base text-text-primary min-h-11",
        "placeholder:text-text-tertiary",
        "hover:border-border-strong",
        "focus:border-cyan focus:outline-none focus:ring-[3px] focus:ring-cyan-muted",
        "disabled:opacity-40 disabled:cursor-not-allowed",
        "transition-colors duration-100",
        className
      )}
      {...props}
    />
  )
);
Input.displayName = "Input";
