import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../app/core/helpers/app.config.dart';
import '../../../app/modules/usuarios/usuario.model.dart';
import '../../../app/modules/usuarios/usuario.repository.dart';

class AuthService {
  static final AuthService _instance = AuthService._init();
  factory AuthService() => _instance;
  AuthService._init();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _keyToken = 'sf_jwt_token';
  static const _keyUserId = 'sf_user_id';
  static const _keyUserEmail = 'sf_user_email';

  final _supabase = Supabase.instance.client;
  final _usuarioRepository = UsuarioRepository();

  Future<AuthResult> cadastrar({
    required String email,
    required String nomeCompleto,
    required String senha,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: senha,
        data: {'nome_completo': nomeCompleto.trim()},
      );

      final authUser = response.user;
      if (authUser == null) {
        return AuthResult.error('Falha ao criar conta. Tente novamente.');
      }

      final supabaseId = authUser.id;
      final session = response.session;

      if (session != null) {
        await _persistirToken(
          token: session.accessToken,
          userId: supabaseId,
          email: email.trim(),
        );
      }

      final usuario = Usuario(
        supabaseId: supabaseId,
        email: email.trim(),
        nomeCompleto: nomeCompleto.trim(),
        grupoId: AppConfig.groupId,
        perfil: 'tecnico',
        isSync: 0,
        ativo: true,
        createdAt: DateTime.now(),
      );

      await _usuarioRepository.insert(usuario);

      await _sincronizarUsuarioSupabase(
          usuario.copyWith(supabaseId: supabaseId));

      return AuthResult.success(
        message: session != null
            ? 'Conta criada com sucesso!'
            : 'Conta criada! Verifique seu e-mail para confirmar.',
        needsEmailVerification: session == null,
      );
    } on AuthException catch (e) {
      return AuthResult.error(_traduzirErroAuth(e.message));
    } catch (e) {
      return AuthResult.error('Erro inesperado: ${e.toString()}');
    }
  }

  Future<AuthResult> login({
    required String email,
    required String senha,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: senha,
      );

      final session = response.session;
      final authUser = response.user;

      if (session == null || authUser == null) {
        return AuthResult.error('Credenciais inválidas. Tente novamente.');
      }

      await _persistirToken(
        token: session.accessToken,
        userId: authUser.id,
        email: email.trim(),
      );

      await _atualizarCacheLocal(authUser, session);

      return AuthResult.success(message: 'Login realizado com sucesso!');
    } on AuthException catch (e) {
      return AuthResult.error(_traduzirErroAuth(e.message));
    } catch (e) {
      return AuthResult.error('Erro de conexão. Verifique sua internet.');
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (_) {}
    await _storage.deleteAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _keyToken);
    return token != null && token.isNotEmpty;
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  Future<String?> getUserEmail() async {
    return await _storage.read(key: _keyUserEmail);
  }

  Future<void> _persistirToken({
    required String token,
    required String userId,
    required String email,
  }) async {
    await Future.wait([
      _storage.write(key: _keyToken, value: token),
      _storage.write(key: _keyUserId, value: userId),
      _storage.write(key: _keyUserEmail, value: email),
    ]);
  }

  Future<void> _atualizarCacheLocal(User authUser, Session session) async {
    try {
      final todos = await _usuarioRepository.findAll();
      final localUser = todos.cast<Usuario?>().firstWhere(
            (u) => u?.supabaseId == authUser.id,
            orElse: () => null,
          );

      final agora = DateTime.now();

      if (localUser != null) {
        final atualizado = localUser.copyWith(
          ultimoLogin: agora.toIso8601String(),
          isSync: 1,
        );
        await _usuarioRepository.update(atualizado);
      } else {
        final nomeCompleto =
            authUser.userMetadata?['nome_completo'] as String? ?? 'Usuário';
        final novoUsuario = Usuario(
          supabaseId: authUser.id,
          email: authUser.email ?? '',
          nomeCompleto: nomeCompleto,
          grupoId: AppConfig.groupId,
          perfil: 'tecnico',
          ultimoLogin: agora.toIso8601String(),
          isSync: 1,
          ativo: true,
          createdAt: agora,
        );
        await _usuarioRepository.insert(novoUsuario);
      }
    } catch (_) {}
  }

  Future<void> _sincronizarUsuarioSupabase(Usuario usuario) async {
    try {
      await _supabase.from('usuarios').upsert({
        'supabase_id': usuario.supabaseId,
        'email': usuario.email,
        'nome_completo': usuario.nomeCompleto,
        'grupo_id': usuario.grupoId,
        'perfil': usuario.perfil,
        'ativo': usuario.ativo,
      });
    } catch (_) {}
  }

  String _traduzirErroAuth(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid credentials')) {
      return 'E-mail ou senha incorretos.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Confirme seu e-mail antes de entrar.';
    }
    if (msg.contains('user already registered') ||
        msg.contains('already been registered')) {
      return 'Este e-mail já está cadastrado.';
    }
    if (msg.contains('password')) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }
    if (msg.contains('rate limit')) {
      return 'Muitas tentativas. Aguarde alguns minutos.';
    }
    return message;
  }
}

class AuthResult {
  final bool success;
  final String message;
  final bool needsEmailVerification;

  const AuthResult._({
    required this.success,
    required this.message,
    this.needsEmailVerification = false,
  });

  factory AuthResult.success({
    required String message,
    bool needsEmailVerification = false,
  }) =>
      AuthResult._(
        success: true,
        message: message,
        needsEmailVerification: needsEmailVerification,
      );

  factory AuthResult.error(String message) =>
      AuthResult._(success: false, message: message);
}
