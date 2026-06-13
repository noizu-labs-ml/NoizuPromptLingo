# SheetJS - Excel File Parser and Writer

## Overview
SheetJS is a comprehensive spreadsheet parser and writer that works with Excel formats (XLSX, XLS, CSV) in JavaScript environments. It provides robust Excel file manipulation without external dependencies.

- **Website**: https://sheetjs.com
- **Documentation**: https://docs.sheetjs.com
- **GitHub**: https://github.com/SheetJS/sheetjs

## Installation
```bash
npm install xlsx
# or
yarn add xlsx
```

## Basic Usage
```javascript
const XLSX = require('xlsx');

// Read Excel file
const workbook = XLSX.readFile('data.xlsx');
const sheetName = workbook.SheetNames[0];
const worksheet = workbook.Sheets[sheetName];
const data = XLSX.utils.sheet_to_json(worksheet);

// Write Excel file
const newWorkbook = XLSX.utils.book_new();
const newWorksheet = XLSX.utils.json_to_sheet(data);
XLSX.utils.book_append_sheet(newWorkbook, newWorksheet, 'Sheet1');
XLSX.writeFile(newWorkbook, 'output.xlsx');
```

## Strengths
- **Format Support**: XLSX, XLS, CSV, ODS, and 20+ formats
- **Browser Compatible**: Works in browsers without server-side processing
- **Formula Support**: Preserves and evaluates Excel formulas
- **Streaming**: Efficient memory usage for large files
- **No Dependencies**: Pure JavaScript implementation

## Limitations
- **Large Files**: Memory intensive for files > 100MB
- **Complex Formatting**: Limited style preservation
- **Charts/Images**: Cannot process embedded objects
- **VBA Macros**: Does not support macro execution

## Best For
- Excel data import/export in web applications
- Batch processing of spreadsheet data
- Converting between spreadsheet formats
- Generating reports from JSON/database data
- Client-side Excel file generation

## NPL-FIM Integration
```yaml
name: sheetjs
category: data-processing
purpose: Excel file manipulation
complexity: medium
dependencies: [xlsx]
```

### NPL Usage Pattern
```npl
⟪excel-processor⟫:
  solution: sheetjs
  operations: [read, write, convert]
  formats: [xlsx, xls, csv]
  features:
    - sheet_manipulation
    - formula_evaluation
    - data_extraction
```