import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Profile view screen showing user information
class ProfileViewScreen extends StatefulWidget {
  final VoidCallback? onEditProfile;
  final VoidCallback? onChangePhoto;

  const ProfileViewScreen({
    super.key,
    this.onEditProfile,
    this.onChangePhoto,
  });

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  _UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
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
        _profile = _getMockProfile();
      });
    }
  }

  _UserProfile _getMockProfile() {
    return _UserProfile(
      name: 'Ahmad Bin Mohd',
      employeeId: 'EMP1234',
      email: 'ahmad.mohd@kerjaflow.com',
      phone: '+60 12-345 6789',
      dateOfBirth: DateTime(1990, 5, 15),
      gender: 'Male',
      nationality: 'Malaysian',
      icNumber: '900515-14-5678',
      address: '123 Jalan Taman Bahagia, 47300 Petaling Jaya, Selangor',
      department: 'Engineering',
      position: 'Software Engineer',
      employmentType: 'Permanent',
      joinDate: DateTime(2022, 3, 1),
      reportingTo: 'Mohd Razak bin Abdullah',
      emergencyContactName: 'Siti Aminah',
      emergencyContactRelation: 'Spouse',
      emergencyContactPhone: '+60 12-987 6543',
      avatarUrl: null,
    );
  }

  Future<void> _onRefresh() async {
    await _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KFAppBar(
        title: 'My Profile',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: widget.onEditProfile,
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: KFSpacing.screenPadding,
      child: Column(
        children: const [
          KFSkeletonCard(height: 180),
          SizedBox(height: KFSpacing.space4),
          KFSkeletonCard(height: 200),
          SizedBox(height: KFSpacing.space4),
          KFSkeletonCard(height: 150),
          SizedBox(height: KFSpacing.space4),
          KFSkeletonCard(height: 150),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return KFErrorState(
      message: _errorMessage!,
      onRetry: _loadProfile,
    );
  }

  Widget _buildContent() {
    final profile = _profile!;

    return KFRefreshable(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        padding: KFSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileHeader(profile),
            const SizedBox(height: KFSpacing.space4),
            KFPrimaryButton(
              label: 'Edit Profile',
              leadingIcon: Icons.edit,
              onPressed: widget.onEditProfile,
            ),
            const SizedBox(height: KFSpacing.space6),
            _buildSection('Personal Information', [
              _ProfileItem(Icons.cake_outlined, 'Date of Birth', _formatDate(profile.dateOfBirth)),
              _ProfileItem(Icons.person_outline, 'Gender', profile.gender),
              _ProfileItem(Icons.flag_outlined, 'Nationality', profile.nationality),
              _ProfileItem(Icons.badge_outlined, 'IC Number', profile.icNumber),
            ]),
            const SizedBox(height: KFSpacing.space4),
            _buildSection('Contact Information', [
              _ProfileItem(Icons.email_outlined, 'Email', profile.email),
              _ProfileItem(Icons.phone_outlined, 'Phone', profile.phone),
              _ProfileItem(Icons.location_on_outlined, 'Address', profile.address),
            ]),
            const SizedBox(height: KFSpacing.space4),
            _buildSection('Employment Information', [
              _ProfileItem(Icons.business_outlined, 'Department', profile.department),
              _ProfileItem(Icons.work_outline, 'Position', profile.position),
              _ProfileItem(Icons.assignment_ind_outlined, 'Employment Type', profile.employmentType),
              _ProfileItem(Icons.calendar_today_outlined, 'Join Date', _formatDate(profile.joinDate)),
              _ProfileItem(Icons.supervisor_account_outlined, 'Reporting To', profile.reportingTo),
            ]),
            const SizedBox(height: KFSpacing.space4),
            _buildSection('Emergency Contact', [
              _ProfileItem(Icons.person_outline, 'Name', profile.emergencyContactName),
              _ProfileItem(Icons.family_restroom, 'Relationship', profile.emergencyContactRelation),
              _ProfileItem(Icons.phone_outlined, 'Phone', profile.emergencyContactPhone),
            ]),
            const SizedBox(height: KFSpacing.space8),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(_UserProfile profile) {
    return KFCard(
      child: Padding(
        padding: const EdgeInsets.all(KFSpacing.space4),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: KFColors.primary100,
                  child: profile.avatarUrl != null
                      ? ClipOval(
                          child: Image.network(
                            profile.avatarUrl!,
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Text(
                          profile.name.substring(0, 1).toUpperCase(),
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
            const SizedBox(height: KFSpacing.space4),
            Text(
              profile.name,
              style: const TextStyle(
                fontSize: KFTypography.fontSizeXl,
                fontWeight: KFTypography.bold,
              ),
            ),
            const SizedBox(height: KFSpacing.space1),
            Text(
              profile.employeeId,
              style: const TextStyle(
                fontSize: KFTypography.fontSizeMd,
                color: KFColors.gray600,
              ),
            ),
            const SizedBox(height: KFSpacing.space1),
            Text(
              '${profile.position} • ${profile.department}',
              style: const TextStyle(
                fontSize: KFTypography.fontSizeSm,
                color: KFColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<_ProfileItem> items) {
    return KFCard(
      child: Padding(
        padding: const EdgeInsets.all(KFSpacing.space4),
        child: Column(
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
            ...items.map((item) => _buildInfoRow(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(_ProfileItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KFSpacing.space3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            item.icon,
            size: 20,
            color: KFColors.gray500,
          ),
          const SizedBox(width: KFSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: KFTypography.fontSizeXs,
                    color: KFColors.gray500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.value,
                  style: const TextStyle(
                    fontSize: KFTypography.fontSizeSm,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _ProfileItem {
  final IconData icon;
  final String label;
  final String value;

  _ProfileItem(this.icon, this.label, this.value);
}

class _UserProfile {
  final String name;
  final String employeeId;
  final String email;
  final String phone;
  final DateTime dateOfBirth;
  final String gender;
  final String nationality;
  final String icNumber;
  final String address;
  final String department;
  final String position;
  final String employmentType;
  final DateTime joinDate;
  final String reportingTo;
  final String emergencyContactName;
  final String emergencyContactRelation;
  final String emergencyContactPhone;
  final String? avatarUrl;

  _UserProfile({
    required this.name,
    required this.employeeId,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.gender,
    required this.nationality,
    required this.icNumber,
    required this.address,
    required this.department,
    required this.position,
    required this.employmentType,
    required this.joinDate,
    required this.reportingTo,
    required this.emergencyContactName,
    required this.emergencyContactRelation,
    required this.emergencyContactPhone,
    this.avatarUrl,
  });
}
