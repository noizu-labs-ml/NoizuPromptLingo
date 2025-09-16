# Chart.js
Simple yet flexible JavaScript charting library. [Docs](https://www.chartjs.org/docs/) | [Examples](https://www.chartjs.org/samples/)

## Install/Setup
```bash
npm install chart.js  # v4.4.4
# or CDN
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.4/dist/chart.umd.min.js"></script>
```

## Basic Usage
```javascript
// Minimal line chart
const ctx = document.getElementById('myChart').getContext('2d');
new Chart(ctx, {
  type: 'line',
  data: {
    labels: ['Jan', 'Feb', 'Mar', 'Apr'],
    datasets: [{
      label: 'Sales',
      data: [12, 19, 3, 17],
      borderColor: 'rgb(75, 192, 192)',
      tension: 0.1
    }]
  },
  options: {
    responsive: true,
    maintainAspectRatio: false
  }
});
```

## Strengths
- Easy to learn and use
- Responsive and mobile-friendly
- Good default styling
- Canvas-based rendering
- Lightweight (60KB gzipped)

## Limitations
- Limited chart types (8 basic)
- No 3D support
- Less flexible than D3
- Canvas-only (no SVG)

## Best For
`simple-dashboards`, `responsive-charts`, `quick-prototypes`, `mobile-apps`, `basic-analytics`