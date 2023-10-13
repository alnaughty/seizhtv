// ignore_for_file: avoid_print

import 'package:easy_localization/easy_localization.dart';
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
import 'package:seizhtv/views/auth/forgotpassword.dart';
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
                  const SizedBox(height: 50),
                  Hero(
                    tag: "auth-logo",
                    child: LogoSVG(
                      bottomText: "Login_your_account".tr(),
                    ),
                  ),
                  Form(
                    key: _kForm,
                    child: Column(
                      children: [
                        LabeledTextField(
                          controller: _email,
                          label: "Email".tr(),
                          hinttext: "Email".tr(),
                          validator: (text) {
                            if (text == null) {
                              return "Unprocessable";
                            } else if (text.isEmpty) {
                              return "Field is required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        LabeledTextField(
                          isPassword: true,
                          controller: _password,
                          label: "Password".tr(),
                          hinttext: "Password".tr(),
                          validator: (text) {
                            if (text == null) {
                              return "Unprocessable";
                            } else if (text.isEmpty) {
                              return "Field is required";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () async {
                      Navigator.push(
                        context,
                        PageTransition(
                          child: const ForgotPasswordPage(),
                          type: PageTransitionType.leftToRight,
                        ),
                      );
                    },
                    child: Text(
                      "Forget_Password".tr(),
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.end,
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
                            _cacher.savePassword(_password.text);
                            _cacher.saveRefID(refId!);
                            _cacher.saveM3uUser(user!);
                            _cacher.saveLoginType(0);
                            print("USER : $user");
                            print("REFID SA MAIN AUTH : $refId");
                            // if (sourceUrl != null) {
                            //   await Navigator.pushReplacementNamed(
                            //       context, "/landing-page");
                            //   return;
                            // } else {
                            //   await Navigator.push(
                            //     context,
                            //     PageTransition(
                            //       child: const SourceManagementPage(),
                            //       type: PageTransitionType.leftToRight,
                            //     ),
                            //   );
                            // }
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
                      child: Text("Login".tr().toUpperCase()),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text.rich(
                    TextSpan(
                      text: 'Dont_have_an_account_yet'.tr(),
                      children: [
                        TextSpan(
                          text: "Register".tr(),
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
                        _cacher.savePassword(_password.text);
                        _cacher.saveRefID(refId!);
                        _cacher.saveM3uUser(user!);
                        _cacher.saveLoginType(0);

                        await Navigator.push(
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
                        Text(
                          "Login_with_Google".tr(),
                          style: const TextStyle(
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
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 30),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'By_using_this_application_you_agree_to_the'.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                        children: <TextSpan>[
                          const TextSpan(text: "\n"),
                          TextSpan(
                            text: 'Terms_&_Conditions'.tr(),
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
