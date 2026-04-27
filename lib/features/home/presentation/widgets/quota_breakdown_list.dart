import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../models/survey_stats_model.dart';

/// Collapsible per-survey breakdown list. Shows the top-N quota rows by
/// `progressPercent` and reveals the rest behind a "show more" toggle.
class QuotaBreakdownList extends StatefulWidget {
  final List<QuotaBreakdownEntry> entries;
  final int topN;

  const QuotaBreakdownList({
    super.key,
    required this.entries,
    this.topN = 5,
  });

  @override
  State<QuotaBreakdownList> createState() => _QuotaBreakdownListState();
}

class _QuotaBreakdownListState extends State<QuotaBreakdownList> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final visible = _expanded
        ? widget.entries
        : widget.entries.take(widget.topN).toList();
    final showToggle = widget.entries.length > widget.topN;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final e in visible) _Row(entry: e),
        if (showToggle)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: () => setState(() => _expanded = !_expanded),
              child: Text(_expanded ? 'عرض أقل' : 'عرض المزيد'),
            ),
          ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final QuotaBreakdownEntry entry;
  const _Row({required this.entry});

  @override
  Widget build(BuildContext context) {
    final percent = (entry.progressPercent.toDouble().clamp(0, 100)) / 100;
    final segments = _splitLabel(entry.displayLabel);
    final theme = Theme.of(context);
    final tagColor = theme.colorScheme.primary;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coordinate segments. Renders as wrapping rows of small tags
          // separated by a thin dot. Adapts to any N segments — the Wrap
          // widget flows them onto as many lines as the content needs, so
          // labels with 2, 4, 6, or more coordinates all read cleanly.
          if (segments.isEmpty)
            Text(
              entry.displayLabel,
              style: theme.textTheme.bodySmall,
              softWrap: true,
            )
          else
            Wrap(
              spacing: 6.w,
              runSpacing: 4.h,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (var i = 0; i < segments.length; i++) ...[
                  if (i > 0)
                    Container(
                      width: 3.w,
                      height: 3.w,
                      decoration: BoxDecoration(
                        color: tagColor.withOpacity(0.45),
                        shape: BoxShape.circle,
                      ),
                    ),
                  Text(
                    segments[i],
                    style: theme.textTheme.bodySmall?.copyWith(
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ],
            ),
          SizedBox(height: 10.h),
          // Progress bar + count
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: percent.toDouble(),
                    minHeight: 6.h,
                    backgroundColor: tagColor.withOpacity(0.10),
                    valueColor: AlwaysStoppedAnimation<Color>(tagColor),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                '${entry.progress}/${entry.target}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Split the server-built display label on the bullet separator.
  /// The server joins coordinate labels with `" • "` (space-bullet-space),
  /// but we tolerate any whitespace around the bullet to be robust.
  /// Returns segments in their original order.
  static List<String> _splitLabel(String label) {
    if (label.isEmpty) return const [];
    return label
        .split('•')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList(growable: false);
  }
}
