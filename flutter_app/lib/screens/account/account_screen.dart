import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../auth/login_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  void _showEditTargetsDialog(BuildContext context, UserProfile user) {
    final calController = TextEditingController(text: '${user.targetCalories.toInt()}');
    final pController = TextEditingController(text: '${user.targetProtein.toInt()}');
    final cController = TextEditingController(text: '${user.targetCarbs.toInt()}');
    final fController = TextEditingController(text: '${user.targetFat.toInt()}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Daily Nutrition Targets',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: calController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Target Calories (kcal)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: pController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Target Protein (g)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: cController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Target Carbs (g)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: fController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Target Fat (g)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGreen,
              foregroundColor: Colors.black,
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
            child: const Text('Save Targets'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ACCOUNT & SETTINGS'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.cardSurface,
                  ),
                  child: const Center(
                    child: Icon(Icons.person_rounded, color: AppColors.accentGreen, size: 36),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'OFFLINE-FIRST ENGINE ACTIVE',
                          style: TextStyle(
                            color: AppColors.accentGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Daily Goals Configuration
          const Text(
            'NUTRITION & FITNESS TARGETS',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.local_fire_department_rounded, color: AppColors.accentOrange),
                  title: const Text('Daily Calories Target', style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Text(
                    '${user.targetCalories.toInt()} kcal',
                    style: const TextStyle(color: AppColors.accentGreen, fontWeight: FontWeight.bold),
                  ),
                  onTap: () => _showEditTargetsDialog(context, user),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.fitness_center_rounded, color: AppColors.accentCyan),
                  title: const Text('Protein Target', style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Text(
                    '${user.targetProtein.toInt()}g',
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                  ),
                  onTap: () => _showEditTargetsDialog(context, user),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.grain_rounded, color: AppColors.accentYellow),
                  title: const Text('Carbs Target', style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Text(
                    '${user.targetCarbs.toInt()}g',
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                  ),
                  onTap: () => _showEditTargetsDialog(context, user),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.opacity_rounded, color: AppColors.accentRed),
                  title: const Text('Fat Target', style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Text(
                    '${user.targetFat.toInt()}g',
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                  ),
                  onTap: () => _showEditTargetsDialog(context, user),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Switch / Sign Out Button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accentRed,
              side: const BorderSide(color: AppColors.divider),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('SWITCH ACCOUNT / LOGOUT', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
