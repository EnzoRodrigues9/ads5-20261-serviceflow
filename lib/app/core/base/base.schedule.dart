import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'base.model.dart';
import 'base.provider.dart';
import 'base.repository.dart';

abstract class BaseSchedule<
    E extends BaseModel,
    R extends BaseRepository<E>,
    P extends BaseProvider<E>> {
  final R repository;
  final P provider;

  Timer? _syncTimer;

  StreamSubscription<List<ConnectivityResult>>?
      _connectivitySubscription;

  bool _isOnline = false;
  bool _isSyncing = false;

  static const _storage =
      FlutterSecureStorage();

  BaseSchedule(
    this.repository,
    this.provider,
  ) {
    _initConnectivityListener();
  }

  Duration get syncInterval =>
      const Duration(minutes: 5);

  String get featureName;

  Future<void> start() async {
    await _loadSyncState();

    _syncTimer = Timer.periodic(
      syncInterval,
      (_) => syncNow(),
    );

    if (_isOnline) {
      await syncNow();
    }

    _logInfo(
      'Schedule iniciado para $featureName',
    );
  }

  void stop() {
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();

    _logInfo(
      'Schedule parado para $featureName',
    );
  }

  Future<bool> syncNow() async {
    if (_isSyncing || !_isOnline) {
      return false;
    }

    _isSyncing = true;

    _logInfo(
      'Iniciando sincronização de $featureName',
    );

    try {
      final uploadSuccess =
          await _uploadPendingChanges();

      final downloadSuccess =
          await _downloadUpdates();

      if (uploadSuccess &&
          downloadSuccess) {
        await _updateLastSyncTimestamp();
      }

      final success =
          uploadSuccess && downloadSuccess;

      _logInfo(
        'Sincronização de $featureName ${success ? 'concluída' : 'falhou'}',
      );

      return success;
    } catch (e) {
      _logError(
        'Erro na sincronização de $featureName',
        e,
      );

      return false;
    } finally {
      _isSyncing = false;
    }
  }

  Future<bool> _uploadPendingChanges() async {
    try {
      final pendingEntities =
          await repository.findAllPendingSync();

      print(
        '📦 [$featureName] Pendentes: ${pendingEntities.length}',
      );

      if (pendingEntities.isEmpty) {
        return true;
      }

      int successCount = 0;

      for (final entity in pendingEntities) {
        print('----------------------------');
        print(
          '📤 Enviando entidade: ${entity.toMap()}',
        );

        final valid =
            await provider.validateBeforeSync(
          entity,
        );

        print('✔️ Validação: $valid');

        if (!valid) {
          continue;
        }

        final success =
            await provider.syncToCloud(
          entity,
        );

        print('☁️ Resultado sync: $success');

        if (success) {
          entity.isSync = 1;

          await repository.update(entity);

          successCount++;

          print('✅ Atualizado localmente');
        } else {
          print('❌ Falha no sync');
        }
      }

      print(
        '📊 Upload finalizado: $successCount/${pendingEntities.length}',
      );

      return successCount ==
          pendingEntities.length;
    } catch (e, stack) {
      print('💥 Erro upload: $e');
      print(stack);

      _logError('Erro no upload', e);

      return false;
    }
  }

  Future<bool> _downloadUpdates() async {
    try {
      final remoteEntities =
          await provider.fetchFromCloud();

      print(
        '📥 [$featureName] Remotos: ${remoteEntities.length}',
      );

      if (remoteEntities.isEmpty) {
        return true;
      }

      int successCount = 0;

      for (final remoteEntity
          in remoteEntities) {
        final localEntity =
            await repository.findById(
          remoteEntity.id!,
        );

        if (localEntity == null) {
          remoteEntity.isSync = 1;

          await repository.insert(
            remoteEntity,
          );

          successCount++;

          print(
            '➕ Inserido local ID ${remoteEntity.id}',
          );
        } else {
          remoteEntity.isSync = 1;

          await repository.update(
            remoteEntity,
          );

          successCount++;

          print(
            '♻️ Atualizado local ID ${remoteEntity.id}',
          );
        }
      }

      print(
        '📊 Download finalizado: $successCount',
      );

      return true;
    } catch (e, stack) {
      print('💥 Erro download: $e');
      print(stack);

      _logError('Erro no download', e);

      return false;
    }
  }

  void _initConnectivityListener() {
    _connectivitySubscription =
        Connectivity()
            .onConnectivityChanged
            .listen(
      (
        List<ConnectivityResult> results,
      ) {
        final result = results.isNotEmpty
            ? results.first
            : ConnectivityResult.none;

        final wasOnline = _isOnline;

        _isOnline =
            result != ConnectivityResult.none;

        print(
          '🌐 [$featureName] Online: $_isOnline',
        );

        if (!wasOnline && _isOnline) {
          syncNow();
        }
      },
    );

    Connectivity()
        .checkConnectivity()
        .then((result) {
      _isOnline =
          result != ConnectivityResult.none;

      print(
        '🌐 [$featureName] Estado inicial online: $_isOnline',
      );
    });
  }

  Future<void> _updateLastSyncTimestamp() async {
    final timestamp =
        DateTime.now().toIso8601String();

    await _storage.write(
      key: '${featureName}_last_sync',
      value: timestamp,
    );
  }

  Future<DateTime?> _getLastSyncTimestamp() async {
    final timestampStr =
        await _storage.read(
      key: '${featureName}_last_sync',
    );

    return timestampStr != null
        ? DateTime.parse(timestampStr)
        : null;
  }

  Future<void> _loadSyncState() async {}

  void _logInfo(String message) {
    print(
      '[${DateTime.now()}] [${featureName.toUpperCase()}_SCHEDULE] INFO: $message',
    );
  }

  void _logError(
    String message,
    dynamic error,
  ) {
    print(
      '[${DateTime.now()}] [${featureName.toUpperCase()}_SCHEDULE] ERROR: $message - $error',
    );
  }

  void dispose() {
    stop();
  }
}