import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:seizhtv/extensions/string.dart';
import 'package:seizhtv/globals/labeled_textfield.dart';
import 'package:seizhtv/globals/palette.dart';

class LoginProvider extends StatefulWidget {
  const LoginProvider({super.key});

  @override
  State<LoginProvider> createState() => _LoginProviderState();
}

class _LoginProviderState extends State<LoginProvider> with ColorPalette {
  final GlobalKey<FormState> _kForm = GlobalKey<FormState>();
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          Form(
            key: _kForm,
            child: Column(
              children: [
                LabeledTextField(
                  controller: _email,
                  label: "Email",
                  hinttext: "example@email.com",
                  validator: (text) {
                    if (text == null) {
                      return "Unprocessable";
                    } else if (text.isEmpty) {
                      return "Field is required";
                    } else if (!text.isValidEmail) {
                      return "Field must contain a valid email";
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
          SizedBox(
            width: double.infinity,
            height: 50,
            child: MaterialButton(
              color: orange,
              onPressed: () async {
                FocusScope.of(context).unfocus();
              },
              child: Text(
                "LOGIN",
                style: TextStyle(color: ColorPalette().white),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
