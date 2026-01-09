import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/theme/app_theme.dart';

/// S-060: Document List Screen
///
/// Displays employee documents with:
/// - Grid/list view toggle
/// - Filter by type (work permit, contract, certificate)
/// - Pull-to-refresh
/// - Upload FAB
class DocumentListScreen extends ConsumerStatefulWidget {
  const DocumentListScreen({super.key});

  @override
  ConsumerState<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends ConsumerState<DocumentListScreen> {
  bool _isGridView = true;
  String _selectedFilter = 'all';

  // Mock data
  final List<Map<String, dynamic>> _documents = [
    {
      'id': 1,
      'name': 'Work Permit 2025',
      'type': 'work_permit',
      'file_type': 'pdf',
      'size': '2.4 MB',
      'uploaded_at': '2025-01-15',
      'expires_at': '2026-01-15',
      'status': 'valid',
    },
    {
      'id': 2,
      'name': 'Employment Contract',
      'type': 'contract',
      'file_type': 'pdf',
      'size': '1.8 MB',
      'uploaded_at': '2024-06-01',
      'expires_at': null,
      'status': 'valid',
    },
    {
      'id': 3,
      'name': 'Safety Training Certificate',
      'type': 'certificate',
      'file_type': 'pdf',
      'size': '0.5 MB',
      'uploaded_at': '2025-03-10',
      'expires_at': '2026-03-10',
      'status': 'valid',
    },
    {
      'id': 4,
      'name': 'Medical Checkup Report',
      'type': 'medical',
      'file_type': 'pdf',
      'size': '3.1 MB',
      'uploaded_at': '2025-02-20',
      'expires_at': '2026-02-20',
      'status': 'expiring_soon',
    },
    {
      'id': 5,
      'name': 'Passport Copy',
      'type': 'identity',
      'file_type': 'image',
      'size': '1.2 MB',
      'uploaded_at': '2024-01-10',
      'expires_at': '2030-01-10',
      'status': 'valid',
    },
  ];

  final List<Map<String, dynamic>> _filters = [
    {'value': 'all', 'label': 'All', 'icon': Icons.folder_outlined},
    {'value': 'work_permit', 'label': 'Work Permit', 'icon': Icons.badge_outlined},
    {'value': 'contract', 'label': 'Contract', 'icon': Icons.description_outlined},
    {'value': 'certificate', 'label': 'Certificate', 'icon': Icons.card_membership_outlined},
    {'value': 'medical', 'label': 'Medical', 'icon': Icons.medical_services_outlined},
    {'value': 'identity', 'label': 'Identity', 'icon': Icons.credit_card_outlined},
  ];

  List<Map<String, dynamic>> get _filteredDocuments {
    if (_selectedFilter == 'all') return _documents;
    return _documents.where((doc) => doc['type'] == _selectedFilter).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'valid':
        return AppColors.success;
      case 'expiring_soon':
        return AppColors.warning;
      case 'expired':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'work_permit':
        return Icons.badge_outlined;
      case 'contract':
        return Icons.description_outlined;
      case 'certificate':
        return Icons.card_membership_outlined;
      case 'medical':
        return Icons.medical_services_outlined;
      case 'identity':
        return Icons.credit_card_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter['value'];
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(filter['label'] as String),
                    avatar: Icon(
                      filter['icon'] as IconData,
                      size: 18,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                    onSelected: (selected) {
                      setState(() => _selectedFilter = filter['value'] as String);
                    },
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Document list/grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
              },
              child: _filteredDocuments.isEmpty
                  ? _buildEmptyState()
                  : _isGridView
                      ? _buildGridView()
                      : _buildListView(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/documents/upload'),
        icon: const Icon(Icons.upload_file),
        label: const Text('Upload'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No documents found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: () => context.push('/documents/upload'),
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Document'),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.85,
      ),
      itemCount: _filteredDocuments.length,
      itemBuilder: (context, index) {
        final doc = _filteredDocuments[index];
        return _buildGridItem(doc);
      },
    );
  }

  Widget _buildGridItem(Map<String, dynamic> doc) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/documents/${doc['id']}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              width: double.infinity,
              color: AppColors.primarySurface,
              child: Icon(
                _getTypeIcon(doc['type'] as String),
                size: 40,
                color: AppColors.primary,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc['name'] as String,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getStatusColor(doc['status'] as String),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        doc['size'] as String,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: _filteredDocuments.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final doc = _filteredDocuments[index];
        return _buildListItem(doc);
      },
    );
  }

  Widget _buildListItem(Map<String, dynamic> doc) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            _getTypeIcon(doc['type'] as String),
            color: AppColors.primary,
          ),
        ),
        title: Text(
          doc['name'] as String,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _getStatusColor(doc['status'] as String),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text('${doc['size']} • ${doc['uploaded_at']}'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/documents/${doc['id']}'),
      ),
    );
  }
}
