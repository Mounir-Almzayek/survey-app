import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/styles/app_colors.dart';

class DashboardProgressSidebar extends StatefulWidget {
  final ScrollController scrollController;
  final List<DashboardSectionNode> sections;

  const DashboardProgressSidebar({
    super.key,
    required this.scrollController,
    required this.sections,
  });

  @override
  State<DashboardProgressSidebar> createState() =>
      _DashboardProgressSidebarState();
}

class _DashboardProgressSidebarState extends State<DashboardProgressSidebar> {
  double _progress = 0.0;
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_updateProgress);
    // Initial check
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateProgress());
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_updateProgress);
    super.dispose();
  }

  void _updateProgress() {
    if (!mounted || !widget.scrollController.hasClients) return;

    final maxScroll = widget.scrollController.position.maxScrollExtent;
    final currentScroll = widget.scrollController.offset;

    // Calculate overall progress percentage
    double newProgress = 0.0;
    if (maxScroll > 0) {
      newProgress = (currentScroll / maxScroll).clamp(0.0, 1.0);
    }

    // Determine active index based on section positions
    int newActiveIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < widget.sections.length; i++) {
      final key = widget.sections[i].key;
      final context = key.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox;
        final offset = box.localToGlobal(Offset.zero);
        // Distance from middle of screen
        final distance = (offset.dy - MediaQuery.of(context).size.height / 2)
            .abs();
        if (distance < minDistance) {
          minDistance = distance;
          newActiveIndex = i;
        }
      }
    }

    if (newProgress != _progress || newActiveIndex != _activeIndex) {
      setState(() {
        _progress = newProgress;
        _activeIndex = newActiveIndex;
      });
    }
  }

  void _scrollToSection(int index) {
    final key = widget.sections[index].key;
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hide on small screens if needed, or make it very compact
    final isCompact = MediaQuery.of(context).size.width < 800;
    if (isCompact && MediaQuery.of(context).size.width < 400) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 60.w,
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Track
          Container(
            width: 2.w,
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          // Progress Fill
          Align(
            alignment: Alignment.topCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 3.w,
              height: (MediaQuery.of(context).size.height * 0.6) * _progress,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          // Nodes
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(widget.sections.length, (index) {
                final isActive = _activeIndex == index;
                return _buildNode(index, isActive);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNode(int index, bool isActive) {
    return GestureDetector(
      onTap: () => _scrollToSection(index),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Tooltip(
          message: widget.sections[index].label,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? AppColors.primary : AppColors.border,
                width: isActive ? 2.w : 1.w,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isActive ? 12.w : 8.w,
              height: isActive ? 12.w : 8.w,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : AppColors.mutedForeground.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: isActive
                  ? Icon(
                      widget.sections[index].icon,
                      size: 8.w,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardSectionNode {
  final GlobalKey key;
  final String label;
  final IconData icon;

  DashboardSectionNode({
    required this.key,
    required this.label,
    required this.icon,
  });
}
