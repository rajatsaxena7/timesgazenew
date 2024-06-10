import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timesgaze/controllers/auth_controller.dart';
import 'package:timesgaze/screens/login_screen.dart';

class FacebookPhotos extends ConsumerStatefulWidget {
  List<String> fphotos;
  FacebookPhotos({super.key, required this.fphotos});

  @override
  ConsumerState<FacebookPhotos> createState() => _FacebookPhotosState();
}

class _FacebookPhotosState extends ConsumerState<FacebookPhotos> {
  final controller = CarouselController();

  void logOutFromFacebook(WidgetRef ref, BuildContext context) {
    ref.read(authControllerProvider).logoutFromFacebook(context);
    // AuthRepository(firestore: FirebaseFirestore.instance,auth: FirebaseAuth.instance,googleSignIn: GoogleSignIn()).logOut(context);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final devicewidth = MediaQuery.of(context).size.width;
    final deviceheight = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
              onPressed: () {
                logOutFromFacebook(ref,context);
              },
              icon: Icon(Icons.logout,color: Colors.black)),
        
        ),
        body: Center(
          child: Row(
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
                    autoPlayInterval: const Duration(seconds: 2),
                    enableInfiniteScroll: false,
                  ),
                  itemCount: widget.fphotos.length,
                  itemBuilder: (context, index, realIndex) {
                    final goolephotos = widget.fphotos[index];

                    return buildImage(goolephotos, index);
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
        ));
  }

  void previous() =>
      controller.previousPage(duration: const Duration(milliseconds: 500));
  void next() =>
      controller.nextPage(duration: const Duration(milliseconds: 500));

  Widget buildImage(String googlephotos, int index) => Container(
        margin: EdgeInsets.symmetric(
          horizontal: 12.0,
        ),
        color: Colors.grey,
        child: Image.network(
          googlephotos,
          fit: BoxFit.cover,
        ),
      );
}
