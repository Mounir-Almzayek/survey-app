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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              entry.displayLabel,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: percent.toDouble(),
                minHeight: 6.h,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          SizedBox(
            width: 50.w,
            child: Text(
              '${entry.progress}/${entry.target}',
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
