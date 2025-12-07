import 'package:flutter/material.dart';

class KeepAliveWrapper extends StatefulWidget {
  final Widget child;

  const KeepAliveWrapper({
    super.key, 
    required this.child,
  });

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context); // valid usage for mixin
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
