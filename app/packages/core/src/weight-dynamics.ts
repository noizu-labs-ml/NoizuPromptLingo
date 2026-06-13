export interface DecayConfig {
  halfLifeHours: number;
}

export function computeDecay(
  currentWeight: number,
  hoursSinceLastReinforcement: number,
  config: DecayConfig
): number {
  return currentWeight * Math.pow(0.5, hoursSinceLastReinforcement / config.halfLifeHours);
}

export function reinforce(
  currentWeight: number,
  relevanceScore: number,
  baseBoost: number = 0.1
): number {
  const boost = baseBoost * relevanceScore;
  return Math.min(1.0, currentWeight + boost * (1.0 - currentWeight));
}

export function denforce(
  currentWeight: number,
  penalty: number = 0.05
): number {
  return Math.max(0.0, currentWeight - penalty);
}

export function hebbianCoActivation(
  currentWeight: number,
  coActivationCount: number,
  baseBoost: number = 0.05
): number {
  const diminishingFactor = 1 / (1 + coActivationCount * 0.1);
  const boost = baseBoost * diminishingFactor;
  return Math.min(1.0, currentWeight + boost * (1.0 - currentWeight));
}

export function shouldPrune(weight: number, threshold: number = 0.05): boolean {
  return weight < threshold;
}

export interface DecayScheduleEntry {
  memoryId: string;
  currentWeight: number;
  hoursSinceReinforcement: number;
  halfLifeHours: number;
}

export function computeDecayBatch(entries: DecayScheduleEntry[]): Map<string, number> {
  const results = new Map<string, number>();
  for (const entry of entries) {
    results.set(
      entry.memoryId,
      computeDecay(entry.currentWeight, entry.hoursSinceReinforcement, {
        halfLifeHours: entry.halfLifeHours,
      })
    );
  }
  return results;
}
