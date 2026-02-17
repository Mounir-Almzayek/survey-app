import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/request_queue_item.dart';
import '../services/request_queue_manager.dart';
import '../services/request_queue_service.dart';
import '../../widgets/unified_snackbar.dart';
import '../../routes/app_pages.dart';
import 'queue_session/queue_session_bloc.dart';
import 'queue_summary_dialog.dart';

class QueueStatusListener extends StatefulWidget {
  final Widget child;

  const QueueStatusListener({super.key, required this.child});

  @override
  State<QueueStatusListener> createState() => _QueueStatusListenerState();
}

class _QueueStatusListenerState extends State<QueueStatusListener> {
  StreamSubscription<QueueResponse>? _responseSubscription;
  StreamSubscription<QueueStatus>? _statusSubscription;

  bool _wasOnline = true;
  bool _hadQueuedOnReconnect = false;
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _listenToQueueResponses();
    _listenToQueueStatus();
    _checkInitialQueueStatus();
  }

  Future<void> _checkInitialQueueStatus() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final all = await RequestQueueService.getAllRequests();
    final connectivity = Connectivity();
    final result = await connectivity.checkConnectivity();
    final isOnline = !result.contains(ConnectivityResult.none);

    if (isOnline && all.isNotEmpty && !_isDialogOpen) {
      _hadQueuedOnReconnect = true;
      _wasOnline = true;

      final initialMap = {for (final item in all) item.id: item};
      _showQueueSummaryDialog(initialItems: initialMap);
    }
  }

  void _listenToQueueResponses() {
    _responseSubscription = RequestQueueManager().responseStream.listen((
      response,
    ) {
      if (!mounted) return;

      if (response.success) {
        String message = 'Request completed';
        final raw = response.response;

        if (raw is Response) {
          final data = raw.data;
          if (data is Map<String, dynamic>) {
            final msg = data['message'];
            if (msg is String && msg.isNotEmpty) {
              message = msg;
            }
          }
        }

        UnifiedSnackbar.success(context, message: message);
      } else {
        final errorMessage = response.error ?? 'Request failed';
        UnifiedSnackbar.error(context, message: errorMessage);
      }
    });
  }

  void _listenToQueueStatus() {
    _statusSubscription = RequestQueueManager().queueStatusStream.listen((
      status,
    ) async {
      if (!mounted) return;

      if (!_wasOnline && status.isOnline) {
        final all = await RequestQueueService.getAllRequests();
        _hadQueuedOnReconnect = all.isNotEmpty;

        if (_hadQueuedOnReconnect && !_isDialogOpen) {
          final initialMap = {for (final item in all) item.id: item};
          _showQueueSummaryDialog(initialItems: initialMap);
        }
      }

      if (_hadQueuedOnReconnect && status.isOnline && status.queueLength == 0) {
        _hadQueuedOnReconnect = false;
      }

      _wasOnline = status.isOnline;
    });
  }

  void _showQueueSummaryDialog({
    required Map<String, RequestQueueItem> initialItems,
  }) {
    final navigatorContext = Pages.navigatorKey.currentContext;
    if (navigatorContext == null) return;

    _isDialogOpen = true;

    showDialog<void>(
      context: navigatorContext,
      builder: (ctx) {
        return BlocProvider(
          create: (_) => QueueSessionBloc(initialItems: initialItems),
          child: const QueueSummaryDialog(),
        );
      },
    ).then((_) => _isDialogOpen = false);
  }

  @override
  void dispose() {
    _responseSubscription?.cancel();
    _statusSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
