import 'package:flutter/material.dart';
import 'package:seizhtv/globals/data.dart';
import 'package:seizhtv/globals/data_cacher.dart';
import 'package:seizhtv/globals/loader.dart';
import 'package:seizhtv/globals/logo.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/models/m3u_user.dart';
import 'package:seizhtv/views/auth/children/provider_children/login.dart';
import 'package:seizhtv/views/auth/children/provider_children/register.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';

class ProviderLogin extends StatefulWidget {
  const ProviderLogin({super.key});

  @override
  State<ProviderLogin> createState() => _ProviderLoginState();
}

class _ProviderLoginState extends State<ProviderLogin>
    with ColorPalette, SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final DataCacher _cacher = DataCacher.instance;
  final ZM3UHandler _handler = ZM3UHandler.instance;
  bool _isLoading = false;
  String? label;
  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 2);
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController.dispose();
    super.dispose();
  }

  Future<void> download(String url) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      label = "Preparing download";
    });
    await _handler.network(url, (value) {
      print("DOWNLOAD : $value%");
      label = "Downloading ${value.ceil()}%";
      if (mounted) setState(() {});
    }, onExtractionCallback: (x) {
      label = "Extracting data ${x.ceil()}%";
      if (mounted) setState(() {});
    }, onFinished: () {
      _isLoading = false;
      if (mounted) setState(() {});
    }).then((value) async {
      if (value != null) {
        await Navigator.pushReplacementNamed(context, "/landing-page");
      }
    });
    _isLoading = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async => !_isLoading,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Scaffold(
              body: Container(
                decoration: BoxDecoration(
                  gradient: gradient,
                ),
                child: Column(
                  children: [
                    PreferredSize(
                      preferredSize: const Size.fromHeight(60),
                      child: AppBar(
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        leadingWidth: 30,
                        title: const Text("Back"),
                        titleTextStyle: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    const Hero(
                      tag: "auth-logo",
                      child: LogoSVG(
                        bottomText: "Login with provider",
                      ),
                    ),
                    Expanded(
                        child: Column(
                      children: [
                        TabBar(
                          controller: _tabController,
                          labelColor: Colors.white,
                          indicatorColor: orange,
                          tabs: [
                            Tab(
                              text: "Login".toUpperCase(),
                            ),
                            Tab(
                              text: "Register".toUpperCase(),
                            )
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              LoginProvider(
                                loadingCallback: (bool b) {
                                  _isLoading = b;
                                  if (mounted) setState(() {});
                                },
                                userCallback: (CredentialProvider u) async {
                                  _isLoading = true;
                                  if (mounted) setState(() {});
                                  refId = u.user.uid;
                                  user = M3uUser.fromProvider(u);
                                  _cacher.savePlaylistName("Firebase M3U");
                                  _cacher.saveRefID(refId!);
                                  _cacher.saveM3uUser(user!);
                                  await download(u.url)
                                      .onError((error, stackTrace) {
                                    _cacher.clearData();
                                  });
                                },
                              ),
                              RegisterProvider(
                                loadingCallback: (bool b) {
                                  _isLoading = b;
                                  if (mounted) setState(() {});
                                },
                                userCallback: (CredentialProvider u) async {
                                  _isLoading = true;
                                  if (mounted) setState(() {});
                                  refId = u.user.uid;
                                  user = M3uUser.fromProvider(u);
                                  _cacher.savePlaylistName("Firebase M3U");
                                  _cacher.saveRefID(refId!);
                                  _cacher.saveM3uUser(user!);
                                  await download(u.url)
                                      .onError((error, stackTrace) {
                                    _cacher.clearData();
                                  });
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    )),
                  ],
                ),
                // child: ListView(
                //   children: [
                // PreferredSize(
                //   preferredSize: const Size.fromHeight(60),
                //   child: AppBar(
                //     elevation: 0,
                //     backgroundColor: Colors.transparent,
                //     leadingWidth: 30,
                //     title: const Text("Back"),
                //     titleTextStyle: const TextStyle(
                //       fontSize: 15,
                //     ),
                //   ),
                // ),
                // const SizedBox(
                //   height: 50,
                // ),
                // const Hero(
                //   tag: "auth-logo",
                //   child: LogoSVG(
                //     bottomText: "Login with provider",
                //   ),
                // ),
                //   ],
                // ),
              ),
            ),
            if (_isLoading) ...{
              Positioned.fill(
                child: SeizhTvLoader(
                  label: label,
                  opacity: .7,
                ),
              )
            },
          ],
        ),
      ),
    );
  }
}
