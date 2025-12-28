import 'package:freezed_annotation/freezed_annotation.dart';

part 'document.freezed.dart';
part 'document.g.dart';

/// Employee document from GET /api/v1/documents
@freezed
class EmployeeDocument with _$EmployeeDocument {
  const factory EmployeeDocument({
    required int id,
    required String documentType,
    required String documentName,
    required String fileName,
    required int fileSize,
    required String mimeType,
    DateTime? issueDate,
    DateTime? expiryDate,
    required bool isExpired,
    int? daysUntilExpiry,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _EmployeeDocument;

  factory EmployeeDocument.fromJson(Map<String, dynamic> json) =>
      _$EmployeeDocumentFromJson(json);
}

/// Document types
enum DocumentType {
  contract,
  certificate,
  permit,
  ic,
  passport,
  visa,
  qualification,
  medical,
  other,
}

extension DocumentTypeX on DocumentType {
  String get value {
    switch (this) {
      case DocumentType.contract:
        return 'contract';
      case DocumentType.certificate:
        return 'certificate';
      case DocumentType.permit:
        return 'permit';
      case DocumentType.ic:
        return 'ic';
      case DocumentType.passport:
        return 'passport';
      case DocumentType.visa:
        return 'visa';
      case DocumentType.qualification:
        return 'qualification';
      case DocumentType.medical:
        return 'medical';
      case DocumentType.other:
        return 'other';
    }
  }

  String get displayName {
    switch (this) {
      case DocumentType.contract:
        return 'Employment Contract';
      case DocumentType.certificate:
        return 'Certificate';
      case DocumentType.permit:
        return 'Work Permit';
      case DocumentType.ic:
        return 'Identity Card';
      case DocumentType.passport:
        return 'Passport';
      case DocumentType.visa:
        return 'Visa';
      case DocumentType.qualification:
        return 'Qualification';
      case DocumentType.medical:
        return 'Medical Report';
      case DocumentType.other:
        return 'Other';
    }
  }

  static DocumentType fromString(String value) {
    switch (value) {
      case 'contract':
        return DocumentType.contract;
      case 'certificate':
        return DocumentType.certificate;
      case 'permit':
        return DocumentType.permit;
      case 'ic':
        return DocumentType.ic;
      case 'passport':
        return DocumentType.passport;
      case 'visa':
        return DocumentType.visa;
      case 'qualification':
        return DocumentType.qualification;
      case 'medical':
        return DocumentType.medical;
      default:
        return DocumentType.other;
    }
  }
}

/// Document upload request
@freezed
class DocumentUploadRequest with _$DocumentUploadRequest {
  const factory DocumentUploadRequest({
    required String documentType,
    required String fileName,
    required List<int> fileBytes,
    DateTime? issueDate,
    DateTime? expiryDate,
  }) = _DocumentUploadRequest;

  factory DocumentUploadRequest.fromJson(Map<String, dynamic> json) =>
      _$DocumentUploadRequestFromJson(json);
}
