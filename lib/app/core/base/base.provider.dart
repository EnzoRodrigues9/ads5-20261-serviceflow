import 'package:flutter/material.dart';
import 'package:serviceflow/app/core/base/base.model.dart';
import 'package:serviceflow/app/core/http/app_client.dart';
import 'package:serviceflow/app/core/logging/log.service.dart';
import 'package:dio/dio.dart';

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

      data.remove('id');
      data.remove('created_at');
      data.remove('is_sync');

      print('📤 [$endpoint] Enviando: $data');

      final response = await _client.post(
        endpoint,
        data: data,
      );

      print('✅ ${response.statusCode} $endpoint');
      print('*** Response ***');
      print('uri: ${response.realUri}');
      print('Response Text:');
      print(response.data);

      print(
        '📥 [$endpoint] ${response.statusCode} ${response.data}',
      );

      return response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;
} catch (e, stack) {

  print('💥 syncToCloud erro: $e');

  if (e is DioException) {
    print('❌ STATUS: ${e.response?.statusCode}');
    print('❌ DATA: ${e.response?.data}');
  }

  print(stack);

  handleError('syncToCloud', e);

  return false;
}
  }



  Future<int?> syncToCloudAndReturnId(
  E entity,
) async {

  try {

    final data = toExternalFormat(entity);

    data.remove('id');
    data.remove('created_at');
    data.remove('is_sync');

    print('📤 [$endpoint] Enviando: $data');

    final response = await _client.post(
      endpoint,
      data: data,
    );

    print('📥 Response: ${response.data}');

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {

      if (response.data is List &&
          response.data.isNotEmpty) {

        return response.data[0]['id'];
      }
    }

    return null;

  } catch (e, stack) {

    print('💥 syncToCloudAndReturnId erro: $e');
    print(stack);

    return null;
  }
}

  Future<List<E>> fetchFromCloud({
    DateTime? lastSync,
  }) async {
    try {
      final queryParams = lastSync != null
          ? {
              'created_at':
                  'gte.${lastSync.toIso8601String()}',
            }
          : null;

      final response = await _client.get(
        endpoint,
        queryParameters: queryParams,
      );

      if (response.data is List) {
        return (response.data as List)
            .map(
              (item) => fromExternalFormat(
                item as Map<String, dynamic>,
              ),
            )
            .toList();
      }

      return [];
    } catch (e) {
      handleError('fetchFromCloud', e);
      return [];
    }
  }

  Future<bool> deleteFromCloud(int id) async {
    try {
      await _client.delete(
        endpoint,
        queryParameters: {
          'id': 'eq.$id',
        },
      );

      return true;
    } catch (e) {
      handleError('deleteFromCloud', e);
      return false;
    }
  }

  @protected
  void handleError(
    String operation,
    dynamic error,
  ) {
    _logger.handleProviderError(
      _className,
      operation,
      error,
    );
  }

  Future<bool> validateBeforeSync(
    E entity,
  ) async {
    return true;
  }

  Future<void> afterSync(
    E entity,
    bool success,
  ) async {}

  Future<E?> resolveConflict(
    E local,
    E remote,
  ) async {
    final localUpdated =
        local.createdAt ??
            DateTime.fromMillisecondsSinceEpoch(0);

    final remoteUpdated =
        remote.createdAt ??
            DateTime.fromMillisecondsSinceEpoch(0);

    return localUpdated.isAfter(remoteUpdated)
        ? local
        : remote;
  }
}