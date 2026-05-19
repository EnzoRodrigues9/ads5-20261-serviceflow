import 'package:serviceflow/app/core/base/base.provider.dart';
import 'usuario.model.dart';

class UsuarioProvider extends BaseProvider<Usuario> {
  @override
  String get endpoint => '/rest/v1/usuarios';

  @override
  Map<String, dynamic> toExternalFormat(Usuario usuario) {
    return {
      'supabase_id': usuario.supabaseId,
      'email': usuario.email,
      'nome_completo': usuario.nomeCompleto,
      'grupo_id': usuario.grupoId,
      'perfil': usuario.perfil,
      'ultimo_login': usuario.ultimoLogin,
      'avatar_local_path': usuario.avatarLocalPath,
      'configuracoes': usuario.configuracoes,
      'ativo': usuario.ativo,
    };
  }

  @override
  Usuario fromExternalFormat(Map<String, dynamic> data) {
    return Usuario(
      id: data['id'] as int?,
      supabaseId: data['supabase_id'] as String? ?? '',
      email: data['email'] as String? ?? '',
      nomeCompleto: data['nome_completo'] as String? ?? '',
      grupoId: data['grupo_id'] as String? ?? '',
      perfil: data['perfil'] as String? ?? 'tecnico',
      ultimoLogin: data['ultimo_login']?.toString(),
      avatarLocalPath: data['avatar_local_path'] as String?,
      configuracoes: data['configuracoes'] as String?,
      isSync: 1,
      createdAt: data['created_at'] != null
          ? DateTime.tryParse(data['created_at'].toString())
          : DateTime.now(),
    );
  }

  @override
  Future<bool> validateBeforeSync(Usuario usuario) async {
    if (usuario.nomeCompleto.trim().isEmpty) {
      handleError('validateBeforeSync', 'Nome obrigatório');
      return false;
    }

    if (usuario.email.trim().isEmpty) {
      handleError('validateBeforeSync', 'Email obrigatório');
      return false;
    }

    if (!usuario.email.contains('@')) {
      handleError('validateBeforeSync', 'Email inválido');
      return false;
    }

    if (usuario.grupoId.trim().isEmpty) {
      handleError('validateBeforeSync', 'Grupo obrigatório');
      return false;
    }

    return true;
  }
}
