/// 再構築種別を表すEnum
///
/// 再構築の種類によって、選択したサブステータスが確定で強化される回数が異なります。
enum RebuildType {
  /// 通常再構築（保証2回）
  ///
  /// 選択した2つのサブステータスのいずれかが2回確定で強化されます。
  /// 残りの3回はランダム強化（4つのサブステータスから抽選）。
  normal(guaranteedRolls: 2, label: '通常再構築'),

  /// 上級再構築（保証3回）
  ///
  /// 選択した2つのサブステータスのいずれかが3回確定で強化されます。
  /// 残りの2回はランダム強化（4つのサブステータスから抽選）。
  advanced(guaranteedRolls: 3, label: '上級再構築'),

  /// 絶対再構築（保証4回）
  ///
  /// 選択した2つのサブステータスのいずれかが4回確定で強化されます。
  /// 残りの1回はランダム強化（4つのサブステータスから抽選）。
  absolute(guaranteedRolls: 4, label: '絶対再構築');

  const RebuildType({required this.guaranteedRolls, required this.label});

  /// 保証強化回数（選択サブステータスから必ず強化される回数）
  final int guaranteedRolls;

  /// 表示用ラベル
  final String label;

  /// 保証回数付きのラベル（UI表示用）
  String get labelWithCount => '$label（保証$guaranteedRolls回）';
}
