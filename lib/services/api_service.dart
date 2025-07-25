import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../state/app_state_controller.dart';

class ApiService {
  static ApiService get to => Get.find<ApiService>();
  final appState = AppStateController.to;

  late final Dio _dio;

  static final ApiService _instance = ApiService._internal();
  final Map<String, CancelToken> _activeRequests = {};

  factory ApiService() => _instance;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
  }

  void _cancelPreviousRequest(String endpoint) {
    final cancelToken = _activeRequests[endpoint];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel('New request to same endpoint');
    }
    _activeRequests.remove(endpoint);
  }

  Future<T> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    bool cancelPrevious = false,
  }) async {
    if (cancelPrevious) {
      _cancelPreviousRequest(endpoint);
    }

    final cancelToken = CancelToken();
    _activeRequests[endpoint] = cancelToken;

    appState.isLoading = true;
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );

      if (fromJson != null) {
        return fromJson(response.data);
      }
      return response.data as T;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } finally {
      _activeRequests.remove(endpoint);
      appState.isLoading = false;
    }
  }

  Future<T> post<T>(
    String endpoint, {
    dynamic data,
    T Function(dynamic)? fromJson,
    bool cancelPrevious = false,
  }) async {
    if (cancelPrevious) {
      _cancelPreviousRequest(endpoint);
    }

    final cancelToken = CancelToken();
    _activeRequests[endpoint] = cancelToken;

    appState.isLoading = true;
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        cancelToken: cancelToken,
      );

      if (fromJson != null) {
        return fromJson(response.data);
      }
      return response.data as T;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } finally {
      _activeRequests.remove(endpoint);
      appState.isLoading = false;
    }
  }

  Future<T> put<T>(
    String endpoint, {
    dynamic data,
    T Function(dynamic)? fromJson,
    bool cancelPrevious = false,
  }) async {
    if (cancelPrevious) {
      _cancelPreviousRequest(endpoint);
    }

    final cancelToken = CancelToken();
    _activeRequests[endpoint] = cancelToken;

    appState.isLoading = true;
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        cancelToken: cancelToken,
      );

      if (fromJson != null) {
        return fromJson(response.data);
      }
      return response.data as T;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw Exception('Request was cancelled');
      }
      throw _handleDioError(e);
    } finally {
      _activeRequests.remove(endpoint);
      appState.isLoading = false;
    }
  }

  Future<T> delete<T>(
    String endpoint, {
    T Function(dynamic)? fromJson,
    bool cancelPrevious = false,
  }) async {
    if (cancelPrevious) {
      _cancelPreviousRequest(endpoint);
    }

    final cancelToken = CancelToken();
    _activeRequests[endpoint] = cancelToken;

    appState.isLoading = true;
    try {
      final response = await _dio.delete(
        endpoint,
        cancelToken: cancelToken,
      );

      if (fromJson != null) {
        return fromJson(response.data);
      }
      return response.data as T;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw Exception('Request was cancelled');
      }
      throw _handleDioError(e);
    } finally {
      _activeRequests.remove(endpoint);
      appState.isLoading = false;
    }
  }

  void cancelAllRequests() {
    for (final cancelToken in _activeRequests.values) {
      if (!cancelToken.isCancelled) {
        cancelToken.cancel('Cancelled all requests');
      }
    }
    _activeRequests.clear();
  }

  void cancelRequestToEndpoint(String endpoint) {
    final cancelToken = _activeRequests[endpoint];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel('Cancelled request to $endpoint');
    }
    _activeRequests.remove(endpoint);
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['error'] ?? 'Unknown error';
        return Exception(message);
      case DioExceptionType.cancel:
        return Exception('Request was cancelled');
      case DioExceptionType.unknown:
        return Exception('Network error: ${error.message}');
      default:
        return Exception('Unknown error occurred');
    }
  }
}
