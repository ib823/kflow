import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/security/secure_screen_mixin.dart';
import '../../../../shared/theme/app_theme.dart';

/// S-040: Payslip PDF Viewer Screen
///
/// View payslip as PDF with:
/// - PDF rendering using flutter_pdfview
/// - FLAG_SECURE enabled (financial data protection)
/// - Page navigation for multi-page documents
/// - Download to device
/// - Share with sensitivity warning
/// - Loading skeleton
/// - Error handling with retry
class PayslipPdfScreen extends ConsumerStatefulWidget {
  final String payslipId;

  const PayslipPdfScreen({
    super.key,
    required this.payslipId,
  });

  @override
  ConsumerState<PayslipPdfScreen> createState() => _PayslipPdfScreenState();
}

class _PayslipPdfScreenState extends ConsumerState<PayslipPdfScreen>
    with SecureScreenMixin {
  bool _isLoading = true;
  String? _error;
  String? _localPath;
  int _currentPage = 0;
  int _totalPages = 0;
  String _payPeriod = '';
  PDFViewController? _pdfController;

  // Mock payslip periods
  final Map<String, String> _mockPayPeriods = {
    '1': 'December 2025',
    '2': 'November 2025',
    '3': 'October 2025',
    '4': 'September 2025',
    '5': 'August 2025',
  };

  @override
  void initState() {
    super.initState();
    enableSecureScreen(); // FLAG_SECURE - prevent screenshots of financial data
    _fetchPdf();
  }

  @override
  void dispose() {
    disableSecureScreen();
    super.dispose();
  }

  Future<void> _fetchPdf() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Simulate API call to GET /api/v1/payslip/{id}/pdf
      await Future.delayed(const Duration(seconds: 1));

      _payPeriod = _mockPayPeriods[widget.payslipId] ?? 'Payslip';

      // In a real app, this would:
      // 1. Call the API to get the PDF
      // 2. Save it to temporary storage
      // 3. Pass the local path to PDFView

      final tempDir = await getTemporaryDirectory();
      _localPath = '${tempDir.path}/payslip_${widget.payslipId}.pdf';

      // Simulate PDF download complete
      setState(() {
        _isLoading = false;
        _totalPages = 2; // Mock: payslips typically have 2 pages
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _downloadPdf() async {
    // In a real app, save to Downloads folder with encryption
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payslip saved to Downloads'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _sharePdf() async {
    // Show sensitivity warning first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 48),
        title: const Text('Share Payslip'),
        content: const Text(
          'This payslip contains sensitive financial and personal information including your salary, tax deductions, and statutory contributions.\n\n'
          'Only share with trusted parties who need this information.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text('Share Anyway'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // In a real app, share the actual PDF file
      await Share.share(
        'Payslip for $_payPeriod',
        subject: 'KerjaFlow Payslip - $_payPeriod',
      );
    }
  }

  void _goToPage(int page) {
    _pdfController?.setPage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_payPeriod.isNotEmpty ? _payPeriod : 'Payslip'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _isLoading ? null : _downloadPdf,
            tooltip: 'Download',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _isLoading ? null : _sharePdf,
            tooltip: 'Share',
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _isLoading || _error != null
          ? null
          : _buildPageNavigation(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingSkeleton();
    }

    if (_error != null) {
      return _buildError();
    }

    // Demo view since we don't have actual PDF files
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
            'Loading payslip...',
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
              'Failed to load payslip',
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
              onPressed: _fetchPdf,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoView() {
    // Demo view showing payslip structure
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // Security indicator
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.infoSurface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.security, size: 16, color: AppColors.info),
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
          const SizedBox(height: AppSpacing.lg),

          // Mock payslip document
          Container(
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
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.md),
                      topRight: Radius.circular(AppRadius.md),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long, color: Colors.white, size: 32),
                      const SizedBox(width: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KerjaFlow Payslip',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            _payPeriod,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white70,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Content placeholder
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      Icon(
                        Icons.picture_as_pdf,
                        size: 80,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'PDF Document',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Your payslip contains detailed earnings, deductions, '
                        'and statutory contributions.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Mock content sections
                      _buildMockSection('Employee Information'),
                      _buildMockSection('Earnings'),
                      _buildMockSection('Deductions'),
                      _buildMockSection('Statutory Contributions'),
                      _buildMockSection('Net Pay'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockSection(String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Widget _buildPageNavigation() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _currentPage > 0
                  ? () => _goToPage(_currentPage - 1)
                  : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                'Page ${_currentPage + 1} of $_totalPages',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            IconButton(
              onPressed: _currentPage < _totalPages - 1
                  ? () => _goToPage(_currentPage + 1)
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }

  /// Build actual PDF viewer (when real file exists)
  Widget _buildPdfViewer() {
    if (_localPath == null) return const SizedBox.shrink();

    return PDFView(
      filePath: _localPath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
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
        _pdfController = controller;
      },
      onPageChanged: (int? page, int? total) {
        if (page != null) {
          setState(() {
            _currentPage = page;
            if (total != null) _totalPages = total;
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
}
