"use client";

import { motion, useTransform, useReducedMotion } from "framer-motion";
import { useScrollSequence } from "@/components/ScrollSequenceContext";

export function HeroNodesSVG() {
  const progress = useScrollSequence();
  const reduced = useReducedMotion();
  const nodeScale = useTransform(progress, [0.15, 0.35], [0, 1]);
  const nodeOpacity = useTransform(progress, [0.15, 0.3], [0, 1]);

  return (
    <svg
      viewBox="0 0 1440 800"
      fill="none"
      className="w-full h-full"
      preserveAspectRatio="xMidYMid slice"
    >
      {/* Upper-right node cluster */}
      <motion.g style={{ opacity: nodeOpacity, scale: nodeScale }} transformOrigin="980 200">
        <circle cx="950" cy="160" r="6" fill="rgba(255,202,2,0.3)" />
        <circle cx="1060" cy="200" r="4" fill="rgba(255,202,2,0.25)" />
        <circle cx="1000" cy="260" r="5" fill="rgba(255,202,2,0.2)" />
        <line x1="950" y1="160" x2="1060" y2="200" stroke="rgba(255,202,2,0.15)" strokeWidth="1" />
        <line x1="1060" y1="200" x2="1000" y2="260" stroke="rgba(255,202,2,0.12)" strokeWidth="1" />
        <line x1="1000" y1="260" x2="950" y2="160" stroke="rgba(255,202,2,0.08)" strokeWidth="1" />
      </motion.g>

      {/* Lower-left node cluster */}
      <motion.g style={{ opacity: nodeOpacity, scale: nodeScale }} transformOrigin="250 580">
        <circle cx="300" cy="540" r="5" fill="rgba(255,202,2,0.25)" />
        <circle cx="200" cy="590" r="3" fill="rgba(255,202,2,0.18)" />
        <circle cx="280" cy="630" r="4" fill="rgba(255,202,2,0.2)" />
        <line x1="300" y1="540" x2="200" y2="590" stroke="rgba(255,202,2,0.12)" strokeWidth="1" />
        <line x1="200" y1="590" x2="280" y2="630" stroke="rgba(255,202,2,0.1)" strokeWidth="1" />
      </motion.g>

      {/* Center node */}
      <motion.g style={{ opacity: nodeOpacity, scale: nodeScale }} transformOrigin="720 400">
        <circle cx="720" cy="400" r="5" fill="rgba(255,202,2,0.3)" />
        {/* Pulsing ring — uses SMIL animate, disabled when reduced motion preferred */}
        {!reduced ? (
          <circle cx="720" cy="400" r="12" stroke="rgba(255,202,2,0.2)" strokeWidth="1" fill="none">
            <animate attributeName="r" values="12;22;12" dur="4s" repeatCount="indefinite" />
            <animate attributeName="opacity" values="0.2;0;0.2" dur="4s" repeatCount="indefinite" />
          </circle>
        ) : (
          <circle cx="720" cy="400" r="12" stroke="rgba(255,202,2,0.2)" strokeWidth="1" fill="none" opacity="0.1" />
        )}
      </motion.g>

      {/* Scattered individual nodes */}
      <motion.circle style={{ opacity: nodeOpacity }} cx="400" cy="180" r="2" fill="rgba(255,202,2,0.12)" />
      <motion.circle style={{ opacity: nodeOpacity }} cx="1200" cy="600" r="2" fill="rgba(255,202,2,0.12)" />
      <motion.circle style={{ opacity: nodeOpacity }} cx="150" cy="350" r="1.5" fill="rgba(255,202,2,0.1)" />
    </svg>
  );
}
