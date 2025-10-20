import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// ============================================
// BASE SHIMMER WRAPPER
// ============================================
class ShimmerWrapper extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerWrapper({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? Colors.grey[300]!,
      highlightColor: highlightColor ?? Colors.grey[100]!,
      child: child,
    );
  }
}

// ============================================
// BASIC SHIMMER COMPONENTS
// ============================================

// Rectangle Shimmer Box
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final Color? color;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(4),
        ),
      ),
    );
  }
}

// Circle Shimmer
class ShimmerCircle extends StatelessWidget {
  final double size;
  final Color? color;

  const ShimmerCircle({super.key, required this.size, this.color});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// Text Line Shimmer
class ShimmerText extends StatelessWidget {
  final double width;
  final double height;

  const ShimmerText({super.key, required this.width, this.height = 14});

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(4),
    );
  }
}

// ============================================
// CARD SHIMMER COMPONENTS
// ============================================

// Simple Card Shimmer
class ShimmerCard extends StatelessWidget {
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  const ShimmerCard({
    super.key,
    this.width,
    required this.height,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Container(
        width: width,
        height: height,
        padding: padding ?? const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
        ),
      ),
    );
  }
}

// Mango/Product Grid Card Shimmer
class ShimmerProductCard extends StatelessWidget {
  const ShimmerProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
              ),
            ),
            // Text placeholders
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// LIST SHIMMER COMPONENTS
// ============================================

// List Tile Shimmer
class ShimmerListTile extends StatelessWidget {
  final bool hasLeading;
  final bool hasTrailing;
  final int subtitleLines;

  const ShimmerListTile({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = false,
    this.subtitleLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Leading (Avatar/Icon)
            if (hasLeading) ...[
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
            ],

            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(
                    subtitleLines,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Container(
                        width: double.infinity * 0.7,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Trailing
            if (hasTrailing) ...[
              const SizedBox(width: 12),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================
// PAGE SHIMMER LAYOUTS
// ============================================

// Grid Shimmer Layout
class ShimmerGridView extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double childAspectRatio;
  final Widget? shimmerItem;

  const ShimmerGridView({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.childAspectRatio = 3 / 4,
    this.shimmerItem,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return shimmerItem ?? const ShimmerProductCard();
      },
    );
  }
}

// List Shimmer Layout
class ShimmerListView extends StatelessWidget {
  final int itemCount;
  final bool hasLeading;
  final bool hasTrailing;
  final int subtitleLines;

  const ShimmerListView({
    super.key,
    this.itemCount = 8,
    this.hasLeading = true,
    this.hasTrailing = false,
    this.subtitleLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return ShimmerListTile(
          hasLeading: hasLeading,
          hasTrailing: hasTrailing,
          subtitleLines: subtitleLines,
        );
      },
    );
  }
}

// ============================================
// USAGE EXAMPLES
// ============================================

/*

// Example 1: Basic Shimmer Components
ShimmerBox(width: 200, height: 20)
ShimmerCircle(size: 50)
ShimmerText(width: 150)

// Example 2: Product Grid Shimmer (like your Mandi page)
ShimmerGridView(
  itemCount: 6,
  crossAxisCount: 2,
  childAspectRatio: 3 / 4,
)

// Example 3: List View Shimmer
ShimmerListView(
  itemCount: 8,
  hasLeading: true,
  hasTrailing: true,
  subtitleLines: 2,
)

// Example 4: Custom Card
ShimmerCard(
  width: double.infinity,
  height: 150,
  borderRadius: BorderRadius.circular(16),
)

// Example 5: Custom Layout with Multiple Components
Column(
  children: [
    ShimmerBox(width: 200, height: 24),
    SizedBox(height: 12),
    ShimmerText(width: 150),
    SizedBox(height: 8),
    Row(
      children: [
        ShimmerCircle(size: 40),
        SizedBox(width: 12),
        Column(
          children: [
            ShimmerText(width: 100),
            SizedBox(height: 4),
            ShimmerText(width: 80),
          ],
        ),
      ],
    ),
  ],
)

// Example 6: For Mandi Page Header
Padding(
  padding: EdgeInsets.all(12),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ShimmerBox(width: 150, height: 26),
          ShimmerCircle(size: 26),
        ],
      ),
      SizedBox(height: 4),
      ShimmerText(width: 100, height: 13),
    ],
  ),
)

// Example 7: Search Bar Shimmer
Padding(
  padding: EdgeInsets.symmetric(horizontal: 16),
  child: ShimmerBox(
    width: double.infinity,
    height: 48,
    borderRadius: BorderRadius.circular(30),
  ),
)

// Example 8: Profile Page Shimmer
Column(
  children: [
    ShimmerCircle(size: 100),
    SizedBox(height: 16),
    ShimmerText(width: 120, height: 20),
    SizedBox(height: 8),
    ShimmerText(width: 180, height: 14),
    SizedBox(height: 24),
    ShimmerBox(
      width: double.infinity,
      height: 150,
      borderRadius: BorderRadius.circular(16),
    ),
  ],
)

*/
