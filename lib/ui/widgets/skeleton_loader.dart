import 'package:flutter/material.dart';

class SkeletonLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({super.key, this.width, this.height, this.borderRadius});

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

class ProfileSkeletonLoader extends StatelessWidget {
  const ProfileSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quote card skeleton
          const SkeletonLoader(
            width: double.infinity,
            height: 120,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          const SizedBox(height: 16),

          // Insights skeleton
          const SkeletonLoader(
            width: double.infinity,
            height: 200,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          const SizedBox(height: 16),

          // Heatmap skeleton
          const SkeletonLoader(
            width: double.infinity,
            height: 180,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          const SizedBox(height: 16),

          // Profile card skeleton
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonLoader(width: 100, height: 24),
                  const SizedBox(height: 16),
                  _buildSkeletonRow(),
                  _buildSkeletonRow(),
                  _buildSkeletonRow(),
                  _buildSkeletonRow(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Summary card skeleton
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonLoader(width: 150, height: 24),
                  const SizedBox(height: 16),
                  _buildSkeletonRow(),
                  _buildSkeletonRow(),
                  _buildSkeletonRow(),
                  _buildSkeletonRow(),
                  _buildSkeletonRow(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonRow() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SkeletonLoader(width: 120, height: 16),
          SkeletonLoader(width: 80, height: 16),
        ],
      ),
    );
  }
}

class ListSkeletonLoader extends StatelessWidget {
  final int itemCount;

  const ListSkeletonLoader({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const SkeletonLoader(
                  width: 40,
                  height: 40,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoader(
                        width: double.infinity,
                        height: 16,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 8),
                      SkeletonLoader(
                        width: 150,
                        height: 12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CardSkeletonLoader extends StatelessWidget {
  const CardSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonLoader(width: 120, height: 24),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatSkeleton(),
                _buildStatSkeleton(),
                _buildStatSkeleton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSkeleton() {
    return Column(
      children: [
        const SkeletonLoader(
          width: 60,
          height: 60,
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        const SizedBox(height: 8),
        SkeletonLoader(
          width: 50,
          height: 12,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
