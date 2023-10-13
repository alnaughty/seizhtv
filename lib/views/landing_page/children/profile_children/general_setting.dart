import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../globals/palette.dart';
import '../../../../models/language.dart';

class GeneralSettingPage extends StatefulWidget {
  const GeneralSettingPage({super.key});

  @override
  State<GeneralSettingPage> createState() => _GeneralSettingPageState();
}

class _GeneralSettingPageState extends State<GeneralSettingPage>
    with ColorPalette {
  Language? selectedLang;
  bool isLoading = false;

  List<Language> languageList = [
    Language(
      langName: 'English',
      locale: const Locale('en'),
    ),
    Language(
      langName: 'French',
      locale: const Locale('fr'),
    )
  ];

  @override
  Widget build(BuildContext context) {
    selectedLang = languageList.singleWhere((e) => e.locale == context.locale);
    return Stack(
      children: [
        Scaffold(
          backgroundColor: black,
          appBar: AppBar(
            backgroundColor: card,
            elevation: 0,
            title: Text("General_Setting".tr()),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select_your_preferred_language".tr(),
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 48,
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: Colors.transparent,
                  ),
                  child: DropdownButton<Language>(
                    isExpanded: false,
                    value: selectedLang,
                    elevation: 0,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                    underline: Container(color: Colors.transparent),
                    dropdownColor: card,
                    icon: Expanded(
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: const Icon(Icons.expand_more_sharp,
                            color: Colors.white),
                      ),
                    ),
                    items: languageList
                        .map<DropdownMenuItem<Language>>((Language value) {
                      return DropdownMenuItem<Language>(
                        value: value,
                        child: Text(value.langName),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedLang = newValue!;
                        if (newValue.langName == 'English') {
                          context.setLocale(const Locale('en'));
                          isLoading = true;
                          Future.delayed(
                            const Duration(seconds: 10),
                            () {
                              isLoading = false;
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/landing-page', (_) => false);
                            },
                          );
                        } else if (newValue.langName == 'French') {
                          context.setLocale(const Locale('fr'));
                          isLoading = true;
                          Future.delayed(
                            const Duration(seconds: 10),
                            () {
                              isLoading = false;
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/landing-page', (_) => false);
                            },
                          );
                        }
                      });
                    },
                  ),
                )
              ],
            ),
          ),
        ),
        isLoading
            ? Container(
                color: highlight.withOpacity(0.5),
                child: Center(
                  child: Image.asset(
                    "assets/images/transsplash.gif",
                    fit: BoxFit.fitWidth,
                  ),
                ),
              )
            : Container()
      ],
    );
  }
}
