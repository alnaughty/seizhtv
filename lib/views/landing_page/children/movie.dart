// ignore_for_file: avoid_print, deprecated_member_use, unnecessary_null_comparison, unrelated_type_equality_checks
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seizhtv/extensions/state.dart';
import 'package:z_m3u_handler/z_m3u_handler.dart';
import '../../../data_containers/favorites.dart';
import '../../../data_containers/history.dart';
import '../../../data_containers/loaded_m3u_data.dart';
import '../../../globals/data.dart';
import '../../../globals/loader.dart';
import '../../../globals/palette.dart';
import '../../../globals/ui_additional.dart';
import '../../../globals/video_loader.dart';
import '../../../services/movie_api.dart';
import 'movie_children/cat_movie.dart';
import 'movie_children/fav_movie.dart';
import 'movie_children/his_movie.dart';
import 'movie_children/movie_list.dart';

class MoviePage extends StatefulWidget {
  const MoviePage({super.key});

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage>
    with ColorPalette, UIAdditional, VideoLoader, MovieAPI {
  static final ZM3UHandler _handler = ZM3UHandler.instance;
  final LoadedM3uData _vm = LoadedM3uData.instance;
  late final ScrollController _scrollController;
  final Favorites _vm1 = Favorites.instance;
  final History _hisvm = History.instance;
  late final TextEditingController _search;
  late List<ClassifiedData> _favdata;
  late List<ClassifiedData> _hisdata;
  late List<M3uEntry> favData = [];
  late List<M3uEntry> hisData = [];
  bool showSearchField = false;
  List<M3uEntry> movieData = [];
  late List<String>? categoryName = [];
  List<ClassifiedData>? displayData;
  String dropdownvalue = "";
  String label = "";
  bool update = false;
  int? ind;
  int? previousIndex;
  int? searchindex;
  bool selected = true;
  bool selectedAgain = false;

  fetchFav() async {
    await _handler
        .getDataFrom(type: CollectionType.favorites, refId: refId!)
        .then((value) {
      if (value != null) {
        _vm1.populate(value);
      }
    });
  }

  fetchHis() async {
    await _handler
        .getDataFrom(type: CollectionType.history, refId: refId!)
        .then((value) {
      if (value != null) {
        _hisvm.populate(value);
      }
    });
  }

  initFavStream() {
    _vm1.stream.listen((event) {
      _favdata = List.from(event.movies);
      favData = _favdata.expand((element) => element.data).toList();
    });
  }

  initHisStream() {
    _hisvm.stream.listen((event) {
      _hisdata = List.from(event.movies);
      hisData = _hisdata.expand((element) => element.data).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _search = TextEditingController();
    fetchFav();
    fetchHis();
    initFavStream();
    initHisStream();
    initStream();
    label = "All (${movieData == null ? "" : movieData.length})";
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _search.dispose();
    super.dispose();
  }

  initStream() {
    _vm.stream.listen((event) {
      displayData = List.from(event.movies);
      for (final ClassifiedData item in displayData!) {
        late final List<M3uEntry> data = item.data;
        movieData.addAll(List.from(data));
      }
      categoryName = ["ALL (${movieData == null ? "" : movieData.length})"];
      for (final ClassifiedData cdata in displayData!) {
        categoryName!.add("${cdata.name} (${cdata.data.length})");
      }
      categoryName!.sort((a, b) => a.compareTo(b));
      if (mounted) setState(() {});
    });
  }

  // final GlobalKey<MovieListPageState> _kList = GlobalKey<MovieListPageState>();
  // final GlobalKey<FaveMoviePageState> _favList =
  //     GlobalKey<FaveMoviePageState>();
  // final GlobalKey<HistoryMoviePageState> _hisList =
  //     GlobalKey<HistoryMoviePageState>();
  // final GlobalKey<MovieCategoryPageState> _catList =
  //     GlobalKey<MovieCategoryPageState>();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: card,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: appbar(
            2,
            onSearchPressed: () async {
              showSearchField = !showSearchField;
              searchindex = showSearchField == true ? ind : null;
              print("showSearchField $showSearchField - $ind");
              print("showSearchField $searchindex - $ind");
              if (mounted) setState(() {});
            },
            onUpdateChannel: () {
              setState(() {
                update = true;
                Future.delayed(
                  const Duration(seconds: 6),
                  () {
                    setState(() {
                      update = false;
                    });
                  },
                );
              });
            },
          ),
        ),
        body: Stack(
          children: [
            displayData == null
                ? SeizhTvLoader(
                    label: Text(
                      "Retrieving_data".tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: UIAdditional().filterChip(
                          chipsLabel: [
                            "${"favorites".tr()} (${favData.length})",
                            "Series History (${hisData.length})",
                          ],
                          onPressed: (index, name) {
                            setState(() {
                              ind = index;
                              selected = false;
                              selectedAgain = false;
                            });
                          },
                          si: ind,
                          selected: selected,
                          filterButton: Container(
                            width: 150,
                            height: 40,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30)),
                            child:
                                // selectedAgain == false
                                //     ? Row(
                                //         mainAxisAlignment:
                                //             MainAxisAlignment.spaceBetween,
                                //         children: [
                                //           Text(label,
                                //               style: const TextStyle(
                                //                   fontSize: 14,
                                //                   fontFamily: "Poppins")),
                                //           const Icon(
                                //               Icons.arrow_drop_down_outlined),
                                //         ],
                                //       )
                                //     :
                                DropdownButton(
                              elevation: 0,
                              isExpanded: true,
                              padding: const EdgeInsets.all(0),
                              underline: Container(),
                              onTap: () {
                                setState(() {
                                  selected = true;
                                  ind = null;
                                });
                              },
                              items: categoryName!.map((value) {
                                return DropdownMenuItem(
                                    value: value, child: Text(value));
                              }).toList(),
                              value: dropdownvalue == ""
                                  ? categoryName == []
                                      ? ""
                                      : categoryName![0]
                                  : dropdownvalue,
                              style: const TextStyle(
                                  fontSize: 14, fontFamily: "Poppins"),
                              icon: const Icon(Icons.arrow_drop_down_outlined),
                              onChanged: (value) {
                                setState(() {
                                  dropdownvalue = value!;
                                  String result1 = dropdownvalue.replaceAll(
                                      RegExp(r"[(]+[0-9]+[)]"), '');
                                  label = result1;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Scrollbar(
                            controller: _scrollController,
                            child: selected == true
                                ? dropdownvalue.contains("All") ||
                                        dropdownvalue == ""
                                    ? MovieListPage(
                                        // key: _kList,
                                        controller: _scrollController,
                                        data: movieData,
                                        showSearchField:
                                            searchindex == 0 ? true : false)
                                    : MovieCategoryPage(
                                        // key: _catList,
                                        category: label,
                                        showSearchField:
                                            searchindex == 0 ? true : false)
                                : ind == 0
                                    ? FaveMoviePage(
                                        // key: _favList,
                                        data: favData,
                                        showSearchField:
                                            searchindex == 0 ? true : false)
                                    : HistoryMoviePage(
                                        // key: _hisList,
                                        data: hisData,
                                        showSearchField:
                                            searchindex == 1 ? true : false)),
                      ),
                    ],
                  ),
            update == true ? loader() : Container()
          ],
        ),
      ),
    );
  }
}

/// SEARCH BAR
// SizedBox(
//   child: AnimatedPadding(
//     duration: const Duration(milliseconds: 10),
//     padding: EdgeInsets.symmetric(
//         horizontal: showSearchField ? 20 : 0),
//     child: AnimatedContainer(
//       duration: const Duration(milliseconds: 10),
//       height: showSearchField ? size.height * .08 : 0,
//       width: double.maxFinite,
//       child: Row(
//         children: [
//           Expanded(
//               child: Container(
//             height: 50,
//             padding: const EdgeInsets.symmetric(
//                 horizontal: 10),
//             decoration: BoxDecoration(
//                 color: highlight,
//                 borderRadius: BorderRadius.circular(10),
//                 boxShadow: [
//                   BoxShadow(
//                       color: highlight
//                           .darken()
//                           .withOpacity(1),
//                       offset: const Offset(2, 2),
//                       blurRadius: 2)
//                 ]),
//             child: Row(
//               children: [
//                 SvgPicture.asset(
//                   "assets/icons/search.svg",
//                   height: 20,
//                   width: 20,
//                   color: white,
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: AnimatedSwitcher(
//                     duration:
//                         const Duration(milliseconds: 300),
//                     child: showSearchField
//                         ? TextField(
//                             onChanged: (text) {
//                               if (text.isEmpty) {
//                                 searchData = movieData;
//                               } else {
//                                 searchData = List.from(
//                                     movieData.where(
//                                         (element) => element
//                                             .title
//                                             .toLowerCase()
//                                             .contains(text
//                                                 .toLowerCase())));
//                               }
//                               searchData!.sort((a, b) => a
//                                   .title
//                                   .compareTo(b.title));
//                               if (mounted) {
//                                 setState(() {});
//                               }
//                             },
//                             cursorColor: orange,
//                             controller: _search,
//                             decoration: InputDecoration(
//                               hintText:
//                                   "Search $ind".tr(),
//                             ),
//                           )
//                         : Container(),
//                   ),
//                 ),
//               ],
//             ),
//           )),
//           const SizedBox(width: 10),
//           GestureDetector(
//             onTap: () {
//               setState(() {
//                 _search.clear();
//                 searchData = movieData;
//                 showSearchField = !showSearchField;
//               });
//             },
//             child: Text(
//               "Cancel".tr(),
//               style: const TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     ),
//   ),
// ),
// if (showSearchField) ...{
//   const SizedBox(height: 15),
// },

// ? showSearchField
//           ? searchData!.isEmpty
//               ? Center(
//                   child: Text(
//                     "No Result Found for `${_search.text}`",
//                     style: TextStyle(
//                       color: Colors.white
//                           .withOpacity(.5),
//                     ),
//                   ),
//                 )
//                   : GridView.builder(
//                       shrinkWrap: true,
//                       controller: _scrollController,
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 20),
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 3,
//                               mainAxisExtent: 155),
//                       itemCount: searchData!.length,
//                       itemBuilder: (context, i) {
//                         final M3uEntry d = searchData![i];

//                         return GestureDetector(
//                           onTap: () async {
//                             String result1 = d.title
//                                 .replaceAll(
//                                     RegExp(
//                                         r"[(]+[a-zA-Z]+[)]|[|]\s+[0-9]+\s[|]"),
//                                     '');
//                             String result2 =
//                                 result1.replaceAll(
//                                     RegExp(
//                                         r"[|]+[a-zA-Z]+[|]|[a-zA-Z]+[|] "),
//                                     '');

//                             print("$d");

//                             Navigator.push(
//                               context,
//                               PageTransition(
//                                 child: MovieDetailsPage(
//                                   data: d,
//                                   title: result2,
//                                 ),
//                                 type: PageTransitionType
//                                     .rightToLeft,
//                               ),
//                             );
//                           },
//                           child: Container(
//                             margin: const EdgeInsets
//                                     .symmetric(
//                                 horizontal: 1.5),
//                             child: Stack(
//                               children: [
//                                 Container(
//                                   margin: const EdgeInsets
//                                           .only(
//                                       top: 10, right: 10),
//                                   child: LayoutBuilder(
//                                     builder:
//                                         (context, c) {
//                                       final double w =
//                                           c.maxWidth;
//                                       return Tooltip(
//                                         message: d.title,
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment
//                                                   .start,
//                                           children: [
//                                             NetworkImageViewer(
//                                               url: d.attributes[
//                                                   'tvg-logo'],
//                                               width: w,
//                                               height: 90,
//                                               fit: BoxFit
//                                                   .cover,
//                                               color:
//                                                   highlight,
//                                             ),
//                                             const SizedBox(
//                                                 height:
//                                                     3),
//                                             Tooltip(
//                                               message:
//                                                   d.title,
//                                               child: Text(
//                                                 d.title,
//                                                 style: const TextStyle(
//                                                     fontSize:
//                                                         12),
//                                                 maxLines:
//                                                     2,
//                                                 overflow:
//                                                     TextOverflow
//                                                         .ellipsis,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                                 Positioned(
//                                   top: 0,
//                                   right: 0,
//                                   child: SizedBox(
//                                     height: 25,
//                                     width: 25,
//                                     child:
//                                         FavoriteIconButton(
//                                       onPressedCallback:
//                                           (bool f) async {
//                                         if (f) {
//                                           showDialog(
//                                             barrierDismissible:
//                                                 false,
//                                             context:
//                                                 context,
//                                             builder:
//                                                 (BuildContext
//                                                     context) {
//                                               Future.delayed(
//                                                   const Duration(
//                                                       seconds:
//                                                           3),
//                                                   () {
//                                                 Navigator.of(
//                                                         context)
//                                                     .pop(
//                                                         true);
//                                               });
//                                               return Dialog(
//                                                 alignment:
//                                                     Alignment
//                                                         .topCenter,
//                                                 shape:
//                                                     RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.circular(10),
//                                                 ),
//                                                 child:
//                                                     Container(
//                                                   padding:
//                                                       const EdgeInsets.symmetric(horizontal: 20),
//                                                   child:
//                                                       Row(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment.spaceBetween,
//                                                     children: [
//                                                       Text(
//                                                         "Added_to_Favorites".tr(),
//                                                         style: const TextStyle(fontSize: 16),
//                                                       ),
//                                                       IconButton(
//                                                         padding: const EdgeInsets.all(0),
//                                                         onPressed: () {
//                                                           Navigator.of(context).pop();
//                                                         },
//                                                         icon: const Icon(Icons.close_rounded),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               );
//                                             },
//                                           );
//                                           await d
//                                               .addToFavorites(
//                                                   refId!);
//                                         } else {
//                                           await d
//                                               .removeFromFavorites(
//                                                   refId!);
//                                         }
//                                         await fetchFav();
//                                       },
//                                       initValue: d
//                                           .existsInFavorites(
//                                               "movie"),
//                                       iconSize: 20,
//                                     ),
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     )  :
