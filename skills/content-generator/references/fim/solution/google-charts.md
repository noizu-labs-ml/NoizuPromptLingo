# Google Charts NPL-FIM Solution

Google Charts offers free, powerful charts with Google's data visualization expertise.

## Installation

```html
<script src="https://www.gstatic.com/charts/loader.js"></script>
<script>
google.charts.load('current', {'packages':['corechart']});
google.charts.setOnLoadCallback(drawChart);
</script>
```

## Working Example

```javascript
function drawChart() {
  const data = google.visualization.arrayToDataTable([
    ['Task', 'Hours'],
    ['Work', 11],
    ['Eat', 2],
    ['Commute', 2],
    ['Watch TV', 2],
    ['Sleep', 7]
  ]);

  const options = {
    title: 'Daily Activities',
    pieHole: 0.4
  };

  const chart = new google.visualization.PieChart(
    document.getElementById('chart')
  );
  chart.draw(data, options);
}
```

## NPL-FIM Integration

```markdown
⟨npl:fim:google-charts⟩
chart: donut
data_source: spreadsheet_url
interactive: true
responsive: true
⟨/npl:fim:google-charts⟩
```

## Key Features
- Direct Google Sheets integration
- GeoCharts for map visualizations
- Timeline and Gantt charts
- Real-time data updates
- Material Design styling

## Best Practices
- Use DataTables for structured data
- Enable chart interactions for drill-down
- Implement responsive sizing with window resize
- Cache visualization objects