import 'package:flutter/material.dart';

class MouseAndPointerBlocker extends StatelessWidget {
  final Widget? child;
  final bool isEnabled;

  const MouseAndPointerBlocker({Key? key, this.child, this.isEnabled = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //if(!isEnabled) return child;
    return IgnorePointer(
      ignoring: !isEnabled,
      child: RawMaterialButton(
        padding: EdgeInsets.zero,
        onPressed: null,
        child: child,
      ),
    );
  }
}
