import 'dart:convert';

import 'package:udevs_video_player/models/download_configuration.dart';
import 'package:udevs_video_player/models/player_configuration.dart';

import 'udevs_video_player_platform_interface.dart';
export 'package:udevs_video_player/models/player_configuration.dart';
export 'package:udevs_video_player/models/movie.dart';
export 'package:udevs_video_player/models/season.dart';
export 'package:udevs_video_player/models/tv_program.dart';
export 'package:udevs_video_player/models/programs_info.dart';
export 'package:udevs_video_player/models/download_configuration.dart';

class UdevsVideoPlayer {
  Future<String?> playVideo({required PlayerConfiguration playerConfig}) {
    String jsonStringConfig = jsonEncode(playerConfig.toJson());
    return UdevsVideoPlayerPlatform.instance.playVideo(
      playerConfigJsonString: jsonStringConfig,
    );
  }

  Future<dynamic> downloadVideo(
      {required DownloadConfiguration downloadConfig}) {
    String jsonStringConfig = jsonEncode(downloadConfig.toJson());
    return UdevsVideoPlayerPlatform.instance
        .downloadVideo(downloadConfigJsonString: jsonStringConfig);
  }

  Future<bool> isDownloadVideo(
      {required DownloadConfiguration downloadConfig}) {
    String jsonStringConfig = jsonEncode(downloadConfig.toJson());
    return UdevsVideoPlayerPlatform.instance
        .isDownloadVideo(downloadConfigJsonString: jsonStringConfig);
  }

  Future<int?> getCurrentProgressDownload(
      {required DownloadConfiguration downloadConfig}) {
    String jsonStringConfig = jsonEncode(downloadConfig.toJson());
    return UdevsVideoPlayerPlatform.instance
        .getCurrentProgressDownload(downloadConfigJsonString: jsonStringConfig);
  }

  Future<dynamic> closeVideo() {
    return UdevsVideoPlayerPlatform.instance.closeVideo();
  }
}
