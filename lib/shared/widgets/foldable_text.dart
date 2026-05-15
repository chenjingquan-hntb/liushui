import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class FoldableText extends StatefulWidget {
  final String text;
  final int maxLines;
  final TextStyle? style;

  const FoldableText({
    super.key,
    required this.text,
    this.maxLines = AppConstants.maxFoldLines,
    this.style,
  });

  @override
  State<FoldableText> createState() => _FoldableTextState();
}

class _FoldableTextState extends State<FoldableText> {
  bool _expanded = false;
  bool _isOverflow = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_expanded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.text, style: widget.style),
          TextButton(
            onPressed: () => setState(() => _expanded = false),
            child: const Text('收起'),
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: widget.text, style: widget.style);
        final tp = TextPainter(
          text: span,
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final overflow = tp.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.text,
              style: widget.style,
              maxLines: widget.maxLines,
              overflow: TextOverflow.ellipsis,
            ),
            if (overflow)
              TextButton(
                onPressed: () => setState(() => _expanded = true),
                child: const Text('展开全部'),
              ),
          ],
        );
      },
    );
  }
}
