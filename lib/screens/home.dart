import 'package:flutter/material.dart';
import 'dart:async';
import 'package:stopwatch_lafay/models/timer_entity.dart';
import 'package:stopwatch_lafay/utilities/ring_manager.dart';
import 'package:stopwatch_lafay/widgets/home_app_bar.dart';
import 'package:stopwatch_lafay/widgets/rep_elevated_button.dart';
import 'package:stopwatch_lafay/widgets/timer_elevated_button.dart';
import 'package:audioplayers/audioplayers.dart' as audio_player;
import 'package:vibration/vibration.dart';
import 'package:audio_session/audio_session.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  // object to manage the countdown
  late Timer _timer;
  // boolean to know whether the stopwatch is on or not
  bool isStopwatchOn = false;
  // string that contain the timer currently running in 00'00" format
  String timerOn = '';
  // integer that contain the timer currently running in seconds format
  int timerOnInSeconds = 0;
  // object to play sounds from assets
  final player = audio_player.AudioPlayer();
  // object to handle device's vibration
  late bool hasVibration;
  // static Vibration vibration = Vibration();
  late bool hasAmplitudeControl;
  // booleans to check if the device has vibration capabilities
  late bool hasCustomVibrationSupport;

  late AudioSession session;

  Map<num, bool> reps = {
    0: true,
    1: false,
    2: false,
    3: false,
    4: false,
    5: false,
    6: false
  };
  // "device persistent storage using plugins like shared preferences"
  List<TimerEntity> timers = [
    TimerEntity(30),
    TimerEntity(60),
    TimerEntity(90),
    TimerEntity(120),
    TimerEntity(180),
    TimerEntity(240),
  ];

  int whichRepButtonIsPressed() {
    for (var i = 0; i < reps.length; i++) {
      if (reps[i] == true) {
        return i;
      }
    }
    return 0;
  }

  void pressRepButton(int number) {
    setState(() {
      for (var i = 0; i < reps.length; i++) {
        if (i == number) {
          reps[i] = true;
        } else {
          reps[i] = false;
        }
      }
    });
  }

  Future<void> startTimer() async {
    await session.setActive(true);
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) async {
        if (timerOnInSeconds == 0) {
          await session.setActive(false);
          setState(() {
            timer.cancel();
            isStopwatchOn = false;
          });
        } else if (timerOnInSeconds <= 6 && timerOnInSeconds >= 2) {
          await RingManager.pool.play(RingManager.soundId);
          setState(() {
            timerOnInSeconds--;
            timerOn = TimerEntity(timerOnInSeconds.toDouble()).getTimer();
            // if vibration checkbox is ticked
            // if (hasVibration) {
            //   Vibration.vibrate(duration: 250, amplitude: 128);
            // }
          });
        } else {
          setState(() {
            timerOnInSeconds--;
            timerOn = TimerEntity(timerOnInSeconds.toDouble()).getTimer();
          });
        }
      },
    );
  }

  startStopwatch(int timer) {
    setState(() {
      isStopwatchOn = true;
      timerOn = timers[timer].getTimer();
      timerOnInSeconds = timers[timer].duration.toInt();
      if (whichRepButtonIsPressed() != 0) {
        pressRepButton(whichRepButtonIsPressed() - 1);
      }
      startTimer();
    });
  }

  void checkVibrationCapabilities() async {
    hasVibration = (await Vibration.hasVibrator())!;
    hasAmplitudeControl = (await Vibration.hasAmplitudeControl())!;
    hasCustomVibrationSupport = (await Vibration.hasCustomVibrationsSupport())!;
  }

  void configureAudioSession() async {
    session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
      androidWillPauseWhenDucked: true,
    ));
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
    player.dispose();
    RingManager.pool.release();
  }

  @override
  Widget build(BuildContext context) {
    checkVibrationCapabilities();
    // configureAudioSession();

    return Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: const HomeAppBar(),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Visibility(
                visible: true,
                child: Expanded(
                  flex: 8,
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(5, 10, 5, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        RepElevatedButton(
                            number: '0',
                            press: reps[0],
                            pressRepButton: () {
                              pressRepButton(0);
                            }),
                        RepElevatedButton(
                            number: '1',
                            press: reps[1],
                            pressRepButton: () {
                              pressRepButton(1);
                            }),
                        RepElevatedButton(
                            number: '2',
                            press: reps[2],
                            pressRepButton: () {
                              pressRepButton(2);
                            }),
                        RepElevatedButton(
                            number: '3',
                            press: reps[3],
                            pressRepButton: () {
                              pressRepButton(3);
                            }),
                        RepElevatedButton(
                            number: '4',
                            press: reps[4],
                            pressRepButton: () {
                              pressRepButton(4);
                            }),
                        RepElevatedButton(
                            number: '5',
                            press: reps[5],
                            pressRepButton: () {
                              pressRepButton(5);
                            }),
                        RepElevatedButton(
                            number: '6',
                            press: reps[6],
                            pressRepButton: () {
                              pressRepButton(6);
                            }),
                      ],
                    ),
                  ),
                ),
              ),
              Visibility(
                  visible: isStopwatchOn ? false : true,
                  child: Flexible(
                      flex: 14,
                      fit: FlexFit.tight,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(5, 10, 5, 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TimerElevatedButton(
                              timer: timers[0].getTimer(),
                              startStopWatch: () async {
                                startStopwatch(0);
                              },
                            ),
                            TimerElevatedButton(
                              timer: timers[1].getTimer(),
                              startStopWatch: () {
                                startStopwatch(1);
                              },
                            )
                          ],
                        ),
                      ))),
              Visibility(
                visible: isStopwatchOn ? false : true,
                child: Flexible(
                    flex: 14,
                    fit: FlexFit.tight,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TimerElevatedButton(
                            timer: timers[2].getTimer(),
                            startStopWatch: () {
                              startStopwatch(2);
                            },
                          ),
                          TimerElevatedButton(
                            timer: timers[3].getTimer(),
                            startStopWatch: () {
                              startStopwatch(3);
                            },
                          ),
                        ],
                      ),
                    )),
              ),
              Visibility(
                visible: isStopwatchOn ? false : true,
                child: Flexible(
                  flex: 14,
                  fit: FlexFit.tight,
                  child: Container(
                      margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TimerElevatedButton(
                            timer: timers[4].getTimer(),
                            startStopWatch: () {
                              startStopwatch(4);
                            },
                          ),
                          TimerElevatedButton(
                            timer: timers[5].getTimer(),
                            startStopWatch: () {
                              startStopwatch(5);
                            },
                          )
                        ],
                      )),
                ),
              ),
              Visibility(
                  visible: isStopwatchOn ? true : false,
                  child: Expanded(
                    flex: 21,
                    child: Container(
                        alignment: Alignment.center,
                        child: (Text(
                          timerOn,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 60),
                        ))),
                  )),
              Visibility(
                visible: isStopwatchOn ? true : false,
                child: Expanded(
                  flex: 21,
                  child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _timer.cancel();
                          isStopwatchOn = false;
                          if (reps[0] != true) {
                            pressRepButton(whichRepButtonIsPressed() + 1);
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[900],
                      ),
                      child: const Text(
                        'STOP',
                        style: TextStyle(fontSize: 40),
                      )),
                ),
              ),
            ]));
  }
}