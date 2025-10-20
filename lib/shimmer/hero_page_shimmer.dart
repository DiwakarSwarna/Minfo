import 'package:flutter/material.dart';
import 'package:mango_app/widgets/shimmer_widgets.dart';

// ============================================
// HERO PAGE SHIMMER WIDGET
// ============================================
class HeroPageShimmer extends StatelessWidget {
  const HeroPageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Color(0xFFFFFFFF),
        scrolledUnderElevation: 0,
        title: Column(
          children: [
            // Header Row Shimmer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ShimmerBox(width: 100, height: 24),
                ShimmerCircle(size: 30),
              ],
            ),

            // Search Bar Shimmer
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ShimmerBox(
                width: double.infinity,
                height: 44,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Carousel Shimmer
          Padding(
            padding: const EdgeInsets.all(16),
            child: ShimmerBox(
              width: double.infinity,
              height: 200,
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          // Filter Section Shimmer
          Container(
            height: 80,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerText(width: 120, height: 16),
                SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ShimmerBox(
                          width: 100,
                          height: 32,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        SizedBox(width: 12),
                        ShimmerBox(
                          width: 100,
                          height: 32,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        SizedBox(width: 12),
                        ShimmerBox(
                          width: 100,
                          height: 32,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        SizedBox(width: 12),
                        ShimmerBox(
                          width: 100,
                          height: 32,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8),

          // Results count shimmer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ShimmerText(width: 200, height: 14),
            ),
          ),

          SizedBox(height: 8),

          // List Section Shimmer
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 12),
              itemCount: 8,
              itemBuilder: (context, index) {
                return _buildMandiCardShimmer();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMandiCardShimmer() {
    return ShimmerWrapper(
      child: Card(
        elevation: 2,
        color: Colors.white,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mandi name
                    Container(
                      width: double.infinity,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: 8),

                    // Price
                    Container(
                      width: 120,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: 6),

                    // Capacity
                    Container(
                      width: 150,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),

              // Distance
              Column(
                children: [
                  Container(
                    width: 50,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 4),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
