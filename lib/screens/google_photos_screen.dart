import 'dart:async';
import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:popover/popover.dart';
import 'package:timesgaze/controllers/auth_controller.dart';
import 'package:timesgaze/repositories/auth_repositories.dart';

import 'package:timesgaze/screens/launch_photo_frame.dart';
import 'package:timesgaze/screens/login_screen.dart';
import 'package:timesgaze/screens/profile_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class GooglePhotos extends ConsumerStatefulWidget {
  // final List<Map<String, String>> photos1;
  //const GooglePhotos({super.key, required this.photos1});
  const GooglePhotos({super.key});

  @override
  ConsumerState<GooglePhotos> createState() => _GooglePhotosState();
}

class _GooglePhotosState extends ConsumerState<GooglePhotos> {
  final controller = CarouselController();
  GoogleSignIn? googleSignIn = GoogleSignIn();
  String selectedOption = 'Last In';

  void resetCarousel() {
    controller.jumpToPage(0);
    
  }

  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _startSignInTimer();
  }

  void _startSignInTimer() {
    _timer = Timer.periodic(Duration(hours: 1), (Timer timer) {
      signInSilently(context, ref);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void signInSilently(BuildContext context, WidgetRef ref) {
    ref.read(authControllerProvider).signInSilently(context);
  }

  List<Map<String, dynamic>> shuffleList(List<Map<String, dynamic>> list) {
    var random = Random();
    for (var i = list.length - 1; i > 0; i--) {
      var n = random.nextInt(i + 1);
      var temp = list[i];
      list[i] = list[n];
      list[n] = temp;
    }
    return list;
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
                    resetCarousel();
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
                    resetCarousel();
                    Navigator.pop(context);
                  });
                },
              ),
              RadioListTile(
                title: Text('Memory Lane'),
                value: 'Memory Lane',
                groupValue: selectedOption,
                onChanged: (value) {
                  setState(() {
                    selectedOption = value!;
                    resetCarousel();

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
    WakelockPlus.enable();

    //print(ref.read(photosAppProvider));
    // final List<Map<String, dynamic>> lastInphotos =
    //     widget.photos1.reversed.toList();
    // ;
    final List<Map<String, dynamic>> lastInphotos =
        List.from(ref.read(photosAppProvider));
    // print(lastInphotos);

    lastInphotos.sort((a, b) {
      final DateTime timeA = DateTime.parse(a['creationTime']);

      final DateTime timeB = DateTime.parse(b['creationTime']);

      return timeB.compareTo(timeA);
    });

    //final List<Map<String, dynamic>> randomphotos = shuffleList(photosfinal);
    final List<Map<String, dynamic>> randomphotos =
        shuffleList(ref.read(photosAppProvider));

    List<Map<String, dynamic>> memoryLanePhotos = [];
    bool isInLastMonths(DateTime creationDate, int months) {
      final now = DateTime.now();
      final cutoffDate = now.subtract(Duration(days: 30 * months));
      return creationDate.isAfter(cutoffDate);
    }

    List<Map<String, dynamic>> filterPhotosByCreationDateWeek(
        List<Map<String, dynamic>> photos, int weeks) {
      final filteredPhotos = <Map<String, dynamic>>[];
      final now = DateTime.now();
      final cutoffDate = now.subtract(Duration(days: 7 * weeks));

      for (var photo in photos) {
        final creationTime = DateTime.parse(photo['creationTime']);
        if (creationTime.isAfter(cutoffDate)) {
          filteredPhotos.add(photo);
        }
      }

      return filteredPhotos;
    }

    List<Map<String, dynamic>> filterPhotosByCreationDate(
        List<Map<String, dynamic>> photos, int months) {
      final filteredPhotos = <Map<String, dynamic>>[];

      for (var photo in photos) {
        final creationTime = DateTime.parse(photo['creationTime']);
        if (isInLastMonths(creationTime, months)) {
          filteredPhotos.add(photo);
        }
      }

      return filteredPhotos;
    }

    final List<Map<String, dynamic>> last1week =
        filterPhotosByCreationDateWeek(ref.read(photosAppProvider), 1);
    final List<Map<String, dynamic>> last1MonthsPhotos =
        filterPhotosByCreationDate(ref.read(photosAppProvider), 1);
    final List<Map<String, dynamic>> last3MonthsPhotos =
        filterPhotosByCreationDate(ref.read(photosAppProvider), 3);

    final List<Map<String, dynamic>> last6MonthsPhotos =
        filterPhotosByCreationDate(ref.read(photosAppProvider), 6);

    if (last1week.isNotEmpty) {
      memoryLanePhotos = last1week;
    } else if (last1MonthsPhotos.isNotEmpty) {
      memoryLanePhotos = last1MonthsPhotos;
    } else if (last3MonthsPhotos.isNotEmpty) {
      memoryLanePhotos = last3MonthsPhotos;
    } else if (last6MonthsPhotos.isNotEmpty) {
      memoryLanePhotos = last6MonthsPhotos;
    } else {
      print('No memory lane photos found.');
    }

    // if (last3MonthsPhotos.isNotEmpty) {
    //   // print('Displaying last 3 months photos: $last3MonthsPhotos');
    // } else {
    //   final List<Map<String, dynamic>> last6MonthsPhotos =
    //       filterPhotosByCreationDate(ref.read(photosAppProvider), 6);
    //   if (last6MonthsPhotos.isNotEmpty) {
    //     print(
    //         'Displaying memory lane photos last 6 months: $last6MonthsPhotos');
    //   } else {
    //     print('No recent photos found.');
    //   }
    // }

    final devicewidth = MediaQuery.of(context).size.width;
    final deviceheight = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          //backgroundColor:   Color.fromARGB(255, 245, 166, 75),
          backgroundColor: Colors.white,

          actions: [
            ElevatedButton(
              onPressed: () {
                showFilterOptionsDialog(context);
              },
              child: FaIcon(
                FontAwesomeIcons.list,
                color: Colors.black,
                size: 0.032 * deviceheight,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 0,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                showLoadingScreen(context);
                signInSilently(context, ref);
                setState(() {});
              },
              child: FaIcon(
                FontAwesomeIcons.arrowsRotate,
                color: Colors.black,
                size: 0.032 * deviceheight,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 0,
              ),
            ),
            Button(),
            SizedBox(
              width: 10,
            )
          ],
        ),
        body: Center(
            child: photosfinal.isNotEmpty
                ? Column(
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
                          Container(
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
                                  autoPlayInterval: const Duration(seconds: 8),
                                  enableInfiniteScroll: false,
                                ),
                                //  itemCount: widget.photos1.length,
                                itemCount: (selectedOption == 'Last In')
                                    ? lastInphotos.length
                                    : (selectedOption == 'Random')
                                        ? randomphotos.length
                                        : memoryLanePhotos.length,

                                itemBuilder: (context, index, realIndex) {
                                  // final photoFrame = widget.photos1[index]['baseUrl'];
                                  final photoFrame = (selectedOption ==
                                          'Last In')
                                      ? lastInphotos[index]['baseUrl']
                                      : (selectedOption == 'Random')
                                          ? randomphotos[index]['baseUrl']
                                          : memoryLanePhotos[index]['baseUrl'];
                                  return buildImage(
                                      photoFrame!, index, context);
                                },
                              )),
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
                            //signInSilently(context, ref);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => LaunchPhotoFrame(
                                        photos: (selectedOption == 'Last In')
                                            ? lastInphotos
                                            : (selectedOption == 'Random')
                                                ? randomphotos
                                                : memoryLanePhotos,
                                      ))),
                            );

                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: ((context) => SignInSilentlyScreen())),
                            // );
                          },
                          child: const Text(
                            'Launch Photo Frame',
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
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
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/nodata.gif',
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'It seems there are no albums to showcase!',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  )));
  }

  void previous() =>
      controller.previousPage(duration: const Duration(milliseconds: 500));
  void next() =>
      controller.nextPage(duration: const Duration(milliseconds: 500));
}

Widget buildImage(String googlephotos, int index, BuildContext context) =>
    Container(
      margin: EdgeInsets.symmetric(
        horizontal: 12.0,
      ),
      color: Colors.grey,
      child: Image.network(
        googlephotos,
        fit: BoxFit.fill,
      ),
    );

class ListItems extends StatelessWidget {
  const ListItems({Key? key}) : super(key: key);
  void logOut(WidgetRef ref, BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    ref.read(authControllerProvider).logOut(context);
    // AuthRepository(firestore: FirebaseFirestore.instance,auth: FirebaseAuth.instance,googleSignIn: GoogleSignIn()).logOut(context);
    Navigator.pop(context);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    //final devicewidth = MediaQuery.of(context).size.width;
    final deviceheight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: deviceheight * 0.01179),
      child: ListView(
        padding: EdgeInsets.all(deviceheight * 0.01179),
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context)
                ..pop()
                ..push(
                  MaterialPageRoute<ProfileScreen>(
                    builder: (context) => ProfileScreen(),
                  ),
                );
            },
            child: Container(
              height: 0.0589 * deviceheight,
              color: Colors.white,
              child: const Center(child: Text('Profile')),
            ),
          ),
          const Divider(),
          Consumer(builder: (context, ref, _) {
            return InkWell(
              onTap: () {
                logOut(ref, context);
              },
              child: Container(
                height: 0.0589 * deviceheight,
                color: Colors.white,
                child: const Center(child: Text('Logout')),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class Button extends StatelessWidget {
  const Button({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceheight = MediaQuery.of(context).size.height;
    final devicewidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      child: const Center(
          child: Icon(
        Icons.more_vert,
        color: Colors.black,
      )),
      onTap: () {
        showPopover(
          context: context,
          bodyBuilder: (context) => const ListItems(),

          direction: PopoverDirection.top,
          width: devicewidth * 0.5555,

          height: 0.2 * deviceheight,
          arrowHeight: 15,
          // arrowWidth: 40,
        );
      },
    );
  }
}

void showLoadingScreen(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/load.gif'),
              SizedBox(height: 20),
              Text("Refreshing your photos..."),
            ],
          ),
        ),
      );
    },
  );
}
