// ignore_for_file: deprecated_member_use, unnecessary_null_comparison

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhtv/globals/data.dart';
import 'package:seizhtv/globals/data_cacher.dart';
import 'package:seizhtv/globals/loader.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/globals/ui_additional.dart';
import 'package:seizhtv/models/option.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import 'profile_children/general_setting.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with ColorPalette, UIAdditional {
  final M3uFirebaseAuthService _auth = M3uFirebaseAuthService.instance;
  static final DataCacher _cacher = DataCacher.instance;
  bool _isLoading = false;
  String label = "";

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: black,
          appBar: AppBar(
            backgroundColor: card,
            elevation: 0,
            title: Text("Profile".tr()),
          ),
          body: ListView(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey),
                  ),
                ),
                width: double.infinity,
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: user?.photoUrl == null
                          ? Image.asset(
                              "assets/icons/default-picture.jpeg",
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              imageUrl: user!.photoUrl!,
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user != null
                              ? user!.displayName ?? refId ?? "Unknown"
                              : refId ?? "Unknown"),
                          // Container(
                          //   margin: const EdgeInsets.all(3),
                          //   height: 25,
                          //   width: 45,
                          //   child: MaterialButton(
                          //     padding: const EdgeInsets.all(0),
                          //     color: orange,
                          //     onPressed: () {},
                          //     child: const Text(
                          //       "active",
                          //       style: TextStyle(fontSize: 12),
                          //     ),
                          //   ),
                          // ),
                          // const Text("Exp. Date :  "),
                          // $expDate
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              options(
                childrenData: [
                  Option(
                    icon: "assets/icons/settings.svg",
                    title: "General_Setting".tr(),
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageTransition(
                          child: const GeneralSettingPage(),
                          type: PageTransitionType.rightToLeft,
                        ),
                      );
                    },
                  ),

                  Option(
                    icon: "assets/icons/delete.svg",
                    title: "Account_Deletion".tr(),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Account deletion"),
                            content: const Text(
                                "Are you sure you want to delete your account?"),
                            actions: [
                              TextButton(
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(color: orange),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text(
                                  "Yes",
                                  style: TextStyle(color: orange),
                                ),
                                onPressed: () async {
                                  setState(() {
                                    _isLoading = true;
                                    label = "Deleting account";
                                  });
                                  final User tempUser =
                                      FirebaseAuth.instance.currentUser!;
                                  print("CURRENT USER: $tempUser");

                                  await _cacher.clearData();
                                  await _auth
                                      .deleteAccount(current: tempUser)
                                      .then((value) async {
                                    if (value == true) {
                                      await Navigator.pushReplacementNamed(
                                          context, "/auth");
                                    }
                                  }).whenComplete(() {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  });

                                  // if (tempUser == null) {
                                  //   // check an loginType
                                  //   final User? u;
                                  //   // if (_cacher.savedLoginType == 1) {
                                  //   //   u = await _google.signIn();
                                  //   // } else {
                                  //   final credential = await FirebaseAuth
                                  //       .instance
                                  //       .signInWithEmailAndPassword(
                                  //           email: _cacher.m3uUser!.email
                                  //               .toString(),
                                  //           password:
                                  //               _cacher.password.toString());
                                  //   u = credential.user;
                                  //   // await loginWithCredentials(
                                  //   //     email: asdada, password: password);
                                  //   // }
                                  //   await _cacher.clearData();
                                  //   await _auth
                                  //       .deleteAccount(current: u)
                                  //       .then((value) async {
                                  //     if (value == true) {
                                  //       await Navigator.pushReplacementNamed(
                                  //           context, "/auth");
                                  //     }
                                  //   });
                                  //   return;
                                  // }
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  // Option(
                  //   icon: "assets/icons/records.svg",
                  //   title: "Records",
                  //   onPressed: () {
                  //     Navigator.push(
                  //   context,
                  //   PageTransition(
                  //     child: const GeneralSettingPage(),
                  //     type: PageTransitionType.rightToLeft,
                  //   ),
                  // );
                  //   },
                  // ),
                  // Option(
                  //   icon: "assets/icons/epg.svg",
                  //   title: "EPG",
                  //   onPressed: () async {
                  //     // Navigator.push(
                  //     //   context,
                  //     //   PageTransition(
                  //     //     child: const GeneralSettingPage(),
                  //     //     type: PageTransitionType.rightToLeft,
                  //     //   ),
                  //     // );
                  //   },
                  // ),
                  // Option(
                  //   icon: "assets/icons/parental-control.svg",
                  //   title: "Parental_Control".tr(),
                  //   onPressed: () {
                  //     Navigator.push(
                  //       context,
                  //       PageTransition(
                  //         child: const ParentalControlPage(),
                  //         type: PageTransitionType.rightToLeft,
                  //       ),
                  //     );
                  //   },
                  // ),
                  // Option(
                  //   icon: "assets/icons/player.svg",
                  //   title: "Player".tr(),
                  //   onPressed: () {
                  //     // Navigator.push(
                  //     //   context,
                  //     //   PageTransition(
                  //     //     child: const GeneralSettingPage(),
                  //     //     type: PageTransitionType.rightToLeft,
                  //     //   ),
                  //     // );
                  //   },
                  // ),
                  // Option(
                  //   icon: "assets/icons/speedtest.svg",
                  //   title: "Speed Test",
                  //   onPressed: () {
                  //     Navigator.push(
                  //   context,
                  //   PageTransition(
                  //     child: const GeneralSettingPage(),
                  //     type: PageTransitionType.rightToLeft,
                  //   ),
                  // );
                  //   },
                  // ),
                  // Option(
                  //   icon: "assets/icons/vpn.svg",
                  //   title: "VPN",
                  //   onPressed: () {
                  //     Navigator.push(
                  //   context,
                  //   PageTransition(
                  //     child: const GeneralSettingPage(),
                  //     type: PageTransitionType.rightToLeft,
                  //   ),
                  // );
                  //   },
                  // ),
                  // Option(
                  //   icon: "assets/icons/termcondition.svg",
                  //   title: "Terms_&_Conditions".tr(),
                  //   onPressed: () {
                  //     // Navigator.push(
                  //     //   context,
                  //     //   PageTransition(
                  //     //     child: const GeneralSettingPage(),
                  //     //     type: PageTransitionType.rightToLeft,
                  //     //   ),
                  //     // );
                  //   },
                  // ),
                ],
              ),
              SafeArea(
                child: MaterialButton(
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                      label = "Logging out";
                    });
                    await _cacher.clearData();
                    await Navigator.pushReplacementNamed(context, "/auth");
                  },
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        "assets/icons/logout.svg",
                        color: orange,
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 15),
                      Text(
                        "Logout".tr(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: orange,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        if (_isLoading) ...{
          Positioned.fill(
            child: SeizhTvLoader(
              label: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              opacity: .7,
            ),
          )
        },
      ],
    );
  }
}
