import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ListHomePage extends StatefulWidget {
  const ListHomePage({Key? key}) : super(key: key);

  @override
  State<ListHomePage> createState() => _ListHomePageState();
}

class _ListHomePageState extends State<ListHomePage> {
  double position = 0.0;
  VideoPlayerController? controller;
  bool _isPlaying = false;
  bool _disposed = false;
  var _onUpdateControllerTime;
  final List<Map> myProducts =
      List.generate(100000, (index) => {"id": index, "name": "Product $index"})
          .toList();
  @override
  void dispose() {
    _disposed = true;
    controller?.pause();
    controller = null;
    super.dispose();
  }

  void _intializeVideo(int index) async {
    final _controller = VideoPlayerController.network(
        'https://ak.picdn.net/shutterstock/videos/1058628376/preview/stock-footage-people-in-the-park-happy-family-silhouette-walk-at-sunset-mom-dad-and-daughters-walk-holding.webm');
    final old = controller;
    controller = _controller;
    if (old != null) {
      old.removeListener(_onControllerUpdate);
      old.pause();
    }
    setState(() {});
    _controller
      ..initialize().then((value) {
        old?.dispose();
        _controller.addListener(_onControllerUpdate);
        _controller.play();
        setState(() {});
      });
  }

  void _onControllerUpdate() async {
    final _controller = controller;
    if (_disposed) return;
    _onUpdateControllerTime = 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_onUpdateControllerTime > now) {
      return;
    }
    // to prevent from runing every milli sconds
    _onUpdateControllerTime = now + 500;
    if (_controller == null) {
      debugPrint("controller is null");
      return;
    }
    if (!_controller.value.isInitialized) {
      debugPrint("controller can not be intialized");
      return;
    }
    final playing = _controller.value.isPlaying;
    _isPlaying = playing;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: SafeArea(
        child: Column(
          children: [
            Container(
              child: controller != null && controller!.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: controller!.value.aspectRatio,
                      child: VideoPlayer(controller!),
                    )
                  : Container(
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Center(
                          child: Container(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ),
            ),
            Container(
              // height: 40,

              color: Colors.red,
              child: Column(
                children: [
                  Slider(
                      value: position,
                      min: 0.0,
                      max: 100,
                      divisions: 100,
                      label: position.toString(),
                      onChanged: (value) {
                        setState(() {
                          position = value;
                        });
                      }),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          padding: EdgeInsets.all(1.0),
                          onPressed: () {},
                          icon: Icon(
                            Icons.fast_rewind,
                          )),
                      IconButton(
                          padding: EdgeInsets.all(1.0),
                          onPressed: () {
                            _intializeVideo(0);
                          },
                          icon: Icon(
                            Icons.play_arrow_rounded,
                          )),
                      IconButton(
                          padding: EdgeInsets.all(1.0),
                          onPressed: () {},
                          icon: Icon(
                            Icons.fast_forward_rounded,
                          )),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Flexible(
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10),
                  itemCount: myProducts.length,
                  itemBuilder: (BuildContext ctx, index) {
                    return Container(
                      alignment: Alignment.center,
                      child: Text(myProducts[index]["name"]),
                      decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(15)),
                    );
                  }),
            )
          ],
        ),
      )),
    );
  }
}
