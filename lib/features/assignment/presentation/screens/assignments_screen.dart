import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/l10n/generated/l10n.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/utils/responsive_layout.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../bloc/assignments_list/assignments_list_bloc.dart';
import '../widgets/assignment_card.dart';
import '../widgets/survey_empty_state.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;
  Timer? _debounce;

  void _onSearchChanged(String v) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        context.read<AssignmentsListBloc>().add(SearchAssignments(v));
        if (v.trim().length > 1) {
          context.read<AssignmentsListBloc>().add(AddToHistory(v));
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
      });
      if (_searchFocusNode.hasFocus) {
        context.read<AssignmentsListBloc>().add(LoadSearchHistory());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<AssignmentsListBloc, AssignmentsListState>(
        builder: (context, state) {
          if (state is AssignmentsListLoading) {
            return const LoadingWidget();
          }

          if (state is AssignmentsListError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: () =>
                  context.read<AssignmentsListBloc>().add(LoadAssignments()),
            );
          }

          if (state is AssignmentsListLoaded) {
            final surveys = state.filteredSurveys;

            return RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: Colors.white,
              displacement: 40,
              onRefresh: () async {
                _searchController.clear();
                context.read<AssignmentsListBloc>().add(LoadAssignments());
              },
              child: Stack(
                children: [
                  Column(
                    children: [
                      _buildSearchHeader(context, state),
                      Expanded(
                        child: surveys.isEmpty
                            ? SurveyEmptyState(
                                isSearch: state.searchQuery.isNotEmpty,
                                onAction: () {
                                  if (state.searchQuery.isNotEmpty) {
                                    _searchController.clear();
                                    context.read<AssignmentsListBloc>().add(
                                      SearchAssignments(''),
                                    );
                                  } else {
                                    context.read<AssignmentsListBloc>().add(
                                      LoadAssignments(),
                                    );
                                  }
                                },
                              )
                            : ListView.separated(
                                physics: const BouncingScrollPhysics(
                                  parent: AlwaysScrollableScrollPhysics(),
                                ),
                                padding: EdgeInsets.fromLTRB(
                                  context.responsive(
                                    16.r,
                                    tablet: 24.r,
                                    desktop: 32.r,
                                  ),
                                  8.h,
                                  context.responsive(
                                    16.r,
                                    tablet: 24.r,
                                    desktop: 32.r,
                                  ),
                                  context.responsive(
                                    100.h,
                                    tablet: 120.h,
                                    desktop: 140.h,
                                  ),
                                ),
                                itemCount: surveys.length,
                                separatorBuilder: (context, index) => SizedBox(
                                  height: context.responsive(
                                    12.h,
                                    tablet: 16.h,
                                    desktop: 20.h,
                                  ),
                                ),
                                itemBuilder: (context, index) {
                                  return TweenAnimationBuilder<double>(
                                    key: ValueKey(surveys[index].id),
                                    duration: Duration(
                                      milliseconds:
                                          500 + (index * 50).clamp(0, 500),
                                    ),
                                    curve: Curves.easeOutBack,
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    builder: (context, value, child) {
                                      return Opacity(
                                        opacity: value.clamp(0.0, 1.0),
                                        child: Transform.translate(
                                          offset: Offset(0, 50 * (1 - value)),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: AssignmentCard(
                                      survey: surveys[index],
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                  if (_isSearchFocused &&
                      state.recentSearches.isNotEmpty &&
                      _searchController.text.isEmpty)
                    _buildSearchHistory(context, state),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context, AssignmentsListLoaded state) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w,
        16.h + MediaQuery.of(context).padding.top,
        16.w,
        16.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).available_surveys,
            style: TextStyle(
              fontSize: context.adaptiveFont(16.sp),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: _onSearchChanged,
            onSubmitted: (v) {
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              context.read<AssignmentsListBloc>().add(SearchAssignments(v));
              context.read<AssignmentsListBloc>().add(AddToHistory(v));
            },
            decoration: InputDecoration(
              hintText: S.of(context).search,
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.primary,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _searchController.clear();
                        context.read<AssignmentsListBloc>().add(
                          SearchAssignments(''),
                        );
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.background,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHistory(
    BuildContext context,
    AssignmentsListLoaded state,
  ) {
    return Positioned(
      top:
          100.h +
          MediaQuery.of(context).padding.top, // Adjust based on header height
      left: 16.w,
      right: 16.w,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16.r),
        color: Colors.white,
        child: Container(
          constraints: BoxConstraints(maxHeight: 300.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 8.w, 4.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      S.of(context).recent_searches,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.read<AssignmentsListBloc>().add(
                        ClearSearchHistory(),
                      ),
                      child: Text(
                        S.of(context).clear_all,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: state.recentSearches.length,
                  itemBuilder: (context, index) {
                    final query = state.recentSearches[index];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.history_rounded, size: 18),
                      title: Text(query, style: TextStyle(fontSize: 13.sp)),
                      onTap: () {
                        _searchController.text = query;
                        _searchFocusNode.unfocus();
                        context.read<AssignmentsListBloc>().add(
                          SearchAssignments(query),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
