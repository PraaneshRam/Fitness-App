import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/water_intake_provider.dart';
import '../providers/food_provider.dart';
import '../providers/workout_progress_provider.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark mode background
      appBar: AppBar(
        title: Text(
          'Insights & Coach',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: Builder(
        builder: (context) {
          try {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Daily Summary',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDataSummary(context),
                  const SizedBox(height: 32),
                  Text(
                    'AI Coach Suggestions',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSuggestions(context),
                ],
              ),
            );
          } catch (e, stackTrace) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error building screen:\\n$e\\n\\n$stackTrace',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildDataSummary(BuildContext context) {
    final waterProvider = context.watch<WaterIntakeProvider>();
    final foodProvider = context.watch<FoodProvider>();
    final workoutProvider = context.watch<WorkoutProgressProvider>();

    final caloriesNum = foodProvider.dailyTotals['calories'];
    final proteinNum = foodProvider.dailyTotals['protein'];
    
    final calories = num.tryParse(caloriesNum?.toString() ?? '0') ?? 0;
    final protein = num.tryParse(proteinNum?.toString() ?? '0') ?? 0;

    double workoutProgress = 0.0;
    try {
      workoutProgress = (workoutProvider.progressPercentage * 100);
      if (workoutProgress.isNaN || workoutProgress.isInfinite) {
        workoutProgress = 0.0;
      }
    } catch (e) {
      workoutProgress = 0.0;
    }

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          title: 'Water',
          value: '${waterProvider.currentIntake} / ${waterProvider.dailyGoal} ml',
          icon: Icons.water_drop,
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'Calories',
          value: '${calories.toStringAsFixed(0)} kcal',
          icon: Icons.local_fire_department,
          color: Colors.orange,
        ),
        _buildStatCard(
          title: 'Protein',
          value: '${protein.toStringAsFixed(1)} g',
          icon: Icons.fitness_center,
          color: Colors.purple,
        ),
        _buildStatCard(
          title: 'Workout',
          value: '${workoutProgress.toStringAsFixed(0)}%',
          icon: Icons.directions_run,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Dark card background
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    final waterProvider = context.watch<WaterIntakeProvider>();
    final foodProvider = context.watch<FoodProvider>();
    final workoutProvider = context.watch<WorkoutProgressProvider>();

    List<Widget> suggestions = [];

    double waterProgress = 0.0;
    try {
      waterProgress = waterProvider.progressPercentage;
      if (waterProgress.isNaN || waterProgress.isInfinite) waterProgress = 0.0;
    } catch (e) {
      waterProgress = 0.0;
    }

    // Water rule
    if (waterProgress < 0.5) {
      suggestions.add(_buildSuggestionCard(
        title: 'Hydration Alert',
        message: 'You are less than halfway to your water goal. Try to drink a glass of water right now!',
        icon: Icons.water_drop,
        color: Colors.blue,
      ));
    } else if (waterProvider.isGoalAchieved) {
      suggestions.add(_buildSuggestionCard(
        title: 'Hydration Master',
        message: 'Great job hitting your water goal today!',
        icon: Icons.thumb_up,
        color: Colors.blue,
      ));
    }

    double workoutProgress = 0.0;
    try {
      workoutProgress = workoutProvider.progressPercentage;
      if (workoutProgress.isNaN || workoutProgress.isInfinite) workoutProgress = 0.0;
    } catch (e) {
      workoutProgress = 0.0;
    }

    // Workout rule
    if (workoutProgress < 0.3) {
      suggestions.add(_buildSuggestionCard(
        title: 'Time to Move',
        message: "You haven't done much of your workout today. A quick 10-minute session can boost your mood!",
        icon: Icons.directions_run,
        color: Colors.orange,
      ));
    } else {
      suggestions.add(_buildSuggestionCard(
        title: 'Workout Warrior',
        message: 'You are making excellent progress on your workouts. Keep the momentum going!',
        icon: Icons.star,
        color: Colors.amber,
      ));
    }

    // Protein rule
    final proteinNum = foodProvider.dailyTotals['protein'];
    final protein = num.tryParse(proteinNum?.toString() ?? '0') ?? 0;
    if (protein < 50) {
      suggestions.add(_buildSuggestionCard(
        title: 'Protein Check',
        message: 'Your protein intake is a bit low. Consider adding some eggs, chicken, or tofu to your next meal.',
        icon: Icons.restaurant,
        color: Colors.purple,
      ));
    } else {
       suggestions.add(_buildSuggestionCard(
        title: 'Protein Powered',
        message: 'Excellent protein intake today! Your muscles will thank you.',
        icon: Icons.fitness_center,
        color: Colors.purple,
      ));
    }

    if (suggestions.isEmpty) {
      suggestions.add(_buildSuggestionCard(
        title: 'On Track',
        message: 'You are doing great across all metrics today. Keep up the excellent work!',
        icon: Icons.celebration,
        color: Colors.teal,
      ));
    }

    return Column(
      children: suggestions.map((s) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: s,
      )).toList(),
    );
  }

  Widget _buildSuggestionCard({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Dark card background for suggestions
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[300],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
