import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';
import '../domain/models/document.dart';

part 'document_api.g.dart';

/// Document API client.
class DocumentApi {
  final Dio _dio;

  DocumentApi(this._dio);

  /// GET /api/v1/documents
  Future<List<EmployeeDocument>> getDocuments({String? type}) async {
    final response = await _dio.get('/api/v1/documents', queryParameters: {
      if (type != null) 'type': type,
    });
    return (response.data['data'] as List)
        .map((e) => EmployeeDocument.fromJson(e))
        .toList();
  }

  /// GET /api/v1/documents/{id}
  Future<Uint8List> downloadDocument(int id) async {
    final response = await _dio.get<List<int>>(
      '/api/v1/documents/$id',
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data!);
  }

  /// POST /api/v1/documents
  Future<EmployeeDocument> uploadDocument({
    required String documentType,
    required String fileName,
    required Uint8List fileBytes,
    DateTime? issueDate,
    DateTime? expiryDate,
  }) async {
    final formData = FormData.fromMap({
      'document_type': documentType,
      'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
      if (issueDate != null) 'issue_date': issueDate.toIso8601String().split('T')[0],
      if (expiryDate != null) 'expiry_date': expiryDate.toIso8601String().split('T')[0],
    });
    final response = await _dio.post('/api/v1/documents', data: formData);
    return EmployeeDocument.fromJson(response.data['data']);
  }

  /// DELETE /api/v1/documents/{id}
  Future<void> deleteDocument(int id) async {
    await _dio.delete('/api/v1/documents/$id');
  }
}

@riverpod
DocumentApi documentApi(DocumentApiRef ref) {
  final dio = ref.watch(dioClientProvider);
  return DocumentApi(dio);
}
