import 'dart:typed_data';

/// What the current platform can actually do.
class BridgeSupport {
  const BridgeSupport({
    required this.canList,
    required this.canBlock,
    required this.canReadHealth,
    required this.platform,
  });

  factory BridgeSupport.fromMap(Map<String, dynamic> map) => BridgeSupport(
    canList: map['canList'] as bool? ?? false,
    canBlock: map['canBlock'] as bool? ?? false,
    canReadHealth: map['canReadHealth'] as bool? ?? false,
    platform: map['platform'] as String? ?? 'unknown',
  );

  /// Whether installed apps can be listed (Android yes, iOS no — opaque
  /// Screen Time tokens only).
  final bool canList;
  final bool canBlock;
  final bool canReadHealth;
  final String platform;

  /// A platform with no capabilities at all (e.g. unsupported OS).
  static const none = BridgeSupport(
    canList: false,
    canBlock: false,
    canReadHealth: false,
    platform: 'unsupported',
  );

  Map<String, dynamic> toMap() => {
    'canList': canList,
    'canBlock': canBlock,
    'canReadHealth': canReadHealth,
    'platform': platform,
  };

  @override
  String toString() =>
      'BridgeSupport(platform: $platform, canList: $canList, '
      'canBlock: $canBlock, canReadHealth: $canReadHealth)';
}

/// Outcome of a permission request.
enum PermissionResult {
  granted,
  denied,
  restricted,
  unsupported;

  static PermissionResult fromName(String? name) => PermissionResult.values
      .firstWhere((v) => v.name == name, orElse: () => unsupported);
}

/// Health metrics the bridge knows how to read.
enum HealthMetric {
  /// Minutes asleep.
  sleep,

  /// Beats per minute.
  restingHeartRate,

  /// Heart-rate variability (SDNN), milliseconds.
  hrv,

  /// Minutes of daylight exposure.
  daylightMinutes,

  /// Step count.
  steps,

  /// Minutes of mindfulness sessions.
  mindfulMinutes;

  static HealthMetric? fromName(String? name) {
    for (final v in HealthMetric.values) {
      if (v.name == name) return v;
    }
    return null;
  }
}

/// One selectable/blockable app.
///
/// On iOS [name] and [icon] are always null: the Screen Time picker returns
/// opaque tokens, and [id] is a stable reference to one. On Android [id] is
/// the package name and all fields are populated.
class AppInfo {
  const AppInfo({required this.id, this.name, this.icon});

  factory AppInfo.fromMap(Map<String, dynamic> map) => AppInfo(
    id: map['id'] as String,
    name: map['name'] as String?,
    icon: map['icon'] as Uint8List?,
  );

  final String id;
  final String? name;
  final Uint8List? icon;

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'icon': icon};

  @override
  String toString() => 'AppInfo(id: $id, name: $name)';
}

/// The result of an app-picking session; pass back into `setBlocking`.
class BlockSelection {
  const BlockSelection({
    required this.apps,
    this.categoryIds = const [],
    int categoryCount = 0,
  }) : _categoryCount = categoryCount;

  factory BlockSelection.fromMap(Map<String, dynamic> map) => BlockSelection(
    apps: [
      for (final raw in (map['apps'] as List? ?? const []))
        AppInfo.fromMap(Map<String, dynamic>.from(raw as Map)),
    ],
    categoryIds: [
      for (final raw in (map['categoryIds'] as List? ?? const []))
        if (raw is String) raw,
    ],
    categoryCount: map['categoryCount'] as int? ?? 0,
  );

  final List<AppInfo> apps;
  final List<String> categoryIds;
  final int _categoryCount;

  /// Number of whole categories selected (iOS Screen Time only).
  int get categoryCount =>
      categoryIds.isEmpty ? _categoryCount : categoryIds.length;

  bool get isEmpty => apps.isEmpty && categoryCount == 0;

  static const empty = BlockSelection(apps: []);

  Map<String, dynamic> toMap() => {
    'apps': [for (final app in apps) app.toMap()],
    'categoryIds': categoryIds,
    'categoryCount': categoryCount,
  };

  @override
  String toString() =>
      'BlockSelection(${apps.length} apps, $categoryCount categories)';
}

/// A half-open time interval `[start, end)`.
class DateRange {
  const DateRange({required this.start, required this.end});

  /// Roughly "last night": 9pm yesterday to now.
  factory DateRange.lastNight({DateTime? now}) {
    final n = now ?? DateTime.now();
    final yesterday = DateTime(n.year, n.month, n.day - 1, 21);
    return DateRange(start: yesterday, end: n);
  }

  final DateTime start;
  final DateTime end;

  Map<String, dynamic> toMap() => {
    'start': start.millisecondsSinceEpoch,
    'end': end.millisecondsSinceEpoch,
  };

  @override
  String toString() => 'DateRange($start – $end)';
}

/// Values for the requested metrics; a metric the platform could not
/// provide maps to null.
class HealthSnapshot {
  const HealthSnapshot({required this.values, required this.range});

  factory HealthSnapshot.fromMap(Map<String, dynamic> map, DateRange range) {
    final raw = Map<String, dynamic>.from(map['values'] as Map? ?? const {});
    return HealthSnapshot(
      values: {
        for (final entry in raw.entries)
          if (HealthMetric.fromName(entry.key) != null)
            HealthMetric.fromName(entry.key)!: entry.value as num?,
      },
      range: range,
    );
  }

  final Map<HealthMetric, num?> values;
  final DateRange range;

  /// A snapshot with every requested metric null (unsupported/denied paths).
  factory HealthSnapshot.empty(Set<HealthMetric> metrics, DateRange range) =>
      HealthSnapshot(values: {for (final m in metrics) m: null}, range: range);

  @override
  String toString() => 'HealthSnapshot($values, $range)';
}
