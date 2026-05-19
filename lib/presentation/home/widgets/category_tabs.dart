import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CategoryTabsWidget extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const CategoryTabsWidget({
    Key? key,
    required this.selectedIndex,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  State<CategoryTabsWidget> createState() => _CategoryTabsWidgetState();
}

class _CategoryTabsWidgetState extends State<CategoryTabsWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = const ["All", "Music", "Podcasts", "Artists", "Playlists"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: widget.selectedIndex,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        widget.onTabSelected(_tabController.index);
      }
    });
  }

  @override
  void didUpdateWidget(CategoryTabsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != _tabController.index) {
      _tabController.animateTo(widget.selectedIndex);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          indicatorPadding: EdgeInsets.zero,
          labelPadding: const EdgeInsets.symmetric(horizontal: 6), // 12px gap between tabs
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          labelColor: Colors.black,
          unselectedLabelColor: AppColors.primaryText,
          labelStyle: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
          ),
          onTap: (index) {
             widget.onTabSelected(index);
          },
          tabs: _tabs.map((tab) => Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            child: Text(tab),
          )).toList(),
        ),
      ),
    );
  }
}
