import 'package:serviceflow/app/core/base/base.model.dart';

class Usuario extends BaseModel {
  final String supabaseId;
  final String email;
  final String nomeCompleto;
  final String grupoId;
  final String perfil;
  final String? ultimoLogin;
  final String? avatarLocalPath;
  final String? configuracoes;

  Usuario({
    int? id,
    DateTime? createdAt,
    int isSync = 0,
    bool ativo = true,
    required this.supabaseId,
    required this.email,
    required this.nomeCompleto,
    required this.grupoId,
    required this.perfil,
    this.ultimoLogin,
    this.avatarLocalPath,
    this.configuracoes,
  }) : super(
          id: id,
          createdAt: createdAt,
          isSync: isSync,
          ativo: ativo,
        );

  Usuario.fromMap(Map<String, dynamic> map)
      : supabaseId = map['supabase_id'] as String,
        email = map['email'] as String,
        nomeCompleto = map['nome_completo'] as String,
        grupoId = map['grupo_id'] as String,
        perfil = map['perfil'] as String? ?? 'tecnico',
        ultimoLogin = map['ultimo_login'] as String?,
        avatarLocalPath = map['avatar_local_path'] as String?,
        configuracoes = map['configuracoes'] as String?,
        super.fromMap(map);

  @override
  Map<String, dynamic> toMap() {
    final baseMap = super.toMap();

    return {
      ...baseMap,
      'supabase_id': supabaseId,
      'email': email,
      'nome_completo': nomeCompleto,
      'grupo_id': grupoId,
      'perfil': perfil,
      'ultimo_login': ultimoLogin,
      'avatar_local_path': avatarLocalPath,
      'configuracoes': configuracoes,
    };
  }

  Usuario copyWith({
    int? id,
    DateTime? createdAt,
    int? isSync,
    bool? ativo,
    String? supabaseId,
    String? email,
    String? nomeCompleto,
    String? grupoId,
    String? perfil,
    String? ultimoLogin,
    String? avatarLocalPath,
    String? configuracoes,
  }) {
    return Usuario(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      isSync: isSync ?? this.isSync,
      ativo: ativo ?? this.ativo,
      supabaseId: supabaseId ?? this.supabaseId,
      email: email ?? this.email,
      nomeCompleto: nomeCompleto ?? this.nomeCompleto,
      grupoId: grupoId ?? this.grupoId,
      perfil: perfil ?? this.perfil,
      ultimoLogin: ultimoLogin ?? this.ultimoLogin,
      avatarLocalPath: avatarLocalPath ?? this.avatarLocalPath,
      configuracoes: configuracoes ?? this.configuracoes,
    );
  }
}