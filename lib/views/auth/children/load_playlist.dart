// ignore_for_file: implementation_imports, avoid_print, must_be_immutable, unused_field

import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
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
      // refId = await getUniqueID();
      // await _cacher.saveRefID(refId!);
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
          fontFamily: "Poppins",
        ),
        textAlign: TextAlign.center,
      );
    });
    await _handler.network(source.source, progressCallback: (value) {
      label = RichText(
        textAlign: TextAlign.center,
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
                    Hero(
                      tag: "auth-logo",
                      child: Center(
                        child: LogoSVG(
                          bottomText: 'Load_your_m3u'.tr(),
                        ),
                      ),
                    ),
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
                      child: Center(
                        child: Text(
                          "Cancel".tr(),
                          style: const TextStyle(color: Colors.black),
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
