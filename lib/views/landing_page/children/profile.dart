import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seizhtv/globals/data.dart';
import 'package:seizhtv/globals/data_cacher.dart';
import 'package:seizhtv/globals/loader.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/globals/ui_additional.dart';
import 'package:seizhtv/models/option.dart';
import 'package:seizhtv/views/landing_page/source_management.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with ColorPalette, UIAdditional {
  static final DataCacher _cacher = DataCacher.instance;
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: black,
          appBar: AppBar(
            backgroundColor: card,
            elevation: 0,
            title: const Text("Profile"),
          ),
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey),
                  ),
                ),
                // height: 100,
                width: double.infinity,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
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
                    const SizedBox(
                      width: 10,
                    ),
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
                          const Text("Exp. Date : Nov. 12, 2022"),
                          // Text("Exp. Date : Nov. 12, 2022")
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
                    title: "General Setting",
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const GeneralSettingPage(),
                      //   ),
                      // );
                    },
                  ),
                  Option(
                    icon: "assets/icons/records.svg",
                    title: "Records",
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const RecordPage(),
                      //   ),
                      // );
                    },
                  ),
                  Option(
                    icon: "assets/icons/epg.svg",
                    title: "EPG",
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        PageTransition(
                          child: const SourceManagementPage(
                            fromInit: false,
                          ),
                          type: PageTransitionType.leftToRight,
                        ),
                      );
                    },
                  ),
                  Option(
                    icon: "assets/icons/parental-control.svg",
                    title: "Parental Control",
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const ParentalControlPage(),
                      //   ),
                      // );
                    },
                  ),
                  Option(
                    icon: "assets/icons/player.svg",
                    title: "Player",
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const PlayerPage(),
                      //   ),
                      // );
                    },
                  ),
                  Option(
                    icon: "assets/icons/speedtest.svg",
                    title: "Speed Test",
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const SpeedTestPage(),
                      //   ),
                      // );
                    },
                  ),
                  Option(
                    icon: "assets/icons/vpn.svg",
                    title: "VPN",
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const VPNPage(),
                      //   ),
                      // );
                    },
                  ),
                  Option(
                    icon: "assets/icons/termcondition.svg",
                    title: "Terms & Conditions",
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const TermsConditionPage(),
                      //   ),
                      // );
                    },
                  ),
                ],
              ),
              SafeArea(
                child: MaterialButton(
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    await _cacher.clearData();
                    // ignore: use_build_context_synchronously
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
                        "Logout",
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
          const Positioned.fill(
            child: SeizhTvLoader(
              label: "Logging out",
              opacity: .7,
            ),
          )
        },
      ],
    );
  }
}
