import 'package:flutter/material.dart';
import 'package:serviceflow/app/core/base/base.model.dart';
import 'package:serviceflow/app/core/http/app_client.dart';
import 'package:serviceflow/app/core/logging/log.service.dart';

/// BaseProvider - Abstração para comunicação com APIs externas
/// 
/// Responsabilidades:
/// - Comunicação HTTP via AppClient
/// - Serialização/Deserialização para formato da API externa
/// - Tratamento de erros padronizado
/// - Métodos CRUD para sincronização com API externa
abstract class BaseProvider<E extends BaseModel> {
  final AppClient _client = AppClient();
  final LogService _logger = LogService();

  String get _className => runtimeType.toString();

  String get endpoint;

  Map<String, dynamic> toExternalFormat(E entity);
  E fromExternalFormat(Map<String, dynamic> data);


  Future<bool> syncToCloud(E entity) async {
    try {
      final data = toExternalFormat(entity);

      // Sempre remove campos gerados pelo banco/não enviáveis
      data.remove('id');
      data.remove('created_at');
      data.remove('is_sync');

      if (entity.isSync == 0) {
        // INSERT: registro nunca foi ao Supabase 
        print('📤 [$_className] POST $endpoint — novo registro');
        final response = await _client.post(endpoint, data: data);

        if (response.statusCode == 201 || response.statusCode == 200) {
          print('✅ [$_className] INSERT bem-sucedido');
          return true;
        } else {
          print('❌ [$_className] INSERT falhou: ${response.statusCode} ${response.data}');
          return false;
        }
      } else {
        // UPDATE: já existe no Supabase, usamos id local como filtro
        print('📤 [$_className] PATCH $endpoint?id=eq.${entity.id}');
        final response = await _client.patch(
          endpoint,
          data: data,
          queryParameters: {'id': 'eq.${entity.id}'},
        );

        if (response.statusCode == 200) {
          print('✅ [$_className] UPDATE bem-sucedido');
          return true;
        } else {
          print('❌ [$_className] UPDATE falhou: ${response.statusCode} ${response.data}');
          return false;
        }
      }
    } catch (e, stack) {
      print('💥 [$_className] Exceção em syncToCloud: $e');
      print('📋 Stack: $stack');
      handleError('syncToCloud', e);
      return false;
    }
  }

  /// Busca entidades do Supabase
  Future<List<E>> fetchFromCloud({DateTime? lastSync}) async {
    try {
      final queryParams = lastSync != null
          ? {'updated_at': 'gte.${lastSync.toIso8601String()}'}
          : null;

      final response = await _client.get(endpoint, queryParameters: queryParams);

      if (response.data is List) {
        return (response.data as List)
            .map((item) => fromExternalFormat(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      handleError('fetchFromCloud', e);
      return [];
    }
  }

  /// Deleta entidade no Supabase via filtro de query param
  Future<bool> deleteFromCloud(int id) async {
    try {
      await _client.delete(endpoint, queryParameters: {'id': 'eq.$id'});
      return true;
    } catch (e) {
      handleError('deleteFromCloud', e);
      return false;
    }
  }

  @protected
  void handleError(String operation, dynamic error) {
    _logger.handleProviderError(_className, operation, error);
  }

  Future<bool> validateBeforeSync(E entity) async => true;
  Future<void> afterSync(E entity, bool success) async {}

  Future<E?> resolveConflict(E local, E remote) async {
    final localUpdated = local.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final remoteUpdated = remote.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return localUpdated.isAfter(remoteUpdated) ? local : remote;
  }
}