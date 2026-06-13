import type { EmotionalMetadata, VADVector, HormonalState } from "./types/emotion.js";

export function vadDistance(a: VADVector, b: VADVector): number {
  return Math.sqrt(
    (a.valence - b.valence) ** 2 +
    (a.arousal - b.arousal) ** 2 +
    (a.dominance - b.dominance) ** 2
  );
}

export function hormonalDistance(a: HormonalState, b: HormonalState): number {
  return Math.sqrt(
    (a.cortisol - b.cortisol) ** 2 +
    (a.dopamine - b.dopamine) ** 2 +
    (a.oxytocin - b.oxytocin) ** 2 +
    (a.serotonin - b.serotonin) ** 2
  );
}

export function emotionalDistance(a: EmotionalMetadata, b: EmotionalMetadata): number {
  const vadDist = vadDistance(a.mood, b.mood);
  const hormoneDist = hormonalDistance(a.hormones, b.hormones);
  // VAD is weighted more heavily (3 dimensions vs 4, but more meaningful)
  return vadDist * 0.6 + hormoneDist * 0.4;
}

export function emotionalResonance(current: EmotionalMetadata, memory: EmotionalMetadata): number {
  const distance = emotionalDistance(current, memory);
  // Max possible distance: sqrt(4 + 1 + 1) * 0.6 + sqrt(1+1+1+1) * 0.4 ≈ 1.47 + 0.8 = 2.27
  const maxDistance = 2.27;
  return Math.max(0, 1 - distance / maxDistance);
}

export function emotionalStateToBucket(state: EmotionalMetadata): string {
  const bucketize = (v: number, min: number, max: number): number => {
    const normalized = (v - min) / (max - min);
    return Math.min(4, Math.floor(normalized * 5));
  };

  const v = bucketize(state.mood.valence, -1, 1);
  const a = bucketize(state.mood.arousal, 0, 1);
  const d = bucketize(state.mood.dominance, 0, 1);
  const c = bucketize(state.hormones.cortisol, 0, 1);
  const dp = bucketize(state.hormones.dopamine, 0, 1);
  const o = bucketize(state.hormones.oxytocin, 0, 1);
  const s = bucketize(state.hormones.serotonin, 0, 1);

  return `${v}${a}${d}${c}${dp}${o}${s}`;
}

export function clamp(value: number, min: number, max: number): number {
  return Math.max(min, Math.min(max, value));
}

export function updateHormones(
  current: HormonalState,
  signals: Partial<Record<keyof HormonalState, number>>,
  learningRate: number = 0.1
): HormonalState {
  return {
    cortisol: clamp(current.cortisol + (signals.cortisol ?? 0) * learningRate, 0, 1),
    dopamine: clamp(current.dopamine + (signals.dopamine ?? 0) * learningRate, 0, 1),
    oxytocin: clamp(current.oxytocin + (signals.oxytocin ?? 0) * learningRate, 0, 1),
    serotonin: clamp(current.serotonin + (signals.serotonin ?? 0) * learningRate, 0, 1),
  };
}
