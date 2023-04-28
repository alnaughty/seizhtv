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
import 'package:seizhtv/models/m3u_user.dart';
import 'package:seizhtv/services/google_sign_in.dart';
import 'package:seizhtv/views/landing_page/source_management.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';

import 'login.dart';

class MainRegisterPage extends StatefulWidget {
  const MainRegisterPage({super.key});

  @override
  State<MainRegisterPage> createState() => _MainRegisterPageState();
}

class _MainRegisterPageState extends State<MainRegisterPage>
    with UIAdditional, ColorPalette {
  final GlobalKey<FormState> _kForm = GlobalKey<FormState>();
  final M3uFirebaseAuthService _auth = M3uFirebaseAuthService.instance;
  final GoogleSignInService _google = GoogleSignInService.instance;
  final DataCacher _cacher = DataCacher.instance;
  late final TextEditingController _email, _password;
  @override
  void initState() {
    // TODO: implement initState
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
                      bottomText: "Register with Us",
                    ),
                  ),
                  Form(
                    key: _kForm,
                    child: Column(
                      children: [
                        LabeledTextField(
                          controller: _email,
                          label: "Email",
                          hinttext: "Email",
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
                            .register(_email.text, _password.text, "")
                            .then((u) async {
                          if (u != null) {
                            refId = u.user.uid;
                            user = M3uUser.fromProvider(u);
                            print("${user}");
                            _cacher.saveRefID(refId!);
                            _cacher.saveM3uUser(user!);
                            _cacher.saveLoginType(0);
                            print("USER : $user");
                            await Navigator.pushReplacement(
                              context,
                              PageTransition(
                                child: const LoginPage(),
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
                      child: Text("Register".toUpperCase()),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text.rich(
                    TextSpan(
                      text: "Already have an account? ",
                      children: [
                        TextSpan(
                          text: "Login",
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.of(context).pop();
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
                        print("USER : $user");
                        await Navigator.pushReplacement(
                          context,
                          PageTransition(
                            child: const LoginPage(),
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
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
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
