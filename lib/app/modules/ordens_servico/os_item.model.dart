import 'package:serviceflow/app/core/base/base.model.dart';

class OsItem extends BaseModel {
  final int? osId;

  final int servicoId;

  final String? descricaoSnapshot;

  final double? precoSnapshot;

  OsItem({
    super.id,
    super.createdAt,
    super.isSync = 0,
    super.ativo = true,
    this.osId,
    required this.servicoId,
    this.descricaoSnapshot,
    this.precoSnapshot,
  });

  factory OsItem.fromMap(
    Map<String, dynamic> map,
  ) {
    return OsItem(
      id: map['id'] as int?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(
              map['created_at'],
            )
          : null,
      isSync: map['is_sync'] ?? 0,
      ativo: map['ativo'] == 1,
      osId: map['os_id'],
      servicoId: map['servico_id'] as int,
      descricaoSnapshot: map['descricao_snapshot'] as String?,
      precoSnapshot: map['preco_snapshot'] != null
          ? (map['preco_snapshot'] as num).toDouble()
          : null,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'os_id': osId,
      'servico_id': servicoId,
      'descricao_snapshot': descricaoSnapshot,
      'preco_snapshot': precoSnapshot,
    };
  }

  OsItem copyWith({
    int? id,
    DateTime? createdAt,
    int? isSync,
    bool? ativo,
    int? osId,
    int? servicoId,
    String? descricaoSnapshot,
    double? precoSnapshot,
  }) {
    return OsItem(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      isSync: isSync ?? this.isSync,
      ativo: ativo ?? this.ativo,
      osId: osId ?? this.osId,
      servicoId: servicoId ?? this.servicoId,
      descricaoSnapshot: descricaoSnapshot ?? this.descricaoSnapshot,
      precoSnapshot: precoSnapshot ?? this.precoSnapshot,
    );
  }
}
