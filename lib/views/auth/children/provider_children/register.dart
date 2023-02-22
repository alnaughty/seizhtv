import 'package:flutter/material.dart';
import 'package:seizhtv/extensions/string.dart';
import 'package:seizhtv/globals/labeled_textfield.dart';
import 'package:seizhtv/globals/palette.dart';

class RegisterProvider extends StatefulWidget {
  const RegisterProvider({super.key});

  @override
  State<RegisterProvider> createState() => _RegisterProviderState();
}

class _RegisterProviderState extends State<RegisterProvider> with ColorPalette {
  final GlobalKey<FormState> _kForm = GlobalKey<FormState>();
  late final TextEditingController _email, _password, _url;
  @override
  void initState() {
    // TODO: implement initState
    _email = TextEditingController();
    _password = TextEditingController();
    _url = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _url.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
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
              const SizedBox(
                height: 10,
              ),
              LabeledTextField(
                controller: _url,
                label: "M3U URL",
                hinttext: "https://example.com",
                validator: (text) {
                  if (text == null) {
                    return "Unprocessable";
                  } else if (text.isEmpty) {
                    return "Field is required";
                  } else if (!text.isValidUrl) {
                    return "Field must contain a valid url";
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
              "REGISTER",
              style: TextStyle(color: ColorPalette().white),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
