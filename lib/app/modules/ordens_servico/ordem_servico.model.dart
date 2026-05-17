import 'package:serviceflow/app/core/base/base.model.dart';


import 'os_item.model.dart';

class OrdemServico extends BaseModel {
  final int clienteId;

  final int tecnicoId;

  final String? observacao;

  final String? pecasAplicadas;

  final double valorPecas;

  final String? fotoAntes;

  final String? fotoDepois;

  final String? assinatura;

  final String status;

  final List<OsItem> itens;

  OrdemServico({
    super.id,
    super.createdAt,
    super.isSync = 0,
    super.ativo = true,
    required this.clienteId,
    required this.tecnicoId,
    this.observacao,
    this.pecasAplicadas,
    this.valorPecas = 0,
    this.fotoAntes,
    this.fotoDepois,
    this.assinatura,
    this.status = 'Em aberto',
    this.itens = const [],
  });

  factory OrdemServico.fromMap(
    Map<String, dynamic> map,
  ) {
    return OrdemServico(
      id: map['id'],

      createdAt:
          map['created_at'] != null
              ? DateTime.parse(
                  map['created_at'],
                )
              : null,

      isSync: map['is_sync'] ?? 0,

      ativo: map['ativo'] == 1,

      clienteId: map['cliente_id'],

      tecnicoId: map['tecnico_id'],

      observacao: map['observacao'],

      pecasAplicadas:
          map['pecas_aplicadas'],

      valorPecas:
          (map['valor_pecas'] ?? 0)
              .toDouble(),

      fotoAntes: map['foto_antes'],

      fotoDepois: map['foto_depois'],

      assinatura: map['assinatura'],

      status:
          map['status'] ??
              'Em aberto',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),

      'cliente_id': clienteId,

      'tecnico_id': tecnicoId,

      'observacao': observacao,

      'pecas_aplicadas':
          pecasAplicadas,

      'valor_pecas': valorPecas,

      'foto_antes': fotoAntes,

      'foto_depois': fotoDepois,

      'assinatura': assinatura,

      'status': status,
    };
  }

  OrdemServico copyWith({
    int? id,
    DateTime? createdAt,
    int? isSync,
    bool? ativo,
    int? clienteId,
    int? tecnicoId,
    String? observacao,
    String? pecasAplicadas,
    double? valorPecas,
    String? fotoAntes,
    String? fotoDepois,
    String? assinatura,
    String? status,
    List<OsItem>? itens,
  }) {
    return OrdemServico(
      id: id ?? this.id,

      createdAt:
          createdAt ?? this.createdAt,

      isSync: isSync ?? this.isSync,

      ativo: ativo ?? this.ativo,

      clienteId:
          clienteId ?? this.clienteId,

      tecnicoId:
          tecnicoId ?? this.tecnicoId,

      observacao:
          observacao ??
              this.observacao,

      pecasAplicadas:
          pecasAplicadas ??
              this.pecasAplicadas,

      valorPecas:
          valorPecas ??
              this.valorPecas,

      fotoAntes:
          fotoAntes ?? this.fotoAntes,

      fotoDepois:
          fotoDepois ??
              this.fotoDepois,

      assinatura:
          assinatura ??
              this.assinatura,

      status: status ?? this.status,

      itens: itens ?? this.itens,
    );
  }
}