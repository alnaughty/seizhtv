// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:seizhtv/data_containers/loaded_m3u_data.dart';
import 'package:seizhtv/extensions/string.dart';
import 'package:seizhtv/globals/data.dart';
import 'package:seizhtv/globals/data_cacher.dart';
import 'package:seizhtv/globals/device_info.dart';
import 'package:seizhtv/globals/labeled_textfield.dart';
import 'package:seizhtv/globals/palette.dart';
import 'package:seizhtv/models/source.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import 'package:z_m3u_handler/src/firebase/firestore_services.dart';

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
  final M3uFirestoreServices _service = M3uFirestoreServices();

  int type = 0;
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

  filePick() async {
    if (_kFormName.currentState!.validate()) {
      // if (file != null) {
      //   setState(() {
      //     _isLoading = true;
      //     label = "Extracting data";
      //   });
      //   _cacher.saveFile(file!);
      //   onSuccess(file);
      // } else {
      //   Fluttertoast.showToast(
      //     msg: "Please upload a file",
      //   );
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _kFormName,
              child: LabeledTextField(
                controller: _name,
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
                        decoration: InputDecoration(
                          hintText: "https://example.com",
                          hintStyle:
                              TextStyle(color: Colors.white.withOpacity(.5)),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 55,
                          width: double.infinity,
                          child: MaterialButton(
                            onPressed: () async {
                              print("PICK");
                              try {
                                await FilePicker.platform.pickFiles(
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
                              color: Colors.white.withOpacity(.5),
                              strokeWidth: 1,
                              child: Center(
                                  child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                              color: Colors.white.withOpacity(.5),
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
                  //             await data.doc(refId).set({
                  //   entry.type.contentStringify: FieldValue.arrayUnion([
                  //     entry.toFireObj(),
                  //   ])
                  // }, SetOptions(merge: true));
                  print(type);
                  if (type == 1 &&
                      (_kFormName.currentState!.validate() &&
                          _kForm.currentState!.validate())) {
                    await _service.firestore
                        .collection("user-source")
                        .doc(refId)
                        .set({
                      "sources": FieldValue.arrayUnion([
                        M3uSource(
                                source: _url.text,
                                isFile: false,
                                name: _name.text)
                            .toJson()
                      ])
                    }, SetOptions(merge: true));
                    _name.clear();
                    _url.clear();
                  } else {
                    if (file != null && _kFormName.currentState!.validate()) {
                      await _service.firestore
                          .collection("user-source")
                          .doc(refId)
                          .set({
                        "sources": FieldValue.arrayUnion([
                          M3uSource(
                                  source: file!.path,
                                  isFile: true,
                                  name: _name.text)
                              .toJson()
                        ])
                      }, SetOptions(merge: true));
                      file = null;
                      _name.clear();
                      if (mounted) setState(() {});
                    }
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add),
                    Text(
                      "Add Source",
                      style: TextStyle(color: ColorPalette().white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            )
          ],
        ));
  }
}
