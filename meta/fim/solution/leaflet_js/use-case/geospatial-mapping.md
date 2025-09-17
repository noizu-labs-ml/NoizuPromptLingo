# Geospatial Mapping with Leaflet.js
**NPL-FIM Direct Implementation Guide**

Interactive web mapping for geographic data visualization, spatial analysis, and location-based applications with comprehensive Leaflet.js integration.

## Quick Start Template

### Complete HTML Implementation
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Leaflet Geospatial Mapping</title>

    <!-- Leaflet CSS -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
          integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY="
          crossorigin=""/>

    <!-- Leaflet Draw CSS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet.draw/1.0.4/leaflet.draw.css"/>

    <!-- MarkerCluster CSS -->
    <link rel="stylesheet" href="https://unpkg.com/leaflet.markercluster@1.4.1/dist/MarkerCluster.css" />
    <link rel="stylesheet" href="https://unpkg.com/leaflet.markercluster@1.4.1/dist/MarkerCluster.Default.css" />

    <style>
        body { margin: 0; padding: 0; font-family: 'Segoe UI', Arial, sans-serif; }
        #map { height: 100vh; width: 100%; }
        .info-panel {
            position: absolute;
            top: 10px;
            right: 10px;
            background: white;
            padding: 15px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            z-index: 1000;
            max-width: 300px;
        }
        .coordinate-display {
            position: absolute;
            bottom: 10px;
            left: 10px;
            background: rgba(255,255,255,0.9);
            padding: 8px 12px;
            border-radius: 4px;
            font-family: monospace;
            font-size: 12px;
            z-index: 1000;
        }
        .custom-popup {
            font-family: 'Segoe UI', Arial, sans-serif;
            min-width: 200px;
        }
        .popup-header {
            font-weight: bold;
            margin-bottom: 8px;
            color: #2c3e50;
        }
        .popup-content {
            font-size: 14px;
            line-height: 1.4;
        }
        .measurement-result {
            background: #e8f5e8;
            padding: 8px;
            border-radius: 4px;
            margin-top: 8px;
            font-weight: bold;
            color: #2e7d32;
        }
    </style>
</head>
<body>
    <div id="map"></div>

    <div class="info-panel">
        <h3>Map Controls</h3>
        <p><strong>Click:</strong> Add marker</p>
        <p><strong>Draw:</strong> Use toolbar on left</p>
        <p><strong>Search:</strong> Type location name</p>
        <div id="search-box">
            <input type="text" id="search-input" placeholder="Search location..."
                   style="width: 100%; padding: 8px; margin-top: 10px; border: 1px solid #ddd; border-radius: 4px;">
        </div>
    </div>

    <div class="coordinate-display" id="coordinates">
        Lat: 0.000000, Lng: 0.000000
    </div>

    <!-- Leaflet JS -->
    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
            integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo="
            crossorigin=""></script>

    <!-- Leaflet Draw JS -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet.draw/1.0.4/leaflet.draw.js"></script>

    <!-- MarkerCluster JS -->
    <script src="https://unpkg.com/leaflet.markercluster@1.4.1/dist/leaflet.markercluster.js"></script>

    <script>
        // Main map initialization and implementation
        // See JavaScript section below for complete code
    </script>
</body>
</html>
```

## Core JavaScript Implementation

### Base Map Setup and Configuration
```javascript
// Initialize map with optimal settings
const map = L.map('map', {
    center: [39.8283, -98.5795], // Geographic center of US
    zoom: 4,
    minZoom: 2,
    maxZoom: 18,
    zoomControl: true,
    attributionControl: true,
    scrollWheelZoom: true,
    doubleClickZoom: true,
    boxZoom: true,
    keyboard: true,
    dragging: true,
    touchZoom: true,
    tap: true,
    tapTolerance: 15
});

// Tile layer configuration with multiple providers
const tileLayers = {
    'OpenStreetMap': L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors',
        maxZoom: 19
    }),
    'Satellite': L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
        attribution: 'Tiles © Esri — Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community',
        maxZoom: 17
    }),
    'Terrain': L.tileLayer('https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png', {
        attribution: 'Map data: © OpenStreetMap contributors, SRTM | Map style: © OpenTopoMap (CC-BY-SA)',
        maxZoom: 17
    }),
    'Dark': L.tileLayer('https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png', {
        attribution: '© OpenStreetMap contributors © CARTO',
        maxZoom: 19
    })
};

// Add default tile layer
tileLayers['OpenStreetMap'].addTo(map);

// Add layer control
L.control.layers(tileLayers).addTo(map);
```

### Advanced Marker Management System
```javascript
// Custom icon definitions
const customIcons = {
    red: L.icon({
        iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-red.png',
        shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
        iconSize: [25, 41],
        iconAnchor: [12, 41],
        popupAnchor: [1, -34],
        shadowSize: [41, 41]
    }),
    blue: L.icon({
        iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-blue.png',
        shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
        iconSize: [25, 41],
        iconAnchor: [12, 41],
        popupAnchor: [1, -34],
        shadowSize: [41, 41]
    }),
    green: L.icon({
        iconUrl: 'https://raw.githubusercontent.com/pointhi/leaflet-color-markers/master/img/marker-icon-green.png',
        shadowUrl: 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/0.7.7/images/marker-shadow.png',
        iconSize: [25, 41],
        iconAnchor: [12, 41],
        popupAnchor: [1, -34],
        shadowSize: [41, 41]
    })
};

// Marker cluster group for performance
const markers = L.markerClusterGroup({
    chunkedLoading: true,
    maxClusterRadius: 80,
    spiderfyOnMaxZoom: true,
    showCoverageOnHover: true,
    zoomToBoundsOnClick: true
});

// Advanced marker creation function
function createAdvancedMarker(lat, lng, options = {}) {
    const marker = L.marker([lat, lng], {
        icon: options.icon || customIcons.red,
        draggable: options.draggable || false,
        title: options.title || '',
        alt: options.alt || '',
        riseOnHover: true,
        riseOffset: 250
    });

    // Enhanced popup content
    const popupContent = `
        <div class="custom-popup">
            <div class="popup-header">${options.title || 'Location'}</div>
            <div class="popup-content">
                <strong>Coordinates:</strong><br>
                Lat: ${lat.toFixed(6)}<br>
                Lng: ${lng.toFixed(6)}<br>
                ${options.description ? `<br><strong>Description:</strong><br>${options.description}` : ''}
                ${options.address ? `<br><strong>Address:</strong><br>${options.address}` : ''}
                <br><br>
                <button onclick="removeMarker(${marker._leaflet_id})" style="background: #e74c3c; color: white; border: none; padding: 5px 10px; border-radius: 3px; cursor: pointer;">Remove</button>
                <button onclick="centerOnMarker(${lat}, ${lng})" style="background: #3498db; color: white; border: none; padding: 5px 10px; border-radius: 3px; cursor: pointer; margin-left: 5px;">Center</button>
            </div>
        </div>
    `;

    marker.bindPopup(popupContent);

    // Add to cluster group
    markers.addLayer(marker);

    return marker;
}

// Add marker cluster group to map
map.addLayer(markers);

// Marker management functions
function removeMarker(markerId) {
    markers.eachLayer(function(layer) {
        if (layer._leaflet_id === markerId) {
            markers.removeLayer(layer);
        }
    });
}

function centerOnMarker(lat, lng) {
    map.setView([lat, lng], 15);
}

// Click handler for adding markers
map.on('click', function(e) {
    const { lat, lng } = e.latlng;
    createAdvancedMarker(lat, lng, {
        title: `Marker ${markers.getLayers().length + 1}`,
        description: 'Marker added by clicking on map',
        draggable: true
    });
});
```

### GeoJSON Data Integration
```javascript
// GeoJSON layer management
const geoJsonLayers = {};

// Function to load and style GeoJSON data
function loadGeoJSON(url, layerName, options = {}) {
    fetch(url)
        .then(response => response.json())
        .then(data => {
            const layer = L.geoJSON(data, {
                style: options.style || {
                    color: '#3388ff',
                    weight: 2,
                    opacity: 0.8,
                    fillOpacity: 0.3
                },
                pointToLayer: function(feature, latlng) {
                    return L.circleMarker(latlng, {
                        radius: 6,
                        fillColor: '#ff7800',
                        color: '#000',
                        weight: 1,
                        opacity: 1,
                        fillOpacity: 0.8
                    });
                },
                onEachFeature: function(feature, layer) {
                    if (feature.properties) {
                        let popupContent = '<div class="custom-popup">';
                        popupContent += '<div class="popup-header">GeoJSON Feature</div>';
                        popupContent += '<div class="popup-content">';

                        for (const [key, value] of Object.entries(feature.properties)) {
                            popupContent += `<strong>${key}:</strong> ${value}<br>`;
                        }

                        popupContent += '</div></div>';
                        layer.bindPopup(popupContent);
                    }

                    // Highlight on hover
                    layer.on({
                        mouseover: function(e) {
                            const layer = e.target;
                            layer.setStyle({
                                weight: 4,
                                color: '#666',
                                dashArray: '',
                                fillOpacity: 0.7
                            });
                            layer.bringToFront();
                        },
                        mouseout: function(e) {
                            geoJsonLayers[layerName].resetStyle(e.target);
                        }
                    });
                }
            });

            geoJsonLayers[layerName] = layer;
            layer.addTo(map);

            // Fit map to layer bounds
            if (options.fitBounds) {
                map.fitBounds(layer.getBounds());
            }
        })
        .catch(error => {
            console.error('Error loading GeoJSON:', error);
        });
}

// Example GeoJSON loading (uncomment and modify URL as needed)
// loadGeoJSON('path/to/your/data.geojson', 'myData', { fitBounds: true });
```

### Drawing Controls and Measurement Tools
```javascript
// Drawing controls setup
const drawnItems = new L.FeatureGroup();
map.addLayer(drawnItems);

// Advanced draw control with all options
const drawControl = new L.Control.Draw({
    position: 'topleft',
    draw: {
        polygon: {
            allowIntersection: false,
            drawError: {
                color: '#e1e100',
                message: '<strong>Error:</strong> Shape edges cannot cross!'
            },
            shapeOptions: {
                color: '#97009c',
                weight: 3,
                opacity: 0.8,
                fillOpacity: 0.3
            }
        },
        polyline: {
            shapeOptions: {
                color: '#f357a1',
                weight: 4,
                opacity: 0.8
            }
        },
        rect: {
            shapeOptions: {
                clickable: false,
                color: '#2c3e50',
                weight: 3,
                opacity: 0.8,
                fillOpacity: 0.3
            }
        },
        circle: {
            shapeOptions: {
                color: '#662d91',
                weight: 3,
                opacity: 0.8,
                fillOpacity: 0.3
            }
        },
        marker: {
            icon: customIcons.blue
        },
        circlemarker: {
            color: '#e74c3c',
            weight: 3,
            opacity: 0.8,
            fillOpacity: 0.6,
            radius: 10
        }
    },
    edit: {
        featureGroup: drawnItems,
        remove: true
    }
});

map.addControl(drawControl);

// Event handlers for drawing
map.on(L.Draw.Event.CREATED, function(e) {
    const type = e.layerType;
    const layer = e.layer;

    // Calculate measurements
    let measurement = '';
    if (type === 'polygon') {
        const area = L.GeometryUtil.geodesicArea(layer.getLatLngs()[0]);
        measurement = `Area: ${(area / 1000000).toFixed(3)} km²`;
    } else if (type === 'polyline') {
        const distance = calculatePolylineDistance(layer);
        measurement = `Distance: ${(distance / 1000).toFixed(3)} km`;
    } else if (type === 'circle') {
        const radius = layer.getRadius();
        const area = Math.PI * radius * radius;
        measurement = `Radius: ${radius.toFixed(2)}m, Area: ${(area / 1000000).toFixed(6)} km²`;
    } else if (type === 'rectangle') {
        const bounds = layer.getBounds();
        const area = L.GeometryUtil.geodesicArea([
            bounds.getNorthWest(),
            bounds.getNorthEast(),
            bounds.getSouthEast(),
            bounds.getSouthWest()
        ]);
        measurement = `Area: ${(area / 1000000).toFixed(3)} km²`;
    }

    // Add popup with measurement
    if (measurement) {
        layer.bindPopup(`
            <div class="custom-popup">
                <div class="popup-header">Measurement</div>
                <div class="popup-content">
                    <div class="measurement-result">${measurement}</div>
                    <br>
                    <button onclick="removeDrawnLayer(${layer._leaflet_id})" style="background: #e74c3c; color: white; border: none; padding: 5px 10px; border-radius: 3px; cursor: pointer;">Remove</button>
                </div>
            </div>
        `);
    }

    drawnItems.addLayer(layer);
});

// Function to calculate polyline distance
function calculatePolylineDistance(layer) {
    const latlngs = layer.getLatLngs();
    let distance = 0;

    for (let i = 0; i < latlngs.length - 1; i++) {
        distance += latlngs[i].distanceTo(latlngs[i + 1]);
    }

    return distance;
}

// Function to remove drawn layers
function removeDrawnLayer(layerId) {
    drawnItems.eachLayer(function(layer) {
        if (layer._leaflet_id === layerId) {
            drawnItems.removeLayer(layer);
        }
    });
}

map.on(L.Draw.Event.EDITED, function(e) {
    const layers = e.layers;
    layers.eachLayer(function(layer) {
        // Update measurements for edited shapes
        console.log('Edited layer:', layer);
    });
});

map.on(L.Draw.Event.DELETED, function(e) {
    const layers = e.layers;
    console.log('Deleted layers:', layers);
});
```

### Location Search and Geocoding
```javascript
// Nominatim geocoding service
async function geocodeLocation(query) {
    const url = `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(query)}&limit=5`;

    try {
        const response = await fetch(url);
        const data = await response.json();
        return data;
    } catch (error) {
        console.error('Geocoding error:', error);
        return [];
    }
}

// Search functionality
const searchInput = document.getElementById('search-input');
let searchResultsLayer = L.layerGroup().addTo(map);

searchInput.addEventListener('keypress', async function(e) {
    if (e.key === 'Enter') {
        const query = this.value.trim();
        if (query) {
            await performSearch(query);
        }
    }
});

async function performSearch(query) {
    // Clear previous search results
    searchResultsLayer.clearLayers();

    try {
        const results = await geocodeLocation(query);

        if (results.length > 0) {
            results.forEach((result, index) => {
                const lat = parseFloat(result.lat);
                const lng = parseFloat(result.lon);

                const marker = L.marker([lat, lng], {
                    icon: customIcons.green
                }).bindPopup(`
                    <div class="custom-popup">
                        <div class="popup-header">Search Result ${index + 1}</div>
                        <div class="popup-content">
                            <strong>${result.display_name}</strong><br><br>
                            <strong>Type:</strong> ${result.type}<br>
                            <strong>Class:</strong> ${result.class}<br>
                            <strong>Coordinates:</strong><br>
                            Lat: ${lat.toFixed(6)}<br>
                            Lng: ${lng.toFixed(6)}<br><br>
                            <button onclick="zoomToLocation(${lat}, ${lng})" style="background: #27ae60; color: white; border: none; padding: 5px 10px; border-radius: 3px; cursor: pointer;">Zoom Here</button>
                            <button onclick="addPermanentMarker(${lat}, ${lng}, '${result.display_name.replace(/'/g, "\\'")}');" style="background: #3498db; color: white; border: none; padding: 5px 10px; border-radius: 3px; cursor: pointer; margin-left: 5px;">Add Marker</button>
                        </div>
                    </div>
                `);

                searchResultsLayer.addLayer(marker);
            });

            // Zoom to first result
            const firstResult = results[0];
            map.setView([parseFloat(firstResult.lat), parseFloat(firstResult.lon)], 12);

        } else {
            alert('No results found for: ' + query);
        }
    } catch (error) {
        console.error('Search error:', error);
        alert('Search failed. Please try again.');
    }
}

function zoomToLocation(lat, lng) {
    map.setView([lat, lng], 15);
}

function addPermanentMarker(lat, lng, name) {
    createAdvancedMarker(lat, lng, {
        title: name,
        description: 'Added from search results',
        icon: customIcons.blue
    });
}
```

### Real-time Coordinate Display
```javascript
// Coordinate display functionality
const coordinateDisplay = document.getElementById('coordinates');

map.on('mousemove', function(e) {
    const { lat, lng } = e.latlng;
    coordinateDisplay.innerHTML = `Lat: ${lat.toFixed(6)}, Lng: ${lng.toFixed(6)}`;
});

map.on('mouseout', function() {
    coordinateDisplay.innerHTML = 'Move mouse over map to see coordinates';
});

// Click coordinate display
map.on('click', function(e) {
    const { lat, lng } = e.latlng;
    console.log(`Clicked coordinates: ${lat}, ${lng}`);
});
```

### Mobile and Touch Optimization
```javascript
// Mobile-specific optimizations
if (L.Browser.mobile) {
    // Adjust controls for mobile
    map.removeControl(map.zoomControl);
    L.control.zoom({
        position: 'bottomright'
    }).addTo(map);

    // Touch gesture handling
    map.on('movestart', function() {
        document.querySelector('.info-panel').style.opacity = '0.5';
    });

    map.on('moveend', function() {
        document.querySelector('.info-panel').style.opacity = '1';
    });
}

// Responsive design adjustments
function adjustForScreenSize() {
    const width = window.innerWidth;
    const infoPanel = document.querySelector('.info-panel');

    if (width < 768) {
        infoPanel.style.position = 'relative';
        infoPanel.style.top = 'auto';
        infoPanel.style.right = 'auto';
        infoPanel.style.margin = '10px';
        infoPanel.style.maxWidth = 'none';
    } else {
        infoPanel.style.position = 'absolute';
        infoPanel.style.top = '10px';
        infoPanel.style.right = '10px';
        infoPanel.style.margin = '0';
        infoPanel.style.maxWidth = '300px';
    }
}

window.addEventListener('resize', adjustForScreenSize);
adjustForScreenSize(); // Initial call
```

## Configuration Options

### Map Configuration
```javascript
const mapConfig = {
    // Basic settings
    center: [39.8283, -98.5795],
    zoom: 4,
    minZoom: 2,
    maxZoom: 18,

    // Interaction options
    zoomControl: true,
    attributionControl: true,
    scrollWheelZoom: true,
    doubleClickZoom: true,
    boxZoom: true,
    keyboard: true,
    dragging: true,
    touchZoom: true,
    tap: true,
    tapTolerance: 15,

    // Performance options
    fadeAnimation: true,
    zoomAnimation: true,
    markerZoomAnimation: true,

    // Bounds and restrictions
    maxBounds: null, // Set to L.latLngBounds() to restrict panning
    maxBoundsViscosity: 0.0,

    // CRS (Coordinate Reference System)
    crs: L.CRS.EPSG3857, // Web Mercator (default)

    // Custom options
    preferCanvas: false, // Use Canvas renderer for better performance with many vectors
    renderer: L.svg() // or L.canvas()
};
```

### Marker Cluster Configuration
```javascript
const clusterConfig = {
    // Clustering behavior
    maxClusterRadius: 80,
    disableClusteringAtZoom: 15,
    spiderfyOnMaxZoom: true,
    showCoverageOnHover: true,
    zoomToBoundsOnClick: true,
    singleMarkerMode: false,

    // Performance
    chunkedLoading: true,
    chunkInterval: 200,
    chunkDelay: 50,
    chunkProgress: null,

    // Appearance
    iconCreateFunction: function(cluster) {
        const count = cluster.getChildCount();
        let className = 'marker-cluster-';

        if (count < 10) {
            className += 'small';
        } else if (count < 100) {
            className += 'medium';
        } else {
            className += 'large';
        }

        return new L.DivIcon({
            html: '<div><span>' + count + '</span></div>',
            className: 'marker-cluster ' + className,
            iconSize: new L.Point(40, 40)
        });
    }
};
```

### Drawing Configuration
```javascript
const drawConfig = {
    draw: {
        polygon: {
            allowIntersection: false,
            drawError: {
                color: '#e1e100',
                message: '<strong>Error:</strong> Shape edges cannot cross!'
            },
            shapeOptions: {
                color: '#97009c',
                weight: 3,
                opacity: 0.8,
                fillOpacity: 0.3
            },
            showArea: true,
            metric: true,
            feet: false
        },
        polyline: {
            shapeOptions: {
                color: '#f357a1',
                weight: 4,
                opacity: 0.8
            },
            showLength: true,
            metric: true,
            feet: false
        },
        circle: {
            shapeOptions: {
                color: '#662d91',
                weight: 3,
                opacity: 0.8,
                fillOpacity: 0.3
            },
            showRadius: true,
            metric: true,
            feet: false
        },
        rectangle: {
            shapeOptions: {
                color: '#2c3e50',
                weight: 3,
                opacity: 0.8,
                fillOpacity: 0.3
            },
            showArea: true,
            metric: true
        },
        marker: true,
        circlemarker: {
            color: '#e74c3c',
            weight: 3,
            opacity: 0.8,
            fillOpacity: 0.6,
            radius: 10
        }
    },
    edit: {
        featureGroup: drawnItems,
        remove: true,
        edit: true,
        poly: {
            allowIntersection: false
        }
    }
};
```

## Advanced Use Cases

### Heat Map Implementation
```javascript
// Heatmap using Leaflet.heat plugin
// Include: <script src="https://unpkg.com/leaflet.heat@0.2.0/dist/leaflet-heat.js"></script>

function createHeatMap(data) {
    // Data format: [[lat, lng, intensity], ...]
    const heat = L.heatLayer(data, {
        radius: 25,
        blur: 15,
        maxZoom: 17,
        max: 1.0,
        minOpacity: 0.1,
        gradient: {
            0.4: 'blue',
            0.6: 'cyan',
            0.7: 'lime',
            0.8: 'yellow',
            1.0: 'red'
        }
    }).addTo(map);

    return heat;
}

// Example usage
const heatmapData = [
    [37.7749, -122.4194, 0.5], // San Francisco
    [40.7128, -74.0060, 0.8],  // New York
    [34.0522, -118.2437, 0.6], // Los Angeles
    [41.8781, -87.6298, 0.7]   // Chicago
];

// Uncomment to add heatmap
// createHeatMap(heatmapData);
```

### Custom Control Implementation
```javascript
// Custom control for data export
L.Control.DataExport = L.Control.extend({
    onAdd: function(map) {
        const container = L.DomUtil.create('div', 'leaflet-bar leaflet-control leaflet-control-custom');

        container.style.backgroundColor = 'white';
        container.style.backgroundImage = 'url(data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0iIzMzODhmZiI+PHBhdGggZD0iTTE5IDloLTRWM0g5djZINWw3IDcgNy03ek01IDE4djJoMTR2LTJINXoiLz48L3N2Zz4=)';
        container.style.backgroundSize = '20px 20px';
        container.style.backgroundRepeat = 'no-repeat';
        container.style.backgroundPosition = 'center';
        container.style.width = '30px';
        container.style.height = '30px';
        container.style.cursor = 'pointer';
        container.title = 'Export Map Data';

        container.onclick = function() {
            exportMapData();
        };

        return container;
    },

    onRemove: function(map) {
        // Nothing to do here
    }
});

L.control.dataExport = function(opts) {
    return new L.Control.DataExport(opts);
};

// Add the custom control
L.control.dataExport({ position: 'topright' }).addTo(map);

function exportMapData() {
    const data = {
        markers: [],
        drawnItems: [],
        mapCenter: map.getCenter(),
        mapZoom: map.getZoom()
    };

    // Export markers
    markers.eachLayer(function(layer) {
        if (layer instanceof L.Marker) {
            data.markers.push({
                lat: layer.getLatLng().lat,
                lng: layer.getLatLng().lng,
                popup: layer.getPopup() ? layer.getPopup().getContent() : null
            });
        }
    });

    // Export drawn items
    drawnItems.eachLayer(function(layer) {
        if (layer instanceof L.Polygon) {
            data.drawnItems.push({
                type: 'polygon',
                coordinates: layer.getLatLngs()[0].map(ll => [ll.lat, ll.lng])
            });
        } else if (layer instanceof L.Polyline) {
            data.drawnItems.push({
                type: 'polyline',
                coordinates: layer.getLatLngs().map(ll => [ll.lat, ll.lng])
            });
        } else if (layer instanceof L.Circle) {
            data.drawnItems.push({
                type: 'circle',
                center: [layer.getLatLng().lat, layer.getLatLng().lng],
                radius: layer.getRadius()
            });
        }
    });

    // Download as JSON
    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'map-data.json';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
}
```

### Real-time Data Integration
```javascript
// WebSocket integration for real-time updates
class RealTimeMap {
    constructor(map, wsUrl) {
        this.map = map;
        this.wsUrl = wsUrl;
        this.realTimeMarkers = L.layerGroup().addTo(map);
        this.connect();
    }

    connect() {
        this.ws = new WebSocket(this.wsUrl);

        this.ws.onopen = () => {
            console.log('WebSocket connected');
        };

        this.ws.onmessage = (event) => {
            const data = JSON.parse(event.data);
            this.handleRealTimeData(data);
        };

        this.ws.onclose = () => {
            console.log('WebSocket disconnected, attempting to reconnect...');
            setTimeout(() => this.connect(), 5000);
        };

        this.ws.onerror = (error) => {
            console.error('WebSocket error:', error);
        };
    }

    handleRealTimeData(data) {
        switch (data.type) {
            case 'location_update':
                this.updateLocation(data);
                break;
            case 'new_marker':
                this.addRealTimeMarker(data);
                break;
            case 'remove_marker':
                this.removeRealTimeMarker(data.id);
                break;
            default:
                console.log('Unknown data type:', data.type);
        }
    }

    updateLocation(data) {
        // Update existing marker or create new one
        let marker = this.findMarkerById(data.id);

        if (marker) {
            marker.setLatLng([data.lat, data.lng]);
        } else {
            marker = L.marker([data.lat, data.lng], {
                icon: customIcons.blue
            }).bindPopup(`
                <div class="custom-popup">
                    <div class="popup-header">Real-time Object: ${data.id}</div>
                    <div class="popup-content">
                        <strong>Last Update:</strong> ${new Date().toLocaleTimeString()}<br>
                        <strong>Speed:</strong> ${data.speed || 'N/A'} km/h<br>
                        <strong>Heading:</strong> ${data.heading || 'N/A'}°
                    </div>
                </div>
            `);

            marker._id = data.id;
            this.realTimeMarkers.addLayer(marker);
        }
    }

    findMarkerById(id) {
        let foundMarker = null;
        this.realTimeMarkers.eachLayer(function(layer) {
            if (layer._id === id) {
                foundMarker = layer;
            }
        });
        return foundMarker;
    }

    addRealTimeMarker(data) {
        const marker = L.marker([data.lat, data.lng], {
            icon: customIcons.green
        }).bindPopup(data.popup || 'Real-time marker');

        marker._id = data.id;
        this.realTimeMarkers.addLayer(marker);
    }

    removeRealTimeMarker(id) {
        const marker = this.findMarkerById(id);
        if (marker) {
            this.realTimeMarkers.removeLayer(marker);
        }
    }

    sendData(data) {
        if (this.ws.readyState === WebSocket.OPEN) {
            this.ws.send(JSON.stringify(data));
        }
    }
}

// Initialize real-time map (uncomment and provide WebSocket URL)
// const realTimeMap = new RealTimeMap(map, 'wss://your-websocket-server.com');
```

### Routing and Directions
```javascript
// Routing using OSRM (Open Source Routing Machine)
class RouteManager {
    constructor(map) {
        this.map = map;
        this.routeLayer = L.layerGroup().addTo(map);
        this.waypoints = [];
    }

    async calculateRoute(startPoint, endPoint, profile = 'driving') {
        const url = `https://router.project-osrm.org/route/v1/${profile}/${startPoint.lng},${startPoint.lat};${endPoint.lng},${endPoint.lat}?overview=full&geometries=geojson&steps=true`;

        try {
            const response = await fetch(url);
            const data = await response.json();

            if (data.routes && data.routes.length > 0) {
                this.displayRoute(data.routes[0]);
                return data.routes[0];
            }
        } catch (error) {
            console.error('Routing error:', error);
        }

        return null;
    }

    displayRoute(route) {
        // Clear existing route
        this.routeLayer.clearLayers();

        // Add route polyline
        const routeLine = L.geoJSON(route.geometry, {
            style: {
                color: '#0066cc',
                weight: 6,
                opacity: 0.8
            }
        }).addTo(this.routeLayer);

        // Add start and end markers
        const coordinates = route.geometry.coordinates;
        const start = coordinates[0];
        const end = coordinates[coordinates.length - 1];

        L.marker([start[1], start[0]], { icon: customIcons.green })
            .bindPopup('Start')
            .addTo(this.routeLayer);

        L.marker([end[1], end[0]], { icon: customIcons.red })
            .bindPopup('End')
            .addTo(this.routeLayer);

        // Add route info popup
        const distance = (route.distance / 1000).toFixed(2);
        const duration = Math.round(route.duration / 60);

        routeLine.bindPopup(`
            <div class="custom-popup">
                <div class="popup-header">Route Information</div>
                <div class="popup-content">
                    <strong>Distance:</strong> ${distance} km<br>
                    <strong>Duration:</strong> ${duration} minutes<br>
                    <strong>Instructions:</strong> ${route.legs[0].steps.length} steps
                </div>
            </div>
        `);

        // Fit map to route
        this.map.fitBounds(routeLine.getBounds(), { padding: [20, 20] });
    }

    clearRoute() {
        this.routeLayer.clearLayers();
        this.waypoints = [];
    }
}

// Initialize route manager
const routeManager = new RouteManager(map);

// Add routing on right-click (example)
let routingMode = false;
let routeStart = null;

map.on('contextmenu', function(e) {
    if (!routingMode) {
        routingMode = true;
        routeStart = e.latlng;
        alert('Routing mode activated. Click destination to calculate route.');
    } else {
        const end = e.latlng;
        routeManager.calculateRoute(routeStart, end);
        routingMode = false;
        routeStart = null;
    }
});
```

## Environment and Dependencies

### Required Dependencies
```html
<!-- Core Leaflet -->
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

<!-- Drawing Tools -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet.draw/1.0.4/leaflet.draw.css"/>
<script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet.draw/1.0.4/leaflet.draw.js"></script>

<!-- Marker Clustering -->
<link rel="stylesheet" href="https://unpkg.com/leaflet.markercluster@1.4.1/dist/MarkerCluster.css" />
<link rel="stylesheet" href="https://unpkg.com/leaflet.markercluster@1.4.1/dist/MarkerCluster.Default.css" />
<script src="https://unpkg.com/leaflet.markercluster@1.4.1/dist/leaflet.markercluster.js"></script>

<!-- Optional: Heatmap -->
<script src="https://unpkg.com/leaflet.heat@0.2.0/dist/leaflet-heat.js"></script>

<!-- Optional: Geometry Utilities -->
<script src="https://unpkg.com/leaflet-geometryutil@0.9.3/src/leaflet.geometryutil.js"></script>
```

### NPM Installation
```bash
# Install Leaflet
npm install leaflet

# Install additional plugins
npm install leaflet.markercluster
npm install leaflet.heat
npm install leaflet-draw
npm install leaflet-geometryutil

# For bundlers like Webpack
npm install --save-dev css-loader style-loader
```

### Webpack Configuration
```javascript
// webpack.config.js
const path = require('path');

module.exports = {
    entry: './src/index.js',
    output: {
        filename: 'bundle.js',
        path: path.resolve(__dirname, 'dist')
    },
    module: {
        rules: [
            {
                test: /\.css$/,
                use: ['style-loader', 'css-loader']
            },
            {
                test: /\.(png|svg|jpg|gif)$/,
                use: ['file-loader']
            }
        ]
    }
};

// src/index.js
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import 'leaflet.markercluster/dist/MarkerCluster.css';
import 'leaflet.markercluster/dist/MarkerCluster.Default.css';
import 'leaflet.markercluster';
import 'leaflet-draw/dist/leaflet.draw.css';
import 'leaflet-draw';

// Fix for default markers in webpack
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
    iconRetinaUrl: require('leaflet/dist/images/marker-icon-2x.png'),
    iconUrl: require('leaflet/dist/images/marker-icon.png'),
    shadowUrl: require('leaflet/dist/images/marker-shadow.png'),
});
```

## Troubleshooting and Common Issues

### Marker Icon Issues
```javascript
// Fix for missing marker icons (common webpack issue)
L.Icon.Default.prototype._getIconUrl = function (name) {
    const size = name === 'icon' ? '' : '-2x';
    return `https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.7.1/images/marker-icon${size}.png`;
};

// Alternative fix with custom paths
L.Icon.Default.mergeOptions({
    iconUrl: '/assets/marker-icon.png',
    iconRetinaUrl: '/assets/marker-icon-2x.png',
    shadowUrl: '/assets/marker-shadow.png'
});
```

### Performance Optimization
```javascript
// Performance tips for large datasets
const performanceOptimizations = {
    // Use Canvas renderer for better performance with many vectors
    preferCanvas: true,

    // Limit marker clustering at high zoom levels
    disableClusteringAtZoom: 15,

    // Chunked loading for large datasets
    chunkedLoading: true,
    chunkInterval: 200,

    // Viewport-based rendering
    onlyRenderVisibleLayers: true,

    // Throttle mousemove events
    throttleMouseEvents: true
};

// Apply optimizations
const optimizedMap = L.map('map', performanceOptimizations);
```

### Mobile-Specific Issues
```javascript
// Mobile performance and touch fixes
if (L.Browser.mobile) {
    // Disable problematic animations on mobile
    L.Icon.Default.prototype.options.crossOrigin = true;

    // Optimize touch handling
    map.options.tap = true;
    map.options.tapTolerance = 20;

    // Reduce animation frames
    L.DomUtil.setTransform = L.DomUtil.setTransform || function(el, offset, scale) {
        const pos = offset || new L.Point(0, 0);
        el.style.transform =
            (L.Browser.ie3d ? 'translate(' + pos.x + 'px,' + pos.y + 'px)' :
             'translate3d(' + pos.x + 'px,' + pos.y + 'px,0)') +
            (scale ? ' scale(' + scale + ')' : '');
    };
}
```

### CORS and API Issues
```javascript
// Handle CORS issues with tile servers
const corsProxy = 'https://cors-anywhere.herokuapp.com/';

// Alternative tile servers for CORS issues
const backupTileLayers = {
    'CartoDB': L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
        attribution: '© OpenStreetMap contributors © CARTO',
        subdomains: 'abcd',
        maxZoom: 19
    }),
    'ESRI': L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}', {
        attribution: 'Tiles © Esri'
    })
};

// Fallback for failed geocoding requests
async function geocodeWithFallback(query) {
    const providers = [
        `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(query)}`,
        `https://api.mapbox.com/geocoding/v5/mapbox.places/${encodeURIComponent(query)}.json?access_token=YOUR_TOKEN`,
        `https://maps.googleapis.com/maps/api/geocode/json?address=${encodeURIComponent(query)}&key=YOUR_KEY`
    ];

    for (const provider of providers) {
        try {
            const response = await fetch(provider);
            if (response.ok) {
                return await response.json();
            }
        } catch (error) {
            console.warn('Geocoding provider failed:', provider);
        }
    }

    throw new Error('All geocoding providers failed');
}
```

### Memory Management
```javascript
// Prevent memory leaks
function cleanupMap() {
    // Remove all layers
    map.eachLayer(function(layer) {
        map.removeLayer(layer);
    });

    // Remove all controls
    map.removeControl(drawControl);

    // Clear event listeners
    map.off();

    // Remove map
    map.remove();
}

// Clean up on page unload
window.addEventListener('beforeunload', cleanupMap);
```

## Advanced Customizations

### Custom Map Themes
```javascript
const mapThemes = {
    dark: {
        tileLayer: L.tileLayer('https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png', {
            attribution: '© OpenStreetMap contributors © CARTO'
        }),
        markerIcon: customIcons.blue,
        polygonStyle: {
            color: '#61dafb',
            weight: 2,
            opacity: 0.8,
            fillOpacity: 0.3
        }
    },
    light: {
        tileLayer: L.tileLayer('https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png', {
            attribution: '© OpenStreetMap contributors © CARTO'
        }),
        markerIcon: customIcons.red,
        polygonStyle: {
            color: '#e74c3c',
            weight: 2,
            opacity: 0.8,
            fillOpacity: 0.3
        }
    }
};

function applyTheme(themeName) {
    const theme = mapThemes[themeName];
    if (theme) {
        // Switch tile layer
        map.eachLayer(function(layer) {
            if (layer instanceof L.TileLayer) {
                map.removeLayer(layer);
            }
        });
        theme.tileLayer.addTo(map);

        // Update marker icons
        markers.eachLayer(function(layer) {
            if (layer instanceof L.Marker) {
                layer.setIcon(theme.markerIcon);
            }
        });
    }
}
```

### Plugin Integration Examples
```javascript
// Leaflet.fullscreen plugin integration
// Include: https://unpkg.com/leaflet.fullscreen@2.4.0/Control.FullScreen.js

if (L.Control.Fullscreen) {
    map.addControl(new L.Control.Fullscreen({
        title: {
            'false': 'View Fullscreen',
            'true': 'Exit Fullscreen'
        }
    }));
}

// Leaflet.minimap plugin integration
// Include: https://unpkg.com/leaflet-minimap@3.6.1/dist/Control.MiniMap.min.js

if (L.Control.MiniMap) {
    const osmUrl = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
    const miniMap = new L.Control.MiniMap(L.tileLayer(osmUrl), {
        position: 'bottomleft',
        width: 150,
        height: 150,
        zoomLevelOffset: -5
    }).addTo(map);
}
```

## Best Practices and Optimization

### Code Organization
```javascript
// Modular approach for large applications
class MapManager {
    constructor(containerId, options = {}) {
        this.map = L.map(containerId, options);
        this.layers = {};
        this.controls = {};
        this.init();
    }

    init() {
        this.setupBaseLayers();
        this.setupControls();
        this.bindEvents();
    }

    setupBaseLayers() {
        // Initialize base layers
    }

    setupControls() {
        // Initialize controls
    }

    bindEvents() {
        // Bind map events
    }

    addDataLayer(name, data, options = {}) {
        // Add data layer
    }

    removeDataLayer(name) {
        // Remove data layer
    }

    exportData() {
        // Export functionality
    }

    destroy() {
        // Cleanup
    }
}

// Usage
const mapManager = new MapManager('map', {
    center: [39.8283, -98.5795],
    zoom: 4
});
```

### Performance Monitoring
```javascript
// Performance monitoring utilities
class MapPerformanceMonitor {
    constructor(map) {
        this.map = map;
        this.metrics = {
            renderTime: [],
            layerCount: 0,
            markerCount: 0,
            memoryUsage: []
        };
        this.startMonitoring();
    }

    startMonitoring() {
        // Monitor render performance
        this.map.on('moveend zoomend', () => {
            const start = performance.now();

            setTimeout(() => {
                const end = performance.now();
                this.metrics.renderTime.push(end - start);
                this.updateLayerCounts();
                this.checkMemoryUsage();
            }, 0);
        });
    }

    updateLayerCounts() {
        let layerCount = 0;
        let markerCount = 0;

        this.map.eachLayer((layer) => {
            layerCount++;
            if (layer instanceof L.Marker) {
                markerCount++;
            }
        });

        this.metrics.layerCount = layerCount;
        this.metrics.markerCount = markerCount;
    }

    checkMemoryUsage() {
        if (performance.memory) {
            this.metrics.memoryUsage.push(performance.memory.usedJSHeapSize);
        }
    }

    getReport() {
        const avgRenderTime = this.metrics.renderTime.reduce((a, b) => a + b, 0) / this.metrics.renderTime.length;

        return {
            averageRenderTime: avgRenderTime.toFixed(2) + 'ms',
            layerCount: this.metrics.layerCount,
            markerCount: this.metrics.markerCount,
            memoryTrend: this.metrics.memoryUsage.length > 1 ?
                (this.metrics.memoryUsage[this.metrics.memoryUsage.length - 1] > this.metrics.memoryUsage[0] ? 'increasing' : 'stable') : 'unknown'
        };
    }
}

// Initialize performance monitoring
const performanceMonitor = new MapPerformanceMonitor(map);
```

## Tool-Specific Advantages

### Leaflet.js Strengths
- **Lightweight**: ~39KB gzipped, minimal overhead
- **Mobile-first**: Excellent touch and mobile support
- **Plugin ecosystem**: Extensive community plugins
- **Flexible**: Works with any tile service or data source
- **Standards-compliant**: Follows web standards and accessibility guidelines
- **Framework-agnostic**: Works with React, Vue, Angular, or vanilla JS
- **Open source**: No licensing fees or usage restrictions

### When to Choose Leaflet.js
- Interactive web maps with custom markers and overlays
- Mobile-responsive mapping applications
- GeoJSON data visualization
- Drawing and editing tools required
- Real-time location tracking
- Custom map styling and branding
- Integration with existing web applications
- Offline-capable mapping (with appropriate plugins)

### Limitations to Consider
- **3D support**: Limited compared to specialized 3D libraries
- **Vector tile performance**: Not as optimized as Mapbox GL JS for vector tiles
- **Built-in geocoding**: Requires external services
- **Advanced analytics**: Limited built-in spatial analysis tools
- **Styling**: Less advanced styling compared to Mapbox Studio

This comprehensive guide provides immediate implementation capability for Leaflet.js geospatial mapping applications, ensuring NPL-FIM systems can generate complete, working solutions without false starts or incomplete implementations.