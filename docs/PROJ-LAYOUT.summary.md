# Project Layout — Summary

```
mallm/
├── src/                        # TypeScript source
│   ├── index.ts                #   CLI entry point
│   ├── resolver.ts             #   Resolution chain
│   ├── formatter.ts            #   Output formatters
│   ├── init.ts                 #   Stub generator
│   ├── help-parser.ts          #   --help parser
│   └── schema.ts               #   Schema types
├── schemas/                    # JSON Schema
├── examples/                   # Example mallm.yaml files
├── dist/                       # Build output (gitignored)
├── docs/                       # Documentation
├── package.json                # Config and deps
├── tsconfig.json               # TypeScript config
└── README.md                   # Project docs
```
