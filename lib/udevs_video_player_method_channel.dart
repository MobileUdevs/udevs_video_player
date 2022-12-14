import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'udevs_video_player_platform_interface.dart';

/// An implementation of [UdevsVideoPlayerPlatform] that uses method channels.
class MethodChannelUdevsVideoPlayer extends UdevsVideoPlayerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('udevs_video_player');

  @override
  Future<String?> playVideo({
    required String playerConfigJsonString,
  }) async {
    if (Platform.isIOS) {
      final res = await methodChannel
          .invokeMethod<String>('playVideo', <String, dynamic>{
        'playerConfigJsonString': jsonDecode(playerConfigJsonString),
      });
      return res;
    }
    final res =
        await methodChannel.invokeMethod<String>('playVideo', <String, dynamic>{
      'playerConfigJsonString': playerConfigJsonString,
    });
    return res;
  }
}
