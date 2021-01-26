import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' show Client;
import 'package:http/http.dart';

import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class RtspStreaming extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RtspStreaming();
}

class _RtspStreaming extends State<RtspStreaming> {
  String initUrl = "rtsp://192.168.1.73:8554/mystream";

  Timer _timer;

  String changeUrl =
      "http://distribution.bbb3d.renderfarming.net/video/mp4/bbb_sunflower_1080p_30fps_normal.mp4";

  VlcPlayerController _videoViewController;
  bool isBuffering = false;

  @override
  void initState() {
    _videoViewController = new VlcPlayerController(onInit: () {
      _videoViewController.play();
    });

    // controller에 addlistener를 달아서, 예외처리 진행
    _videoViewController.addListener(() {
      switch (_videoViewController.playingState) {
        case PlayingState.STOPPED:
          resetPlayer();
          break;
        case PlayingState.BUFFERING:
          resetPlayer();
          break;
        case PlayingState.PLAYING:
          setState(() {
            isBuffering = false;
          });
          if (_timer != null) {
            _timer.cancel();
            print("timer playing");
          }
          break;
        case PlayingState.ERROR:
          resetPlayer();
          print("VLC encountered error");
          break;
        default:
          setState(() {});
          break;
      }
    });

    super.initState();
  }

  // vlc player를 초기화하고 재시작하는 함수
  resetPlayer() {
    setState(() {
      isBuffering = true;
    });
    _videoViewController.dispose();
    _timer = Timer.periodic(new Duration(seconds: 1), (timer) async {
      _videoViewController.play();
    });
  }

  // RTSP 재생을 위한 vlc player를 return하는 함수
  showPlaying() {
    return Column(
      children: <Widget>[
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
              '--no-rtsp-tcp',
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

  // ignore: missing_return
  Future<List> getPortSpeed() async {
    Client client = Client();
    var url = "https://seadronix.jp.ngrok.io/get/portspeed";

    // var token = '';

    try {
      Map data = {
        "harbor": ["KR_USN"],
        "dock": "silo"
      };

      var body = json.encode(data);

      final response = await client.post(url,
          headers: {"Content-Type": "application/json"}, body: body);

      print(response.body);
    } catch (e) {
      print(e);
    }
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
                GestureDetector(
                  onTap: () {
                    getPortSpeed();
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 70,
                    alignment: Alignment.center,
                    color: Colors.black,
                    child: Text(
                      "TEST",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                )
              ],
            ));
      }),
    );
  }

  @override
  void dispose() {
    _videoViewController.dispose();
    _timer.cancel();
    super.dispose();
  }
}
