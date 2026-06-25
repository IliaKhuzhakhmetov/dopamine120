import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../theme/context_ext.dart';
import '../theme/dop_block_field_theme.dart';

enum BlockType { core, glass, goo }

enum BlockFieldMode { spawn, delete, inspect }

enum BlockFieldEventSource { userTap, programmatic, random }

enum BlockFieldBlockEventKind { spawned, deleted, tapped }

@immutable
class BlockFieldConfig {
  const BlockFieldConfig({
    this.columns = 8,
    this.rows = 8,
    this.maxHeight = 6,
    this.tileWidth,
    this.tileHeight,
    this.blockHeight,
    this.cameraScale = 1,
  }) : assert(columns > 0),
       assert(rows > 0),
       assert(maxHeight > 0),
       assert(tileWidth == null || tileWidth > 0),
       assert(tileHeight == null || tileHeight > 0),
       assert(blockHeight == null || blockHeight > 0),
       assert(cameraScale > 0);

  final int columns;
  final int rows;
  final int maxHeight;
  final double? tileWidth;
  final double? tileHeight;
  final double? blockHeight;
  final double cameraScale;

  @override
  bool operator ==(Object other) {
    return other is BlockFieldConfig &&
        other.columns == columns &&
        other.rows == rows &&
        other.maxHeight == maxHeight &&
        other.tileWidth == tileWidth &&
        other.tileHeight == tileHeight &&
        other.blockHeight == blockHeight &&
        other.cameraScale == cameraScale;
  }

  @override
  int get hashCode => Object.hash(
    columns,
    rows,
    maxHeight,
    tileWidth,
    tileHeight,
    blockHeight,
    cameraScale,
  );
}

@immutable
class BlockFieldPosition {
  const BlockFieldPosition({required this.x, required this.y, required this.z});

  final int x;
  final int y;
  final int z;

  @override
  bool operator ==(Object other) {
    return other is BlockFieldPosition &&
        other.x == x &&
        other.y == y &&
        other.z == z;
  }

  @override
  int get hashCode => Object.hash(x, y, z);

  @override
  String toString() => 'BlockFieldPosition(x: $x, y: $y, z: $z)';
}

@immutable
class BlockFieldBlock {
  const BlockFieldBlock({
    required this.id,
    required this.type,
    required this.position,
  });

  final String id;
  final BlockType type;
  final BlockFieldPosition position;
}

@immutable
class BlockFieldBlockEvent {
  const BlockFieldBlockEvent({
    required this.kind,
    required this.block,
    required this.source,
  });

  final BlockFieldBlockEventKind kind;
  final BlockFieldBlock block;
  final BlockFieldEventSource source;

  BlockType get type => block.type;

  BlockFieldPosition get position => block.position;
}

@immutable
class BlockFieldCellEvent {
  const BlockFieldCellEvent({required this.position, required this.source});

  final BlockFieldPosition position;
  final BlockFieldEventSource source;
}

class BlockFieldController extends ChangeNotifier {
  BlockFieldController({
    this.config = const BlockFieldConfig(),
    Iterable<BlockFieldBlock> blocks = const [],
    BlockType selectedType = BlockType.core,
    BlockFieldMode mode = BlockFieldMode.spawn,
  }) : _blocks = List<BlockFieldBlock>.of(blocks),
       _selectedType = selectedType,
       _mode = mode;

  final BlockFieldConfig config;
  final List<BlockFieldBlock> _blocks;
  final _events = StreamController<BlockFieldBlockEvent>.broadcast(sync: true);
  int _nextId = 0;
  BlockType _selectedType;
  BlockFieldMode _mode;

  List<BlockFieldBlock> get blocks => List.unmodifiable(_blocks);

  Stream<BlockFieldBlockEvent> get events => _events.stream;

  BlockType get selectedType => _selectedType;

  set selectedType(BlockType value) {
    if (_selectedType == value) return;
    _selectedType = value;
    notifyListeners();
  }

  BlockFieldMode get mode => _mode;

  set mode(BlockFieldMode value) {
    if (_mode == value) return;
    _mode = value;
    notifyListeners();
  }

  BlockFieldBlock? addBlock({
    required BlockFieldPosition position,
    BlockType? type,
    String? id,
    BlockFieldEventSource source = BlockFieldEventSource.programmatic,
  }) {
    if (!_isInside(position) || _blockAt(position) != null) return null;

    final blockId = id ?? _nextBlockId();
    if (_blocks.any((block) => block.id == blockId)) return null;

    final block = BlockFieldBlock(
      id: blockId,
      type: type ?? selectedType,
      position: position,
    );
    _blocks.add(block);
    _emit(
      BlockFieldBlockEvent(
        kind: BlockFieldBlockEventKind.spawned,
        block: block,
        source: source,
      ),
    );
    notifyListeners();
    return block;
  }

  BlockFieldBlock? spawnAt(
    int x,
    int y, {
    BlockType? type,
    BlockFieldEventSource source = BlockFieldEventSource.programmatic,
  }) {
    final position = nextAvailablePosition(x, y);
    if (position == null) return null;
    return addBlock(position: position, type: type, source: source);
  }

  BlockFieldBlock? removeBlock(
    String id, {
    BlockFieldEventSource source = BlockFieldEventSource.programmatic,
  }) {
    final index = _blocks.indexWhere((block) => block.id == id);
    if (index == -1) return null;

    final block = _blocks.removeAt(index);
    _emit(
      BlockFieldBlockEvent(
        kind: BlockFieldBlockEventKind.deleted,
        block: block,
        source: source,
      ),
    );
    notifyListeners();
    return block;
  }

  BlockFieldBlock? deleteTopBlockAt(
    int x,
    int y, {
    BlockFieldEventSource source = BlockFieldEventSource.programmatic,
  }) {
    final block = topBlockAt(x, y);
    if (block == null) return null;
    return removeBlock(block.id, source: source);
  }

  void clear({
    BlockFieldEventSource source = BlockFieldEventSource.programmatic,
  }) {
    if (_blocks.isEmpty) return;
    final removed = List<BlockFieldBlock>.of(_blocks);
    _blocks.clear();
    for (final block in removed) {
      _emit(
        BlockFieldBlockEvent(
          kind: BlockFieldBlockEventKind.deleted,
          block: block,
          source: source,
        ),
      );
    }
    notifyListeners();
  }

  BlockFieldBlock? topBlockAt(int x, int y) {
    BlockFieldBlock? top;
    for (final block in _blocks) {
      final position = block.position;
      if (position.x != x || position.y != y) continue;
      if (top == null || position.z > top.position.z) top = block;
    }
    return top;
  }

  BlockFieldPosition? nextAvailablePosition(int x, int y) {
    if (x < 0 || y < 0 || x >= config.columns || y >= config.rows) {
      return null;
    }
    final top = topBlockAt(x, y);
    final z = top == null ? 0 : top.position.z + 1;
    if (z >= config.maxHeight) return null;
    return BlockFieldPosition(x: x, y: y, z: z);
  }

  bool _isInside(BlockFieldPosition position) {
    return position.x >= 0 &&
        position.y >= 0 &&
        position.z >= 0 &&
        position.x < config.columns &&
        position.y < config.rows &&
        position.z < config.maxHeight;
  }

  BlockFieldBlock? _blockAt(BlockFieldPosition position) {
    for (final block in _blocks) {
      if (block.position == position) return block;
    }
    return null;
  }

  String _nextBlockId() {
    while (_blocks.any((block) => block.id == 'block_$_nextId')) {
      _nextId++;
    }
    return 'block_${_nextId++}';
  }

  void _emit(BlockFieldBlockEvent event) {
    if (!_events.isClosed) _events.add(event);
  }

  @override
  void dispose() {
    _events.close();
    super.dispose();
  }
}

class BlockFieldWidget extends StatefulWidget {
  const BlockFieldWidget({
    super.key,
    this.controller,
    this.config = const BlockFieldConfig(),
    this.onBlockSpawn,
    this.onBlockDeleted,
    this.onBlockTap,
    this.onCellTap,
    this.padding = EdgeInsets.zero,
    this.style,
  });

  final BlockFieldController? controller;
  final BlockFieldConfig config;
  final ValueChanged<BlockFieldBlockEvent>? onBlockSpawn;
  final ValueChanged<BlockFieldBlockEvent>? onBlockDeleted;
  final ValueChanged<BlockFieldBlockEvent>? onBlockTap;
  final ValueChanged<BlockFieldCellEvent>? onCellTap;
  final EdgeInsetsGeometry padding;
  final DopBlockFieldTheme? style;

  @override
  State<BlockFieldWidget> createState() => _BlockFieldWidgetState();
}

class _BlockFieldWidgetState extends State<BlockFieldWidget>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  BlockFieldController? _internalController;
  StreamSubscription<BlockFieldBlockEvent>? _events;
  final Map<String, _BlockVisual> _visuals = {};
  _CellHit? _feedbackCell;
  double _feedback = 1;
  Duration? _lastTick;

  BlockFieldController get _controller =>
      widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
    _internalController = widget.controller == null
        ? BlockFieldController(config: widget.config)
        : null;
    _attachController();
  }

  @override
  void didUpdateWidget(BlockFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final needsControllerSwap =
        oldWidget.controller != widget.controller ||
        (widget.controller == null && oldWidget.config != widget.config);
    if (needsControllerSwap) {
      (oldWidget.controller ?? _internalController)?.removeListener(
        _syncVisuals,
      );
      _events?.cancel();
      if (oldWidget.controller == null) _internalController?.dispose();
      _internalController = widget.controller == null
          ? BlockFieldController(config: widget.config)
          : null;
      _visuals.clear();
      _attachController();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller.removeListener(_syncVisuals);
    _events?.cancel();
    if (widget.controller == null) _internalController?.dispose();
    super.dispose();
  }

  void _attachController() {
    _controller.addListener(_syncVisuals);
    _events = _controller.events.listen(_handleBlockEvent);
    _syncVisuals();
  }

  void _handleBlockEvent(BlockFieldBlockEvent event) {
    switch (event.kind) {
      case BlockFieldBlockEventKind.spawned:
        widget.onBlockSpawn?.call(event);
      case BlockFieldBlockEventKind.deleted:
        widget.onBlockDeleted?.call(event);
      case BlockFieldBlockEventKind.tapped:
        break;
    }
  }

  void _syncVisuals() {
    final blocksById = {
      for (final block in _controller.blocks) block.id: block,
    };
    for (final entry in blocksById.entries) {
      final visual = _visuals[entry.key];
      if (visual == null) {
        _visuals[entry.key] = _BlockVisual(block: entry.value);
      } else {
        visual
          ..block = entry.value
          ..removing = false;
      }
    }
    for (final id in _visuals.keys.toList()) {
      if (!blocksById.containsKey(id)) _visuals[id]!.removing = true;
    }
    _startTicker();
    if (mounted) setState(() {});
  }

  void _startTicker() {
    _lastTick = null;
    if (!_ticker.isActive) _ticker.start();
  }

  void _tick(Duration elapsed) {
    final previous = _lastTick;
    _lastTick = elapsed;
    final dt = previous == null
        ? 0.016
        : (elapsed - previous).inMicroseconds / Duration.microsecondsPerSecond;
    var animating = false;

    for (final entry in _visuals.entries.toList()) {
      final visual = entry.value;
      final delta = dt / 0.18;
      visual.progress += visual.removing ? -delta : delta;
      visual.progress = visual.progress.clamp(0.0, 1.0);
      if (visual.removing && visual.progress == 0) {
        _visuals.remove(entry.key);
      } else if (visual.progress != (visual.removing ? 0 : 1)) {
        animating = true;
      }
    }

    if (_feedback < 1) {
      _feedback = (_feedback + dt / 0.22).clamp(0.0, 1.0);
      animating = true;
    }

    if (mounted) setState(() {});
    if (!animating) _ticker.stop();
  }

  void _handleTapDown(TapDownDetails details) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(details.globalPosition);
    final theme = widget.style ?? context.blockFieldTheme;
    final metrics = _BlockFieldMetrics(
      size: box.size,
      padding: widget.padding.resolve(Directionality.of(context)),
      config: _controller.config,
      theme: theme,
    );
    final blockHit = _hitBlock(local, metrics);
    final cellHit = blockHit == null
        ? _hitCell(local, metrics)
        : _CellHit(blockHit.block.position.x, blockHit.block.position.y);

    if (cellHit != null) {
      _feedbackCell = cellHit;
      _feedback = 0;
      _startTicker();
    }

    switch (_controller.mode) {
      case BlockFieldMode.spawn:
        if (cellHit == null) return;
        _controller.spawnAt(
          cellHit.x,
          cellHit.y,
          source: BlockFieldEventSource.userTap,
        );
      case BlockFieldMode.delete:
        if (cellHit == null) return;
        _controller.deleteTopBlockAt(
          cellHit.x,
          cellHit.y,
          source: BlockFieldEventSource.userTap,
        );
      case BlockFieldMode.inspect:
        if (blockHit != null) {
          widget.onBlockTap?.call(
            BlockFieldBlockEvent(
              kind: BlockFieldBlockEventKind.tapped,
              block: blockHit.block,
              source: BlockFieldEventSource.userTap,
            ),
          );
        } else if (cellHit != null) {
          widget.onCellTap?.call(
            BlockFieldCellEvent(
              position: BlockFieldPosition(x: cellHit.x, y: cellHit.y, z: 0),
              source: BlockFieldEventSource.userTap,
            ),
          );
        }
    }
  }

  _BlockShape? _hitBlock(Offset local, _BlockFieldMetrics metrics) {
    final shapes = _buildBlockShapes(_visuals.values, metrics);
    for (final shape in shapes.reversed) {
      if (shape.contains(local)) return shape;
    }
    return null;
  }

  _CellHit? _hitCell(Offset local, _BlockFieldMetrics metrics) {
    for (var y = _controller.config.rows - 1; y >= 0; y--) {
      for (var x = _controller.config.columns - 1; x >= 0; x--) {
        if (_diamondPath(metrics.project(x, y, 0), metrics).contains(local)) {
          return _CellHit(x, y);
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.style ?? context.blockFieldTheme;
    return Semantics(
      label: 'Block field',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        child: CustomPaint(
          painter: _BlockFieldPainter(
            controller: _controller,
            visuals: List<_BlockVisual>.of(_visuals.values),
            feedbackCell: _feedbackCell,
            feedback: _feedback,
            padding: widget.padding.resolve(Directionality.of(context)),
            theme: theme,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _BlockFieldPainter extends CustomPainter {
  _BlockFieldPainter({
    required this.controller,
    required this.visuals,
    required this.feedbackCell,
    required this.feedback,
    required this.padding,
    required this.theme,
  });

  final BlockFieldController controller;
  final List<_BlockVisual> visuals;
  final _CellHit? feedbackCell;
  final double feedback;
  final EdgeInsets padding;
  final DopBlockFieldTheme theme;

  @override
  void paint(Canvas canvas, Size size) {
    final metrics = _BlockFieldMetrics(
      size: size,
      padding: padding,
      config: controller.config,
      theme: theme,
    );
    _drawGrid(canvas, metrics);
    _drawFeedback(canvas, metrics);
    for (final shape in _buildBlockShapes(visuals, metrics)) {
      _drawBlock(canvas, shape);
    }
  }

  void _drawGrid(Canvas canvas, _BlockFieldMetrics metrics) {
    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = theme.gridFillColor;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = theme.strokeWidth
      ..color = theme.gridLineColor;

    for (var y = 0; y < controller.config.rows; y++) {
      for (var x = 0; x < controller.config.columns; x++) {
        final path = _diamondPath(metrics.project(x, y, 0), metrics);
        canvas.drawPath(path, fill);
        canvas.drawPath(path, line);
      }
    }
  }

  void _drawFeedback(Canvas canvas, _BlockFieldMetrics metrics) {
    final cell = feedbackCell;
    if (cell == null || feedback >= 1) return;
    final eased = Curves.easeOutCubic.transform(feedback);
    final center = metrics.project(cell.x, cell.y, 0);
    final path = _diamondPath(center, metrics, inflate: 1 + eased * 0.18);
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = theme.cellFeedbackColor.withValues(alpha: 1 - eased);
    canvas.drawPath(path, paint);
  }

  void _drawBlock(Canvas canvas, _BlockShape shape) {
    final opacity = Curves.easeOutCubic.transform(shape.visual.progress);
    final palette = _palette(shape.block.type, theme);
    final shadow = Paint()
      ..style = PaintingStyle.fill
      ..color = theme.shadowColor.withValues(alpha: 0.28 * opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, theme.glowBlur * 0.35);
    canvas.drawPath(shape.base, shadow);

    final glow = Paint()
      ..style = PaintingStyle.fill
      ..color = palette.glow.withValues(alpha: palette.glow.a * opacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, theme.glowBlur);
    canvas.drawPath(shape.top, glow);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = theme.strokeWidth
      ..color = Colors.black.withValues(alpha: 0.10 * opacity);
    for (final face in [
      (shape.left, palette.left),
      (shape.right, palette.right),
      (shape.top, palette.top),
    ]) {
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = face.$2.withValues(alpha: opacity);
      canvas.drawPath(face.$1, paint);
      canvas.drawPath(face.$1, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _BlockFieldPainter oldDelegate) {
    return oldDelegate.controller != controller ||
        oldDelegate.visuals != visuals ||
        oldDelegate.feedbackCell != feedbackCell ||
        oldDelegate.feedback != feedback ||
        oldDelegate.padding != padding ||
        oldDelegate.theme != theme;
  }
}

class _BlockFieldMetrics {
  _BlockFieldMetrics({
    required this.size,
    required this.padding,
    required this.config,
    required this.theme,
  }) : tileWidth = config.tileWidth ?? theme.tileWidth,
       tileHeight = config.tileHeight ?? theme.tileHeight,
       blockHeight = config.blockHeight ?? theme.blockHeight {
    final availableWidth = math.max(1, size.width - padding.horizontal);
    final availableHeight = math.max(1, size.height - padding.vertical);
    final gridWidth = (config.columns + config.rows) * tileWidth / 2;
    final gridHeight = (config.columns + config.rows) * tileHeight / 2;
    final sceneHeight = gridHeight + config.maxHeight * blockHeight;
    final fit = math.min(
      availableWidth / gridWidth,
      availableHeight / sceneHeight,
    );
    scale = math.min(1, fit) * config.cameraScale;
    origin = Offset(
      size.width / 2,
      padding.top +
          (availableHeight - sceneHeight * scale) / 2 +
          config.maxHeight * blockHeight * scale +
          tileHeight * scale / 2,
    );
  }

  final Size size;
  final EdgeInsets padding;
  final BlockFieldConfig config;
  final DopBlockFieldTheme theme;
  final double tileWidth;
  final double tileHeight;
  final double blockHeight;
  late final double scale;
  late final Offset origin;

  Offset project(int x, int y, num z) {
    return origin +
        Offset(
          (x - y) * tileWidth * scale / 2,
          (x + y) * tileHeight * scale / 2 - z * blockHeight * scale,
        );
  }
}

class _BlockVisual {
  _BlockVisual({required this.block});

  BlockFieldBlock block;
  double progress = 0;
  bool removing = false;
}

class _BlockShape {
  _BlockShape({
    required this.block,
    required this.visual,
    required this.base,
    required this.top,
    required this.left,
    required this.right,
  });

  final BlockFieldBlock block;
  final _BlockVisual visual;
  final Path base;
  final Path top;
  final Path left;
  final Path right;

  bool contains(Offset point) {
    return top.contains(point) || left.contains(point) || right.contains(point);
  }
}

class _CellHit {
  const _CellHit(this.x, this.y);

  final int x;
  final int y;

  @override
  bool operator ==(Object other) {
    return other is _CellHit && other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);
}

List<_BlockShape> _buildBlockShapes(
  Iterable<_BlockVisual> visuals,
  _BlockFieldMetrics metrics,
) {
  final sorted = List<_BlockVisual>.of(visuals)
    ..sort((a, b) {
      final ap = a.block.position;
      final bp = b.block.position;
      final depth = (ap.x + ap.y).compareTo(bp.x + bp.y);
      if (depth != 0) return depth;
      final x = ap.x.compareTo(bp.x);
      if (x != 0) return x;
      return ap.z.compareTo(bp.z);
    });

  return [
    for (final visual in sorted)
      if (visual.progress > 0) _shapeFor(visual, metrics),
  ];
}

_BlockShape _shapeFor(_BlockVisual visual, _BlockFieldMetrics metrics) {
  final block = visual.block;
  final position = block.position;
  final reveal = visual.removing
      ? 1.0
      : Curves.easeOutCubic.transform(visual.progress);
  final baseCenter = metrics.project(position.x, position.y, position.z);
  final topCenter =
      baseCenter - Offset(0, metrics.blockHeight * metrics.scale * reveal);
  final base = _diamondPath(baseCenter, metrics);
  final top = _diamondPath(topCenter, metrics);
  final basePoints = _diamondPoints(baseCenter, metrics);
  final topPoints = _diamondPoints(topCenter, metrics);

  final left = Path()
    ..moveTo(topPoints.left.dx, topPoints.left.dy)
    ..lineTo(topPoints.bottom.dx, topPoints.bottom.dy)
    ..lineTo(basePoints.bottom.dx, basePoints.bottom.dy)
    ..lineTo(basePoints.left.dx, basePoints.left.dy)
    ..close();
  final right = Path()
    ..moveTo(topPoints.right.dx, topPoints.right.dy)
    ..lineTo(topPoints.bottom.dx, topPoints.bottom.dy)
    ..lineTo(basePoints.bottom.dx, basePoints.bottom.dy)
    ..lineTo(basePoints.right.dx, basePoints.right.dy)
    ..close();

  return _BlockShape(
    block: block,
    visual: visual,
    base: base,
    top: top,
    left: left,
    right: right,
  );
}

Path _diamondPath(
  Offset center,
  _BlockFieldMetrics metrics, {
  double inflate = 1,
}) {
  final points = _diamondPoints(center, metrics, inflate: inflate);
  return Path()
    ..moveTo(points.top.dx, points.top.dy)
    ..lineTo(points.right.dx, points.right.dy)
    ..lineTo(points.bottom.dx, points.bottom.dy)
    ..lineTo(points.left.dx, points.left.dy)
    ..close();
}

({Offset top, Offset right, Offset bottom, Offset left}) _diamondPoints(
  Offset center,
  _BlockFieldMetrics metrics, {
  double inflate = 1,
}) {
  final halfWidth = metrics.tileWidth * metrics.scale * inflate / 2;
  final halfHeight = metrics.tileHeight * metrics.scale * inflate / 2;
  return (
    top: center - Offset(0, halfHeight),
    right: center + Offset(halfWidth, 0),
    bottom: center + Offset(0, halfHeight),
    left: center - Offset(halfWidth, 0),
  );
}

DopBlockFieldPalette _palette(BlockType type, DopBlockFieldTheme theme) {
  return switch (type) {
    BlockType.core => theme.core,
    BlockType.glass => theme.glass,
    BlockType.goo => theme.goo,
  };
}
