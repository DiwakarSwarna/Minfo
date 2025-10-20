import 'package:flutter/material.dart';
import 'package:mango_app/widgets/shimmer_widgets.dart';

// ============================================
// PROFILE PAGE SHIMMER WIDGET
// ============================================
class ProfilePageShimmer extends StatelessWidget {
  const ProfilePageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ShimmerCircle(size: 32, color: Colors.white.withOpacity(0.3)),
              const SizedBox(width: 8),
              ShimmerBox(
                width: 150,
                height: 20,
                color: Colors.white.withOpacity(0.3),
              ),
            ],
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
              // Farmer Name Input Shimmer
              _buildInputFieldShimmer("Farmer Name:"),
              const SizedBox(height: 20),

              // Mango Types Section Shimmer
              _buildMangoTypesShimmer(),
              const SizedBox(height: 20),

              // Location Section Shimmer
              _buildLocationShimmer(),
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
                height: 64,
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
        ShimmerText(width: 120, height: 18),
        const SizedBox(height: 8),
        ShimmerBox(
          width: double.infinity,
          height: 56,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }

  Widget _buildMangoTypesShimmer() {
    return ShimmerWrapper(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            // Divider
            Divider(height: 1, color: Colors.grey[300]),
            // Mango type items
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMangoTypeItemShimmer(),
                  const SizedBox(height: 12),
                  _buildMangoTypeItemShimmer(),
                  const SizedBox(height: 12),
                  _buildMangoTypeItemShimmer(),
                  const SizedBox(height: 16),
                  // Add button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 120,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
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

  Widget _buildMangoTypeItemShimmer() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey[300]!),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerText(width: 80, height: 18),
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
