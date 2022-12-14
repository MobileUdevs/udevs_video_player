import 'package:flutter_test/flutter_test.dart';
import 'package:udevs_video_player/models/player_configuration.dart';
import 'package:udevs_video_player/udevs_video_player.dart';
import 'package:udevs_video_player/udevs_video_player_platform_interface.dart';
import 'package:udevs_video_player/udevs_video_player_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockUdevsVideoPlayerPlatform
    with MockPlatformInterfaceMixin
    implements UdevsVideoPlayerPlatform {
  @override
  Future<String?> playVideo({
    required String playerConfigJsonString,
  }) =>
      Future.value('42');
}

void main() {
  final UdevsVideoPlayerPlatform initialPlatform =
      UdevsVideoPlayerPlatform.instance;

  test('$MethodChannelUdevsVideoPlayer is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelUdevsVideoPlayer>());
  });

  test('playVideo', () async {
    UdevsVideoPlayer udevsVideoPlayerPlugin = UdevsVideoPlayer();
    MockUdevsVideoPlayerPlatform fakePlatform = MockUdevsVideoPlayerPlatform();
    UdevsVideoPlayerPlatform.instance = fakePlatform;

    expect(
        await udevsVideoPlayerPlugin.playVideo(
            playerConfig: PlayerConfiguration(
              duration: 0,
              initialResolution: {},
              resolutions: {},
              qualityText: '',
              speedText: '',
              lastPosition: 0,
              title: '',
              isSerial: false,
              episodeButtonText: '',
              nextButtonText: '',
              seasons: [],
              isLive: false,
              tvProgramsText: '',
              programsInfoList: [],
              showController: false,
              playVideoFromAsset: false,
              assetPath: '',
              seasonIndex: 0,
              episodeIndex: 0,
              locale: "en"
            )),
        '42');
  });
}
