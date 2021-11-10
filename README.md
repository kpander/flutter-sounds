# Sounds wrapper class

Play a sound file. Manage which channel sounds are played in. Play, loop, pause, and control sound over time.

When a sound stops playing, its channel is removed automatically.

This is primarily a convenience wrapper around the [just_audio](https://pub.dev/packages/just_audio) package.


## Installation

@todo add pubspec.yaml example for github


## Usage examples

Play a single sound `effect.mp3` which is located at `./assets/effect.mp3`.

```
Sound sound = Sounds();
sound.play("assets/effect.mp3");
```

---

Play a single sound `effect.mp3` at a volume level of 0.5 (50% volume).

```
Sound sound = Sounds();
sound.play("assets/effect.mp3", volume: 0.5);
```

---

Play a music track `music.mp3` (located at `./assets/music.mp3`) and get a channel reference so we can pause the sound later.

```
Sound sound = Sounds();
String key = await sound.play("assets/music.mp3");
await sound.pause(key);
```

---

Play a music track `music.mp3` and have it loop forever.

```
Sound sound = Sounds();
sound.play("assets/music.mp3", isLoop: true);
```

---

Play a music track `music.mp3` at an initial volume of 0.5. Later, change the volume of that channel to 1.0.

```
Sound sound = Sounds();
String key = await sound.play("assets/music.mp3", volume: 0.5);
...
setVolume(1.0, key: key);
```


## API

### Properties

bool isMuted

When `true`, audio is silent.


### Methods

#### setVolume(double volume, { String key }) -> void

Set the volume level for all sound channels.

If `key` is provided, only set the volume level for the channel identified by `key`.


#### play(String filename, { String key, double volume, bool isLoop }) -> String

Play the sound file `filename`. Specify the full path, e.g.: `assets/myfile.mp3`.

If `key` is provided, play the sound in the channel identified by `key` instead of making a new channel.

`volume` provides the volume level for this sound. Default value = `1.0`.

If `isLoop` = true, loop the sound forever. Default value = `false`.

Returns `key` identifying the channel used.


#### playCollection(List<String> filenames, { String key, double volume, int loopCount }) -> String

Play the collection of sounds listed in `filenames`, one after the other.

If `key` is provided, play the collection in the channel identified by `key` instead of making a new channel.

`volume` provides the volume level for this collection. Default value = `1.0`.

`loopCount` defines the number of times to play the collection. Default value = `1`.

Returns `key` identifying the channel used.


#### preload(String filename, { String key }) -> Future<String>

Preload the given `filename` in a sound channel.

If `key` is provided, preload the file in the channel identified by `key` instead of making a new channel.

Returns `key` identifying the channel used.


#### pause(String key) -> Future<bool>

Pause sound playback in the channel identified by `key`.

Returns `true` if the sound was paused, `false` if no channel was found for the given `key`.


#### resume(String key) -> bool

Resume sound playback in the channel identified by `key`.

Returns `true` if the sound was resumed, `false` if no channel was found for the given `key`.


#### remove(String key) -> bool

Stop sound playback in the channel identified by `key`, and remove the channel.

Returns `true` if the sound was stopped and removed, `false` if no channel was found for the given `key`.


#### shutdown() -> void

Stop and dispose of all audio channels.


## Reference

  - https://suragch.medium.com/playing-short-audio-clips-in-flutter-with-just-audio-3c80eb7eb6ea
  - https://github.com/ryanheise/just_audio/issues/189


