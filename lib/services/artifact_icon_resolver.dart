import 'package:flutter/services.dart';

/// 聖遺物のアイコンパスを解決するサービス
class ArtifactIconResolver {
  ArtifactIconResolver(this._availableAssets);

  final Set<String> _availableAssets;

  static ArtifactIconResolver? _cache;

  /// アーティファクトアイコンリゾルバーを読み込む
  static Future<ArtifactIconResolver> load() async {
    if (_cache != null) {
      return _cache!;
    }
    
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assetPaths = manifest
        .listAssets()
        .where((path) => path.startsWith('assets/artifacts/'))
        .toSet();
    _cache = ArtifactIconResolver(assetPaths);
    return _cache!;
  }

  /// 指定されたアイコン名と装備種別に対応するパスを取得する
  String? pathFor(String? iconName, String? equipType) {
    final candidates = <String>[];
    
    if (iconName != null && iconName.isNotEmpty) {
      candidates.add('assets/artifacts/$iconName.webp');
    }
    if (equipType != null && equipType.isNotEmpty) {
      candidates.add('assets/artifacts/$equipType.webp');
    }
    
    for (final candidate in candidates) {
      if (_availableAssets.contains(candidate)) {
        return candidate;
      }
    }
    return null;
  }
}