
# BGUG

[Break Guns Using Gems](https://fireslime.xyz/games/bgug) is an open-source mobile game for Android and iOS.

It's a fast paced side-scrolling platformer with innovative controls and a gun-related twist.

Developed by the [Fireslime Team](https://fireslime.xyz) using [flame](https://flame-engine.org).

This is also a good, complete example and showcase of all flame has to offer. Please check this source code if you have advanced questions about flame.

## Gameplay

BGUG puts you in control of a tiny robot, in his quest to avoid obstacles and collect gems.

Use the gems to block the pathway of the guns that try to kill you and see how much you can endure the tireless obstacles in this endless runner.

Collect coins on your adventure and by blocking the guns, then use those coins to buy awesome custom skin for your tiny robot, choosing between a total of more than 30 skins available.

Hold the left side of the screen to jump; the longer you hold, the higher you'll jump upon release. Hold the right of the screen to fall quicker after your jumps.

Simple but innovative and hard-to-master controls keep you in the flow in order to improve after every death. Become the best among your friends and get all the achievements!

Also check out the playground with no coin rewards but 100% customizable options. Make your own game with the abundant configs.

## Running

You can download from the [Play Store](https://play.google.com/store/apps/details?id=xyz.luan.bgug) or build yourself. After cloning, just run the build script to both fetch dependencies and build the generated files:

```bash
./cmds/build.sh
```

After that, just use `flutter run` to run on your emulator or connected device

Remember to set the constants:

```dart
const bool ENABLE_LOGIN = true;
const bool ENABLE_ADS = true;
const bool ENABLE_IAP = false;
```

To your liking.

## Installation

Alternatively, you can run `flutter build apk --split-per-abi` to generate an APK to later install on any devices. 

Installing to your device is as simple as connecting it in debug mode and running`flutter install`
Have fun!

## Contributing

Star, open your issue or PR us, we'd be really, really glad!

To open an PR:

 * Fork it!
 * Create a feature branch.
 * Make your modifications (remember to KISS)
 * Submit your PR

Any help is appreciated! Thanks!
