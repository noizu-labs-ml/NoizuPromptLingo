# Apache ECharts NPL-FIM Solution

Apache ECharts provides enterprise-grade interactive charts with extensive customization.

## Installation

```html
<script src="https://cdn.jsdelivr.net/npm/echarts@5.4.3/dist/echarts.min.js"></script>
```

NPM: `npm install echarts`

## Working Example

```html
<div id="chart" style="width: 600px; height: 400px;"></div>
<script>
const chart = echarts.init(document.getElementById('chart'));
chart.setOption({
  title: { text: 'Sales Data' },
  xAxis: { type: 'category', data: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'] },
  yAxis: { type: 'value' },
  series: [{
    type: 'line',
    data: [120, 200, 150, 80, 270],
    smooth: true,
    areaStyle: {}
  }]
});
</script>
```

## NPL-FIM Integration

```markdown
⟨npl:fim:echarts⟩
type: line-area
data: sales_metrics
features: [animation, tooltip, zoom]
theme: dark
⟨/npl:fim:echarts⟩
```

## Key Features
- 20+ chart types (line, bar, pie, scatter, heatmap, treemap)
- Canvas/SVG rendering with GPU acceleration
- Mobile responsive with touch gestures
- Rich interactions: zoom, drag, brush selection
- Custom themes and visual mappings

## Best Practices
- Use Canvas for large datasets (>1000 points)
- Enable data sampling for performance
- Implement lazy loading for dashboard views
- Cache chart instances for updates