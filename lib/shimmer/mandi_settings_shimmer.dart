import 'package:flutter/material.dart';
import 'package:mango_app/widgets/shimmer_widgets.dart';

// ============================================
// MANDI SETTINGS SHIMMER WIDGET
// ============================================
class MandiSettingsShimmer extends StatelessWidget {
  const MandiSettingsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: ShimmerBox(
            width: 120,
            height: 20,
            color: Colors.white.withOpacity(0.3),
          ),
          leading: Padding(
            padding: const EdgeInsets.all(12),
            child: ShimmerCircle(
              size: 24,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ShimmerCircle(
                size: 24,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Avatar Shimmer
              Center(child: ShimmerCircle(size: 100)),
              const SizedBox(height: 30),

              // Mandi Name Input Shimmer
              _buildInputFieldShimmer("Mandi Name:"),
              const SizedBox(height: 20),

              // Owner Name Input Shimmer
              _buildInputFieldShimmer("Owner Name:"),
              const SizedBox(height: 20),

              // Location Input Shimmer
              _buildInputFieldShimmer("Location:"),
              const SizedBox(height: 10),

              // Use Current Location Button Shimmer
              ShimmerBox(
                width: double.infinity,
                height: 48,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 30),

              // Change Password Button Shimmer
              ShimmerBox(
                width: double.infinity,
                height: 48,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 30),

              // Save Button Shimmer
              ShimmerBox(
                width: double.infinity,
                height: 48,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 16),

              // Delete Account Button Shimmer
              Center(child: ShimmerText(width: 120, height: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputFieldShimmer(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerText(width: 100, height: 18),
        const SizedBox(height: 8),
        ShimmerBox(
          width: double.infinity,
          height: 56,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }
}
