import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:seizhtv/globals/data_cacher.dart';
import 'package:seizhtv/seizh_tv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final DataCacher _cacher = DataCacher.instance;
  await _cacher.init();
  await dotenv.load();
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('fr')],
      path: 'assets/lang', // <-- change the path of the translation files
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child: SeizhTv(),
    ),
  );
}
