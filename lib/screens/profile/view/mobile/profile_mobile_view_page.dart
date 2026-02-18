import 'package:flutter/material.dart';
import 'package:hrm/core/repo/prefernces_repo.dart';
import 'package:hrm/core/model/login_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final PreferencesRepository _prefsRepo = PreferencesRepository();

  bool _isLoading = true;

  String? _username;
  String? _emailId;
  int? _userId;
  int? _employeeId;
  int? _companyId;
  List<String>? _userRoles;
  String? _authStatus;
  bool _isLoggedIn = false;
  LoginData? _loginData;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _prefsRepo.getUsername(),
        _prefsRepo.getEmailId(),
        _prefsRepo.getUserId(),
        _prefsRepo.getEmployeeId(),
        _prefsRepo.getCompanyId(),
        _prefsRepo.getUserRoles(),
        _prefsRepo.getAuthStatus(),
        _prefsRepo.isLoggedIn(),
        _prefsRepo.getUserData(),
      ]);

      setState(() {
        _username    = results[0] as String?;
        _emailId     = results[1] as String?;
        _userId      = int.tryParse((results[2] as String?) ?? '');
        _employeeId  = results[3] as int?;
        _companyId   = results[4] as int?;
        _userRoles   = results[5] as List<String>?;
        _authStatus  = results[6] as String?;
        _isLoggedIn  = results[7] as bool;
        _loginData   = results[8] as LoginData?;
        _isLoading   = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _prefsRepo.logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfileData,
              child: CustomScrollView(
                slivers: [
                  // ── App Bar with Avatar ──────────────────────────────────
                  SliverAppBar(
                    expandedHeight: 220,
                    pinned: true,
                    backgroundColor: colorScheme.primary,
                    flexibleSpace: FlexibleSpaceBar(
                      background: _buildHeader(colorScheme),
                    ),
                    actions: [
                      IconButton(
                        tooltip: 'Refresh',
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: _loadProfileData,
                      ),
                    ],
                  ),

                  // ── Body Content ─────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Auth Status Badge
                          if (_authStatus != null) ...[
                            _buildAuthBadge(),
                            const SizedBox(height: 16),
                          ],

                          // Personal Info Card
                          _buildSectionCard(
                            title: 'Personal Information',
                            icon: Icons.person_outline,
                            children: [
                              _buildInfoRow(
                                icon: Icons.badge_outlined,
                                label: 'Username',
                                value: _username ?? '—',
                              ),
                              _buildInfoRow(
                                icon: Icons.email_outlined,
                                label: 'Email',
                                value: _emailId ?? '—',
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Account Details Card
                          _buildSectionCard(
                            title: 'Account Details',
                            icon: Icons.manage_accounts_outlined,
                            children: [
                              _buildInfoRow(
                                icon: Icons.tag,
                                label: 'User ID',
                                value: _userId?.toString() ?? '—',
                              ),
                              _buildInfoRow(
                                icon: Icons.work_outline,
                                label: 'Employee ID',
                                value: _employeeId?.toString() ?? '—',
                              ),
                              _buildInfoRow(
                                icon: Icons.business_outlined,
                                label: 'Company ID',
                                value: _companyId?.toString() ?? '—',
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Roles Card
                          _buildSectionCard(
                            title: 'Assigned Roles',
                            icon: Icons.security_outlined,
                            children: [
                              if (_userRoles != null && _userRoles!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _userRoles!
                                        .map((role) => _buildRoleChip(role))
                                        .toList(),
                                  ),
                                )
                              else
                                _buildInfoRow(
                                  icon: Icons.info_outline,
                                  label: 'Roles',
                                  value: 'No roles assigned',
                                ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Token Info Card
                          if (_loginData != null)
                            _buildSectionCard(
                              title: 'Session Info',
                              icon: Icons.lock_outline,
                              children: [
                                _buildInfoRow(
                                  icon: Icons.token_outlined,
                                  label: 'Token Type',
                                  value: _loginData!.tokenType,
                                ),
                                _buildInfoRow(
                                  icon: Icons.circle,
                                  label: 'Login Status',
                                  value: _isLoggedIn ? 'Active' : 'Inactive',
                                  valueColor: _isLoggedIn
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ],
                            ),

                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _handleLogout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.logout),
                              label: const Text(
                                'Logout',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(ColorScheme colorScheme) {
    final initials = _getInitials(_username);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withOpacity(0.75),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          // Avatar
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              border: Border.all(color: Colors.white, width: 2.5),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _username ?? 'User',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _emailId ?? '',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Auth Status Badge ────────────────────────────────────────────────────────
  Widget _buildAuthBadge() {
    final isSuccess = _authStatus == 'Success';
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSuccess
              ? Colors.green.withOpacity(0.12)
              : Colors.orange.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSuccess ? Colors.green : Colors.orange,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSuccess ? Icons.verified_outlined : Icons.warning_amber_outlined,
              size: 16,
              color: isSuccess ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 6),
            Text(
              'Auth Status: $_authStatus',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSuccess ? Colors.green.shade700 : Colors.orange.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section Card ─────────────────────────────────────────────────────────────
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  // ── Info Row ─────────────────────────────────────────────────────────────────
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ── Role Chip ────────────────────────────────────────────────────────────────
  Widget _buildRoleChip(String role) {
    return Chip(
      label: Text(
        role.trim(),
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor:
          Theme.of(context).colorScheme.primary.withOpacity(0.1),
      side: BorderSide(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  // ── Helper ───────────────────────────────────────────────────────────────────
  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}