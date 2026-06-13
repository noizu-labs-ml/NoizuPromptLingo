"use client";

// hero-diorama.tsx — the GPU-accelerated landing hero for TheRobotWars.
//
// A warm-lit, slowly rotating low-poly diorama: a glowing "SPARK crystal"
// (faction core) floating over a hex homestead platform, ringed by small
// drifting agent-cubes. Built with low-poly primitives (no GLTF download) so it
// stays light enough to honor the project's "runs on a Chromebook" promise.
//
// Art-direction alignment (assets/art-direction.md):
//   - warm key light (deep gold / amber), cool lavender-blue rim/shadow
//   - soft bloom-ish emissive glow, never harsh
//   - gentle float + slow auto-rotate, disabled under prefers-reduced-motion
//
// This module is only ever loaded client-side (via next/dynamic ssr:false in
// hero.tsx), so importing three/@react-three is safe here.

import { Canvas, useFrame } from "@react-three/fiber";
import {
  Float,
  OrbitControls,
  ContactShadows,
  Environment,
} from "@react-three/drei";
import { useMemo, useRef } from "react";
import type { Group, Mesh } from "three";
import { prefersReducedMotion } from "@/lib/webgl";

// Warm palette pulled from the art-direction lighting table.
const GOLD = "#FFD54F";
const AMBER = "#FFB347";
const PEACH = "#FFDAB9";
const LAVENDER = "#B0A4C8";
const DEEP_PURPLE = "#5C4A72";

function SparkCrystal() {
  const ref = useRef<Mesh>(null);
  useFrame((_, delta) => {
    if (ref.current) ref.current.rotation.y += delta * 0.35;
  });
  return (
    <mesh ref={ref} castShadow>
      {/* icosahedron, detail 0 = faceted low-poly gem */}
      <icosahedronGeometry args={[1.05, 0]} />
      <meshStandardMaterial
        color={GOLD}
        emissive={AMBER}
        emissiveIntensity={0.55}
        metalness={0.35}
        roughness={0.25}
        flatShading
      />
    </mesh>
  );
}

function AgentCube({
  radius,
  speed,
  offset,
  color,
}: {
  radius: number;
  speed: number;
  offset: number;
  color: string;
}) {
  const ref = useRef<Mesh>(null);
  useFrame((state) => {
    const t = state.clock.elapsedTime * speed + offset;
    if (ref.current) {
      ref.current.position.set(
        Math.cos(t) * radius,
        Math.sin(t * 1.3) * 0.35 + 0.2,
        Math.sin(t) * radius
      );
      ref.current.rotation.x += 0.01;
      ref.current.rotation.y += 0.015;
    }
  });
  return (
    <mesh ref={ref} castShadow>
      <boxGeometry args={[0.28, 0.28, 0.28]} />
      <meshStandardMaterial
        color={color}
        emissive={color}
        emissiveIntensity={0.2}
        roughness={0.4}
        metalness={0.2}
        flatShading
      />
    </mesh>
  );
}

function HexPlatform() {
  return (
    <mesh position={[0, -1.45, 0]} receiveShadow rotation={[0, Math.PI / 6, 0]}>
      {/* 6-sided cylinder = hex tile, nodding to the isometric homestead grid */}
      <cylinderGeometry args={[2.1, 2.3, 0.5, 6]} />
      <meshStandardMaterial
        color={PEACH}
        roughness={0.85}
        metalness={0.05}
        flatShading
      />
    </mesh>
  );
}

function Scene({ reduced }: { reduced: boolean }) {
  const group = useRef<Group>(null);
  const cubes = useMemo(
    () => [
      { radius: 1.9, speed: 0.5, offset: 0, color: "#7FB3D5" }, // NEI blue
      { radius: 2.2, speed: 0.38, offset: 2.1, color: "#E59866" }, // human warm
      { radius: 1.7, speed: 0.62, offset: 4.2, color: "#A9DFBF" }, // fay green
    ],
    []
  );

  return (
    <group ref={group} position={[0, 0.2, 0]}>
      {/* Key light: warm afternoon gold from the west */}
      <directionalLight
        position={[4, 6, 3]}
        intensity={2.4}
        color={GOLD}
        castShadow
        shadow-mapSize-width={1024}
        shadow-mapSize-height={1024}
      />
      {/* Cool lavender rim/fill so shadows read blue-violet, never black */}
      <directionalLight position={[-5, 2, -4]} intensity={0.8} color={LAVENDER} />
      <ambientLight intensity={0.5} color={PEACH} />
      <pointLight position={[0, 1.5, 0]} intensity={1.2} color={AMBER} distance={6} />

      <Float
        speed={reduced ? 0 : 1.4}
        rotationIntensity={reduced ? 0 : 0.4}
        floatIntensity={reduced ? 0 : 0.8}
      >
        <SparkCrystal />
      </Float>

      {cubes.map((c, i) => (
        <AgentCube key={i} {...c} />
      ))}

      <HexPlatform />

      <ContactShadows
        position={[0, -1.18, 0]}
        opacity={0.4}
        scale={8}
        blur={2.6}
        far={4}
        color={DEEP_PURPLE}
      />
      <Environment preset="sunset" />
    </group>
  );
}

export default function HeroDiorama() {
  const reduced = prefersReducedMotion();
  return (
    <Canvas
      shadows
      dpr={[1, 2]}
      camera={{ position: [0, 1.2, 6], fov: 42 }}
      gl={{ antialias: true, alpha: true }}
      aria-hidden="true"
    >
      <Scene reduced={reduced} />
      <OrbitControls
        enablePan={false}
        enableZoom={false}
        autoRotate={!reduced}
        autoRotateSpeed={0.6}
        minPolarAngle={Math.PI / 3}
        maxPolarAngle={Math.PI / 2.1}
      />
    </Canvas>
  );
}
