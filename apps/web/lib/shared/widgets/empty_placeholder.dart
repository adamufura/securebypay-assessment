import 'package:flutter/material.dart';

/// Shared empty placeholder used when a feature widget folder needs a marker.
class EmptyPlaceholder extends StatelessWidget {
  const EmptyPlaceholder({super.key, this.message = 'Nothing here yet'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(message));
  }
}
