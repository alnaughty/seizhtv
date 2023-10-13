import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class FavoriteIconButton extends StatefulWidget {
  const FavoriteIconButton({
    Key? key,
    required this.onPressedCallback,
    required this.initValue,
    this.iconSize = 30,
    this.showOutline = false,
    this.colorFixed = false,
    this.shadowColor = Colors.white,
  }) : super(key: key);
  final ValueChanged<bool> onPressedCallback;
  final bool initValue;
  final double iconSize;
  final bool colorFixed;
  final bool showOutline;
  final Color shadowColor;

  @override
  State<FavoriteIconButton> createState() => _FavoriteIconButtonState();
}

class _FavoriteIconButtonState extends State<FavoriteIconButton> {
  late final BehaviorSubject<bool> _status;

  late bool value = widget.initValue;
  @override
  void initState() {
    _status = BehaviorSubject<bool>()
      ..stream.debounceTime(const Duration(milliseconds: 600)).listen((event) {
        widget.onPressedCallback(event);
      });
    super.initState();
  }

  @override
  void dispose() {
    _status.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: SizedBox(
        child: Icon(
          value ? Icons.favorite : Icons.favorite_border,
          color: value ? Colors.red : Colors.white,
          shadows: widget.showOutline
              ? [Shadow(color: widget.shadowColor, blurRadius: 2)]
              : null,
          size: widget.iconSize,
        ),
      ),
      onTap: () {
        setState(() {
          value = !value;
        });
        _status.add(value);
        // article.isFavorite = !article.isFavorite;
        // setState(() {});
        // widget.onPressFav(!widget.isFavorite);
      },
    );
  }
}
