import { execSync } from 'node:child_process';
import type { Readable } from 'node:stream';

interface Recording {
  stream: Readable;
  stop: () => void;
}

export function checkSoxInstalled(): boolean {
  try {
    execSync('which sox', { stdio: 'ignore' });
    return true;
  } catch {
    return false;
  }
}

export async function startRecording(): Promise<Recording> {
  const record = await import('node-record-lpcm16');
  const recording = record.default.record({
    sampleRate: 16000,
    channels: 1,
    audioType: 'wav',
    recorder: 'sox',
  });

  const stream = recording.stream();

  return {
    stream,
    stop: () => recording.stop(),
  };
}

export async function collectBuffer(stream: Readable): Promise<Buffer> {
  const chunks: Buffer[] = [];
  for await (const chunk of stream) {
    chunks.push(Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk));
  }
  return Buffer.concat(chunks);
}

export function computeAmplitude(chunk: Buffer): number {
  if (chunk.length < 2) return 0;
  let sumSquares = 0;
  const sampleCount = Math.floor(chunk.length / 2);
  for (let i = 0; i < chunk.length - 1; i += 2) {
    const sample = chunk.readInt16LE(i);
    sumSquares += sample * sample;
  }
  const rms = Math.sqrt(sumSquares / sampleCount);
  return Math.min(1, rms / 32768);
}
