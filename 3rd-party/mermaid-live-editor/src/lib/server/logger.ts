type LogLevel = 'debug' | 'info' | 'warn' | 'error';
type LogFields = Record<string, unknown>;

const LEVEL_PRIORITY: Record<LogLevel, number> = {
  debug: 10,
  info: 20,
  warn: 30,
  error: 40
};

const OTEL_SEVERITY_NUMBER: Record<LogLevel, number> = {
  debug: 5,
  info: 9,
  warn: 13,
  error: 17
};

const LOG_FORMAT = process.env.LOG_FORMAT ?? 'jsonl';
const SERVICE_NAME = process.env.OTEL_SERVICE_NAME ?? process.env.SERVICE_NAME ?? 'mermaid';
const SERVICE_NAMESPACE = process.env.SERVICE_NAMESPACE ?? 'creative';
const DEPLOYMENT_ENVIRONMENT =
  process.env.OTEL_DEPLOYMENT_ENVIRONMENT ?? process.env.NODE_ENV ?? 'production';
const MIN_LEVEL = (process.env.LOG_LEVEL as LogLevel | undefined) ?? 'info';
const MAX_FIELD_LENGTH = Number(process.env.LOG_MAX_FIELD_LENGTH ?? 8192);

let consoleJsonLoggerInstalled = false;

function shouldLog(level: LogLevel): boolean {
  return LEVEL_PRIORITY[level] >= (LEVEL_PRIORITY[MIN_LEVEL] ?? LEVEL_PRIORITY.info);
}

function truncate(value: string): string {
  if (value.length <= MAX_FIELD_LENGTH) {
    return value;
  }

  return `${value.slice(0, MAX_FIELD_LENGTH)}...<truncated>`;
}

function serializeError(error: Error): LogFields {
  return {
    message: truncate(error.message),
    name: error.name,
    stack: error.stack ? truncate(error.stack) : undefined
  };
}

function normalizeValue(value: unknown, seen = new WeakSet<object>()): unknown {
  if (value === null || value === undefined) {
    return value;
  }

  if (typeof value === 'string') {
    return truncate(value);
  }

  if (typeof value === 'number' || typeof value === 'boolean') {
    return value;
  }

  if (typeof value === 'bigint') {
    return value.toString();
  }

  if (value instanceof Date) {
    return value.toISOString();
  }

  if (value instanceof URL) {
    return value.toString();
  }

  if (value instanceof Error) {
    return serializeError(value);
  }

  if (Array.isArray(value)) {
    return value.map((entry) => normalizeValue(entry, seen));
  }

  if (typeof value === 'object') {
    if (seen.has(value)) {
      return '[Circular]';
    }

    seen.add(value);
    return Object.fromEntries(
      Object.entries(value as Record<string, unknown>).map(([key, entry]) => [
        key,
        normalizeValue(entry, seen)
      ])
    );
  }

  return String(value);
}

function messageFromConsoleArgs(args: unknown[]): string {
  return (
    args
      .map((arg) => {
        if (typeof arg === 'string') {
          return arg;
        }

        if (arg instanceof Error) {
          return arg.message;
        }

        try {
          return JSON.stringify(normalizeValue(arg));
        } catch {
          return String(arg);
        }
      })
      .join(' ')
      .trim() || 'console log'
  );
}

function writeLog(level: LogLevel, message: string, fields: LogFields = {}): void {
  if (!shouldLog(level)) {
    return;
  }

  const ts = new Date();
  const record = normalizeValue({
    'deployment.environment': DEPLOYMENT_ENVIRONMENT,
    ...fields,
    body: message,
    level,
    message,
    'service.name': SERVICE_NAME,
    'service.namespace': SERVICE_NAMESPACE,
    severity_number: OTEL_SEVERITY_NUMBER[level],
    severity_text: level.toUpperCase(),
    ts: ts.toISOString()
  });

  const stream = level === 'error' || level === 'warn' ? process.stderr : process.stdout;

  if (LOG_FORMAT === 'jsonl') {
    stream.write(`${JSON.stringify(record)}\n`);
    return;
  }

  stream.write(`[${ts.toISOString()}] ${level.toUpperCase()} ${message}\n`);
}

export function parseTraceparent(traceparent: string | null): LogFields {
  const match = traceparent?.match(/^([0-9a-f]{2})-([0-9a-f]{32})-([0-9a-f]{16})-([0-9a-f]{2})$/i);
  if (!match) {
    return {};
  }

  return {
    trace_flags: match[4],
    trace_id: match[2],
    traceparent,
    span_id: match[3]
  };
}

export function installConsoleJsonLogger(): void {
  if (consoleJsonLoggerInstalled || LOG_FORMAT !== 'jsonl') {
    return;
  }

  consoleJsonLoggerInstalled = true;

  const wrap =
    (level: LogLevel) =>
    (...args: unknown[]): void => {
      const error = args.find((arg): arg is Error => arg instanceof Error);
      writeLog(level, messageFromConsoleArgs(args), {
        console_args: args.map((arg) => normalizeValue(arg)),
        error: error ? serializeError(error) : undefined,
        event: 'console'
      });
    };

  console.debug = wrap('debug');
  console.info = wrap('info');
  console.log = wrap('info');
  console.warn = wrap('warn');
  console.error = wrap('error');
}

export const logger = {
  debug: (message: string, fields?: LogFields) => writeLog('debug', message, fields),
  error: (message: string, fields?: LogFields) => writeLog('error', message, fields),
  info: (message: string, fields?: LogFields) => writeLog('info', message, fields),
  warn: (message: string, fields?: LogFields) => writeLog('warn', message, fields)
};
