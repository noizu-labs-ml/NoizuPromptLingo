"use client";

import { useEffect, useRef, useState } from "react";

export default function CounterAnimation({
  target,
  className,
}: {
  target: number;
  className?: string;
}) {
  const [display, setDisplay] = useState("0");
  const ref = useRef<HTMLSpanElement>(null);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;

    const observer = new IntersectionObserver((entries) => {
      if (entries[0].isIntersecting) {
        const duration = 2000;
        const steps = 40;
        const increment = target / steps;
        const interval = duration / steps;
        let current = 0;

        const timer = setInterval(() => {
          current += increment;
          if (current >= target) {
            setDisplay(target.toLocaleString());
            clearInterval(timer);
          } else {
            setDisplay(Math.floor(current).toLocaleString());
          }
        }, interval);

        observer.disconnect();
      }
    });

    observer.observe(el);
    return () => observer.disconnect();
  }, [target]);

  return (
    <strong ref={ref} className={className}>
      {display}
    </strong>
  );
}
