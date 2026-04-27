/// Heatmap data point matching GET /needs/heatmap/data response.
class HeatmapDataPoint {
  final double lat;
  final double lng;
  final int weight; // urgency-weighted
  final String category;
  final String zone;
  final int needCount;

  HeatmapDataPoint({
    required this.lat,
    required this.lng,
    required this.weight,
    required this.category,
    required this.zone,
    this.needCount = 1,
  });

  factory HeatmapDataPoint.fromJson(Map<String, dynamic> json) {
    return HeatmapDataPoint(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      weight: json['weight'] ?? 1,
      category: json['category'] ?? 'other',
      zone: json['zone'] ?? '',
      needCount: json['needCount'] ?? 1,
    );
  }
}

/// Zone summary data from heatmap endpoint.
class ZoneSummary {
  final String zone;
  final int totalNeeds;
  final double avgUrgency;
  final Map<String, int> categories;

  ZoneSummary({
    required this.zone,
    required this.totalNeeds,
    required this.avgUrgency,
    required this.categories,
  });

  factory ZoneSummary.fromJson(String zone, Map<String, dynamic> json) {
    final cats = json['categories'] as Map<String, dynamic>? ?? {};
    return ZoneSummary(
      zone: zone,
      totalNeeds: json['totalNeeds'] ?? 0,
      avgUrgency: (json['avgUrgency'] as num?)?.toDouble() ?? 0.0,
      categories: cats.map((k, v) => MapEntry(k, v as int)),
    );
  }
}

/// Full heatmap response container.
class HeatmapResponse {
  final List<HeatmapDataPoint> points;
  final Map<String, ZoneSummary> zoneSummary;
  final int totalActiveNeeds;

  HeatmapResponse({
    required this.points,
    required this.zoneSummary,
    required this.totalActiveNeeds,
  });

  factory HeatmapResponse.fromJson(Map<String, dynamic> json) {
    final pointsList = (json['points'] as List? ?? [])
        .map((p) => HeatmapDataPoint.fromJson(p as Map<String, dynamic>))
        .toList();

    final zoneSummaryMap = <String, ZoneSummary>{};
    final rawZones = json['zoneSummary'] as Map<String, dynamic>? ?? {};
    rawZones.forEach((key, value) {
      zoneSummaryMap[key] =
          ZoneSummary.fromJson(key, value as Map<String, dynamic>);
    });

    return HeatmapResponse(
      points: pointsList,
      zoneSummary: zoneSummaryMap,
      totalActiveNeeds: json['totalActiveNeeds'] ?? 0,
    );
  }
}
