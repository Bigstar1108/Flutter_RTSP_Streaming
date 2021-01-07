import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class RtspStreaming extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RtspStreaming();
}

class _RtspStreaming extends State<RtspStreaming> {
  String initUrl = "rtsp://192.168.1.73:8554/mystream";

  String changeUrl =
      "http://distribution.bbb3d.renderfarming.net/video/mp4/bbb_sunflower_1080p_30fps_normal.mp4";

  VlcPlayerController _videoViewController;
  bool isBuffering = false;

  @override
  void initState() {
    _videoViewController = new VlcPlayerController(onInit: () {
      _videoViewController.play();
    });

    // _videoViewController.addListener(() {
    //   switch (_videoViewController.playingState) {
    //     // case PlayingState.PAUSED:
    //     //   setState(() {
    //     //     isBuffering = false;
    //     //   });
    //     //   break;
    //     case PlayingState.STOPPED:
    //       setState(() {
    //         isBuffering = true;
    //       });
    //       break;
    //     case PlayingState.BUFFERING:
    //       setState(() {
    //         isBuffering = true;
    //       });
    //       break;
    //     case PlayingState.PLAYING:
    //       setState(() {
    //         isBuffering = false;
    //       });
    //       break;
    //     case PlayingState.ERROR:
    //       setState(() {
    //         isBuffering = true;
    //       });
    //       print("VLC encountered error");
    //       break;
    //     default:
    //       setState(() {});
    //       break;
    //   }
    // });

    super.initState();
  }

  showPlaying() {
    return Column(
      children: <Widget>[
        // _videoViewController.isPlaying() != null ? Text('connecting...') : Text('playing'),
        isBuffering ? Text('connecting...') : Text('playing'),
        SizedBox(
          height: 250,
          child: new VlcPlayer(
            aspectRatio: 16 / 9,
            url: initUrl,
            isLocalMedia: false,
            controller: _videoViewController,
            options: [
              '--quiet',
              '--no-drop-late-frames',
              '--no-skip-frames',
              '--no-rtsp-tcp', // tcp로 받지 않겠다.
            ],
            hwAcc: HwAcc.DISABLED,
            placeholder: Container(
              height: 250.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[CircularProgressIndicator()],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Builder(builder: (context) {
        return Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                showPlaying(),
              ],
            ));
      }),
    );
  }

  @override
  void dispose() {
    _videoViewController.dispose();
    super.dispose();
  }
}
