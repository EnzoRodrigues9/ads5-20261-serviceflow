import 'package:serviceflow/app/core/base/base.model.dart';

class Cliente extends BaseModel {
  final String nome;
  final String email;
  final String telefone;
  final String? documento;
  final String? endereco;
  final String? cidade;
  final String? estado;
  final String? cep;

  Cliente({
    int? id,
    DateTime? createdAt,
    int isSync = 0,
    bool ativo = true,
    required this.nome,
    required this.email,
    required this.telefone,
    this.documento,
    this.endereco,
    this.cidade,
    this.estado,
    this.cep,
  }) : super(id: id, createdAt: createdAt, isSync: isSync, ativo: ativo);

  Cliente.fromMap(Map<String, dynamic> map)
      : nome = map['nome'] as String,
        email = map['email'] as String,
        telefone = map['telefone'] as String,
        documento = map['documento'] as String?,
        endereco = map['endereco'] as String?,
        cidade = map['cidade'] as String?,
        estado = map['estado'] as String?,
        cep = map['cep'] as String?,
        super.fromMap(map);

  @override
  Map<String, dynamic> toMap() {
    final baseMap = super.toMap();
    return {
      ...baseMap,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'documento': documento,
      'endereco': endereco,
      'cidade': cidade,
      'estado': estado,
      'cep': cep,
    };
  }

  Cliente copyWith({
    int? id,
    DateTime? createdAt,
    int? isSync,
    bool? ativo,
    String? nome,
    String? email,
    String? telefone,
    String? documento,
    String? endereco,
    String? cidade,
    String? estado,
    String? cep,
  }) {
    return Cliente(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      isSync: isSync ?? this.isSync,
      ativo: ativo ?? this.ativo,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      documento: documento ?? this.documento,
      endereco: endereco ?? this.endereco,
      cidade: cidade ?? this.cidade,
      estado: estado ?? this.estado,
      cep: cep ?? this.cep,
    );
  }
}
