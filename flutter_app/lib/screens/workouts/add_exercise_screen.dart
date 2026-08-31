import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/exercise.dart';
import '../../providers/workout_provider.dart';
import '../../services/exercise_catalog.dart';
import '../../theme/app_colors.dart';

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({super.key});

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final _searchController = TextEditingController();
  final List<Exercise> _allExercises = ExerciseCatalog.getDefaultExercises();
  List<Exercise> _filtered = [];
  BodyPart? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _filtered = _allExercises;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filtered = _allExercises.where((e) {
        final matchesQuery = query.isEmpty || e.name.toLowerCase().contains(query);
        final matchesCategory = _selectedCategory == null || e.bodyPart == _selectedCategory;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  void _showCreateCustomExerciseDialog() {
    final nameController = TextEditingController();
    BodyPart selectedPart = BodyPart.chest;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.cardBorder),
          ),
          title: const Text(
            'New Custom Exercise',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'e.g. Incline Cable Press',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.cardSurface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<BodyPart>(
                initialValue: selectedPart,
                dropdownColor: AppColors.cardBackground,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.cardSurface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: BodyPart.values
                    .map((bp) => DropdownMenuItem(
                          value: bp,
                          child: Text(bp.name.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setModalState(() => selectedPart = val);
                },
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
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  final custom = Exercise(
                    id: const Uuid().v4(),
                    name: name,
                    bodyPart: selectedPart,
                  );
                  context.read<WorkoutProvider>().addExerciseToActiveWorkout(custom);
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add Exercise'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Select Exercise'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.accentGreen),
            tooltip: 'Create Custom Exercise',
            onPressed: _showCreateCustomExerciseDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _filter(),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search 60+ exercises...',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
              ),
            ),
          ),

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('ALL'),
                  selected: _selectedCategory == null,
                  onSelected: (_) {
                    setState(() => _selectedCategory = null);
                    _filter();
                  },
                  backgroundColor: AppColors.cardBackground,
                  selectedColor: AppColors.accentGreen.withValues(alpha: 0.25),
                  checkmarkColor: AppColors.accentGreen,
                  labelStyle: TextStyle(
                    color: _selectedCategory == null ? AppColors.accentGreen : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                ...BodyPart.values.map(
                  (bp) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(bp.name.toUpperCase()),
                      selected: _selectedCategory == bp,
                      onSelected: (_) {
                        setState(() => _selectedCategory = _selectedCategory == bp ? null : bp);
                        _filter();
                      },
                      backgroundColor: AppColors.cardBackground,
                      selectedColor: AppColors.accentGreen.withValues(alpha: 0.25),
                      checkmarkColor: AppColors.accentGreen,
                      labelStyle: TextStyle(
                        color: _selectedCategory == bp ? AppColors.accentGreen : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Exercises List
          Expanded(
            child: ListView.separated(
              itemCount: _filtered.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final exercise = _filtered[index];
                return ListTile(
                  title: Text(
                    exercise.name,
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    exercise.bodyPart.name.toUpperCase(),
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.add_circle_outline, color: AppColors.accentGreen),
                  onTap: () {
                    context.read<WorkoutProvider>().addExerciseToActiveWorkout(exercise);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
