//
// Generated file. Do not edit.
//

// ignore: unused_import
import 'dart:ui';

import 'package:audioplayers/audioplayers_web.dart';
import 'package:firebase_core_web/firebase_core_web.dart';
import 'package:url_launcher_web/url_launcher_web.dart';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// ignore: public_member_api_docs
void registerPlugins(PluginRegistry registry) {
  AudioplayersPlugin.registerWith(registry.registrarFor(AudioplayersPlugin));
  FirebaseCoreWeb.registerWith(registry.registrarFor(FirebaseCoreWeb));
  UrlLauncherPlugin.registerWith(registry.registrarFor(UrlLauncherPlugin));
  registry.registerMessageHandler();
}
