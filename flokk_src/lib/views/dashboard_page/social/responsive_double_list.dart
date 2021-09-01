import 'package:flokk/_internal/components/spacing.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/styled_components/scrolling/styled_listview.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/views/dashboard_page/social/tabbed_list_view.dart';
import 'package:flokk/views/empty_states/placeholder_content_switcher.dart';
import 'package:flutter/material.dart';

/// This Widget displays 2 lists in either a dual-column mode or a combined tabbed-view
class ResponsiveDoubleList extends StatefulWidget {
  final bool useTabView;

  final List<Widget> list1;
  final String list1Title;

  final List<Widget> list2;
  final String list2Title;

  final Widget list1Placeholder;
  final Widget list2Placeholder;

  final AssetImage list1Icon;
  final AssetImage list2Icon;

  const ResponsiveDoubleList(
      {Key? key,
      required this.list1,
      required this.list2,
      required this.list1Title,
      required this.list2Title,
      required this.list1Placeholder,
      required this.list2Placeholder,
      required this.useTabView,
      required this.list1Icon,
      required this.list2Icon})
      : super(key: key);

  @override
  _ResponsiveDoubleListState createState() => _ResponsiveDoubleListState();
}

class _ResponsiveDoubleListState extends State<ResponsiveDoubleList> {
  int _selectedTabIndex = 0;

  void _handleSocialTabPressed(int index) {
    print(index);
    setState(() => _selectedTabIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useTabView) {
      return TabbedListView(
        index: _selectedTabIndex,
        onTabPressed: _handleSocialTabPressed,
        list1: widget.list1,
        list1Placeholder: widget.list1Placeholder,
        list1Title: widget.list1Title,
        list1Icon: widget.list1Icon,
        list2: widget.list2,
        list2Placeholder: widget.list2Placeholder,
        list2Title: widget.list2Title,
        list2Icon: widget.list2Icon,
      );
    } else {
      return Row(
        children: [
          PlaceholderContentSwitcher(
            hasContent: () => widget.list1.isNotEmpty,
            placeholder: widget.list1Placeholder,
            content: StyledListViewWithTitle(
                listItems: widget.list1,
                title: widget.list1Title,
                icon: widget.list1Icon),
          ).flexible(),
          HSpace(Insets.l),
          PlaceholderContentSwitcher(
            hasContent: () => widget.list2.isNotEmpty,
            placeholder: widget.list2Placeholder,
            content: StyledListViewWithTitle(
                listItems: widget.list2,
                title: widget.list2Title,
                icon: widget.list2Icon),
          ).flexible(),
        ],
      );
    }
  }
}
