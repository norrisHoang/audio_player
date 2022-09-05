import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({Key? key}) : super(key: key);

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen>
    with TickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  late MusicModel _currentSong;
  late String _statusMusic;
  late int _positionMusic;
  Duration? _position;
  Duration? _total;

  List<MusicModel> _tempListMusic = [];

  //1
  final TextEditingController _textController = TextEditingController();
  late final AnimationController _animationController;

  @override
  void initState() {
    _statusMusic = 'stop';

    _positionMusic = 0;
    _currentSong = MusicModel.list[_positionMusic];

    _getTimeMusic();

    _animationController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
    super.initState();
  }

  @override
  void dispose() {
    _player.dispose();
    _textController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  _getTimeMusic() {
    Future.delayed(Duration.zero, () async {
      _player.onDurationChanged.listen((Duration d) {
        _total = d; //get the duration of audio
        setState(() {});
      });
      _player.onPositionChanged.listen((Duration p) {
        _position = p; //get the current position of playing audio
        setState(() {});
      });

      _player.onPlayerComplete.listen((event) {
        _autoNextMusic();
      });
      //
      // _player.onPlayerStateChanged.listen((PlayerState state) {
      //   print('${state.name} + ${state..index}');
      // });
    });
  }

  _autoNextMusic() {
    _statusMusic = 'playing';
    _getCurrentSong(isSkipNext: true);
    _handleControlMusic(isAuto: true, isSelectedList: false);
    setState(() {});
  }

  _getCurrentSong({required bool isSkipNext}) {
    if (MusicModel.list.indexOf(_currentSong) > 0 &&
        MusicModel.list.indexOf(_currentSong) < MusicModel.list.length - 1) {
      if (isSkipNext) {
        _positionMusic++;
      } else {
        _positionMusic--;
      }
      _currentSong = MusicModel.list[_positionMusic];
    } else if (MusicModel.list.indexOf(_currentSong) <= 0) {
      if (isSkipNext) {
        _positionMusic++;
      } else {
        _positionMusic = MusicModel.list.length - 1;
      }
      _currentSong = MusicModel.list[_positionMusic];
    } else {
      if (isSkipNext) {
        _positionMusic = 0;
      } else {
        _positionMusic--;
      }
      _currentSong = MusicModel.list[_positionMusic];
    }
  }

  Future<void> _handleControlMusic(
      {required bool isAuto, required bool isSelectedList}) async {
    switch (_statusMusic) {
      case 'playing':
        {
          if (isSelectedList) {
            await _player.stop();
          }
          await _player.play(AssetSource(_currentSong.uri.toString()),
              volume: 1);
          break;
        }
      case 'pause':
        {
          await _player.pause();
          break;
        }
      case 'previous':
        {
          _statusMusic = 'playing';
          Duration? temp = Duration(seconds: ((_position!.inSeconds) - 8));

          await _player.seek(Duration(seconds: temp.inSeconds));
          await _player.play(AssetSource(_currentSong.uri.toString()),
              volume: 1);
          break;
        }
      case 'next':
        {
          _statusMusic = 'playing';
          Duration? temp = Duration(seconds: ((_position!.inSeconds) + 8));
          if (temp >= _total!) {
            temp = _total;
            _position = _total;
            setState(() {});
          }
          await _player.release();
          await _player.seek(Duration(seconds: temp!.inSeconds));
          await _player.play(AssetSource(_currentSong.uri.toString()),
              volume: 1);
          break;
        }
      case 'skip':
        {
          _statusMusic = 'playing';
          setState(() {});
          await _player.stop();
          await _player.play(AssetSource(_currentSong.uri.toString()),
              volume: 1);
          break;
        }
      default:
        {
          await _player.dispose();
          break;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [_buildListMusic(context)],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTitleMusic(context),
            _buildBackgroundMusic(context),
            _buildProgressBarMusic(context),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildButtonSkip(context, isSkipNext: false),
                const SizedBox(width: 10),
                _buildButtonNextAndPrevious(context, isNext: false),
                const SizedBox(width: 10),
                _buildButtonPlay(context),
                const SizedBox(width: 10),
                _buildButtonStop(context),
                const SizedBox(width: 10),
                _buildButtonNextAndPrevious(context, isNext: true),
                const SizedBox(width: 10),
                _buildButtonSkip(context, isSkipNext: true)
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildListMusic(BuildContext context) {
    return Container(
      height: 50,
      width: 50,
      alignment: Alignment.center,
      // decoration: BoxDecoration(
      //     // borderRadius: const BorderRadius.all(Radius.circular(25)),
      //     border: Border.all(color: Colors.grey)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25), //radius for animation
          onTap: () {
            _showModal(context);
            setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            child: const Icon(Icons.list_outlined),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleMusic(BuildContext context) {
    return Center(
      child: Text(
        'ID ${_currentSong.id} : ${_currentSong.name}',
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildBackgroundMusic(BuildContext context) {
    return Center(
        child: MyAnimatedWidgetScreen(
      controller: _animationController,
      image: _currentSong.image,
    ));
  }

  Widget _buildProgressBarMusic(BuildContext context) {
    if (_position != null && _total != null && _position! >= _total!) {
      _position = _total;
    }
    return Column(
      children: [
        Slider(
          inactiveColor: Colors.black12,
          activeColor: Colors.grey,
          value: _position?.inSeconds.toDouble() ?? 0.0,
          min: 0,
          max: _total?.inSeconds.toDouble() ?? 0.0,
          divisions: null,
          onChanged: (double value) async {
            _player.seek(Duration(seconds: value.toInt()));
            setState(() {});
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _durationToString(_position?.inSeconds ?? 0),
              ),
              Text(
                _durationToString(_total?.inSeconds ?? 0),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildButtonPlay(BuildContext context) {
    return Container(
      height: 50,
      width: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(25)),
          border: Border.all(color: Colors.grey)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25), //radius for animation
          onTap: () {
            if (_statusMusic.contains('playing')) {
              _statusMusic = 'pause';
            } else {
              _statusMusic = 'playing';
            }
            _handleControlMusic(isAuto: false, isSelectedList: false);
            setState(() {});
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            child: _statusMusic.contains('stop')
                ? const Icon(Icons.play_arrow)
                : Icon(_statusMusic.contains('playing')
                    ? Icons.pause
                    : Icons.play_arrow),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonStop(BuildContext context) {
    return Container(
      height: 50,
      width: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(25)),
          border: Border.all(color: Colors.grey)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25), //radius for animation
          onTap: () {
            _statusMusic = 'stop';
            _handleControlMusic(isAuto: false, isSelectedList: false);
            setState(() {
              _position = Duration.zero;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            child: const Icon(Icons.stop),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonNextAndPrevious(BuildContext context,
      {required bool isNext}) {
    return Container(
      height: 50,
      width: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(25)),
          border: Border.all(color: Colors.grey)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25), //radius for animation
          onTap: () {
            setState(() {
              if (_total != null && _position != null) {
                if (isNext) {
                  _statusMusic = 'next';
                } else {
                  _statusMusic = 'previous';
                }
                _handleControlMusic(isAuto: false, isSelectedList: false);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(isNext ? Icons.fast_forward : Icons.fast_rewind),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonSkip(BuildContext context, {required bool isSkipNext}) {
    return Container(
      height: 50,
      width: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(25)),
          border: Border.all(color: Colors.grey)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25), //radius for animation
          onTap: () {
            setState(() {
              _statusMusic = 'skip';
              _getCurrentSong(isSkipNext: isSkipNext);
              _handleControlMusic(isAuto: false, isSelectedList: false);
            });
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(isSkipNext ? Icons.skip_next : Icons.skip_previous),
          ),
        ),
      ),
    );
  }

  // Convert duration to string
  String _durationToString(int minutes) {
    var d = Duration(minutes: minutes);
    List<String> parts = d.toString().split(':');
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  void _showModal(context) {
    showModalBottomSheet(
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
        ),
        context: context,
        builder: (context) {
          //3
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return DraggableScrollableSheet(
                expand: false,
                builder:
                    (BuildContext context, ScrollController scrollController) {
                  return Column(children: [
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(children: [
                          Flexible(
                              child: TextField(
                                  controller: _textController,
                                  autofocus: false,
                                  decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.all(8),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0),
                                        borderSide: const BorderSide(),
                                      ),
                                      prefixIcon: const Icon(Icons.search),
                                      suffixIcon: Visibility(
                                        visible:
                                            _textController.text.isNotEmpty,
                                        child: IconButton(
                                            icon: const Icon(Icons.close),
                                            color: const Color(0xFF1F91E7),
                                            onPressed: () {
                                              setState(() {
                                                _textController.clear();
                                                _tempListMusic.clear();
                                              });
                                            }),
                                      )),
                                  onChanged: (value) {
                                    //4
                                    setState(() {
                                      _tempListMusic = _buildSearchList(value)
                                          as List<MusicModel>;
                                    });
                                  })),
                        ])),
                    Expanded(
                      child: ListView.separated(
                          controller: scrollController,
                          //5
                          itemCount: (_tempListMusic.isNotEmpty)
                              ? _tempListMusic.length
                              : MusicModel.list.length,
                          separatorBuilder: (context, index) {
                            return const Divider();
                          },
                          itemBuilder: (context, index) {
                            return InkWell(

                                //6
                                child: (_tempListMusic.isNotEmpty)
                                    ? _showBottomSheetWithSearch(
                                        index: index,
                                        listOfCities: _tempListMusic)
                                    : _showBottomSheetWithSearch(
                                        index: index,
                                        listOfCities: MusicModel.list),
                                onTap: () {
                                  if (_tempListMusic.isNotEmpty) {
                                    _currentSong = _tempListMusic[index];
                                  } else {
                                    _currentSong = MusicModel.list[index];
                                  }
                                  _statusMusic = 'playing';
                                  _handleControlMusic(
                                      isAuto: false, isSelectedList: true);
                                  Navigator.of(context).pop();
                                  setState(() {});
                                });
                          }),
                    )
                  ]);
                });
          });
        });
  }

  Widget _showBottomSheetWithSearch(
      {required int index, required List<MusicModel> listOfCities}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Text('${listOfCities[index].id} - ${listOfCities[index].name}',
          style: const TextStyle(color: Colors.black, fontSize: 16),
          textAlign: TextAlign.start),
    );
  }

  //9
  List _buildSearchList(String userSearchTerm) {
    List<MusicModel> searchList = [];

    searchList.addAll(MusicModel.list.where((element) {
      return element.name!.toLowerCase().contains(userSearchTerm.toLowerCase());
    }).toList());
    return searchList;
  }
}

// Model position data music
class PositionData {
  final Duration position;
  final Duration bufferedPosition;

  PositionData(this.position, this.bufferedPosition);
}

class MusicModel {
  final int id;
  final String? name;
  final String? image;
  final String? uri;

  MusicModel({required this.id, this.name, this.image, this.uri});

  static List<MusicModel> list = [
    MusicModel(
      id: 19,
      name: 'Ái nộ',
      image: 'assets/images/img_ai_no.jpg',
      uri: 'audio/ai_no.mp3',
    ),
    MusicModel(
        id: 69,
        name: 'Vì mẹ bắt chia tay',
        image: 'assets/images/img_vi_me_bat_chia_tay.jpg',
        uri: 'audio/vi_me_bat_chia_tay.mp3'),
    MusicModel(
        id: 14,
        name: 'Yêu đơn phương là gì',
        image: 'assets/images/img_yeu_don_phuong_la_gi.jpg',
        uri: 'audio/yeu_don_phuong_la_gi.mp3'),
    MusicModel(
      id: 19,
      name: 'Ái nộ',
      image: 'assets/images/img_ai_no.jpg',
      uri: 'audio/ai_no.mp3',
    ),
    MusicModel(
        id: 60,
        name: 'Vì mẹ bắt chia tay',
        image: 'assets/images/img_vi_me_bat_chia_tay.jpg',
        uri: 'audio/vi_me_bat_chia_tay.mp3'),
    MusicModel(
      id: 21,
      name: 'Ái nộ',
      image: 'assets/images/img_ai_no.jpg',
      uri: 'audio/ai_no.mp3',
    ),
    MusicModel(
        id: 77,
        name: 'Yêu đơn phương là gì',
        image: 'assets/images/img_yeu_don_phuong_la_gi.jpg',
        uri: 'audio/yeu_don_phuong_la_gi.mp3'),
  ];
}

//      CLASS ANIMATION IMAGE MUSIC
class MyAnimatedWidgetScreen extends AnimatedWidget {
  final String? image;

  const MyAnimatedWidgetScreen(
      {Key? key, required AnimationController controller, this.image})
      : super(key: key, listenable: controller);

  Animation<double> get _progress => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: _progress.value * 2.0 * math.pi,
      child: Container(
          margin: const EdgeInsets.symmetric(vertical: 40),
          height: 200,
          width: 200,
          alignment: Alignment.center,
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(100))),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Image.asset(
                image ?? 'asset/images/img_default_music.jpg',
                fit: BoxFit.fill,
                height: 200,
                width: 200,
              ),
              Center(
                  child: Container(
                height: 40,
                width: 40,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(25))),
              )),
            ],
          )),
    );
  }
}
//              SOLUTION 2
//
// StreamBuilder<Duration?>(
//   stream: _player.onDurationChanged,
//   builder: (context, snapshot) {
//     _total = snapshot.data ?? Duration.zero;
//     return StreamBuilder<PositionData>(
//       stream: Rx.combineLatest2<Duration, Duration, PositionData>(
//           _player.onPositionChanged,
//           _player.onPositionChanged,
//           (position, bufferedPosition) =>
//               PositionData(position, bufferedPosition)),
//       builder: (context, snapshot) {
//         final positionData = snapshot.data ??
//             PositionData(Duration.zero, Duration.zero);
//         _position = positionData.position;
//         if (_position! > _total!) {
//           _position = _total!;
//           print(_position!.inSeconds);
//         }
//         // var bufferedPosition = positionData.bufferedPosition;
//         // if (bufferedPosition > total) {
//         // }
//         return Padding(
//           //   bufferedPosition = total;
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           child: ProgressBar(
//             thumbColor: Colors.grey,
//             progressBarColor: Colors.grey,
//             thumbGlowColor: Colors.white12,
//             total: Duration(seconds: _total!.inSeconds),
//             progress: Duration(seconds: _position!.inSeconds),
//             onSeek: (newPosition) {
//               _player
//                   .seek(Duration(seconds: newPosition.inSeconds));
//               setState(() {});
//             },
//           ),
//         );
//       },
//     );
//   },
// ),
