import clsx from "clsx";

export function Logomark({
  className,
  ...props
}: React.ComponentPropsWithoutRef<"svg"> & {}) {
  return (
    <svg
      viewBox="0 0 134.17 134.17"
      className={clsx("transition-all duration-300", className)}
      {...props}
    >
      <circle
        cx="67.08"
        cy="67.08"
        r="67.08"
        transform="translate(-9.93 122.49) rotate(-80.73)"
        className="fill-gold-400"
      />
      <path
        d="m69.28,20.56c-32.11,0-54.93,24.54-54.93,53.83,0,19.29,9.28,29.54,19.53,29.54,20.26,0,34-35.34,37.38-75.28,27.18.83,39.52,18.75,39.52,38.41,0,20.97-11.91,34.17-35.16,40.44v8.59c28.17-7.02,44.19-21.07,44.19-49.4,0-23.8-15.26-46.14-50.54-46.14Zm-35.16,74.83c-5.86,0-11.48-8.18-11.48-21.24,0-21.36,15.26-41.75,39.92-44.8-3.05,33.45-13.67,66.04-28.44,66.04Z"
        className="fill-zinc-950"
      />
    </svg>
  );
}

export function Logo({
  className,
  invert = false,
  ...props
}: React.ComponentPropsWithoutRef<"svg"> & {
  invert?: boolean;
}) {
  return (
    <svg
      viewBox="0 0 340 50"
      aria-hidden="true"
      className={clsx("group/logo", className)}
      {...props}
    >
      <Logomark preserveAspectRatio="xMinYMid meet" />
      <path
        transform="translate(50, 0)"
        className={invert ? "fill-white" : "fill-zinc-100"}
        d="
    M9.34,44.38V10.77h3.84c5.23,8.06,17.52,26.83,19.63,30.48h.05c-.29-4.85-.24-9.79-.24-15.27v-15.22h2.64v33.6h-3.55
    c-4.99-7.78-17.47-27.31-19.87-31.01h-.05c.24,4.42.19,9.31.19,15.41v15.6h-2.64Z
    M63.34,32.33c0,6.67-3.7,12.62-10.85,12.62-6.48,0-10.51-5.33-10.51-12.58
    0-6.86,3.79-12.58,10.75-12.58,6.38,0,10.61,4.99,10.61,12.53Z
    M44.52,32.38c0,5.71,3.07,10.32,8.16,10.32s8.11-4.27,8.11-10.32
    c0-5.66-2.88-10.32-8.21-10.32s-8.06,4.56-8.06,10.32Z
    M69.48,9h2.4v4.66h-2.4v-4.66ZM69.48,20.37h2.4v24h-2.4v-24Z
    M77.25,42.17l15.17-19.54h-14.4v-2.26h17.19v2.3l-14.98,19.44h15.51l-.58,2.26h-17.91v-2.21Z
    M118.06,37.37c0,2.35.05,6.1.05,7.01h-2.3c-.1-.62-.14-2.21-.14-4.18
    -1.01,2.83-3.46,4.75-7.73,4.75-3.46,0-7.87-1.34-7.87-8.69v-15.89h2.35v15.31
    c0,3.5,1.1,6.91,5.86,6.91,5.38,0,7.39-3.02,7.39-9.89v-12.34h2.4v16.99Z"
      />
    </svg>
  );
}

export function LogoWithSuffix({
  className,
  suffix = "Labs",
  invert = false,
  ...props
}: React.ComponentPropsWithoutRef<"div"> & {
  suffix?: string;
  invert?: boolean;
}) {
  return (
    <div className={clsx("flex items-center gap-3", className)} {...props}>
      <Logomark className="h-9 w-9" />
      <div className="flex items-baseline gap-1.5">
        <span
          className={clsx(
            "font-semibold text-lg tracking-tight",
            invert ? "text-white" : "text-zinc-100"
          )}
        >
          noizu
        </span>
        <span className="text-sm font-medium text-gold-400">{suffix}</span>
      </div>
    </div>
  );
}
