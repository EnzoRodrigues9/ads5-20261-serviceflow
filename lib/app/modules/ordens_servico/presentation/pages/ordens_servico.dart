class OrdemServico {
  final int id;

  String cliente;
  String descricao;
  double valor;
  String status;

  String? fotoAntes;
  String? fotoDepois;

  OrdemServico({
    required this.id,
    required this.cliente,
    required this.descricao,
    required this.valor,
    required this.status,
    this.fotoAntes,
    this.fotoDepois,
  });
}