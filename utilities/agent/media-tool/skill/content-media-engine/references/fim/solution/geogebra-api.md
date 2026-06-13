# GeoGebra API Integration

## Setup
```html
<!-- GeoGebra Web Applet -->
<script src="https://www.geogebra.org/apps/deployggb.js"></script>

<div id="ggb-applet"></div>

<script>
const params = {
  appName: "graphing",  // or "geometry", "3d", "cas"
  width: 800,
  height: 600,
  showToolBar: true,
  showAlgebraInput: true,
  showMenuBar: false,
  appletOnLoad: function(api) {
    window.ggbApplet = api;
  }
};
const applet = new GGBApplet(params, true);
applet.inject('ggb-applet');
</script>
```

## API Commands
```javascript
// Wait for applet load
function runGeoGebra() {
  const api = window.ggbApplet;

  // Create objects
  api.evalCommand("A = (1, 2)");
  api.evalCommand("B = (4, 5)");
  api.evalCommand("line = Line(A, B)");
  api.evalCommand("f(x) = x^2 - 3x + 2");

  // Set properties
  api.setColor("A", 255, 0, 0);
  api.setPointSize("A", 5);
  api.setLineStyle("line", 2); // dashed

  // Get values
  const xA = api.getXcoord("A");
  const value = api.getValue("f(2)");
}
```

## Dynamic Construction
```javascript
// Slider-controlled parabola
api.evalCommand("a = Slider(-5, 5, 0.1)");
api.evalCommand("b = Slider(-5, 5, 0.1)");
api.evalCommand("c = Slider(-5, 5, 0.1)");
api.evalCommand("f(x) = a*x^2 + b*x + c");

// Intersection points
api.evalCommand("roots = Intersect(f, xAxis)");

// Tangent line
api.evalCommand("P = Point(f)");
api.evalCommand("tangent = Tangent(P, f)");
```

## 3D Graphics
```javascript
// 3D mode required
api.setPerspective("3d");

// 3D objects
api.evalCommand("A = (1, 2, 3)");
api.evalCommand("sphere = Sphere(A, 2)");
api.evalCommand("plane = x + y + z = 6");
api.evalCommand("curve3d = Curve(cos(t), sin(t), t, t, 0, 4π)");
```

## NPL-FIM Export
```javascript
// Export NPL construction to GeoGebra
const nplConstruct = npl.parse("circle(center: O, radius: 3)");
const ggbCommands = nplConstruct.toGeoGebra();
ggbCommands.forEach(cmd => api.evalCommand(cmd));
```