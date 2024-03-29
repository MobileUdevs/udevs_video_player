import 'dart:core';

import 'package:udevs_video_player/models/programs_info.dart';
import 'package:udevs_video_player/models/season.dart';

class PlayerConfiguration {
  Map<String, String> initialResolution;
  Map<String, String> resolutions;
  String qualityText;
  String speedText;
  int lastPosition;
  String title;
  bool isSerial;
  String episodeButtonText;
  String nextButtonText;
  List<Season> seasons;
  bool isLive;
  String tvProgramsText;
  List<ProgramsInfo> programsInfoList;
  bool showController;
  bool playVideoFromAsset;
  String assetPath;
  int seasonIndex;
  int episodeIndex;
  bool isMegogo;
  bool isPremier;
  String videoId;
  String sessionId;
  String megogoAccessToken;
  String authorization;
  String autoText;
  String baseUrl;
  bool fromCache;

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['initialResolution'] = initialResolution;
    map['resolutions'] = resolutions;
    map['qualityText'] = qualityText;
    map['speedText'] = speedText;
    map['lastPosition'] = lastPosition;
    map['title'] = title;
    map['isSerial'] = isSerial;
    map['episodeButtonText'] = episodeButtonText;
    map['nextButtonText'] = nextButtonText;
    map['seasons'] = seasons.map((v) => v.toJson()).toList();
    map['isLive'] = isLive;
    map['tvProgramsText'] = tvProgramsText;
    map['programsInfoList'] = programsInfoList.map((v) => v.toJson()).toList();
    map['showController'] = showController;
    map['playVideoFromAsset'] = playVideoFromAsset;
    map['assetPath'] = assetPath;
    map['seasonIndex'] = seasonIndex;
    map['episodeIndex'] = episodeIndex;
    map['isMegogo'] = isMegogo;
    map['isPremier'] = isPremier;
    map['videoId'] = videoId;
    map['sessionId'] = sessionId;
    map['megogoAccessToken'] = megogoAccessToken;
    map['authorization'] = authorization;
    map['autoText'] = autoText;
    map['baseUrl'] = baseUrl;
    map['fromCache'] = fromCache;
    return map;
  }

  @override
  String toString() {
    return 'PlayerConfiguration{'
        'initialResolution: $initialResolution, '
        'resolutions: $resolutions, '
        'qualityText: $qualityText, '
        'speedText: $speedText, '
        'lastPosition: $lastPosition, '
        'title: $title, '
        'isSerial: $isSerial, '
        'episodeButtonText: $episodeButtonText, '
        'nextButtonText: $nextButtonText, '
        'seasons: $seasons, '
        'isLive: $isLive, '
        'tvProgramsText: $tvProgramsText, '
        'programsInfoList: $programsInfoList, '
        'showController: $showController, '
        'playVideoFromAsset: $playVideoFromAsset, '
        'assetPath: $assetPath, '
        'seasonIndex: $seasonIndex, '
        'episodeIndex: $episodeIndex, '
        'isMegogo: $isMegogo, '
        'isPremier: $isPremier, '
        'videoId: $videoId, '
        'sessionId: $sessionId, '
        'megogoAccessToken: $megogoAccessToken, '
        'authorization: $authorization, '
        'autoText: $autoText '
        'baseUrl: $baseUrl, '
        'fromCache: $fromCache'
        '}';
  }

  PlayerConfiguration({
    required this.initialResolution,
    required this.resolutions,
    required this.qualityText,
    required this.speedText,
    required this.lastPosition,
    required this.title,
    required this.isSerial,
    required this.episodeButtonText,
    required this.nextButtonText,
    required this.seasons,
    required this.isLive,
    required this.tvProgramsText,
    required this.programsInfoList,
    required this.showController,
    required this.playVideoFromAsset,
    required this.assetPath,
    required this.seasonIndex,
    required this.episodeIndex,
    required this.isMegogo,
    required this.isPremier,
    required this.videoId,
    required this.sessionId,
    required this.megogoAccessToken,
    required this.authorization,
    required this.autoText,
    required this.baseUrl,
    required this.fromCache,
  });
}
