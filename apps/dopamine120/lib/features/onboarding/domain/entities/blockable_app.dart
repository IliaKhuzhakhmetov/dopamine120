import 'dart:typed_data';

/// An app the user can choose to block. On iOS [name] and [icon] are null —
/// Screen Time hands out opaque tokens only.
class BlockableApp {
  const BlockableApp({required this.id, this.name, this.icon});

  final String id;
  final String? name;
  final Uint8List? icon;
}
