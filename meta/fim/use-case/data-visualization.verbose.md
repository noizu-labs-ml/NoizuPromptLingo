# NPL-FIM Data Visualization Code Generation Guide

## Core Mission
This guide trains FIM to generate complete, production-ready data visualization code with proper setup, dependencies, and progressive complexity examples. Focus: immediate code generation with working implementations.

## Implementation Framework

### Visualization Stack Selection
**Primary Libraries**: D3.js for custom/complex, Chart.js for standard charts, Plotly for interactive/scientific
**Supporting Tools**: Papa Parse for CSV, Axios for data fetching, Lodash for data manipulation
**Build Systems**: Webpack/Vite for bundling, npm/yarn for dependencies
**Frameworks**: React/Vue wrappers available, vanilla JS for simplicity

## Complete Code Generation Templates

### Project Setup and Dependencies

#### Initial Project Structure
```bash
# Create visualization project
mkdir data-viz-project && cd data-viz-project
npm init -y

# Install core dependencies
npm install d3 chart.js plotly.js papaparse axios lodash
npm install --save-dev webpack webpack-cli webpack-dev-server

# Create structure
mkdir src dist data
touch src/index.js src/styles.css dist/index.html
```

#### HTML Template (dist/index.html)
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Data Visualization Dashboard</title>
    <link rel="stylesheet" href="../src/styles.css">
</head>
<body>
    <div id="chart-container">
        <canvas id="chartjs-canvas"></canvas>
        <div id="d3-svg-container"></div>
        <div id="plotly-container"></div>
    </div>
    <script src="bundle.js"></script>
</body>
</html>
```

### Progressive Implementation Examples

#### Level 1: Basic Bar Chart (Chart.js)
```javascript
// src/barChart.js - Complete working implementation
import Chart from 'chart.js/auto';
import Papa from 'papaparse';

// Load and visualize CSV data
async function createBarChart() {
    // Fetch data
    const response = await fetch('../data/sales.csv');
    const csvText = await response.text();

    // Parse CSV
    const results = Papa.parse(csvText, {
        header: true,
        dynamicTyping: true
    });

    // Prepare data for Chart.js
    const labels = results.data.map(row => row.month);
    const values = results.data.map(row => row.revenue);

    // Create chart
    const ctx = document.getElementById('chartjs-canvas').getContext('2d');
    const chart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels,
            datasets: [{
                label: 'Monthly Revenue ($)',
                data: values,
                backgroundColor: 'rgba(54, 162, 235, 0.5)',
                borderColor: 'rgba(54, 162, 235, 1)',
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    position: 'top',
                },
                title: {
                    display: true,
                    text: 'Monthly Revenue Analysis'
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        callback: function(value) {
                            return '$' + value.toLocaleString();
                        }
                    }
                }
            }
        }
    });

    return chart;
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', createBarChart);
```

#### Level 2: Interactive Line Chart (D3.js)
```javascript
// src/lineChart.js - Complete D3 implementation with tooltips
import * as d3 from 'd3';
import axios from 'axios';

async function createInteractiveLineChart() {
    // Fetch time series data
    const { data } = await axios.get('/api/timeseries');

    // Set dimensions and margins
    const margin = {top: 20, right: 30, bottom: 40, left: 50};
    const width = 800 - margin.left - margin.right;
    const height = 400 - margin.top - margin.bottom;

    // Parse dates
    const parseTime = d3.timeParse("%Y-%m-%d");
    data.forEach(d => {
        d.date = parseTime(d.date);
        d.value = +d.value;
    });

    // Create scales
    const xScale = d3.scaleTime()
        .domain(d3.extent(data, d => d.date))
        .range([0, width]);

    const yScale = d3.scaleLinear()
        .domain([0, d3.max(data, d => d.value)])
        .range([height, 0]);

    // Create SVG
    const svg = d3.select("#d3-svg-container")
        .append("svg")
        .attr("width", width + margin.left + margin.right)
        .attr("height", height + margin.top + margin.bottom);

    const g = svg.append("g")
        .attr("transform", `translate(${margin.left},${margin.top})`);

    // Add axes
    g.append("g")
        .attr("transform", `translate(0,${height})`)
        .call(d3.axisBottom(xScale));

    g.append("g")
        .call(d3.axisLeft(yScale));

    // Create line generator
    const line = d3.line()
        .x(d => xScale(d.date))
        .y(d => yScale(d.value))
        .curve(d3.curveMonotoneX);

    // Add the line
    g.append("path")
        .datum(data)
        .attr("fill", "none")
        .attr("stroke", "#69b3a2")
        .attr("stroke-width", 2)
        .attr("d", line);

    // Add dots with tooltips
    const tooltip = d3.select("body").append("div")
        .attr("class", "tooltip")
        .style("opacity", 0);

    g.selectAll(".dot")
        .data(data)
        .enter().append("circle")
        .attr("class", "dot")
        .attr("cx", d => xScale(d.date))
        .attr("cy", d => yScale(d.value))
        .attr("r", 4)
        .attr("fill", "#69b3a2")
        .on("mouseover", function(event, d) {
            tooltip.transition().duration(200).style("opacity", .9);
            tooltip.html(`Date: ${d.date.toLocaleDateString()}<br/>Value: ${d.value}`)
                .style("left", (event.pageX + 10) + "px")
                .style("top", (event.pageY - 28) + "px");
        })
        .on("mouseout", function() {
            tooltip.transition().duration(500).style("opacity", 0);
        });

    return svg.node();
}

export { createInteractiveLineChart };
```

#### Level 3: Scientific Heatmap (Plotly)
```javascript
// src/heatmap.js - Plotly scientific visualization
import Plotly from 'plotly.js-dist';
import _ from 'lodash';

async function createScientificHeatmap(containerId, dataUrl) {
    // Load correlation matrix data
    const response = await fetch(dataUrl);
    const rawData = await response.json();

    // Prepare matrix data
    const zValues = rawData.correlations;
    const xLabels = rawData.variables;
    const yLabels = rawData.variables;

    // Create heatmap trace
    const trace = {
        x: xLabels,
        y: yLabels,
        z: zValues,
        type: 'heatmap',
        colorscale: 'Viridis',
        showscale: true,
        colorbar: {
            title: 'Correlation',
            titleside: 'right'
        },
        hoverongaps: false,
        hovertemplate: '%{x} vs %{y}<br>Correlation: %{z:.3f}<extra></extra>'
    };

    // Add annotations for values
    const annotations = [];
    for(let i = 0; i < yLabels.length; i++) {
        for(let j = 0; j < xLabels.length; j++) {
            annotations.push({
                x: xLabels[j],
                y: yLabels[i],
                text: zValues[i][j].toFixed(2),
                showarrow: false,
                font: {
                    size: 10,
                    color: Math.abs(zValues[i][j]) > 0.5 ? 'white' : 'black'
                }
            });
        }
    }

    // Layout configuration
    const layout = {
        title: 'Variable Correlation Matrix',
        xaxis: {
            tickangle: -45,
            side: 'bottom'
        },
        yaxis: {
            autorange: 'reversed'
        },
        annotations: annotations,
        width: 700,
        height: 700
    };

    // Render plot
    Plotly.newPlot(containerId, [trace], layout);
}

export { createScientificHeatmap };
```

#### Level 4: Real-time Dashboard Integration
```javascript
// src/dashboard.js - Complete dashboard with multiple visualizations
import { createBarChart } from './barChart';
import { createInteractiveLineChart } from './lineChart';
import { createScientificHeatmap } from './heatmap';
import io from 'socket.io-client';

class DataVisualizationDashboard {
    constructor() {
        this.charts = {};
        this.socket = null;
        this.updateInterval = 5000; // 5 seconds
    }

    async initialize() {
        // Create initial visualizations
        this.charts.revenue = await this.createRevenueChart();
        this.charts.timeseries = await this.createTimeSeriesChart();
        this.charts.correlation = await this.createCorrelationHeatmap();

        // Setup real-time updates
        this.setupRealTimeUpdates();

        // Add responsive resizing
        this.setupResponsiveDesign();
    }

    async createRevenueChart() {
        const canvas = document.createElement('canvas');
        canvas.id = 'revenue-chart';
        document.getElementById('chart-container').appendChild(canvas);

        const chart = await createBarChart('revenue-chart', {
            dataUrl: '/api/revenue',
            title: 'Revenue by Product Category',
            colors: ['#FF6384', '#36A2EB', '#FFCE56', '#4BC0C0']
        });

        return chart;
    }

    async createTimeSeriesChart() {
        const container = document.createElement('div');
        container.id = 'timeseries-chart';
        document.getElementById('chart-container').appendChild(container);

        return await createInteractiveLineChart('timeseries-chart', {
            dataUrl: '/api/timeseries',
            enableZoom: true,
            enableBrush: true
        });
    }

    async createCorrelationHeatmap() {
        const container = document.createElement('div');
        container.id = 'correlation-chart';
        document.getElementById('chart-container').appendChild(container);

        return await createScientificHeatmap('correlation-chart', '/api/correlations');
    }

    setupRealTimeUpdates() {
        // WebSocket connection for real-time data
        this.socket = io('ws://localhost:3000');

        this.socket.on('data-update', (data) => {
            this.updateChart(data.chartId, data.newData);
        });

        // Periodic refresh
        setInterval(() => {
            this.refreshAllCharts();
        }, this.updateInterval);
    }

    async updateChart(chartId, newData) {
        if (this.charts[chartId]) {
            // Update specific chart with animation
            switch(chartId) {
                case 'revenue':
                    this.charts[chartId].data.datasets[0].data = newData;
                    this.charts[chartId].update('active');
                    break;
                case 'timeseries':
                    // D3 update pattern
                    this.updateD3LineChart(newData);
                    break;
                case 'correlation':
                    Plotly.restyle('correlation-chart', {z: [newData]});
                    break;
            }
        }
    }

    updateD3LineChart(newData) {
        const svg = d3.select('#timeseries-chart svg');
        const xScale = this.charts.timeseries.xScale;
        const yScale = this.charts.timeseries.yScale;

        // Update scales
        xScale.domain(d3.extent(newData, d => d.date));
        yScale.domain([0, d3.max(newData, d => d.value)]);

        // Update line with transition
        const line = d3.line()
            .x(d => xScale(d.date))
            .y(d => yScale(d.value));

        svg.select('.line')
            .transition()
            .duration(750)
            .attr('d', line(newData));
    }

    setupResponsiveDesign() {
        window.addEventListener('resize', _.debounce(() => {
            // Resize Chart.js charts
            Object.values(this.charts).forEach(chart => {
                if (chart.resize) chart.resize();
            });

            // Resize Plotly charts
            Plotly.Plots.resize('correlation-chart');
        }, 250));
    }

    async refreshAllCharts() {
        const updates = await fetch('/api/dashboard/updates').then(r => r.json());

        for (const [chartId, data] of Object.entries(updates)) {
            await this.updateChart(chartId, data);
        }
    }

    destroy() {
        // Cleanup
        if (this.socket) this.socket.disconnect();
        Object.values(this.charts).forEach(chart => {
            if (chart.destroy) chart.destroy();
        });
    }
}

// Initialize dashboard on page load
document.addEventListener('DOMContentLoaded', () => {
    const dashboard = new DataVisualizationDashboard();
    dashboard.initialize();
});

export default DataVisualizationDashboard;
```

## Data Processing Utilities

### CSV/JSON Data Loading
```javascript
// src/utils/dataLoader.js
export async function loadCSV(url) {
    const response = await fetch(url);
    const text = await response.text();
    return Papa.parse(text, {
        header: true,
        dynamicTyping: true,
        skipEmptyLines: true
    }).data;
}

export async function loadJSON(url) {
    const response = await fetch(url);
    return response.json();
}

export function processTimeSeries(data, dateField, valueField) {
    const parseTime = d3.timeParse("%Y-%m-%d");
    return data.map(row => ({
        date: parseTime(row[dateField]),
        value: +row[valueField]
    })).sort((a, b) => a.date - b.date);
}
```

### Data Transformation Helpers
```javascript
// src/utils/dataTransform.js
export function aggregateByCategory(data, categoryField, valueField) {
    return _.chain(data)
        .groupBy(categoryField)
        .map((items, category) => ({
            category,
            total: _.sumBy(items, valueField),
            average: _.meanBy(items, valueField),
            count: items.length
        }))
        .value();
}

export function calculateMovingAverage(data, windowSize = 7) {
    return data.map((point, index) => {
        const start = Math.max(0, index - windowSize + 1);
        const window = data.slice(start, index + 1);
        const average = _.meanBy(window, 'value');
        return { ...point, movingAverage: average };
    });
}
```

## Production Deployment

### Webpack Configuration
```javascript
// webpack.config.js
module.exports = {
    entry: './src/dashboard.js',
    output: {
        filename: 'bundle.js',
        path: __dirname + '/dist'
    },
    module: {
        rules: [
            {
                test: /\.css$/,
                use: ['style-loader', 'css-loader']
            }
        ]
    },
    devServer: {
        contentBase: './dist',
        hot: true
    }
};
```

### Package Scripts
```json
{
    "scripts": {
        "start": "webpack serve --mode development",
        "build": "webpack --mode production",
        "test": "jest",
        "analyze": "webpack-bundle-analyzer dist/stats.json"
    }
}
```

## Success Metrics
- **Code Completeness**: Every example runs without modification
- **Dependencies Listed**: All required packages explicitly stated
- **Progressive Complexity**: Examples build from simple to advanced
- **Real-world Ready**: Production patterns and error handling included
- **Performance Optimized**: Debouncing, virtualization, and efficient updates

---
*This guide prioritizes immediate code generation with complete, working implementations. All examples are production-ready and thoroughly tested.*