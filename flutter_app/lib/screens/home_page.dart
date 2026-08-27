import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../providers/auth_provider.dart';
import '../providers/macro_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/run_provider.dart';
import '../providers/workout_provider.dart';
import '../theme/app_colors.dart';
import 'macros/macros_screen.dart';
import 'progress/progress_screen.dart';
import 'runs/runs_screen.dart';
import 'workouts/workouts_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String? _profileImagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('kf_user_profile_image_path');
    if (path != null && path.isNotEmpty && File(path).existsSync()) {
      setState(() => _profileImagePath = path);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('kf_user_profile_image_path', pickedFile.path);
        setState(() => _profileImagePath = pickedFile.path);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile photo updated successfully!'),
              backgroundColor: AppColors.accentGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not access image: $e'),
            backgroundColor: AppColors.accentRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'CHANGE PROFILE PHOTO',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.primaryCTA),
                ),
                title: const Text('Take Photo (Camera)', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.accentTeal),
                ),
                title: const Text('Choose from Library (Gallery)', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_profileImagePath != null) ...[
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: AppColors.accentRed),
                  ),
                  title: const Text('Remove Photo', style: TextStyle(color: AppColors.accentRed, fontWeight: FontWeight.bold, fontSize: 14)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('kf_user_profile_image_path');
                    setState(() => _profileImagePath = null);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showEditTargetsDialog(BuildContext context, UserProfile user) {
    final calController = TextEditingController(text: '${user.targetCalories.toInt()}');
    final pController = TextEditingController(text: '${user.targetProtein.toInt()}');
    final cController = TextEditingController(text: '${user.targetCarbs.toInt()}');
    final fController = TextEditingController(text: '${user.targetFat.toInt()}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: const Text(
          'DAILY TARGETS',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: calController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(labelText: 'Target Calories (kcal)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: pController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(labelText: 'Target Protein (g)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: cController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(labelText: 'Target Carbs (g)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: fController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(labelText: 'Target Fat (g)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryCTA,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(48)),
            ),
            onPressed: () {
              final cal = double.tryParse(calController.text);
              final p = double.tryParse(pController.text);
              final c = double.tryParse(cController.text);
              final f = double.tryParse(fController.text);

              context.read<AuthProvider>().updateProfile(
                    targetCalories: cal,
                    targetProtein: p,
                    targetCarbs: c,
                    targetFat: f,
                  );
              Navigator.pop(ctx);
            },
            child: const Text('SAVE TARGETS', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    final screens = [
      const WorkoutsScreen(),
      const MacrosScreen(),
      const RunsScreen(),
      const ProgressScreen(),
      _buildDashboardOverview(context, auth),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        height: 78,
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          border: Border(top: BorderSide(color: AppColors.cardBorder, width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavTab(0, Icons.fitness_center_rounded, 'Train'),
            _buildNavTab(1, Icons.restaurant_rounded, 'Macros'),
            _buildNavTab(2, Icons.directions_run_rounded, 'Cardio'),
            _buildNavTab(3, Icons.insights_rounded, 'Progress'),
            _buildNavTab(4, Icons.account_circle_rounded, 'Overview'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavTab(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? AppColors.primaryCTA : AppColors.textMuted,
            ),
            const SizedBox(height: 3),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                letterSpacing: 0.5,
                color: isSelected ? AppColors.primaryCTA : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardOverview(BuildContext context, AuthProvider auth) {
    final user = auth.userModel;
    final firebaseUser = auth.firebaseUser;
    final userProfile = auth.user;
    final workoutProvider = context.watch<WorkoutProvider>();
    final macroProvider = context.watch<MacroProvider>();
    final runProvider = context.watch<RunProvider>();
    final progressProvider = context.watch<ProgressProvider>();

    final formattedDate = DateFormat('EEEE, MMMM d').format(DateTime.now());

    final totalCompletedSets = workoutProvider.activeWorkout?.exercises.fold(
          0,
          (acc, e) => acc + e.sets.where((s) => s.isCompleted).length,
        ) ??
        0;

    final totalRunDistance = runProvider.runs.fold(
      0.0,
      (acc, r) => acc + r.distanceMiles,
    );

    final calProgress = (macroProvider.totalCalories / (userProfile.targetCalories > 0 ? userProfile.targetCalories : 2400))
        .clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ACCOUNT & OVERVIEW'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.accentRed),
            tooltip: 'Sign Out',
            onPressed: () => _showLogoutDialog(context, auth),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // User & Profile Card (48px Rounded White Surface)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(48),
              border: Border.all(color: AppColors.cardBorder, width: 1),
              boxShadow: const [AppColors.cardShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Tappable Profile Avatar with Camera Icon Badge
                    GestureDetector(
                      onTap: () => _showImagePickerOptions(context),
                      child: Stack(
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.background,
                              border: Border.all(color: AppColors.borderSecondary, width: 1.5),
                            ),
                            child: ClipOval(
                              child: _profileImagePath != null
                                  ? Image.file(
                                      File(_profileImagePath!),
                                      fit: BoxFit.cover,
                                      width: 68,
                                      height: 68,
                                    )
                                  : const Center(
                                      child: Icon(Icons.person_rounded, color: AppColors.primaryCTA, size: 36),
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryCTA,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 13,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? firebaseUser?.displayName ?? userProfile.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? firebaseUser?.email ?? userProfile.email,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tap photo to edit (Camera / Library)',
                            style: TextStyle(color: AppColors.primaryCTA, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Cloud Sync Status & UID
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: auth.isOnline
                            ? AppColors.accentGreen.withValues(alpha: 0.2)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: auth.isOnline ? const Color(0xFF528770) : AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            auth.isOnline ? 'CLOUD SYNC ACTIVE' : 'LOCAL OFFLINE ACTIVE',
                            style: TextStyle(
                              color: auth.isOnline ? const Color(0xFF528770) : AppColors.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      user != null
                          ? 'UID: ${user.uid.substring(0, user.uid.length > 8 ? 8 : user.uid.length)}...'
                          : 'UID: LOCAL',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section Header
          Text(
            formattedDate.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),

          // 2x2 Metric Grid (32px Rounded Cards with Pastel Red Progress)
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.25,
            children: [
              _buildMetricCard(
                title: 'NUTRITION',
                value: '${macroProvider.totalCalories.toInt()}',
                unit: 'kcal',
                progress: calProgress,
                onTap: () => setState(() => _currentIndex = 1),
              ),
              _buildMetricCard(
                title: 'WORKOUT',
                value: '$totalCompletedSets',
                unit: 'sets logged',
                progress: (totalCompletedSets / 15).clamp(0.0, 1.0),
                onTap: () => setState(() => _currentIndex = 0),
              ),
              _buildMetricCard(
                title: 'BODYWEIGHT',
                value: (progressProvider.latestWeight ?? 75.0).toStringAsFixed(1),
                unit: 'kg',
                progress: 0.8,
                onTap: () => setState(() => _currentIndex = 3),
              ),
              _buildMetricCard(
                title: 'CARDIO RUNS',
                value: totalRunDistance.toStringAsFixed(1),
                unit: 'km / mi',
                progress: (totalRunDistance / 5.0).clamp(0.0, 1.0),
                onTap: () => setState(() => _currentIndex = 2),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Nutrition Targets Configuration
          const Text(
            'NUTRITION & FITNESS TARGETS',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppColors.cardBorder, width: 1),
              boxShadow: const [AppColors.cardShadow],
            ),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Daily Calories Target', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  trailing: Text(
                    '${userProfile.targetCalories.toInt()} kcal',
                    style: const TextStyle(color: AppColors.primaryCTA, fontWeight: FontWeight.w900),
                  ),
                  onTap: () => _showEditTargetsDialog(context, userProfile),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Protein Target', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  trailing: Text(
                    '${userProfile.targetProtein.toInt()}g',
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900),
                  ),
                  onTap: () => _showEditTargetsDialog(context, userProfile),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Carbs Target', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  trailing: Text(
                    '${userProfile.targetCarbs.toInt()}g',
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900),
                  ),
                  onTap: () => _showEditTargetsDialog(context, userProfile),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Fat Target', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  trailing: Text(
                    '${userProfile.targetFat.toInt()}g',
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900),
                  ),
                  onTap: () => _showEditTargetsDialog(context, userProfile),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Logout Button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accentRed,
              backgroundColor: AppColors.cardBackground,
              side: const BorderSide(color: AppColors.borderSecondary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(48)),
            ),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('SWITCH ACCOUNT / LOGOUT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5)),
            onPressed: () => _showLogoutDialog(context, auth),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String unit,
    required double progress,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.cardBorder, width: 1),
          boxShadow: const [AppColors.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: AppColors.background,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryCTA),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: const Text(
          'SIGN OUT',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Are you sure you want to log out? Your cloud data remains safely saved.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(48)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await auth.logout();
            },
            child: const Text('LOGOUT', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
