import 'dart:math';
import 'package:flokk/_internal/components/one_line_text.dart';
import 'package:flokk/_internal/utils/string_utils.dart';
import 'package:flokk/_internal/utils/utils.dart';
import 'package:flokk/app_extensions.dart';
import 'package:flokk/styled_components/buttons/base_styled_button.dart';
import 'package:flokk/styled_components/styled_icons.dart';
import 'package:flokk/styled_components/styled_image_icon.dart';
import 'package:flokk/styled_components/styled_text_input.dart';
import 'package:flokk/styles.dart';
import 'package:flokk/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class StyledAutoCompleteDropdown extends StatefulWidget {
  final String? initialValue;
  final String hint;
  final List<String> items;
  final double maxHeight;
  final void Function(String)? onChanged;
  final void Function(bool)? onFocusChanged;

  const StyledAutoCompleteDropdown(
      {Key? key, this.initialValue, this.hint = "", this.items = const<String>[], this.onChanged, this.onFocusChanged, this.maxHeight = 500})
      : super(key: key);

  @override
  _StyledAutoCompleteDropdownState createState() => _StyledAutoCompleteDropdownState();
}

class _StyledAutoCompleteDropdownState extends State<StyledAutoCompleteDropdown> {
  bool _isOpen = false;
  OverlayEntry? _overlay;
  late ValueNotifier<List<String>> _itemsFiltered;
  late TextEditingController _textController;
  FocusNode? _textFocusNode;
  late FocusScopeNode _dropDownFocusNode;
  LayerLink layerLink = LayerLink();
  bool _skipNextFocusOut = false;

  String get currentText => _textController.text;

  @override
  void initState() {
    RawKeyboard.instance.addListener(_handleRawKeyPressed);
    _itemsFiltered = ValueNotifier(widget.items);
    _textController = TextEditingController(text: widget.initialValue);
    _dropDownFocusNode = FocusScopeNode();
    _dropDownFocusNode.addListener(handleDropdownFocusChanged);
    super.initState();
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleRawKeyPressed);
    // TODO: These dispose calls seem to break the contact edit menu
    //_itemsFiltered.dispose();
    //_textController.dispose();
    //_dropDownFocusNode.dispose();
    super.dispose();
  }

  void _updateFilteredItems() {
    _itemsFiltered.value = widget.items.where((i) => i.contains(currentText.toUpperCase())).toList();
  }

  void _handleArrowTap() {
    if (!_isOpen) {
      showOverlay();
      _textFocusNode?.requestFocus();
    } else {
      showOverlay(false);
      Utils.unFocus();
    }
  }

  void _handleRawKeyPressed(RawKeyEvent evt) {
    if (evt is RawKeyDownEvent) {
      if ((_textFocusNode?.hasFocus ?? false) && evt.logicalKey == LogicalKeyboardKey.arrowDown) {
        _skipNextFocusOut = true;
        Future.microtask(() => _dropDownFocusNode.requestFocus());
      }
      if (_dropDownFocusNode.hasFocus &&
          (evt.logicalKey == LogicalKeyboardKey.arrowRight || evt.logicalKey == LogicalKeyboardKey.arrowLeft)) {
        _textFocusNode?.requestFocus();
      }
    }
  }

  void _handleFocusChanged(bool value) {
    if (_skipNextFocusOut && !value) {
      _skipNextFocusOut = false;
      return;
    }
    showOverlay(value);
    widget.onFocusChanged?.call(value);
  }

  _handleFocusCreate(FocusNode focusNode) {
    _textFocusNode = focusNode;
  }

  void _handleValueChanged(String value) {
    _updateFilteredItems();
    widget.onChanged?.call(value);
    showOverlay();
  }

  void _handleItemSelected(String value) {
    _textController.text = value;
    _updateFilteredItems();
    widget.onChanged?.call(value);
    showOverlay(false);
    _textFocusNode?.requestFocus();
    //Utils.unFocus();
  }

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    bool downArrow = _itemsFiltered.value.isNotEmpty && _isOpen;

    /// Wrap the dropdown content in a [CompositedTransformTarget] so the Overlay can easily position itself here.
    return CompositedTransformTarget(
      link: layerLink,
      child: Stack(
        children: <Widget>[
          StyledFormTextInput(
              capitalization: TextCapitalization.words,
              contentPadding: EdgeInsets.only(right: 22, bottom: Insets.sm),
              controller: _textController,
              initialValue: widget.initialValue,
              hintText: widget.hint,
              maxLines: 1,
              textStyle: TextStyles.Body2,
              onFocusCreated: _handleFocusCreate,
              onFocusChanged: _handleFocusChanged,
              onChanged: _handleValueChanged),
          StyledImageIcon(StyledIcons.dropdownClose, size: 12, color: theme.greyStrong)
              .rotate(angle: downArrow ? 0 : pi, animate: true)
              .animate(Durations.fast, Curves.easeOut)
              .alignment(Alignment.topLeft)
              .gestures(onTap: _handleArrowTap)
              .positioned(right: 4, top: 4),
        ],
      ),
    );
  }

  void showOverlay([bool show = true]) {
    if (show && _overlay == null) {
      final overlay = OverlayEntry(builder: (_) => _AutoCompleteDropdown(this, focusNode: _dropDownFocusNode));
      _overlay = overlay;
      Overlay.of(context)?.insert(overlay);
    } else if (!show && _overlay != null) {
      _overlay?.remove();
      _overlay = null;
    }
    setState(() => _isOpen = show);
  }

  void handleDropdownFocusChanged() {
    if (!_dropDownFocusNode.hasFocus) {
      showOverlay(false);
    }
  }
}

class _AutoCompleteDropdown extends StatelessWidget {
  final _StyledAutoCompleteDropdownState state;
  final double rowHeight;
  final FocusScopeNode? focusNode;

  _AutoCompleteDropdown(this.state, {Key? key, this.focusNode, this.rowHeight = 40}) : super(key: key);

  List<String> get items => state.widget.items;

  List<String> get filteredItems => state._itemsFiltered.value;

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch();
    RenderBox? rb = state.context.findRenderObject() as RenderBox?;
    if (rb == null) return Container();
    Size size = rb.size;
    double longest = StringUtils.measureLongest(filteredItems, TextStyles.Caption, 50);
    longest += Insets.m * 2;
    double maxHeight = state.widget.maxHeight;

    /// Use [CompositedTransformFollower] to link the overlay position to the original content.
    /// Automatically updates when the window resizes or on scroll.
    return CompositedTransformFollower(
      showWhenUnlinked: false,

      /// Use a layerLink to connect to the CompositedTransformTarget
      link: state.layerLink,
      child: ValueListenableBuilder<List<String>>(
        valueListenable: state._itemsFiltered,
        builder: (_, matches, __) {
          return FocusScope(
            node: focusNode,
            child: Stack(
              children: <Widget>[
                ListView.builder(
                  itemExtent: rowHeight,
                  itemCount: matches.length,
                  itemBuilder: (_, index) {
                    return BaseStyledBtn(
                      contentPadding: EdgeInsets.symmetric(horizontal: Insets.m),
                      minHeight: rowHeight,
                      onPressed: () => state._handleItemSelected(matches[index]),
                      child: OneLineText(
                        "${matches[index].toUpperCase()}",
                        style: TextStyles.Caption.textColor(theme.greyWeak),
                      ).alignment(Alignment.centerLeft),
                    );
                  },
                )
                    .decorated(color: theme.surface, boxShadow: Shadows.m(theme.accent1))
                    .constrained(width: max(longest, size.width), height: min(matches.length * rowHeight, maxHeight))
                    .padding(top: 26)
                //.positioned(left: pos.dx, top: pos.dy)
              ],
            ),
          );
        },
      ),
    );
  }
}
