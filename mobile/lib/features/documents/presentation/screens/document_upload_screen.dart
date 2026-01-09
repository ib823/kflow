import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../shared/theme/app_theme.dart';

/// S-061: Document Upload Screen
///
/// Upload documents with:
/// - Camera capture
/// - Gallery picker
/// - File picker (PDF)
/// - Document type selection
/// - Optional expiry date
class DocumentUploadScreen extends ConsumerStatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  ConsumerState<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends ConsumerState<DocumentUploadScreen> {
  String? _selectedType;
  String? _selectedFileName;
  String? _selectedFilePath;
  bool _isUploading = false;
  DateTime? _expiryDate;
  final _nameController = TextEditingController();

  final List<Map<String, dynamic>> _documentTypes = [
    {'value': 'work_permit', 'label': 'Work Permit', 'icon': Icons.badge_outlined},
    {'value': 'contract', 'label': 'Employment Contract', 'icon': Icons.description_outlined},
    {'value': 'certificate', 'label': 'Certificate', 'icon': Icons.card_membership_outlined},
    {'value': 'medical', 'label': 'Medical Report', 'icon': Icons.medical_services_outlined},
    {'value': 'identity', 'label': 'Identity Document', 'icon': Icons.credit_card_outlined},
    {'value': 'other', 'label': 'Other', 'icon': Icons.folder_outlined},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickFromCamera() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _selectedFileName = image.name;
        _selectedFilePath = image.path;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _selectedFileName = image.name;
        _selectedFilePath = image.path;
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFileName = result.files.first.name;
        _selectedFilePath = result.files.first.path;
      });
    }
  }

  Future<void> _selectExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (date != null) {
      setState(() => _expiryDate = date);
    }
  }

  Future<void> _upload() async {
    if (_selectedFilePath == null || _selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file and document type')),
      );
      return;
    }

    setState(() => _isUploading = true);

    // Simulate upload
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isUploading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document uploaded successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Document'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File selection area
            _buildFileSelector(),

            const SizedBox(height: AppSpacing.xl),

            // Document type dropdown
            Text(
              'Document Type',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                hintText: 'Select document type',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: _documentTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type['value'] as String,
                  child: Row(
                    children: [
                      Icon(type['icon'] as IconData, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Text(type['label'] as String),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedType = value),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Document name
            Text(
              'Document Name (Optional)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Enter custom name',
                prefixIcon: Icon(Icons.edit_outlined),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Expiry date
            Text(
              'Expiry Date (Optional)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: _selectExpiryDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  hintText: 'Select expiry date',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  suffixIcon: Icon(Icons.chevron_right),
                ),
                child: Text(
                  _expiryDate != null
                      ? '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}'
                      : 'No expiry date',
                  style: TextStyle(
                    color: _expiryDate != null
                        ? AppColors.textPrimary
                        : AppColors.textHint,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Upload button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _upload,
                child: _isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Upload Document'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileSelector() {
    if (_selectedFileName != null) {
      return Card(
        color: AppColors.successSurface,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedFileName!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Ready to upload',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _selectedFileName = null;
                    _selectedFilePath = null;
                  });
                },
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.divider,
          width: 2,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Select a file to upload',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'PDF, JPG, PNG up to 10MB',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildOptionButton(
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                onTap: _pickFromCamera,
              ),
              const SizedBox(width: AppSpacing.lg),
              _buildOptionButton(
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                onTap: _pickFromGallery,
              ),
              const SizedBox(width: AppSpacing.lg),
              _buildOptionButton(
                icon: Icons.folder_outlined,
                label: 'Files',
                onTap: _pickFile,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
