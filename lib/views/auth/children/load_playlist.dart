// ignore_for_file: implementation_imports, avoid_print, must_be_immutable, unused_field

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:seizhtv/globals/data.dart';
import 'package:seizhtv/globals/data_cacher.dart';
import 'package:seizhtv/globals/device_info.dart';
import 'package:seizhtv/globals/loader.dart';
import 'package:seizhtv/globals/logo.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/models/source.dart';
import 'package:seizhtv/views/auth/children/playlist.dart';
import 'package:z_m3u_handler/src/firebase/firestore_services.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';

class LoadWithPlaylist extends StatefulWidget {
  LoadWithPlaylist({super.key, required this.isUpdate, this.data});

  final bool isUpdate;
  M3uSource? data;

  @override
  State<LoadWithPlaylist> createState() => _LoadWithPlaylistState();
}

class _LoadWithPlaylistState extends State<LoadWithPlaylist>
    with MyDeviceInfo, ColorPalette {
  final M3uFirestoreServices _service = M3uFirestoreServices();
  final DataCacher _cacher = DataCacher.instance;
  final ZM3UHandler _handler = ZM3UHandler.instance;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      refId = await getUniqueID();
      await _cacher.saveRefID(refId!);
      if (mounted) setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> onSuccess(File? data) async {
    if (data == null) return;
    _isLoading = true;
    if (mounted) setState(() {});
    await _cacher.saveFile(data);
    await _cacher.saveDate(DateTime.now().toString());
    // ignore: use_build_context_synchronously
    await Navigator.pushReplacementNamed(context, "/landing-page");
    print(data);
    _isLoading = false;
    if (mounted) setState(() {});
  }

  bool _isLoading = false;
  String? label;
  download(M3uSource source) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      label = "Preparing download";
    });
    await _handler.network(source.source, progressCallback: (value) {
      label = "Downloading ${value.ceil()}%";
      if (mounted) setState(() {});
    }, onFinished: () {
      _isLoading = false;
      if (mounted) setState(() {});
    }).then((value) async {
      if (value == null) return;
      _cacher.savePlaylistName(source.name);
      await _cacher.saveUrl(source.source);
      await onSuccess(value);
    }).onError((error, stackTrace) {
      _cacher.clearData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey.shade800,
        body: refId == null
            ? const SeizhTvLoader(
                hasBackgroundColor: false,
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: gradient,
                ),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    const Hero(
                      tag: "auth-logo",
                      child: LogoSVG(
                        bottomText: "Load your Playlist(File/URL)",
                      ),
                    ),
                    // StreamBuilder(
                    //     stream: _service.getListener(
                    //         collection: "user-source", docId: refId!),
                    //     builder: (_, snapshot) {
                    //       if (snapshot.hasError || !snapshot.hasData) {
                    //         return Container();
                    //       }
                    //       if (snapshot.data!.data() == null)
                    //         return Container();
                    //       final List<M3uSource> _sources =
                    //           ((snapshot.data!.data() as Map)['sources']
                    //                   as List)
                    //               .map((e) => M3uSource.fromFirestore(e))
                    //               .toList();
                    //       return ListView.separated(
                    //         shrinkWrap: true,
                    //         physics: const NeverScrollableScrollPhysics(),
                    //         itemBuilder: (_, i) {
                    //           final M3uSource _source = _sources[i];
                    //           return ClipRRect(
                    //             borderRadius: BorderRadius.circular(5),
                    //             child: Container(
                    //               color: card,
                    //               padding:
                    //                   const EdgeInsets.symmetric(vertical: 5),
                    //               child: ListTile(
                    //                 title: Text(_source.name),
                    //                 trailing: PopupMenuButton<String>(
                    //                   itemBuilder: (
                    //                     _,
                    //                   ) =>
                    //                       ["Load Source", "Delete Source"]
                    //                           .map(
                    //                             (e) => PopupMenuItem<String>(
                    //                               value: e,
                    //                               child: Text(e),
                    //                             ),
                    //                           )
                    //                           .toList(),
                    //                   onSelected: (String? value) async {
                    //                     if (value == null) return;
                    //                     print(value);
                    //                     if (value == "Load Source") {
                    //                       if (_source.isFile) {
                    //                         _cacher.savePlaylistName(
                    //                             _source.name);
                    //                         await onSuccess(
                    //                           File(_source.source),
                    //                         );
                    //                       } else {
                    //                         await download(_source);
                    //                       }
                    //                     } else {
                    //                       await _service.firestore
                    //                           .collection("user-source")
                    //                           .doc(refId)
                    //                           .set(
                    //                         {
                    //                           "sources":
                    //                               FieldValue.arrayRemove(
                    //                                   [_source.toJson()])
                    //                         },
                    //                       );
                    //                     }
                    //                   },
                    //                   offset: const Offset(0, 30),
                    //                 ),
                    //                 subtitle: Text(
                    //                   _source.source,
                    //                   maxLines: 2,
                    //                   overflow: TextOverflow.ellipsis,
                    //                 ),
                    //                 leading: ClipRRect(
                    //                   borderRadius: BorderRadius.circular(60),
                    //                   child: user == null
                    //                       ? Image.asset(
                    //                           "assets/icons/default-picture.jpeg",
                    //                           height: 40,
                    //                           width: 40,
                    //                           fit: BoxFit.cover,
                    //                         )
                    //                       : user!.photoUrl == null
                    //                           ? Image.asset(
                    //                               "assets/icons/default-picture.jpeg",
                    //                               height: 40,
                    //                               width: 40,
                    //                               fit: BoxFit.cover,
                    //                             )
                    //                           : CachedNetworkImage(
                    //                               imageUrl: user!.photoUrl!,
                    //                               height: 40,
                    //                               width: 40,
                    //                             ),
                    //                 ),
                    //               ),
                    //             ),
                    //           );
                    //         },
                    //         separatorBuilder: (_, i) => const SizedBox(
                    //           height: 10,
                    //         ),
                    //         itemCount: _sources.length,
                    //       );
                    //     }),
                    LoadPlaylist(
                      isUpdate: widget.isUpdate,
                      data: widget.data,
                    ),
                    MaterialButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      height: 50,
                      color: Colors.white,
                      child: const Center(
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }
}
