// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart' as _svg;
import 'package:vector_graphics/vector_graphics.dart' as _vg;

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// File path: assets/icons/brains.svg
  SvgGenImage get brains => const SvgGenImage('assets/icons/brains.svg');

  /// File path: assets/icons/creation.svg
  SvgGenImage get creation => const SvgGenImage('assets/icons/creation.svg');

  /// File path: assets/icons/creation_spark.svg
  SvgGenImage get creationSpark =>
      const SvgGenImage('assets/icons/creation_spark.svg');

  /// File path: assets/icons/deprivation.svg
  SvgGenImage get deprivation =>
      const SvgGenImage('assets/icons/deprivation.svg');

  /// File path: assets/icons/deprivation_orb.svg
  SvgGenImage get deprivationOrb =>
      const SvgGenImage('assets/icons/deprivation_orb.svg');

  /// Directory path: assets/icons/imagination
  $AssetsIconsImaginationGen get imagination =>
      const $AssetsIconsImaginationGen();

  /// File path: assets/icons/imagination.svg
  SvgGenImage get imaginationSvg =>
      const SvgGenImage('assets/icons/imagination.svg');

  /// File path: assets/icons/imagination_blob.svg
  SvgGenImage get imaginationBlob =>
      const SvgGenImage('assets/icons/imagination_blob.svg');

  /// File path: assets/icons/rainbow.svg
  SvgGenImage get rainbow => const SvgGenImage('assets/icons/rainbow.svg');

  /// File path: assets/icons/reward.svg
  SvgGenImage get reward => const SvgGenImage('assets/icons/reward.svg');

  /// File path: assets/icons/reward_wave.svg
  SvgGenImage get rewardWave =>
      const SvgGenImage('assets/icons/reward_wave.svg');

  /// File path: assets/icons/spark.svg
  SvgGenImage get spark => const SvgGenImage('assets/icons/spark.svg');

  /// File path: assets/icons/work.svg
  SvgGenImage get work => const SvgGenImage('assets/icons/work.svg');

  /// List of all assets
  List<SvgGenImage> get values => [
    brains,
    creation,
    creationSpark,
    deprivation,
    deprivationOrb,
    imaginationSvg,
    imaginationBlob,
    rainbow,
    reward,
    rewardWave,
    spark,
    work,
  ];
}

class $AssetsSoundGen {
  const $AssetsSoundGen();

  /// Directory path: assets/sound/dopamine120_op1_pack
  $AssetsSoundDopamine120Op1PackGen get dopamine120Op1Pack =>
      const $AssetsSoundDopamine120Op1PackGen();
}

class $AssetsIconsImaginationGen {
  const $AssetsIconsImaginationGen();

  /// File path: assets/icons/imagination/frame_01.svg
  SvgGenImage get frame01 =>
      const SvgGenImage('assets/icons/imagination/frame_01.svg');

  /// File path: assets/icons/imagination/frame_02.svg
  SvgGenImage get frame02 =>
      const SvgGenImage('assets/icons/imagination/frame_02.svg');

  /// File path: assets/icons/imagination/frame_03.svg
  SvgGenImage get frame03 =>
      const SvgGenImage('assets/icons/imagination/frame_03.svg');

  /// File path: assets/icons/imagination/frame_04.svg
  SvgGenImage get frame04 =>
      const SvgGenImage('assets/icons/imagination/frame_04.svg');

  /// List of all assets
  List<SvgGenImage> get values => [frame01, frame02, frame03, frame04];
}

class $AssetsSoundDopamine120Op1PackGen {
  const $AssetsSoundDopamine120Op1PackGen();

  /// File path: assets/sound/dopamine120_op1_pack/creation_op1.wav
  String get creationOp1 =>
      'assets/sound/dopamine120_op1_pack/creation_op1.wav';

  /// File path: assets/sound/dopamine120_op1_pack/deprivation_op1.wav
  String get deprivationOp1 =>
      'assets/sound/dopamine120_op1_pack/deprivation_op1.wav';

  /// File path: assets/sound/dopamine120_op1_pack/imagination_op1.wav
  String get imaginationOp1 =>
      'assets/sound/dopamine120_op1_pack/imagination_op1.wav';

  /// File path: assets/sound/dopamine120_op1_pack/reward_op1.wav
  String get rewardOp1 => 'assets/sound/dopamine120_op1_pack/reward_op1.wav';

  /// List of all assets
  List<String> get values => [
    creationOp1,
    deprivationOp1,
    imaginationOp1,
    rewardOp1,
  ];
}

class Assets {
  const Assets._();

  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsSoundGen sound = $AssetsSoundGen();
}

class SvgGenImage {
  const SvgGenImage(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = false;

  const SvgGenImage.vec(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = true;

  final String _assetName;
  final Size? size;
  final Set<String> flavors;
  final bool _isVecFormat;

  _svg.SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    _svg.SvgTheme? theme,
    _svg.ColorMapper? colorMapper,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    final _svg.BytesLoader loader;
    if (_isVecFormat) {
      loader = _vg.AssetBytesLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
      );
    } else {
      loader = _svg.SvgAssetLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
        theme: theme,
        colorMapper: colorMapper,
      );
    }
    return _svg.SvgPicture(
      loader,
      key: key,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter:
          colorFilter ??
          (color == null ? null : ColorFilter.mode(color, colorBlendMode)),
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
