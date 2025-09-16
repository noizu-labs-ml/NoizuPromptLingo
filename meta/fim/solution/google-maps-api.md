# Google Maps API

Google's mapping platform with extensive features and services.

## API Key Setup
```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY&callback=initMap"></script>
```
Get key at: https://console.cloud.google.com/apis/credentials

## Basic Map
```javascript
function initMap() {
  const map = new google.maps.Map(document.getElementById('map'), {
    center: {lat: 37.7749, lng: -122.4194},
    zoom: 12,
    mapTypeId: 'roadmap'
  });
}
```

## Marker
```javascript
const marker = new google.maps.Marker({
  position: {lat: 37.7749, lng: -122.4194},
  map: map,
  title: 'San Francisco',
  icon: 'custom-icon.png'
});
```

## Info Window
```javascript
const infoWindow = new google.maps.InfoWindow({
  content: '<h3>Location Details</h3>'
});

marker.addListener('click', () => {
  infoWindow.open(map, marker);
});
```

## Directions Service
```javascript
const directionsService = new google.maps.DirectionsService();
const directionsRenderer = new google.maps.DirectionsRenderer();

directionsService.route({
  origin: 'San Francisco, CA',
  destination: 'Los Angeles, CA',
  travelMode: 'DRIVING'
}, (result, status) => {
  if (status === 'OK') {
    directionsRenderer.setDirections(result);
  }
});
```

## Places API
```javascript
const service = new google.maps.places.PlacesService(map);
service.nearbySearch({
  location: {lat: 37.7749, lng: -122.4194},
  radius: 1000,
  type: ['restaurant']
}, (results, status) => {
  results.forEach(place => console.log(place.name));
});
```

## Drawing Manager
```javascript
const drawingManager = new google.maps.drawing.DrawingManager({
  drawingMode: google.maps.drawing.OverlayType.POLYGON,
  drawingControl: true,
  drawingControlOptions: {
    drawingModes: ['polygon', 'circle', 'rectangle']
  }
});
```

## Key Features
- Street View integration
- Geocoding services
- Real-time traffic data
- Places autocomplete
- Distance matrix API