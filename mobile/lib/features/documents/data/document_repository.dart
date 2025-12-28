import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/models/document.dart';
import 'document_api.dart';

part 'document_repository.g.dart';

/// Repository for document management.
class DocumentRepository {
  final DocumentApi _api;

  DocumentRepository(this._api);

  Future<List<EmployeeDocument>> getDocuments({String? type}) =>
      _api.getDocuments(type: type);

  Future<Uint8List> downloadDocument(int id) => _api.downloadDocument(id);

  Future<EmployeeDocument> uploadDocument({
    required String documentType,
    required String fileName,
    required Uint8List fileBytes,
    DateTime? issueDate,
    DateTime? expiryDate,
  }) =>
      _api.uploadDocument(
        documentType: documentType,
        fileName: fileName,
        fileBytes: fileBytes,
        issueDate: issueDate,
        expiryDate: expiryDate,
      );

  Future<void> deleteDocument(int id) => _api.deleteDocument(id);

  /// Get documents expiring within N days.
  Future<List<EmployeeDocument>> getExpiringDocuments({int withinDays = 30}) async {
    final docs = await getDocuments();
    return docs.where((d) {
      if (d.daysUntilExpiry == null) return false;
      return d.daysUntilExpiry! <= withinDays && !d.isExpired;
    }).toList();
  }
}

@riverpod
DocumentRepository documentRepository(DocumentRepositoryRef ref) {
  return DocumentRepository(ref.watch(documentApiProvider));
}
