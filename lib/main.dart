import 'dart:convert';

import 'package:artifact_diagnoser/models/user_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, fontFamily: 'GISDK'),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  List<ReliquarySummary> _summaries = const [];
  bool _isLoading = false;

  Future<void> _handleExecute() async {
    final messenger = ScaffoldMessenger.maybeOf(context);

    setState(() {
      _isLoading = true;
    });

    try {
      final jsonString = await rootBundle.loadString(
        'assets/json/userdata.json',
      );
      final userData = UserData.fromJsonString(jsonString);
      final localizer = await StatLocalizer.load();
      final appendResolver = await StatAppendResolver.load();
      final iconResolver = await ArtifactIconResolver.load();
      final summaries = _buildReliquarySummaries(
        userData,
        localizer,
        appendResolver,
        iconResolver,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _summaries = summaries;
        _isLoading = false;
      });

      debugPrint(
        'Loaded user UID: ${userData.uid} with ${summaries.length} reliquaries',
      );
      messenger?.showSnackBar(
        SnackBar(content: Text('ユーザーデータを読み込みました: UID ${userData.uid}')),
      );
    } catch (error, stackTrace) {
      if (!mounted) {
        return;
      }

      setState(() {
        _summaries = const [];
        _isLoading = false;
      });
      debugPrint('ユーザーデータの読み込みに失敗しました: $error');
      debugPrint('$stackTrace');
      messenger?.showSnackBar(
        const SnackBar(content: Text('ユーザーデータの読み込みに失敗しました')),
      );
    }
  }

  List<ReliquarySummary> _buildReliquarySummaries(
    UserData data,
    StatLocalizer localizer,
    StatAppendResolver appendResolver,
    ArtifactIconResolver iconResolver,
  ) {
    final results = <ReliquarySummary>[];
    for (final avatar in data.avatarInfoList) {
      for (final equipment in avatar.equipList) {
        final reliquary = equipment.reliquary;
        final flat = equipment.flat;
        if (reliquary == null || flat.reliquarySubstats == null) {
          continue;
        }

        final substats = flat.reliquarySubstats!;
        final appendIds = reliquary.appendPropIdList ?? const <int>[];
        final entries = <_MutableSubstat>[];
        final map = <String, _MutableSubstat>{};

        for (var i = 0; i < substats.length; i++) {
          final substat = substats[i];
          final identifier = i < appendIds.length
              ? _extractIdentifier(appendIds[i])
              : substat.appendPropId;
          final initialList = <int>[];
          if (i < appendIds.length) {
            initialList.add(_extractSuffix(appendIds[i]));
          }
          final entry = _MutableSubstat(
            appendPropId: substat.appendPropId,
            statValue: substat.statValue,
            identifier: identifier,
            statAppendList: initialList,
          );
          entries.add(entry);
          map[identifier] = entry;
        }

        for (var i = substats.length; i < appendIds.length; i++) {
          final identifier = _extractIdentifier(appendIds[i]);
          final suffix = _extractSuffix(appendIds[i]);
          final entry = map[identifier];
          entry?.statAppendList.add(suffix);
        }

        results.add(
          ReliquarySummary(
            avatarId: avatar.avatarId,
            itemId: equipment.itemId,
            equipType: flat.equipType,
            equipTypeLabel: localizer.labelFor(flat.equipType),
            mainPropId: flat.reliquaryMainstat?.mainPropId,
            mainPropLabel: localizer.labelFor(
              flat.reliquaryMainstat?.mainPropId,
            ),
            mainStatValue: flat.reliquaryMainstat?.statValue,
            iconAssetPath: iconResolver.pathFor(flat.icon, flat.equipType),
            substats: entries.map((entry) {
              final appendValues = appendResolver.valuesFor(
                entry.appendPropId,
                entry.statAppendList,
              );
              return entry.toSubstatSummary(
                displayName: localizer.labelFor(entry.appendPropId),
                appendValueStrings: appendValues,
              );
            }).toList(),
          ),
        );
      }
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Artifact Diagnoser')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('テキストを入力してください', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  TextField(
                    maxLines: 5,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'サンプルテキスト...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleExecute,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('実行'),
                  ),
                  const SizedBox(height: 24),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator()),
                  if (!_isLoading && _summaries.isEmpty)
                    const Text('実行結果はまだありません。'),
                  if (_summaries.isNotEmpty)
                    SelectionArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            '装備解析結果 (${_summaries.length} 件)',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          for (final summary in _summaries)
                            ReliquarySummaryView(summary: summary),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ReliquarySummary {
  const ReliquarySummary({
    required this.avatarId,
    required this.itemId,
    required this.equipType,
    required this.equipTypeLabel,
    required this.mainPropId,
    required this.mainPropLabel,
    required this.mainStatValue,
    required this.substats,
    required this.iconAssetPath,
  });

  final int avatarId;
  final int itemId;
  final String? equipType;
  final String equipTypeLabel;
  final String? mainPropId;
  final String mainPropLabel;
  final double? mainStatValue;
  final List<SubstatSummary> substats;
  final String? iconAssetPath;
}

class SubstatSummary {
  const SubstatSummary({
    required this.appendPropId,
    required this.displayName,
    required this.statValue,
    required this.identifier,
    required this.statAppendList,
    required this.appendValueStrings,
  });

  final String appendPropId;
  final String displayName;
  final double statValue;
  final String identifier;
  final List<int> statAppendList;
  final List<String> appendValueStrings;
}

class ReliquarySummaryView extends StatelessWidget {
  const ReliquarySummaryView({super.key, required this.summary});

  final ReliquarySummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (summary.iconAssetPath != null)
              Center(
                child: Image.asset(
                  summary.iconAssetPath!,
                  width: 64,
                  height: 64,
                  fit: BoxFit.contain,
                ),
              ),
            if (summary.iconAssetPath != null) const SizedBox(height: 8),
            if (summary.mainPropId != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'メインステータス: ${summary.mainPropLabel} '
                  '(${_formatNumber(summary.mainStatValue)})',
                ),
              ),
            if (summary.equipType?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('装備部位: ${summary.equipTypeLabel}'),
              ),
            const Text('サブステータス:'),
            for (final substat in summary.substats)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '・${substat.displayName} : ${_formatNumber(substat.statValue)} '
                  '(${_formatAppendValues(substat.appendValueStrings)})',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MutableSubstat {
  _MutableSubstat({
    required this.appendPropId,
    required this.statValue,
    required this.identifier,
    required this.statAppendList,
  });

  final String appendPropId;
  final double statValue;
  final String identifier;
  final List<int> statAppendList;

  SubstatSummary toSubstatSummary({
    required String displayName,
    required List<String> appendValueStrings,
  }) {
    return SubstatSummary(
      appendPropId: appendPropId,
      displayName: displayName,
      statValue: statValue,
      identifier: identifier,
      statAppendList: List<int>.from(statAppendList),
      appendValueStrings: appendValueStrings,
    );
  }
}

class StatLocalizer {
  StatLocalizer(this._labels);

  final Map<String, String> _labels;

  static StatLocalizer? _cache;

  static Future<StatLocalizer> load() async {
    if (_cache != null) {
      return _cache!;
    }
    final content = await rootBundle.loadString('assets/json/stats_l18n.json');
    final Map<String, dynamic> data =
        jsonDecode(content) as Map<String, dynamic>;
    final labels = data.map((key, value) => MapEntry(key, value.toString()));
    _cache = StatLocalizer(labels);
    return _cache!;
  }

  String labelFor(String? key) {
    if (key == null || key.isEmpty) {
      return '';
    }
    return _labels[key] ?? key;
  }
}

class StatAppendResolver {
  StatAppendResolver(this._values);

  final Map<String, Map<String, String>> _values;

  static StatAppendResolver? _cache;

  static Future<StatAppendResolver> load() async {
    if (_cache != null) {
      return _cache!;
    }
    final content = await rootBundle.loadString(
      'assets/json/stats_append.json',
    );
    final Map<String, dynamic> raw =
        jsonDecode(content) as Map<String, dynamic>;
    final values = <String, Map<String, String>>{};
    raw.forEach((key, dynamic value) {
      final map = <String, String>{};
      (value as Map).forEach((innerKey, innerValue) {
        map[innerKey.toString()] = innerValue.toString();
      });
      values[key] = map;
    });
    _cache = StatAppendResolver(values);
    return _cache!;
  }

  List<String> valuesFor(String appendPropId, List<int> suffixes) {
    final table = _values[appendPropId];
    if (table == null) {
      return suffixes.map((suffix) => suffix.toString()).toList();
    }
    final result = <String>[];
    for (final suffix in suffixes) {
      final key = suffix.toString();
      result.add(table[key] ?? key);
    }
    return result;
  }
}

class ArtifactIconResolver {
  ArtifactIconResolver(this._availableAssets);

  final Set<String> _availableAssets;

  static ArtifactIconResolver? _cache;

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

String _extractIdentifier(int value) {
  final digits = value.abs().toString();
  final splitIndex = digits.isNotEmpty ? digits.length - 1 : 0;
  final basePart = digits.substring(0, splitIndex);
  if (basePart.isEmpty) {
    return ''.padLeft(5, '0');
  }
  return basePart.padLeft(5, '0');
}

int _extractSuffix(int value) {
  final digits = value.abs().toString();
  if (digits.isEmpty) {
    return 0;
  }
  return int.parse(digits.substring(digits.length - 1));
}

String _formatNumber(num? value) {
  if (value == null) {
    return '-';
  }
  final doubleValue = value.toDouble();
  if (doubleValue == doubleValue.roundToDouble()) {
    return doubleValue.toInt().toString();
  }
  return doubleValue.toString();
}

String _formatAppendValues(List<String> values) {
  if (values.isEmpty) {
    return 'なし';
  }
  return values.join(' + ');
}
