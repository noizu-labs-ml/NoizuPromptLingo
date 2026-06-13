# Highcharts NPL-FIM Solution

Highcharts provides commercial-grade interactive charts with extensive customization and export capabilities.

## Installation

```html
<script src="https://code.highcharts.com/highcharts.js"></script>
<script src="https://code.highcharts.com/modules/exporting.js"></script>
```

NPM: `npm install highcharts`

## Working Example

```javascript
Highcharts.chart('container', {
  chart: { type: 'spline' },
  title: { text: 'Temperature Trends' },
  xAxis: { categories: ['Jan', 'Feb', 'Mar', 'Apr', 'May'] },
  yAxis: { title: { text: 'Temperature (°C)' } },
  series: [{
    name: '2023',
    data: [7.0, 6.9, 9.5, 14.5, 18.2]
  }, {
    name: '2024',
    data: [3.9, 4.2, 5.7, 8.5, 11.9]
  }],
  plotOptions: {
    spline: {
      marker: { enabled: true }
    }
  }
});
```

## NPL-FIM Integration

```markdown
⟨npl:fim:highcharts⟩
type: stock-chart
data: financial_series
indicators: [sma, ema, rsi]
export: [pdf, svg, png]
⟨/npl:fim:highcharts⟩
```

## Key Features
- Stock charts with technical indicators
- 3D charts and polar projections
- Boost module for 1M+ data points
- Server-side rendering with Node.js
- Export to PDF/SVG/PNG

## Best Practices
- Use Boost for datasets >10k points
- Enable lazy loading for dashboard views
- Implement drilldown for hierarchical data
- License required for commercial use