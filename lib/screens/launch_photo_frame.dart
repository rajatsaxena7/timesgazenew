import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class LaunchPhotoFrame extends StatefulWidget {
  final List<Map<String, dynamic>> photos;
  const LaunchPhotoFrame({super.key, required this.photos});

  @override
  State<LaunchPhotoFrame> createState() => _LaunchPhotoFrameState();
}

class _LaunchPhotoFrameState extends State<LaunchPhotoFrame> {
  final controller = CarouselController();
  @override
  Widget build(BuildContext context) {
    WakelockPlus.enable();

    final devicewidth = MediaQuery.of(context).size.width;
    final deviceheight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        child: CarouselSlider.builder(
          carouselController: controller,
          options: CarouselOptions(
            height: deviceheight,
            viewportFraction: 1,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            enableInfiniteScroll: false,
          ),
          itemCount: widget.photos.length,
          itemBuilder: (context, index, realIndex) {
            final goolephotos = widget.photos[index]['baseUrl'];
            return buildImage(goolephotos, index);
          },
        ),
      ),
    );
  }
}

Widget buildImage(String googlephotos, int index) => Container(
      color: Colors.grey,
      child: Image.network(
        googlephotos,
        fit: BoxFit.contain,
      ),
    );
