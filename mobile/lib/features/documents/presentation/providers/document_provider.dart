import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/document_repository.dart';
import '../../domain/models/document.dart';

part 'document_provider.g.dart';

@riverpod
class DocumentsNotifier extends _$DocumentsNotifier {
  String? _typeFilter;

  @override
  Future<List<EmployeeDocument>> build() async {
    return ref.watch(documentRepositoryProvider).getDocuments(type: _typeFilter);
  }

  void setTypeFilter(String? type) {
    _typeFilter = type;
    ref.invalidateSelf();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(documentRepositoryProvider).getDocuments(type: _typeFilter),
    );
  }

  Future<bool> uploadDocument({
    required String documentType,
    required String fileName,
    required Uint8List fileBytes,
    DateTime? issueDate,
    DateTime? expiryDate,
  }) async {
    try {
      await ref.read(documentRepositoryProvider).uploadDocument(
        documentType: documentType,
        fileName: fileName,
        fileBytes: fileBytes,
        issueDate: issueDate,
        expiryDate: expiryDate,
      );
      await refresh();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteDocument(int id) async {
    try {
      await ref.read(documentRepositoryProvider).deleteDocument(id);
      await refresh();
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Provider for downloading document bytes.
@riverpod
Future<Uint8List> documentDownload(DocumentDownloadRef ref, int id) async {
  return ref.watch(documentRepositoryProvider).downloadDocument(id);
}

/// Provider for expiring documents (for dashboard warnings).
@riverpod
Future<List<EmployeeDocument>> expiringDocuments(
  ExpiringDocumentsRef ref, {
  int withinDays = 30,
}) async {
  return ref.watch(documentRepositoryProvider).getExpiringDocuments(withinDays: withinDays);
}
