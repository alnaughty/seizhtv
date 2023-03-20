import 'package:flutter/material.dart';
import 'package:seizhtv/data_containers/loaded_m3u_data.dart';
import 'package:seizhtv/extensions/list.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';

class SearchContentPage extends StatefulWidget {
  const SearchContentPage({super.key, required this.type});
  final int type;
  /*
    0||1 => live
    2 => movie
    3 => series
   */

  @override
  State<SearchContentPage> createState() => _SearchContentPageState();
}

class _SearchContentPageState extends State<SearchContentPage>
    with ColorPalette {
  final LoadedM3uData _vm = LoadedM3uData.instance;
  late final List<M3uEntry> _data;
  List<M3uEntry>? _displayData;
  List<M3uEntry> filter(CategorizedM3UData data) {
    switch (widget.type) {
      case 0:
      case 1:
        return data.live.expand((element) => element.data).toList().unique();
      case 2:
      case 3:
      default:
        return [];
    }
  }

  initStream() {
    _vm.stream.listen((event) {
      _data = filter(event);
      _displayData = List.from(_data);
      _displayData!.sort((a, b) => a.title.compareTo(b.title));
      print(_data);
      if (mounted) setState(() {});
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    initStream();
    // WidgetsBinding.instance.addPostFrameCallback((_) {

    // });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: card,
      body: Container(),
    );
  }
}
