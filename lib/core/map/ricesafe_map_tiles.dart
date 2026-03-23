import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';

/// Base map tiles for RiceSafe.
///
/// `tile.openstreetmap.org` is meant for light web/demo use; mobile apps often
/// see empty/grey tiles (rate limits, blocking, or network paths). Carto
/// basemaps (OSM data, Fastly CDN) are a common choice for embedded maps.
TileLayer ricesafeMapTileLayer() {
  return TileLayer(
    urlTemplate:
        'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
    subdomains: const ['a', 'b', 'c', 'd'],
    userAgentPackageName: 'com.ricesafe.app',
    maxNativeZoom: 20,
  );
}

/// Attribution required for [ricesafeMapTileLayer] (OSM + CARTO).
Widget ricesafeMapAttribution({
  AttributionAlignment alignment = AttributionAlignment.bottomRight,
}) {
  return RichAttributionWidget(
    alignment: alignment,
    attributions: const [
      TextSourceAttribution('OpenStreetMap contributors · CARTO'),
    ],
  );
}
