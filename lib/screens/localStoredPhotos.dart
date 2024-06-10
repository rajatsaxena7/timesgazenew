import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timesgaze/screens/google_photos_screen.dart';
import 'package:timesgaze/screens/launch_photo_frame.dart';

class GetPhotosFromLocalStorage extends StatefulWidget {
  //final List<Map<String, dynamic>> storedPhotos;
  const GetPhotosFromLocalStorage({super.key});

  @override
  State<GetPhotosFromLocalStorage> createState() =>
      _GetPhotosFromLocalStorageState();
}

class _GetPhotosFromLocalStorageState extends State<GetPhotosFromLocalStorage> {
  final controller = CarouselController();

  @override
  void initState() {
    super.initState();
    fetchStoredPhotos();
    fetch3StoredPhotos();
    fetch5StoredPhotos();
  }

  List<Map<String, dynamic>> storedPhotos = [];
  List<Map<String, dynamic>> stored3Photos = [];
  List<Map<String, dynamic>> stored5Photos = [];
  String selectedOption = 'Last In';

  Future<void> fetchStoredPhotos() async {
    storedPhotos = await getStoredPhotosFromLocalStorage();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> fetch3StoredPhotos() async {
    stored3Photos = await get3yearStoredPhotos();
    print(stored3Photos);

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> fetch5StoredPhotos() async {
    stored5Photos = await get5yearStoredPhotos();
    print(stored5Photos);
    if (mounted) {
      setState(() {});
    }
  }

  Future<List<Map<String, dynamic>>> getStoredPhotosFromLocalStorage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final encodedPhotos = prefs.getStringList('stored_photos') ?? [];
    final decodedPhotos =
        encodedPhotos.map((encodedPhoto) => jsonDecode(encodedPhoto)).toList();

    return decodedPhotos.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> get3yearStoredPhotos() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final encodedPhotos = prefs.getStringList('stored_threeYearsPhotos') ?? [];
    final decodedPhotos =
        encodedPhotos.map((encodedPhoto) => jsonDecode(encodedPhoto)).toList();

    return decodedPhotos.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> get5yearStoredPhotos() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final encodedPhotos = prefs.getStringList('stored_fiveYearsPhotos') ?? [];
    final decodedPhotos =
        encodedPhotos.map((encodedPhoto) => jsonDecode(encodedPhoto)).toList();

    return decodedPhotos.cast<Map<String, dynamic>>();
  }

  Future<void> showFilterOptionsDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filters'),
          content: Column(
            children: [
              RadioListTile(
                title: Text('Last In'),
                value: 'Last In',
                groupValue: selectedOption,
                onChanged: (value) {
                  setState(() {
                    selectedOption = value!;
                    Navigator.pop(context);
                  });
                },
              ),
              RadioListTile(
                title: Text('Random'),
                value: 'Random',
                groupValue: selectedOption,
                onChanged: (value) {
                  setState(() {
                    selectedOption = value!;
                    Navigator.pop(context);
                  });
                },
              ),
              // RadioListTile(
              //   title: Text('5 Years'),
              //   value: '5 Years',
              //   groupValue: selectedOption,
              //   onChanged: (value) {
              //     setState(() {
              //       selectedOption = value!;
              //       Navigator.pop(context);
              //     });
              //   },
              // ),
              RadioListTile(
                title: Text('Memory Lane'),
                value: 'Memory Lane',
                groupValue: selectedOption,
                onChanged: (value) {
                  setState(() {
                    selectedOption = value!;
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final devicewidth = MediaQuery.of(context).size.width;
    final deviceheight = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          actions: [
            ElevatedButton(
              onPressed: () {
                showFilterOptionsDialog(context);
                setState(() {});
              },
              child: Icon(
                Icons.filter,
                size: 30,
              ),
              // child: Text(
              //   'Filters',
              //   style: TextStyle(color: Colors.black),
              // )
            ),
            Button()
          ],
        ),
        body: Center(
          child: (storedPhotos.isEmpty &&
                  stored3Photos.isEmpty &&
                  stored5Photos.isEmpty)
              ? Center(
                  child: Text(
                    'No photos available.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: previous,
                          icon: FaIcon(
                            FontAwesomeIcons.circleChevronLeft,
                            size: deviceheight * 0.0442,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          // color: Colors.black,
                          // height: deviceheight * 0.31413,
                          height: deviceheight * 0.737,
                          width: devicewidth * 0.6944,
                          // width: 250,
                          child: CarouselSlider.builder(
                            carouselController: controller,
                            options: CarouselOptions(
                              height: deviceheight * 0.6,
                              viewportFraction: 1,
                              autoPlay: true,
                              //  autoPlayInterval: const Duration(seconds: 2),
                              enableInfiniteScroll: false,
                            ),
                            itemCount: (selectedOption == 'Last In')
                                ? storedPhotos.length
                                : (selectedOption == 'Random')
                                    ? stored3Photos.length
                                    : (selectedOption == '5 Years')
                                        ? stored5Photos.length
                                        : storedPhotos.length,
                            itemBuilder: (context, index, realIndex) {
                              final photoFrame = (selectedOption == 'Last In')
                                  ? storedPhotos[index]['baseUrl']
                                  : (selectedOption == 'Random')
                                      ? stored3Photos[index]['baseUrl']
                                      : (selectedOption == '5 Years')
                                          ? stored5Photos[index]['baseUrl']
                                          : storedPhotos[index]['baseUrl'];
                              //  final photoFrame = storedPhotos[index]['baseUrl'];

                              //print(photoFrame);
                              return buildImage(photoFrame!, index);
                            },
                          ),
                        ),
                        IconButton(
                          onPressed: next,
                          icon: FaIcon(
                            FontAwesomeIcons.circleChevronRight,
                            size: deviceheight * 0.0442,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          right: deviceheight * 0.04424,
                          left: 0.04424 * deviceheight,
                          bottom: 0.04424 * deviceheight),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => LaunchPhotoFrame(
                                    photos: (selectedOption == 'Last In')
                                        ? storedPhotos
                                        : (selectedOption == 'Random')
                                            ? stored3Photos
                                            : stored5Photos))),
                          );
                        },
                        child: const Text(
                          'Launch Photo Frame',
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            // backgroundColor: const Color.fromARGB(255, 240, 175, 89),

                            minimumSize:
                                Size(double.infinity, deviceheight * 0.0737),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    0.0295 * deviceheight),
                                side: BorderSide(
                                  color: Color.fromARGB(255, 245, 166, 75),
                                ))),
                      ),
                    ),
                  ],
                ),
        ));
  }

  void previous() =>
      controller.previousPage(duration: const Duration(milliseconds: 500));
  void next() =>
      controller.nextPage(duration: const Duration(milliseconds: 500));
}

Widget buildImage(String googlephotos, int index) => Container(
      margin: EdgeInsets.symmetric(
        horizontal: 12.0,
      ),
      color: Colors.grey,
      child: Image.network(
        googlephotos,
        fit: BoxFit.fill,
      ),
    );
