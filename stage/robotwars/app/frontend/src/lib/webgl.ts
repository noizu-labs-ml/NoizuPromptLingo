// Lightweight runtime checks the landing-page hero uses to decide whether to
// mount the GPU-accelerated diorama or fall back to a static illustration.
// TheRobotWars promises to run "on anything with a browser" — so the hero must
// degrade gracefully when WebGL is unavailable or the user prefers no motion.

export function hasWebGL(): boolean {
  if (typeof window === "undefined") return false;
  try {
    const canvas = document.createElement("canvas");
    const gl =
      canvas.getContext("webgl2") ||
      canvas.getContext("webgl") ||
      canvas.getContext("experimental-webgl");
    return !!gl;
  } catch {
    return false;
  }
}

export function prefersReducedMotion(): boolean {
  if (typeof window === "undefined") return false;
  return window.matchMedia?.("(prefers-reduced-motion: reduce)").matches ?? false;
}
