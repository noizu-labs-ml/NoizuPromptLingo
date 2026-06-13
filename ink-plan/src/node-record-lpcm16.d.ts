declare module 'node-record-lpcm16' {
  interface RecordOptions {
    sampleRate?: number;
    channels?: number;
    audioType?: string;
    recorder?: string;
  }

  interface Recording {
    stream(): import('node:stream').Readable;
    stop(): void;
  }

  function record(options?: RecordOptions): Recording;

  export default { record };
}
