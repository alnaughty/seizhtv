// ignore_for_file: avoid_print, implementation_imports, no_leading_underscores_for_local_identifiers

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhtv/globals/ui_additional.dart';
import 'package:seizhtv/views/auth/main_auth.dart';
import 'package:z_m3u_handler/src/firebase/firestore_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../../globals/data.dart';
import '../../globals/data_cacher.dart';
import '../../globals/device_info.dart';
import '../../globals/loader.dart';
import '../../globals/logo.dart';
import '../../models/source.dart';
import '../landing_page/source_management.dart';
import 'children/load_playlist.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with MyDeviceInfo, ColorPalette, UIAdditional {
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey.shade800,
          body: Container(
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
                  child: LogoSVG(),
                ),
                const SizedBox(
                  height: 50,
                ),
                StreamBuilder(
                  stream: _service.getListener(
                      collection: "user-source", docId: refId!),
                  builder: (_, snapshot) {
                    if (snapshot.hasError || !snapshot.hasData) {
                      return Container();
                    }
                    if (snapshot.data!.data() == null) return Container();
                    final List<M3uSource> _sources =
                        ((snapshot.data!.data() as Map)['sources'] as List)
                            .map((e) => M3uSource.fromFirestore(e))
                            .toList();

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (_, i) {
                        final M3uSource _source = _sources[i];

                        return GestureDetector(
                          onTap: () async {
                            if (_source.isFile) {
                              _cacher.savePlaylistName(_source.name);
                              _cacher.saveExpDate(_source.expDate!.toString());

                              await onSuccess(
                                File(_source.source),
                              );
                            } else {
                              _cacher.saveExpDate(DateFormat('MMM. dd, yyyy')
                                  .format(_source.expDate!));
                              await download(_source);
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                              color: card,
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                title: Text(_source.name),
                                trailing: PopupMenuButton<String>(
                                  itemBuilder: (_) => [
                                    "Load Source",
                                    "Update Source",
                                    "Delete Source"
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

                                    if (value == "Load Source") {
                                      if (_source.isFile) {
                                        _cacher.savePlaylistName(_source.name);
                                        _cacher.saveExpDate(
                                            DateFormat('MMM. dd, yyyy')
                                                .format(_source.expDate!));
                                        await onSuccess(
                                          File(_source.source),
                                        );
                                      } else {
                                        await download(_source);
                                      }
                                    } else if (value == "Update Source") {
                                      Navigator.push(
                                        context,
                                        PageTransition(
                                          child: LoadWithPlaylist(
                                            isUpdate: true,
                                            data: _source,
                                          ),
                                          type: PageTransitionType.leftToRight,
                                        ),
                                      );
                                    } else {
                                      await _service.firestore
                                          .collection("user-source")
                                          .doc(refId)
                                          .set(
                                        {
                                          "sources": FieldValue.arrayRemove(
                                              [_source.toJson()])
                                        },
                                      );
                                    }
                                  },
                                  offset: const Offset(0, 30),
                                ),
                                subtitle: Text(
                                  _source.source,
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
                      itemCount: _sources.length,
                    );
                  },
                ),
                const SizedBox(height: 50),
                Column(
                  children: [
                    button2(
                      title: "Login with your account",
                      assetPath: "assets/icons/users.svg",
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          PageTransition(
                            child: const MainAuthPage(),
                            type: PageTransitionType.leftToRight,
                          ),
                        );
                      },
                      foregroundColor: Colors.black,
                    ),
                    const SizedBox(height: 10),
                    button2(
                      title: "Load your playlist (File/URL)",
                      assetPath: "assets/icons/folder.svg",
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          PageTransition(
                            child: LoadWithPlaylist(
                              isUpdate: false,
                              data: null,
                            ),
                            type: PageTransitionType.leftToRight,
                          ),
                        );
                      },
                      foregroundColor: Colors.black,
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 30),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'By using this application, you agree to the \n',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Terms & Conditions',
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              print('Terms & Conditions');
                            },
                          style: TextStyle(
                            height: 1.3,
                            color: ColorPalette().orange,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
    );
  }
}
