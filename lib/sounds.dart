/*
  // FINAL API FROM HERE DOWN

  sounds = Sounds();
  sounds.isMuted = false; // default
  sounds.isMuted = true;

  sounds.setVolume(1.0); // set volume for all existing channels
  sounds.setVolume(1.0, key: "abc"); set volume for channel id "abc"

  String key = sounds.play("file.mp3"); // play file, get the key for it
  await sounds.play("file.mp3", key: "abc"); // play file, use channel "abc"

  String key = sounds.play("file.mp3", volume: -1.0); // play file, use current vol for that channel
  String key = sounds.play("file.mp3", volume: 1.0); // play file with given volume
  String key = sounds.play("file.mp3", isLoop: true); // play file and repeat forever
  String key = sounds.play("file.mp3", isLoop: false); // play file and never loop it

  String key = await sounds.preload("file.mp3"); // preload file, and get key for the channel
  await sounds.preload("file.mp3", key: "abc"); // preload file into channel with id "abc"

  await sounds.pause("abc"); // pause channel with id "abc"
  bool success = sounds.resume("abc"); // resume playback of channel with id "abc"
  bool success = sounds.remove("abc"); // delete the channel with id "abc"


  String key = sounds.playCollection([ "file1", "file2" ], loopCount: 5);

*/

import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';

class Sounds {
  Map _channels = <String, AudioPlayer>{};
  Map _volumes = <String, double>{};

  final double _defaultVolume = 1.0;
  bool _isMuted = false; // Is volume muted or enabled?

  int _channelCounter = 0;

  Sounds();

  set isMuted(bool value) {
    _isMuted = value;
    _updateVolumes();
  }

  // If no key provided, generate a new key.
  // If no volume provided, use existing volume for the channel.
  //   If we're creating a new channel, use default volume of 1.0.
  // If no loop provided, do not loop.
  String play(String filename, { 
    String key = "",
    double volume = -1.0,
    bool isLoop = false,
    }) {

    if (key == "" && volume == -1.0) volume = _defaultVolume;
    if (key == "") key = _nextChannelKey();
    _addPlayer(key);

    if (volume == -1.0) volume = _volumes[key];
    setVolume(volume, key: key);

    debugPrint("Playing $filename on: $key");
    Object loopMode = isLoop ? LoopMode.all : LoopMode.off;
    _channels[key].setLoopMode(loopMode);
    _channels[key].setAsset(filename); 
    _channels[key].play();

    _channels[key].playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        // This sound finished playing. Remove its audio channel.
        _deleteChannel(key);
      }
    });

    return key;
  }
  
  Future<bool> pause(String key) async {
    if (!_channels.containsKey(key)) return Future.value(false);
    await _channels[key].pause();
    return Future.value(true);
  }

  bool resume(String key) {
    if (!_channels.containsKey(key)) return false;
    _channels[key].play();
    return true;
  }

  bool remove(String key) {
    if (!_channels.containsKey(key)) return false;
    _deleteChannel(key);
    return true;
  }

  String playCollection(List<String> filenames, {
    String key = "",
    double volume = -1.0,
    int loopCount = 1,
    }) {

    if (key == "" && volume == -1.0) volume = _defaultVolume;
    if (key == "") key = _nextChannelKey();
    _addPlayer(key);

    if (volume == -1.0) volume = _volumes[key];
    setVolume(volume, key: key);

    List<AudioSource> children = [];
    for (String filename in filenames) {
      children.add(AudioSource.uri(Uri.parse('asset:///$filename')));
    }

    _channels[key].setAudioSource(
      LoopingAudioSource(
        count: loopCount,
        child: ConcatenatingAudioSource(
          children: children,
        ),
      ),
    );

    _channels[key].play();

    return key;
  }

  // If no key provided, set volume for all channels.
  // If no volume provided, use existing volume for the channel.
  void setVolume(double volume, { String key = "" }) {
    List<dynamic> keys;
    keys = key == "" ? _channels.keys.toList() : [ key ];

    for (String channelKey in keys) {
      _volumes[channelKey] = volume;
    }

    _updateVolumes();
  }

  Future<String> preload(filename, { String key = "" }) async {
    if (key == "" || !_channels.containsKey(key)) {
      key = _nextChannelKey();
      _addPlayer(key);
    }

    await _channels[key].setAsset(filename); 

    return key;
  }

  void _updateVolumes() async {
    List<dynamic> keys = _channels.keys.toList();
    if (keys.isEmpty) return;

    for (String key in keys) {
      double volume = _isMuted ? 0 : _volumes[key];
      await _channels[key]?.setVolume(volume);
    }
  }

  void _addPlayer(String key) {
    if (!_channels.containsKey(key)) {
      _channels[key] = AudioPlayer();
      _volumes[key] = _defaultVolume;
    }
  }

  void shutdown() {
    for (String key in _channels.keys) {
      _channels[key].dispose();
    }
    _channels = {};
    _volumes = {};
  }

  _deleteChannel(String key) {
    _channels[key]?.dispose();
    _channels.remove(key);
    _volumes.remove(key);
  }

  String _nextChannelKey() {
    String key = "chn-$_channelCounter";
    while (_channels.keys.contains(key)) {
      _channelCounter++;
      key = "chn-$_channelCounter";
    }

    return key;
  }

}
