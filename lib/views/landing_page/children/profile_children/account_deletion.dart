import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../globals/palette.dart';

class AccountDeletionPage extends StatefulWidget {
  const AccountDeletionPage({super.key});

  @override
  State<AccountDeletionPage> createState() => _AccountDeletionPageState();
}

class _AccountDeletionPageState extends State<AccountDeletionPage>
    with ColorPalette {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      appBar: AppBar(
        backgroundColor: card,
        elevation: 0,
        title: Text("Account_Deletion".tr()),
        centerTitle: false,
      ),
    );
  }
}
