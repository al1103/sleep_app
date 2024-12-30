import 'dart:async';

import 'package:deep_pick/deep_pick.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleep/core/infrastructure/datasource/remote/api_exception.dart';
import 'package:sleep/core/infrastructure/datasource/remote/status_code.dart';
import 'package:sleep/env/env.dart';

part 'api_service.g.dart';

typedef InitGeneric<T> = T Function(Map<String, dynamic>);

@Riverpod(keepAlive: true)
ApiService apiService(ApiServiceRef ref) => ApiService();

class ApiService {
  ApiService() {
    _dio = Dio(baseOptions);

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseHeader: false,
          responseBody: true,
        ),
      );
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, handler) async {
          if (error.response == null || error.response!.data == null) {
            return handler.next(error);
          }
          // #region Error handler
          // if (error.response!.statusCode == ResponseCodes.unauthorized) {
          //   BotToast.closeAllLoading();
          //   unawaited(Get.offAllNamed(RouteNames.login));
          //   return;
          // }
          // #endregion
          return handler.next(error);
        },
      ),
    );
  }

  final baseOptions = BaseOptions(
    baseUrl: Env.instance.apiUrl,
    connectTimeout: const Duration(seconds: 5000),
    receiveTimeout: const Duration(seconds: 5000),
    headers: {
      'Accept': 'application/json',
    },
    contentType: 'application/json; charset=utf-8',
  );

  final defaultOptions = Options(
    contentType: 'application/json; charset=utf-8',
  );

  late Dio _dio;

  Future<TData> requestGet<TData>(
    String path,
    Map<String, dynamic>? queryParams, {
    Options? options,
    InitGeneric<TData>? responseFactory,
  }) async {
    return _request(
      'GET',
      path,
      responseFactory: responseFactory,
      queryParameters: queryParams,
      options: options,
    );
  }

  Future<TData> requestPost<TData>(
    String path,
    dynamic body, {
    Options? options,
    InitGeneric<TData>? responseFactory,
  }) async {
    return _request(
      'POST',
      path,
      responseFactory: responseFactory,
      data: body,
      options: options,
    );
  }

  Future<TData> requestPut<TData>(
    String path,
    dynamic body,
    InitGeneric<TData> responseFactory, {
    Options? options,
  }) async {
    return _request(
      'PUT',
      path,
      responseFactory: responseFactory,
      data: body,
      options: options,
    );
  }

  Future<TData> requestPatch<TData>(
    String path,
    dynamic body,
    InitGeneric<TData> responseFactory, {
    Options? options,
  }) async {
    return _request(
      'PATCH',
      path,
      responseFactory: responseFactory,
      data: body,
      options: options,
    );
  }

  Future<TData> requestDelete<TData>(
    String path,
    dynamic body, {
    Options? options,
    InitGeneric<TData>? responseFactory,
  }) async {
    return _request(
      'DELETE',
      path,
      responseFactory: responseFactory,
      data: body,
      options: options,
    );
  }

  Future<TData> _request<TData>(
    String method,
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    InitGeneric<TData>? responseFactory,
  }) async {
    try {
      final ops = options ?? defaultOptions;
      final response = await _dio.request<dynamic>(
        path,
        data: data,
        options: ops.copyWith(
          headers: await _header(),
          method: method,
        ),
        queryParameters: queryParameters,
      );

      if (responseFactory == null) return Future.value();

      final responseData = pick(response.data).asMapOrNull<String, dynamic>();
      if (responseData == null) {
        throw Exception();
      }

      return responseFactory(responseData);
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.data != null) {
          throw ApiException.fromJson(pick(e.response!.data).asMapOrThrow());
        } else {
          throw ApiException(StatusCode.systemError, e.toString());
        }
      } else {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.receiveTimeout:
          case DioExceptionType.sendTimeout:
            throw ApiException(StatusCode.timeout, e.toString());
          case DioExceptionType.badCertificate:
          case DioExceptionType.badResponse:
          case DioExceptionType.cancel:
          case DioExceptionType.connectionError:
          case DioExceptionType.unknown:
            throw ApiException(StatusCode.systemError, e.toString());
        }
      }
    } catch (e) {
      throw ApiException(StatusCode.systemError, e.toString());
    }
  }

  Future<Map<String, dynamic>> _header() async {
    final headers = baseOptions.headers;
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    if (authToken != null) {
      headers['authorization'] = 'Bearer $authToken';
    }
    return headers;
  }
}
