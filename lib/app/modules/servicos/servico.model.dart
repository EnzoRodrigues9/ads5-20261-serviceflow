import 'package:serviceflow/app/core/base/base.model.dart';

class Servico extends BaseModel {
  final String descricao;
  final double preco;
  final String? tempoEstimado;

  Servico({
    int? id,
    DateTime? createdAt,
    int isSync = 0,
    bool ativo = true,
    required this.descricao,
    required this.preco,
    this.tempoEstimado,
  }) : super(
          id: id,
          createdAt: createdAt,
          isSync: isSync,
          ativo: ativo,
        );

  Servico.fromMap(Map<String, dynamic> map)
      : descricao = map['descricao'] as String,
        preco = (map['preco'] as num).toDouble(),
        tempoEstimado = map['tempo_estimado'] as String?,
        super.fromMap(map);

  @override
  Map<String, dynamic> toMap() {
    final baseMap = super.toMap();

    return {
      ...baseMap,
      'descricao': descricao,
      'preco': preco,
      'tempo_estimado': tempoEstimado,
    };
  }

  Servico copyWith({
    int? id,
    DateTime? createdAt,
    int? isSync,
    bool? ativo,
    String? descricao,
    double? preco,
    String? tempoEstimado,
  }) {
    return Servico(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      isSync: isSync ?? this.isSync,
      ativo: ativo ?? this.ativo,
      descricao: descricao ?? this.descricao,
      preco: preco ?? this.preco,
      tempoEstimado: tempoEstimado ?? this.tempoEstimado,
    );
  }
}