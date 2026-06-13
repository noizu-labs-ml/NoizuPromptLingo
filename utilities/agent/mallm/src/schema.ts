export interface MallmExample {
  command: string;
  description: string;
  output?: string;
}

export interface MallmArgument {
  name: string;
  type: "flag" | "option" | "positional" | "variadic";
  required?: boolean;
  default?: string;
  value?: string;
  description: string;
  choices?: string[];
}

export interface MallmConfig {
  mallm: string;
  name: string;
  version?: string;
  summary: string;
  description?: string;

  usage?: {
    synopsis: string;
    examples?: MallmExample[];
  };

  arguments?: MallmArgument[];

  subcommands?: Array<{
    name: string;
    summary: string;
    description?: string;
    arguments?: MallmArgument[];
    examples?: MallmExample[];
  }>;

  environment?: Array<{
    name: string;
    required?: boolean;
    default?: string;
    description: string;
  }>;

  files?: Array<{
    path: string;
    description: string;
  }>;

  skills?: Array<{
    name: string;
    path?: string;
    url?: string;
    description: string;
  }>;

  related?: Array<{
    name: string;
    description: string;
  }>;

  context?: {
    when_to_use?: string;
    when_not_to_use?: string;
    common_patterns?: Array<{
      name: string;
      description?: string;
      steps: string[];
    }>;
    gotchas?: string[];
  };

  output?: {
    stdout?: string;
    stderr?: string;
    exit_codes?: Record<number, string>;
    formats?: string[];
  };

  install?: {
    method: string;
    command?: string;
    url?: string;
  };
}

export interface ResolvedMallm {
  config: MallmConfig;
  source: "project-local" | "user-config" | "native" | "help-generated";
  path?: string;
}
