# Kino.MapLibre

## Description
Kino.MapLibre provides interactive MapLibre GL JS maps for Elixir LiveBook environments. It enables embedding vector-based maps with custom styling, data layers, and interactive controls directly in Elixir notebooks.

**Documentation**: [hexdocs.pm/kino_maplibre](https://hexdocs.pm/kino_maplibre) | [MapLibre GL JS](https://maplibre.org/maplibre-gl-js/docs/)

## Installation
```elixir
# In LiveBook setup cell
Mix.install([
  {:kino_maplibre, "~> 0.1.10"},
  {:kino, "~> 0.12.0"}
])
```

## Example Usage
```elixir
# Create basic map
map = MapLibre.new(center: {-74.5, 40}, zoom: 9)

# Add data layer with GeoJSON
geojson_data = %{
  type: "FeatureCollection",
  features: [
    %{
      type: "Feature",
      geometry: %{type: "Point", coordinates: [-74.5, 40.5]},
      properties: %{name: "Sample Location"}
    }
  ]
}

map
|> MapLibre.add_source("points", type: :geojson, data: geojson_data)
|> MapLibre.add_layer(
  id: "point-layer",
  source: "points",
  type: :circle,
  paint: %{"circle-radius" => 8, "circle-color" => "#007cbf"}
)
```

## Strengths
- **Interactive maps**: Pan, zoom, rotate, tilt controls
- **Vector rendering**: Crisp graphics at any zoom level
- **Custom styling**: Full control over map appearance
- **Data layers**: GeoJSON, vector tiles, raster support
- **LiveBook integration**: Native rendering in notebook cells

## Limitations
- **LiveBook only**: Requires LiveBook runtime environment
- **Internet dependency**: Needs tile server access for base maps
- **Performance**: Complex geometries may impact rendering speed
- **Style complexity**: Advanced styling requires MapLibre knowledge

## Best For
- **Geographic analysis**: Spatial data exploration in Elixir
- **Location intelligence**: Business location analysis
- **Data journalism**: Interactive map stories
- **Research**: Geographic data visualization
- **Prototyping**: Rapid map-based application development

## NPL-FIM Integration
```fim
@component: kino_maplibre_map
@type: geospatial
@runtime: livebook
@pattern: interactive_mapping

trigger: geo_data_ready
action: |
  MapLibre.new(center: {{{lng}}, {{lat}}}, zoom: {{zoom}})
  |> MapLibre.add_source("{{source_id}}", type: :geojson, data: {{geojson}})
  |> MapLibre.add_layer(
    id: "{{layer_id}}",
    source: "{{source_id}}",
    type: :{{layer_type}},
    paint: {{paint_config}}
  )
output: interactive_map
```