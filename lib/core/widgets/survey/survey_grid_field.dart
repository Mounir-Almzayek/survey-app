import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../enums/survey_enums.dart';
import '../../models/survey/question_model.dart';
import '../../models/survey/question_option_model.dart';
import '../../models/survey/question_row_model.dart';
import '../../styles/app_colors.dart';
import '../../utils/responsive_layout.dart';
import 'survey_question_card.dart';

/// Matrix question — either single or multi select per row.
///
/// Answer shape:
/// - [QuestionType.singleSelectGrid]: `Map<String, String>` (row.value → option.value)
/// - [QuestionType.multiSelectGrid]:  `Map<String, List<String>>`
///
/// Keys use `row.value` (not `row.id`) so the payload matches the web client's
/// shape and the backend's generic JSON-serialisation path.
class SurveyGridField extends StatefulWidget {
  final Question question;
  final dynamic value; // Map<String, String> or Map<String, List<String>>
  final ValueChanged<dynamic> onChanged;
  final String? errorText;
  final bool isVisible;
  final bool isEditable;

  const SurveyGridField({
    super.key,
    required this.question,
    required this.onChanged,
    this.value,
    this.errorText,
    this.isVisible = true,
    this.isEditable = true,
  });

  @override
  State<SurveyGridField> createState() => _SurveyGridFieldState();
}

class _SurveyGridFieldState extends State<SurveyGridField> {
  late final ScrollController _scrollController;
  late Map<String, dynamic> _selection;

  bool get _isMulti => widget.question.type == QuestionType.multiSelectGrid;

  List<QuestionRow> get _rows {
    final rows = (widget.question.questionRows ?? const <QuestionRow>[])
        .where((r) => (r.value ?? '').isNotEmpty)
        .toList();
    rows.sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
    return rows;
  }

  List<QuestionOption> get _options {
    final opts =
        (widget.question.questionOptions ?? const <QuestionOption>[]).toList();
    opts.sort((a, b) => a.id.compareTo(b.id));
    return opts;
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _selection = _parseValue(widget.value);
  }

  @override
  void didUpdateWidget(SurveyGridField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _selection = _parseValue(widget.value);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _parseValue(dynamic v) {
    if (v is Map) return Map<String, dynamic>.from(v);
    return {};
  }

  bool _isSelected(String rowValue, String optionValue) {
    final current = _selection[rowValue];
    if (_isMulti) {
      return current is List && current.contains(optionValue);
    }
    return current == optionValue;
  }

  void _onCellTap(String rowValue, String optionValue) {
    final updated = Map<String, dynamic>.from(_selection);
    if (_isMulti) {
      final list = (updated[rowValue] is List)
          ? List<String>.from(updated[rowValue] as List)
          : <String>[];
      if (list.contains(optionValue)) {
        list.remove(optionValue);
      } else {
        list.add(optionValue);
      }
      if (list.isEmpty) {
        updated.remove(rowValue);
      } else {
        updated[rowValue] = list;
      }
      final result =
          updated.map((k, v) => MapEntry(k, List<String>.from(v as List)));
      setState(() => _selection = Map<String, dynamic>.from(result));
      widget.onChanged(result);
    } else {
      if (updated[rowValue] == optionValue) {
        updated.remove(rowValue);
      } else {
        updated[rowValue] = optionValue;
      }
      final result = updated.map((k, v) => MapEntry(k, v as String));
      setState(() => _selection = Map<String, dynamic>.from(result));
      widget.onChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows;
    final opts = _options;
    final labelWidth =
        context.responsive(110.w, tablet: 130.w, desktop: 150.w);
    final cellWidth = context.responsive(80.w, tablet: 90.w, desktop: 100.w);

    return SurveyQuestionCard(
      label: widget.question.label,
      helpText: widget.question.helpText,
      isRequired: widget.question.isRequired,
      errorText: widget.errorText,
      isVisible: widget.isVisible,
      validations: widget.question.questionValidations,
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context, labelWidth, cellWidth, opts),
              SizedBox(height: 8.h),
              for (final row in rows)
                RepaintBoundary(
                  child: _buildRow(context, row, opts, labelWidth, cellWidth),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, double labelWidth, double cellWidth,
      List<QuestionOption> opts) {
    return Row(
      children: [
        SizedBox(width: labelWidth),
        for (final opt in opts)
          SizedBox(
            width: cellWidth,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
              child: Text(
                opt.label ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.adaptiveFont(11.sp),
                  fontWeight: FontWeight.w700,
                  color: AppColors.mutedForeground,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, QuestionRow row,
      List<QuestionOption> opts, double labelWidth, double cellWidth) {
    return Container(
      margin: EdgeInsets.only(bottom: 6.h),
      decoration: BoxDecoration(
        color: AppColors.muted.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10.r),
      ),
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Text(
                row.label ?? '',
                style: TextStyle(
                  fontSize: context.adaptiveFont(12.sp),
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
            ),
          ),
          for (final opt in opts)
            SizedBox(
              width: cellWidth,
              child: Center(
                child: _cell(context, row.value ?? '', opt.value ?? ''),
              ),
            ),
        ],
      ),
    );
  }

  Widget _cell(BuildContext context, String rowValue, String optionValue) {
    final selected = _isSelected(rowValue, optionValue);
    final iconSelected = _isMulti
        ? Icons.check_box_rounded
        : Icons.radio_button_checked_rounded;
    final iconUnselected = _isMulti
        ? Icons.check_box_outline_blank_rounded
        : Icons.radio_button_off_rounded;
    return GestureDetector(
      key: ValueKey('grid-cell-$rowValue-$optionValue'),
      behavior: HitTestBehavior.opaque,
      onTap: widget.isEditable ? () => _onCellTap(rowValue, optionValue) : null,
      child: Padding(
        padding: EdgeInsets.all(6.r),
        child: Icon(
          selected ? iconSelected : iconUnselected,
          color: selected
              ? AppColors.surveyPrimary
              : AppColors.mutedForeground.withValues(alpha: 0.6),
          size: context.adaptiveIcon(22.sp),
        ),
      ),
    );
  }
}
