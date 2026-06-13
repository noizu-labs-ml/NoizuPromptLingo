"use client";

import { motion, useReducedMotion } from "framer-motion";
import { ReactNode } from "react";

interface TextRevealProps {
  children: string;
  as?: "h1" | "h2" | "h3" | "p" | "span";
  className?: string;
  stagger?: number;
  duration?: number;
  gradient?: boolean;
}

export function TextReveal({
  children,
  as: Tag = "h2",
  className = "",
  stagger = 0.05,
  duration = 0.4,
  gradient = false,
}: TextRevealProps) {
  const reduced = useReducedMotion();
  const words = children.split(" ");

  if (reduced) {
    return <Tag className={className}>{children}</Tag>;
  }

  return (
    <Tag className={className}>
      <motion.span
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true, margin: "-50px" }}
        variants={{ hidden: {}, visible: { transition: { staggerChildren: stagger } } }}
        style={{ display: "inline" }}
      >
        {words.map((word, i) => (
          <motion.span
            key={i}
            variants={{
              hidden: { opacity: 0, y: 20 },
              visible: { opacity: 1, y: 0, transition: { duration, ease: "easeOut" } },
            }}
            className={`inline-block ${gradient ? "gradient-text" : ""}`}
            style={{ marginRight: "0.25em" }}
          >
            {word}
          </motion.span>
        ))}
      </motion.span>
    </Tag>
  );
}

interface GradientWordProps {
  children: string;
  className?: string;
}

export function GradientWord({ children, className = "" }: GradientWordProps) {
  return <span className={`gradient-text ${className}`}>{children}</span>;
}
