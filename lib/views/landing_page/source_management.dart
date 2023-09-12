// ignore_for_file: implementation_imports, avoid_print, unrelated_type_equality_checks

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhtv/globals/data.dart';
import 'package:seizhtv/globals/data_cacher.dart';
import 'package:seizhtv/globals/loader.dart';
import 'package:seizhtv/globals/logo.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/globals/ui_additional.dart';
import 'package:seizhtv/models/source.dart';
import 'package:seizhtv/views/auth/children/load_xtream_code.dart';
import 'package:z_m3u_handler/src/firebase/firestore_services.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../auth/children/load_playlist.dart';

class SourceManagementPage extends StatefulWidget {
  const SourceManagementPage({super.key, this.fromInit = true});
  final bool fromInit;

  @override
  State<SourceManagementPage> createState() => _SourceManagementPageState();
}

class _SourceManagementPageState extends State<SourceManagementPage>
    with UIAdditional, ColorPalette {
  final M3uFirestoreServices _service = M3uFirestoreServices();
  final ZM3UHandler _handler = ZM3UHandler.instance;
  final DataCacher _cacher = DataCacher.instance;

  // Future<void> onSuccess(File? data) async {
  //   if (data == null) return;
  //   _isLoading = true;
  //   if (mounted) setState(() {});
  //   // await _cacher.saveFile(data);
  //   await _cacher.saveSource(data.toString());
  //   await _cacher.saveDate(DateTime.now().toString());
  //   await Navigator.pushReplacementNamed(context, "/landing-page");
  //   print(data);
  //   _isLoading = false;
  //   if (mounted) setState(() {});
  // }
  Future<void> onSuccess(File? data) async {
    if (data == null) return;
    _isLoading = true;
    if (mounted) setState(() {});
    await _cacher.saveFile(data);
    await _cacher.saveDate(DateTime.now().toString());
    print(data);
    await Navigator.pushReplacementNamed(context, "/landing-page");
    _isLoading = false;
    if (mounted) setState(() {});
  }

  bool _isLoading = false;
  Widget? label;
  download(M3uSource source) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      label = Text(
        "Preparing_download".tr(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      );
    });
    await _handler.network(source.source, progressCallback: (value) {
      label = RichText(
        text: TextSpan(
          text: 'Downloading'.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: "Poppins",
          ),
          children: [
            TextSpan(
              text: " ${value.ceil()}%",
            ),
          ],
        ),
      );
      if (mounted) setState(() {});
    }, onFinished: () {
      _isLoading = false;
      if (mounted) setState(() {});
    }).then((value) async {
      if (value == null) return;
      print("FILE IN DOWNLOAD: $value");
      _cacher.savePlaylistName(source.name);
      await _cacher.saveUrl(source.source);
      await onSuccess(value);
    }).onError((error, stackTrace) {
      _cacher.clearData();
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      body: Container(
        decoration: BoxDecoration(
          gradient: gradient,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 80,
                    ),
                    Hero(
                      tag: "auth-logo",
                      child: LogoSVG(
                        bottomText: "Manage_Sources".tr(),
                      ),
                    ),
                    StreamBuilder(
                        stream: _service.getListener(
                            collection: "user-source", docId: refId!),
                        builder: (_, snapshot) {
                          if (snapshot.hasError || !snapshot.hasData) {
                            return Container();
                          }
                          if (snapshot.data!.data() == null) return Container();
                          final List<M3uSource> sources =
                              ((snapshot.data!.data() as Map)['sources']
                                      as List)
                                  .map((e) => M3uSource.fromFirestore(e))
                                  .toList();

                          print("REFID: $refId");
                          print("SOURCE: $sources");
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (_, i) {
                              final M3uSource source = sources[i];
                              return GestureDetector(
                                onTap: () async {
                                  print("SOURCE: ${source.source}");
                                  if (source.isFile) {
                                    await onSuccess(File(source.source));
                                    await _cacher.savePlaylistName(source.name);
                                  } else {
                                    await download(source);
                                    await _cacher.savePlaylistName(source.name);
                                  }
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Container(
                                    color: card,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: ListTile(
                                      title: Text(source.name),
                                      trailing: PopupMenuButton<String>(
                                        itemBuilder: (
                                          _,
                                        ) =>
                                            [
                                          "Load_Source".tr(),
                                          "Update_source".tr(),
                                          "Delete_Source".tr()
                                        ]
                                                .map(
                                                  (e) => PopupMenuItem<String>(
                                                    value: e,
                                                    child: Text(e),
                                                  ),
                                                )
                                                .toList(),
                                        onSelected: (String? value) async {
                                          if (value == null) return;
                                          print(value);
                                          if (value == "Load_Source".tr()) {
                                            if (source.isFile) {
                                              _cacher.savePlaylistName(
                                                  source.name);
                                              await onSuccess(
                                                File(source.source),
                                              );
                                            } else {
                                              await download(source);
                                            }
                                          } else if (value ==
                                              "Update_source".tr()) {
                                            print("Update_source".tr());
                                            Navigator.push(
                                              context,
                                              PageTransition(
                                                child: LoadWithPlaylist(
                                                  isUpdate: true,
                                                  data: source,
                                                ),
                                                type: PageTransitionType
                                                    .leftToRight,
                                              ),
                                            );
                                          } else {
                                            await _service.firestore
                                                .collection("user-source")
                                                .doc(refId)
                                                .set(
                                              {
                                                "sources":
                                                    FieldValue.arrayRemove(
                                                        [source.toJson()])
                                              },
                                            );
                                          }
                                        },
                                        offset: const Offset(0, 30),
                                      ),
                                      subtitle: Text(
                                        source.source,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(60),
                                        child: user == null
                                            ? Image.asset(
                                                "assets/icons/default-picture.jpeg",
                                                height: 40,
                                                width: 40,
                                                fit: BoxFit.cover,
                                              )
                                            : user!.photoUrl == null
                                                ? Image.asset(
                                                    "assets/icons/default-picture.jpeg",
                                                    height: 40,
                                                    width: 40,
                                                    fit: BoxFit.cover,
                                                  )
                                                : CachedNetworkImage(
                                                    imageUrl: user!.photoUrl!,
                                                    height: 40,
                                                    width: 40,
                                                  ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            separatorBuilder: (_, i) => const SizedBox(
                              height: 10,
                            ),
                            itemCount: sources.length,
                          );
                        }),
                    const SizedBox(height: 50),
                    // LoadPlaylist(),
                    button2(
                      title: 'Load_your_source'.tr(),
                      assetPath: "assets/icons/users.svg",
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          PageTransition(
                            child: const XtreamCodePage(),
                            type: PageTransitionType.rightToLeft,
                          ),
                        );
                      },
                      foregroundColor: Colors.black,
                    ),
                    const SizedBox(height: 10),
                    button2(
                      title: 'Load_your_m3u'.tr(),
                      assetPath: "assets/icons/folder.svg",
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          PageTransition(
                            child: LoadWithPlaylist(
                              isUpdate: false,
                              data: null,
                            ),
                            type: PageTransitionType.rightToLeft,
                          ),
                        );
                      },
                      foregroundColor: Colors.black,
                    ),
                    // if (!widget.fromInit) ...{
                    // MaterialButton(
                    //   onPressed: () {
                    //     Navigator.of(context).pop();
                    //   },
                    //   height: 50,
                    //   color: white,
                    //   child: Center(
                    //     child: Text(
                    //       "Cancel".tr(),
                    //       style: const TextStyle(color: Colors.black),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 20),
                    // },
                    // Container(
                    //   margin: const EdgeInsets.symmetric(vertical: 30),
                    //   child: RichText(
                    //     textAlign: TextAlign.center,
                    //     text: TextSpan(
                    //       text:
                    //           'By using this application, you agree to the \n',
                    //       style: const TextStyle(
                    //         fontSize: 14,
                    //       ),
                    //       children: <TextSpan>[
                    //         TextSpan(
                    //           text: 'Terms & Conditions',
                    //           recognizer: TapGestureRecognizer()
                    //             ..onTap = () {
                    //               print('Terms & Conditions');
                    //             },
                    //           style: TextStyle(
                    //             height: 1.3,
                    //             color: ColorPalette().orange,
                    //             fontWeight: FontWeight.bold,
                    //             decoration: TextDecoration.underline,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
            if (_isLoading) ...{
              Positioned.fill(
                child: SeizhTvLoader(
                  label: label,
                ),
              )
            }
          ],
        ),
      ),
    );
  }
}
