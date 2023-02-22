import 'package:flutter/material.dart';
import 'package:seizhtv/globals/logo.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/views/auth/children/provider_children/login.dart';
import 'package:seizhtv/views/auth/children/provider_children/register.dart';

class ProviderLogin extends StatefulWidget {
  const ProviderLogin({super.key});

  @override
  State<ProviderLogin> createState() => _ProviderLoginState();
}

class _ProviderLoginState extends State<ProviderLogin>
    with ColorPalette, SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 2);
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: gradient,
          ),
          child: Column(
            children: [
              PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  leadingWidth: 30,
                  title: const Text("Back"),
                  titleTextStyle: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              const Hero(
                tag: "auth-logo",
                child: LogoSVG(
                  bottomText: "Login with provider",
                ),
              ),
              Expanded(
                  child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    indicatorColor: orange,
                    tabs: [
                      Tab(
                        text: "Login".toUpperCase(),
                      ),
                      Tab(
                        text: "Register".toUpperCase(),
                      )
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: const [
                        LoginProvider(),
                        RegisterProvider(),
                      ],
                    ),
                  )
                ],
              )),
            ],
          ),
          // child: ListView(
          //   children: [
          // PreferredSize(
          //   preferredSize: const Size.fromHeight(60),
          //   child: AppBar(
          //     elevation: 0,
          //     backgroundColor: Colors.transparent,
          //     leadingWidth: 30,
          //     title: const Text("Back"),
          //     titleTextStyle: const TextStyle(
          //       fontSize: 15,
          //     ),
          //   ),
          // ),
          // const SizedBox(
          //   height: 50,
          // ),
          // const Hero(
          //   tag: "auth-logo",
          //   child: LogoSVG(
          //     bottomText: "Login with provider",
          //   ),
          // ),
          //   ],
          // ),
        ),
      ),
    );
  }
}
