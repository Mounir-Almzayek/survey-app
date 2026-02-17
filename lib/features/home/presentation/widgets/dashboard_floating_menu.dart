import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:king_abdulaziz_center_survey_app/core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';

class DashboardFloatingMenu extends StatefulWidget {
  final ScrollController scrollController;
  final List<DashboardSectionNode> sections;

  const DashboardFloatingMenu({
    super.key,
    required this.scrollController,
    required this.sections,
  });

  @override
  State<DashboardFloatingMenu> createState() => _DashboardFloatingMenuState();
}

class _DashboardFloatingMenuState extends State<DashboardFloatingMenu>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  double _progress = 0.0;
  int _activeIndex = 0;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutBack,
    );

    widget.scrollController.addListener(_updateProgress);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateProgress());
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_updateProgress);
    _expandController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    if (!mounted || !widget.scrollController.hasClients) return;

    final maxScroll = widget.scrollController.position.maxScrollExtent;
    final currentScroll = widget.scrollController.offset;

    double newProgress = 0.0;
    if (maxScroll > 0) {
      newProgress = (currentScroll / maxScroll).clamp(0.0, 1.0);
    }

    int newActiveIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < widget.sections.length; i++) {
      final key = widget.sections[i].key;
      final context = key.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox;
        final offset = box.localToGlobal(Offset.zero);
        final distance = (offset.dy - MediaQuery.of(context).size.height / 3)
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

  void _toggleMenu() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  void _scrollToSection(int index) {
    _toggleMenu();
    final key = widget.sections[index].key;
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    // Sides requested to be reversed: Arabic -> Right, English -> Left (Already handled by Positioned logic)
    final alignment = isRtl ? Alignment.bottomRight : Alignment.bottomLeft;
    final s = S.of(context);

    // Responsive values - Optimized for Desktop to be more compact and logical
    final fabSize = context.responsive(60.0, tablet: 56.0, desktop: 52.0);
    final innerCircleSize = context.responsive(
      52.0,
      tablet: 48.0,
      desktop: 44.0,
    );
    final menuWidth = context.responsive(260.0, tablet: 200.0, desktop: 160.0);
    final edgePadding = context.responsive(20.0, tablet: 24.0, desktop: 32.0);
    final fabBottom = context.responsive(120.0, tablet: 100.0, desktop: 50.0);
    final menuBottom = context.responsive(200.0, tablet: 170.0, desktop: 60.0);

    return Stack(
      alignment: alignment,
      children: [
        // Backdrop Overlay when expanded
        if (_isExpanded)
          GestureDetector(
            onTap: _toggleMenu,
            child: FadeTransition(
              opacity: _expandAnimation,
              child: Container(
                color: Colors.black26,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
            ),
          ),

        // Expanded Menu (Slide Up from bottom)
        Positioned(
          left: isRtl ? edgePadding : null,
          right: isRtl ? null : edgePadding,
          bottom: menuBottom,
          child: ScaleTransition(
            scale: _expandAnimation,
            alignment: alignment,
            child: FadeTransition(
              opacity: _expandAnimation,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.responsive(24.0)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: menuWidth,
                    padding: EdgeInsets.all(context.responsive(16.0)),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(
                        context.responsive(24.0),
                      ),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          s.home,
                          style: TextStyle(
                            fontSize: context.adaptiveFont(16.0),
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                          ),
                        ),
                        SizedBox(height: context.responsive(16.0)),
                        ...List.generate(widget.sections.length, (index) {
                          final section = widget.sections[index];
                          final isActive = _activeIndex == index;
                          return _buildMenuItem(index, section, isActive);
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Floating Action Button (Moved above bottom bar)
        Positioned(
          bottom: fabBottom,
          left: isRtl ? edgePadding : null,
          right: isRtl ? null : edgePadding,
          child: GestureDetector(
            onTap: _toggleMenu,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                width: fabSize,
                height: fabSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Progress Circle
                    SizedBox(
                      width: innerCircleSize,
                      height: innerCircleSize,
                      child: CircularProgressIndicator(
                        value: _progress,
                        strokeWidth: context.responsive(3.0),
                        backgroundColor: AppColors.muted.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    // Icon
                    Icon(
                      _isExpanded ? Icons.close : Icons.query_stats,
                      color: AppColors.primary,
                      size: context.responsive(28.0),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    int index,
    DashboardSectionNode section,
    bool isActive,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.responsive(8.0)),
      child: InkWell(
        onTap: () => _scrollToSection(index),
        borderRadius: BorderRadius.circular(context.responsive(12.0)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(
            horizontal: context.responsive(12.0),
            vertical: context.responsive(10.0),
          ),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(context.responsive(12.0)),
          ),
          child: Row(
            children: [
              Icon(
                section.icon,
                size: context.adaptiveIcon(20.0),
                color: isActive ? AppColors.primary : AppColors.mutedForeground,
              ),
              SizedBox(width: context.responsive(12.0)),
              Expanded(
                child: Text(
                  section.label,
                  style: TextStyle(
                    fontSize: context.adaptiveFont(14.0),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? AppColors.primary
                        : AppColors.mutedForeground,
                  ),
                ),
              ),
              if (isActive)
                Icon(
                  Icons.arrow_right_alt,
                  size: context.adaptiveIcon(16.0),
                  color: AppColors.primary,
                ),
            ],
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
