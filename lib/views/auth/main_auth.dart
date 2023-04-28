import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhtv/globals/data.dart';
import 'package:seizhtv/globals/data_cacher.dart';
import 'package:seizhtv/globals/labeled_textfield.dart';
import 'package:seizhtv/globals/loader.dart';
import 'package:seizhtv/globals/logo.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/globals/ui_additional.dart';
import 'package:seizhtv/services/google_sign_in.dart';
import 'package:seizhtv/views/auth/children/load_playlist.dart';
import 'package:seizhtv/views/auth/register.dart';
import 'package:seizhtv/views/landing_page/source_management.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';

import '../../models/m3u_user.dart';

class MainAuthPage extends StatefulWidget {
  const MainAuthPage({super.key});

  @override
  State<MainAuthPage> createState() => _MainAuthPageState();
}

class _MainAuthPageState extends State<MainAuthPage>
    with UIAdditional, ColorPalette {
  final GlobalKey<FormState> _kForm = GlobalKey<FormState>();
  final M3uFirebaseAuthService _auth = M3uFirebaseAuthService.instance;
  final GoogleSignInService _google = GoogleSignInService.instance;
  final DataCacher _cacher = DataCacher.instance;
  late final TextEditingController _email, _password;
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
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
                    height: 80,
                  ),
                  const Hero(
                    tag: "auth-logo",
                    child: LogoSVG(
                      bottomText: "Login your account",
                    ),
                  ),
                  Form(
                    key: _kForm,
                    child: Column(
                      children: [
                        LabeledTextField(
                          controller: _email,
                          label: "Username",
                          hinttext: "Username",
                          validator: (text) {
                            if (text == null) {
                              return "Unprocessable";
                            } else if (text.isEmpty) {
                              return "Field is required";
                            }
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        LabeledTextField(
                          isPassword: true,
                          controller: _password,
                          label: "Password",
                          hinttext: "Password",
                          validator: (text) {
                            if (text == null) {
                              return "Unprocessable";
                            } else if (text.isEmpty) {
                              return "Field is required";
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  MaterialButton(
                    onPressed: () async {
                      FocusScope.of(context).unfocus();

                      if (_kForm.currentState!.validate()) {
                        _isLoading = true;
                        if (mounted) setState(() {});
                        await _auth
                            .login(_email.text, _password.text)
                            .then((u) async {
                          if (u != null) {
                            refId = u.user.uid;
                            user = M3uUser.fromProvider(u);
                            _cacher.saveRefID(refId!);
                            _cacher.saveM3uUser(user!);
                            _cacher.saveLoginType(0);
                            print("USER : $user");
                            await Navigator.pushReplacement(
                              context,
                              PageTransition(
                                child: const SourceManagementPage(),
                                type: PageTransitionType.leftToRight,
                              ),
                            );
                          }
                          _isLoading = false;
                          if (mounted) setState(() {});
                        }).onError((error, stackTrace) {
                          _isLoading = false;
                          if (mounted) setState(() {});
                        });
                      }
                    },
                    color: orange,
                    height: 55,
                    child: Center(
                      child: Text("Login".toUpperCase()),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text.rich(
                    TextSpan(
                      text: "Don't have an account yet? ",
                      children: [
                        TextSpan(
                          text: "Register",
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              await Navigator.push(
                                context,
                                PageTransition(
                                  child: const MainRegisterPage(),
                                  type: PageTransitionType.leftToRight,
                                ),
                              );
                            },
                          style: TextStyle(
                            color: orange,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1.5,
                          color: Colors.white.withOpacity(.3),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: const Text("OR"),
                      ),
                      Expanded(
                        child: Container(
                          height: 1.5,
                          color: Colors.white.withOpacity(.3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  MaterialButton(
                    onPressed: () async {
                      _isLoading = true;
                      if (mounted) setState(() {});
                      await _google.signOut();
                      await _google.signIn().then((u) async {
                        if (u == null) return;
                        refId = u.user.uid;
                        user = M3uUser.fromProvider(u);
                        _cacher.saveRefID(refId!);
                        _cacher.saveM3uUser(user!);
                        _cacher.saveLoginType(0);

                        await Navigator.pushReplacement(
                          context,
                          PageTransition(
                            child: const SourceManagementPage(),
                            type: PageTransitionType.leftToRight,
                          ),
                        );
                      }).whenComplete(() {
                        _isLoading = false;
                        if (mounted) setState(() {});
                      });
                    },
                    height: 50,
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/icons/2991148.png",
                          height: 30,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          "Login with Google",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
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
                    )),
                  ),
                  // button2(
                  //   title: "Load your playlist (File/URL)",
                  //   assetPath: "assets/icons/folder.svg",
                  //   onPressed: () async {
                  //     await Navigator.push(
                  //       context,
                  //       PageTransition(
                  //         child: const LoadWithPlaylist(),
                  //         type: PageTransitionType.leftToRight,
                  //       ),
                  //     );
                  //   },
                  //   foregroundColor: Colors.black,
                  // ),
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  // button2(
                  //   title: "Login with your MAC Address",
                  //   assetPath: "assets/icons/mac.svg",
                  //   onPressed: () async {
                  //     await Navigator.push(
                  //       context,
                  //       PageTransition(
                  //         child: const LoadWithMacAddress(),
                  //         type: PageTransitionType.leftToRight,
                  //       ),
                  //     );
                  //   },
                  //   foregroundColor: Colors.black,
                  // ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading) ...{
            const Positioned.fill(
              child: SeizhTvLoader(
                opacity: .7,
              ),
            )
          },
        ],
      ),
    );
  }
}
