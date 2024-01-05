import 'package:flutter/material.dart';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var f = NumberFormat('###,###,###,###');
  late SharedPreferences _prefs;
  int count = 1;
  int isClear = 0; // 0 노클, 1 클리어
  List<String> safeRoutes = ["safe.png", "safe2.png"];
  final shakeKey = GlobalKey<ShakeWidgetState>();
  late final AssetsAudioPlayer _assetsAudioPlayer =
      AssetsAudioPlayer.newPlayer();

  BannerAd myBanner = BannerAd(
    size: AdSize.banner,
    adUnitId: '{ad id}',
    listener: const BannerAdListener(),
    request: const AdRequest(),
  );

  @override
  void initState() {
    super.initState();
    setSettings();
    myBanner.load();
    _assetsAudioPlayer.open(
      Audio("assets/audios/bgm.mp3"),
      loopMode: LoopMode.single,
      playInBackground: PlayInBackground.disabledRestoreOnForeground,
      autoStart: true,
    );
    _assetsAudioPlayer.play();
  }

  void decrementCounter() {
    setState(() {
      if (--count <= 0) {
        isClear = 1;
        _prefs.setInt("isClear", isClear);
        count = 0;
      }

      _prefs.setInt("count", count);
    });
  }

  void setSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      count = _prefs.getInt('count') ?? 100000000;
      isClear = _prefs.getInt('isClear') ?? 0;

      //test
      // count = 10;
      // _prefs.setInt("count", count);
      // isClear = 0;
      // _prefs.setInt("isClear", isClear);
    });
  }

  Widget countText(int isClear) {
    if (isClear == 1) {
      return const SizedBox(
        height: 143,
      );
    }

    return Text(
      f.format(count),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 100,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isClear == 0) {
          shakeKey.currentState?.shake();
        }
        decrementCounter();
      },
      child: MaterialApp(
        theme: ThemeData(
          fontFamily: 'HakgyoansimGaeulsopung',
        ),
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                countText(isClear),
                const SizedBox(
                  height: 50,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: ShakeMe(
                    key: shakeKey,
                    shakeCount: 2,
                    shakeOffset: 10,
                    shakeDuration: const Duration(milliseconds: 100),
                    child: Image.asset('assets/images/${safeRoutes[isClear]}'),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: SizedBox(
            height: 50,
            child: AdWidget(ad: myBanner),
          ),
        ),
      ),
    );
  }
}
