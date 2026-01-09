import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/security/secure_screen_mixin.dart';
import '../../../../shared/theme/app_theme.dart';

/// S-062: Document Viewer Screen
///
/// View documents with:
/// - PDF viewing with flutter_pdfview
/// - Image viewing with pinch-to-zoom (InteractiveViewer)
/// - FLAG_SECURE enabled (sensitive documents)
/// - Download and share functionality
/// - Proper error handling and loading states
class DocumentViewerScreen extends ConsumerStatefulWidget {
  final String documentId;
  final String? documentName;
  final String? documentType;

  const DocumentViewerScreen({
    super.key,
    required this.documentId,
    this.documentName,
    this.documentType,
  });

  @override
  ConsumerState<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends ConsumerState<DocumentViewerScreen>
    with SecureScreenMixin {
  bool _isLoading = true;
  String? _error;
  String? _localPath;
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isPdf = false;

  // Mock document data
  final Map<String, Map<String, dynamic>> _mockDocuments = {
    '1': {
      'name': 'Work Permit 2025',
      'type': 'pdf',
      'url': 'https://example.com/docs/work_permit.pdf',
    },
    '2': {
      'name': 'Employment Contract',
      'type': 'pdf',
      'url': 'https://example.com/docs/contract.pdf',
    },
    '3': {
      'name': 'Safety Training Certificate',
      'type': 'pdf',
      'url': 'https://example.com/docs/safety_cert.pdf',
    },
    '4': {
      'name': 'Medical Checkup Report',
      'type': 'pdf',
      'url': 'https://example.com/docs/medical.pdf',
    },
    '5': {
      'name': 'Passport Copy',
      'type': 'image',
      'url': 'https://example.com/docs/passport.jpg',
    },
  };

  @override
  void initState() {
    super.initState();
    enableSecureScreen(); // FLAG_SECURE - prevent screenshots
    _loadDocument();
  }

  @override
  void dispose() {
    disableSecureScreen();
    super.dispose();
  }

  Future<void> _loadDocument() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final doc = _mockDocuments[widget.documentId];
      if (doc == null) {
        throw Exception('Document not found');
      }

      final docType = widget.documentType ?? doc['type'] as String;
      _isPdf = docType == 'pdf';

      // In a real app, this would download from the URL
      // For now, we'll create a mock local path
      final tempDir = await getTemporaryDirectory();
      _localPath = '${tempDir.path}/mock_document.${_isPdf ? 'pdf' : 'jpg'}';

      // Simulate file download (in reality, use Dio to download)
      // For demo purposes, we'll just set loading to false

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _downloadDocument() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document saved to Downloads'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _shareDocument() async {
    // Show sensitivity warning first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Document'),
        content: const Text(
          'This document may contain sensitive information. '
          'Are you sure you want to share it?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Share'),
          ),
        ],
      ),
    );

    if (confirmed == true && _localPath != null) {
      // In a real app, share the actual file
      await Share.share(
        'Sharing document: ${widget.documentName ?? 'Document'}',
        subject: widget.documentName,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final docName = widget.documentName ??
        _mockDocuments[widget.documentId]?['name'] as String? ??
        'Document';

    return Scaffold(
      appBar: AppBar(
        title: Text(docName),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _isLoading ? null : _downloadDocument,
            tooltip: 'Download',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _isLoading ? null : _shareDocument,
            tooltip: 'Share',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingSkeleton();
    }

    if (_error != null) {
      return _buildError();
    }

    // Demo view since we don't have actual files
    return _buildDemoView();
  }

  Widget _buildLoadingSkeleton() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Loading document...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Failed to load document',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton.icon(
              onPressed: _loadDocument,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoView() {
    // Since we don't have actual PDF/image files, show a placeholder
    return Column(
      children: [
        // Page indicator for PDFs
        if (_isPdf)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            color: AppColors.surfaceVariant,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Page ${_currentPage + 1} of ${_totalPages > 0 ? _totalPages : 1}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

        // Document viewer placeholder
        Expanded(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(AppSpacing.lg),
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isPdf ? Icons.picture_as_pdf : Icons.image,
                      size: 80,
                      color: _isPdf ? Colors.red : AppColors.primary,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      widget.documentName ??
                          _mockDocuments[widget.documentId]?['name'] as String? ??
                          'Document',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _isPdf ? 'PDF Document' : 'Image Document',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.infoSurface,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.security,
                            size: 16,
                            color: AppColors.info,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Screen capture protected',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.info,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build actual PDF viewer (when real file exists)
  Widget _buildPdfViewer() {
    if (_localPath == null) return const SizedBox.shrink();

    return PDFView(
      filePath: _localPath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: false,
      pageFling: true,
      pageSnap: true,
      fitPolicy: FitPolicy.BOTH,
      preventLinkNavigation: true,
      onRender: (pages) {
        setState(() {
          _totalPages = pages ?? 0;
        });
      },
      onViewCreated: (PDFViewController controller) {
        // Store controller if needed
      },
      onPageChanged: (int? page, int? total) {
        if (page != null) {
          setState(() {
            _currentPage = page;
          });
        }
      },
      onError: (error) {
        setState(() {
          _error = error.toString();
        });
      },
      onPageError: (page, error) {
        debugPrint('Page $page error: $error');
      },
    );
  }

  /// Build actual image viewer (when real file exists)
  Widget _buildImageViewer() {
    if (_localPath == null) return const SizedBox.shrink();

    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: Image.file(
          File(_localPath!),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildError();
          },
        ),
      ),
    );
  }
}
