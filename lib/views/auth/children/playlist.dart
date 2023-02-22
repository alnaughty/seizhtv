// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:seizhtv/data_containers/loaded_m3u_data.dart';
import 'package:seizhtv/extensions/string.dart';
import 'package:seizhtv/globals/data.dart';
import 'package:seizhtv/globals/data_cacher.dart';
import 'package:seizhtv/globals/device_info.dart';
import 'package:seizhtv/globals/labeled_textfield.dart';
import 'package:seizhtv/globals/loader.dart';
import 'package:seizhtv/globals/logo.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';

class LoadPlaylist extends StatefulWidget {
  const LoadPlaylist({super.key});

  @override
  State<LoadPlaylist> createState() => _LoadPlaylistState();
}

class _LoadPlaylistState extends State<LoadPlaylist>
    with ColorPalette, MyDeviceInfo {
  late final TextEditingController _name;
  late final TextEditingController _url;
  final GlobalKey<FormState> _kFormName = GlobalKey<FormState>();
  final GlobalKey<FormState> _kForm = GlobalKey<FormState>();
  final ZM3UHandler _handler = ZM3UHandler.instance;
  final DataCacher _cacher = DataCacher.instance;
  final LoadedM3uData _vm = LoadedM3uData.instance;

  int type = 0;
  bool _isLoading = false;
  File? file;
  @override
  void initState() {
    // TODO: implement initState
    _name = TextEditingController();
    _url = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _name.dispose();
    _url.dispose();
    super.dispose();
  }

  String? label;
  Future<void> onSuccess(CategorizedM3UData? data) async {
    if (data == null) return;
    _cacher.savePlaylistName(_name.text);
    refId = await getUniqueID();
    if (refId != null) {
      _cacher.saveRefID(refId!);
    }
    if (mounted) setState(() {});
    _vm.populate(data);
    Navigator.pushReplacementNamed(context, "/landing-page");
    print(data);
  }

  filePick() async {
    if (_kFormName.currentState!.validate()) {
      if (file != null) {
        setState(() {
          _isLoading = true;
          label = "Extracting data";
        });
        await _handler.file(
          file!,
          onFinished: () {
            print("FINISHED!");
            _isLoading = false;
            label = null;
            if (mounted) setState(() {});
          },
          extractionProgressCallback: (x) {
            label = "Extracting data ${x.ceil()}%";
            if (mounted) setState(() {});
          },
        ).then((value) async {
          await onSuccess(value);
        });
      } else {
        Fluttertoast.showToast(
          msg: "Please upload a file",
        );
      }
    }
  }

  download() async {
    FocusScope.of(context).unfocus();
    if (_kFormName.currentState!.validate() &&
        _kForm.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        label = "Preparing download";
      });
      print("PROCEED");
      await _handler.network(_url.text, (value) {
        print("DOWNLOAD : $value%");
        label = "Downloading ${value.ceil()}%";
        if (mounted) setState(() {});
      }, onExtractionCallback: (x) {
        label = "Extracting data ${x.ceil()}%";
        if (mounted) setState(() {});
      }, onFinished: () {
        _isLoading = false;
        if (mounted) setState(() {});
      }).then((value) async {
        await onSuccess(value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Scaffold(
            body: Container(
              height: size.height,
              decoration: BoxDecoration(
                gradient: gradient,
              ),
              child: SingleChildScrollView(
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
                      height: 90,
                    ),
                    const Hero(
                      tag: "auth-logo",
                      child: LogoSVG(
                        bottomText: "Load your Playlist (File/URL)",
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Form(
                              key: _kFormName,
                              child: LabeledTextField(
                                label: "Playlist Name",
                                hinttext: "Type your playlist name",
                                validator: (text) {
                                  if (text == null) {
                                    return "Initiation error";
                                  } else if (text.isEmpty) {
                                    return "Field must not be empty";
                                  }
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const Text(
                              "Playlist Type",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    child: Row(
                                      children: [
                                        Radio<int>(
                                          value: 0,
                                          groupValue: type,
                                          onChanged: (int? value) {
                                            if (value != null && mounted) {
                                              setState(() {
                                                type = value;
                                                file = null;
                                                _url.clear();
                                              });
                                            }
                                          },
                                        ),
                                        const Text("File")
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Radio<int>(
                                        value: 1,
                                        groupValue: type,
                                        onChanged: (int? value) {
                                          if (value != null && mounted) {
                                            setState(() {
                                              type = value;
                                              file = null;
                                              _url.clear();
                                            });
                                          }
                                        },
                                      ),
                                      const Text("M3U URL")
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Text(
                              type == 1 ? "URL" : "File",
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 400),
                              child: type == 1
                                  ? Form(
                                      key: _kForm,
                                      child: TextFormField(
                                        controller: _url,
                                        cursorColor: Colors.white,
                                        validator: (text) {
                                          if (text == null) {
                                            return "Unprocessable";
                                          } else if (text.isEmpty) {
                                            return "Field is required";
                                          } else if (!text.isValidUrl) {
                                            return "Field must contain a valid url";
                                          }
                                        },
                                        onEditingComplete: () async {
                                          await download();
                                        },
                                        decoration: InputDecoration(
                                          hintText: "https://example.com",
                                          hintStyle: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(.5)),
                                          border: const OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.white),
                                          ),
                                          focusedBorder:
                                              const OutlineInputBorder(
                                            borderSide:
                                                BorderSide(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 55,
                                          width: double.infinity,
                                          child: MaterialButton(
                                            onPressed: () async {
                                              print("PICK");
                                              try {
                                                await FilePicker.platform
                                                    .pickFiles(
                                                  allowMultiple: false,
                                                  type: FileType.custom,
                                                  allowedExtensions: ['m3u'],
                                                ).then((value) {
                                                  if (value == null) {
                                                    setState(() {
                                                      file = null;
                                                    });
                                                    return;
                                                  }
                                                  setState(() {
                                                    file = File(
                                                      value.files.single.path!,
                                                    );
                                                  });
                                                });
                                              } catch (e) {
                                                print("FILE PICK ERROR : $e");
                                              }
                                            },
                                            padding: EdgeInsets.zero,
                                            child: DottedBorder(
                                              dashPattern: const [5, 5],
                                              color:
                                                  Colors.white.withOpacity(.5),
                                              strokeWidth: 1,
                                              child: Center(
                                                  child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SvgPicture.asset(
                                                    "assets/icons/folder.svg",
                                                    height: 20,
                                                    width: 20,
                                                    color: ColorPalette().white,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  const Text("Browse")
                                                ],
                                              )),
                                            ),
                                          ),
                                        ),
                                        if (file != null) ...{
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            file!.path.split("/").last,
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withOpacity(.5),
                                              fontStyle: FontStyle.italic,
                                            ),
                                          )
                                        }
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
                                color: ColorPalette().orange,
                                onPressed: () async {
                                  FocusScope.of(context).unfocus();
                                  if (type == 1) {
                                    await download();
                                  } else {
                                    await filePick();
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.add),
                                    Text(
                                      "Add Source",
                                      style: TextStyle(
                                          color: ColorPalette().white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading) ...{
            Positioned.fill(
              child: SeizhTvLoader(
                label: label,
                opacity: .7,
              ),
            )
          },
        ],
      ),
    );
  }
}
