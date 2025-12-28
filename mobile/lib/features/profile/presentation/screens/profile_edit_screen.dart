import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/models/profile.dart';
import '../providers/profile_provider.dart';

/// S-071: Profile Edit Screen
///
/// Allows editing of limited profile fields:
/// - Phone number
/// - Emergency contact
/// - Personal email
/// - Address
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _personalEmailController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  void _loadProfile() {
    final profileAsync = ref.read(profileNotifierProvider);
    profileAsync.whenData((profile) {
      _phoneController.text = profile.phone ?? '';
      _emergencyNameController.text = profile.emergencyContactName ?? '';
      _emergencyPhoneController.text = profile.emergencyContactPhone ?? '';
      _personalEmailController.text = profile.personalEmail ?? '';
      _addressController.text = profile.address ?? '';
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _personalEmailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(profileNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _isLoading ? null : _onSave,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) => _buildForm(theme, profile),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildForm(ThemeData theme, Profile profile) {
    return Form(
      key: _formKey,
      onChanged: () {
        if (!_hasChanges) {
          setState(() {
            _hasChanges = true;
          });
        }
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Read-only info section
          _buildSectionHeader(theme, 'Personal Information'),
          _buildReadOnlyField(theme, 'Full Name', profile.fullName),
          _buildReadOnlyField(theme, 'Employee ID', profile.employeeNumber),
          _buildReadOnlyField(theme, 'Email', profile.email),
          _buildReadOnlyField(theme, 'Job Title', profile.jobTitle),
          _buildReadOnlyField(theme, 'Department', profile.department),

          const SizedBox(height: 24),

          // Editable fields section
          _buildSectionHeader(theme, 'Contact Information'),

          const SizedBox(height: 16),

          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: const Icon(Icons.phone_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _personalEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Personal Email',
              prefixIcon: const Icon(Icons.alternate_email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (!value.contains('@') || !value.contains('.')) {
                  return 'Please enter a valid email';
                }
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _addressController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Address',
              prefixIcon: const Icon(Icons.home_outlined),
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Emergency contact section
          _buildSectionHeader(theme, 'Emergency Contact'),

          const SizedBox(height: 16),

          TextFormField(
            controller: _emergencyNameController,
            decoration: InputDecoration(
              labelText: 'Contact Name',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _emergencyPhoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Contact Phone',
              prefixIcon: const Icon(Icons.phone_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Save button
          FilledButton(
            onPressed: _hasChanges && !_isLoading ? _onSave : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Save Changes'),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final request = ProfileUpdateRequest(
      phone: _phoneController.text.isEmpty ? null : _phoneController.text,
      emergencyContactName: _emergencyNameController.text.isEmpty
          ? null
          : _emergencyNameController.text,
      emergencyContactPhone: _emergencyPhoneController.text.isEmpty
          ? null
          : _emergencyPhoneController.text,
      personalEmail: _personalEmailController.text.isEmpty
          ? null
          : _personalEmailController.text,
      address: _addressController.text.isEmpty ? null : _addressController.text,
    );

    final success = await ref.read(profileNotifierProvider.notifier).updateProfile(request);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    }
  }
}
