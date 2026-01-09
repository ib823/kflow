import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Profile edit screen for updating user information
class ProfileEditScreen extends StatefulWidget {
  final VoidCallback? onSave;
  final VoidCallback? onChangePhoto;

  const ProfileEditScreen({
    super.key,
    this.onSave,
    this.onChangePhoto,
  });

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyRelationController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasChanges = false;
  String? _errorMessage;

  // Non-editable fields (for display only)
  String _name = '';
  String _employeeId = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _setupListeners();
  }

  void _setupListeners() {
    _phoneController.addListener(_onFieldChanged);
    _addressController.addListener(_onFieldChanged);
    _emergencyNameController.addListener(_onFieldChanged);
    _emergencyRelationController.addListener(_onFieldChanged);
    _emergencyPhoneController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyNameController.dispose();
    _emergencyRelationController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
        // Populate form fields
        _name = 'Ahmad Bin Mohd';
        _employeeId = 'EMP1234';
        _email = 'ahmad.mohd@kerjaflow.com';
        _phoneController.text = '+60 12-345 6789';
        _addressController.text = '123 Jalan Taman Bahagia, 47300 Petaling Jaya, Selangor';
        _emergencyNameController.text = 'Siti Aminah';
        _emergencyRelationController.text = 'Spouse';
        _emergencyPhoneController.text = '+60 12-987 6543';
        _hasChanges = false;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isSaving = false;
        _hasChanges = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: KFColors.success600,
          behavior: SnackBarBehavior.floating,
        ),
      );

      widget.onSave?.call();
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to leave without saving?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep Editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: KFColors.error600),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: KFAppBar(
          title: 'Edit Profile',
          actions: [
            TextButton(
              onPressed: _hasChanges && !_isSaving ? _handleSave : null,
              child: Text(
                'Save',
                style: TextStyle(
                  color: _hasChanges && !_isSaving
                      ? KFColors.primary600
                      : KFColors.gray400,
                  fontWeight: KFTypography.semiBold,
                ),
              ),
            ),
          ],
        ),
        body: _isLoading
            ? _buildLoadingState()
            : _errorMessage != null
                ? _buildErrorState()
                : _buildContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: KFLoadingIndicator(),
    );
  }

  Widget _buildErrorState() {
    return KFErrorState(
      message: _errorMessage!,
      onRetry: _loadProfile,
    );
  }

  Widget _buildContent() {
    return KFLoadingOverlay(
      isLoading: _isSaving,
      message: 'Saving changes...',
      child: SingleChildScrollView(
        padding: KFSpacing.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo change
              _buildPhotoSection(),
              const SizedBox(height: KFSpacing.space6),
              // Non-editable info banner
              KFInfoBanner(
                message: 'Some fields can only be updated by HR. Contact HR for changes to name, email, or employee details.',
                backgroundColor: KFColors.info50,
                textColor: KFColors.info700,
                icon: Icons.info_outline,
              ),
              const SizedBox(height: KFSpacing.space6),
              // Non-editable fields
              _buildSection('Account Information (Read-only)', [
                _buildReadOnlyField('Name', _name),
                _buildReadOnlyField('Employee ID', _employeeId),
                _buildReadOnlyField('Email', _email),
              ]),
              const SizedBox(height: KFSpacing.space4),
              // Editable contact info
              _buildSection('Contact Information', [
                KFTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: 'Enter your phone number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone number is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: KFSpacing.space4),
                KFTextArea(
                  controller: _addressController,
                  label: 'Address',
                  hint: 'Enter your full address',
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Address is required';
                    }
                    return null;
                  },
                ),
              ]),
              const SizedBox(height: KFSpacing.space4),
              // Emergency contact
              _buildSection('Emergency Contact', [
                KFTextField(
                  controller: _emergencyNameController,
                  label: 'Contact Name',
                  hint: 'Enter emergency contact name',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Emergency contact name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: KFSpacing.space4),
                KFTextField(
                  controller: _emergencyRelationController,
                  label: 'Relationship',
                  hint: 'e.g., Spouse, Parent, Sibling',
                  prefixIcon: Icons.family_restroom,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Relationship is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: KFSpacing.space4),
                KFTextField(
                  controller: _emergencyPhoneController,
                  label: 'Contact Phone',
                  hint: 'Enter emergency contact phone',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Emergency contact phone is required';
                    }
                    return null;
                  },
                ),
              ]),
              const SizedBox(height: KFSpacing.space8),
              KFPrimaryButton(
                label: 'Save Changes',
                onPressed: _hasChanges ? _handleSave : null,
                isLoading: _isSaving,
              ),
              const SizedBox(height: KFSpacing.space6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: KFColors.primary100,
                child: Text(
                  _name.isNotEmpty ? _name.substring(0, 1).toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: KFTypography.fontSize4xl,
                    fontWeight: KFTypography.bold,
                    color: KFColors.primary600,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: widget.onChangePhoto,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: KFColors.primary600,
                      shape: BoxShape.circle,
                      border: Border.all(color: KFColors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: KFColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: KFSpacing.space3),
          KFTextButton(
            label: 'Change Photo',
            onPressed: widget.onChangePhoto,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: KFTypography.fontSizeMd,
            fontWeight: KFTypography.semiBold,
          ),
        ),
        const SizedBox(height: KFSpacing.space3),
        ...children,
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KFSpacing.space3),
      child: Container(
        padding: const EdgeInsets.all(KFSpacing.space3),
        decoration: BoxDecoration(
          color: KFColors.gray100,
          borderRadius: KFRadius.radiusMd,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: KFTypography.fontSizeXs,
                      color: KFColors.gray500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: KFTypography.fontSizeSm,
                      color: KFColors.gray700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.lock_outline,
              size: 16,
              color: KFColors.gray400,
            ),
          ],
        ),
      ),
    );
  }
}
