//
//  VideoPlayerViewController.swift
//  Runner
//
//  Created by Sunnatillo Shavkatov on 21/04/22.
//

import UIKit
import TinyConstraints
import AVFoundation
import AVKit
import MediaPlayer
import XLActionController
import NVActivityIndicatorView
import SnapKit
import GoogleCast

/* The player state. */
enum PlaybackMode: Int {
    case none = 0
    case local
    case remote
}

enum CastSessionStatus {
    case started
    case resumed
    case ended
    case failedToStart
    case alreadyConnected
}

class VideoPlayerViewController: UIViewController, AVPictureInPictureControllerDelegate,  GCKRequestDelegate, SettingsBottomSheetCellDelegate, BottomSheetCellDelegate, PlayerViewDelegate {
    
    private var speedList = ["2.0","1.5","1.25","1.0","0.5"].sorted()
    
    private var pipController: AVPictureInPictureController!
    private var pipPossibleObservation: NSKeyValueObservation?
    /// chrome cast
    private var sessionManager: GCKSessionManager!
    private var castMediaController: GCKUIMediaController!
    private var volumeController: GCKUIDeviceVolumeController!
    private var playbackMode = PlaybackMode.none
    private var localPlaybackImplicitlyPaused: Bool = false
    ///
    weak var delegate: VideoPlayerDelegate?
    private var url: String?
    var qualityLabelText = ""
    var speedLabelText = ""
    var selectedSeason: Int = 0
    var selectSesonNum: Int = 0
    var isRegular: Bool = false
    var resolutions: [String:String]?
    var sortedResolutions: [String] = []
    var seasons : [Season] = [Season]()
    var qualityDelegate: QualityDelegate!
    var speedDelegte: SpeedDelegate!
    var playerConfiguration: PlayerConfiguration!
    private var isVolume = false
    private var volumeViewSlider: UISlider!
    private var playerRate: Float = 1.0
    private var selectedSpeedText = "1.0x"
    var selectedQualityText = "Auto"
    
    private var playerView: PlayerView = {
        return PlayerView()
    }()
    
    private var portraitConstraints = Constraints()
    private var landscapeConstraints = Constraints()
    
    init() {
        sessionManager = GCKCastContext.sharedInstance().sessionManager
        castMediaController = GCKUIMediaController()
        volumeController = GCKUIDeviceVolumeController()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupPictureInPicture() {
        if AVPictureInPictureController.isPictureInPictureSupported() {
            pipController = AVPictureInPictureController(playerLayer: playerView.playerLayer)
            pipController.delegate = self
            pipPossibleObservation = pipController.observe(\AVPictureInPictureController.isPictureInPicturePossible,
                                                            options: [.initial, .new]) { [weak self] _, change in
                self?.playerView.setIsPipEnabled(v: change.newValue ?? false)
            }
        } else {
            playerView.setIsPipEnabled(v: false)
        }
    }
    
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        playerView.isHiddenPiP(isPiP: true)
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        playerView.isHiddenPiP(isPiP: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        url = playerConfiguration.url
        title = playerConfiguration.title
        let resList = resolutions ?? ["480p":playerConfiguration.url]
        var k4 = false
        sortedResolutions = Array(resList.keys).sorted().reversed()
        Array(resList.keys).sorted().reversed().forEach { quality in
            if quality == "1080p" {
                sortedResolutions.removeLast()
                sortedResolutions.insert("1080p", at: k4 ? 2 : 1)
            }
            if quality == "4k" {
                if let index = sortedResolutions.firstIndex(of: quality) {
                    k4 = true
                    sortedResolutions.remove(at: index)
                    sortedResolutions.insert(quality, at: 1)
                }
            }
            if quality == "8k" {
                if let index = sortedResolutions.firstIndex(of: quality) {
                    sortedResolutions.remove(at: index)
                    sortedResolutions.insert(quality, at: 1)
                }
            }
        }
        
        view.backgroundColor = .black
        
        playerView.delegate = self
        playerView.playerConfiguration = playerConfiguration
        view.addSubview(playerView)
        playerView.edgesToSuperview()

        NotificationCenter.default.addObserver(self, selector: #selector(castDeviceDidChange),
                                               name: NSNotification.Name.gckCastStateDidChange,
                                               object: GCKCastContext.sharedInstance())
        
    }
    
    @objc func castDeviceDidChange(_: Notification) {
        if GCKCastContext.sharedInstance().castState != .noDevicesAvailable {
            GCKCastContext.sharedInstance().presentCastInstructionsViewControllerOnce(with: playerView.castButton)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        let hasConnectedSession: Bool = (sessionManager.hasConnectedSession())
        if hasConnectedSession, (playbackMode != .remote) {
            populateMediaInfo(false, playPosition: 0)
            switchToRemotePlayback()
        } else if sessionManager.currentSession == nil, (playbackMode != .local) {
            switchToLocalPlayback()
        } else {
            populateMediaInfo(false, playPosition: 0)
        }
        sessionManager.add(self)
        setupPictureInPicture()
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setNeedsUpdateOfHomeIndicatorAutoHidden()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        setNeedsUpdateOfHomeIndicatorAutoHidden()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        playerView.changeConstraints()
        if UIApplication.shared.statusBarOrientation == .landscapeLeft || UIApplication.shared.statusBarOrientation == .landscapeRight {
            addVideosLandscapeConstraints()
        } else {
            addVideoPortaitConstraints()
        }
    }
    
    //MARK: - Hide Home Indicator
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    //@available(iOS 11, *)
    override var childForHomeIndicatorAutoHidden: UIViewController? {
        return nil
    }
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return [.bottom]
    }
    
    func populateMediaInfo(_ autoPlay: Bool, playPosition: TimeInterval) {
        playerView.loadMedia(buildMediaInfo(position: playerView.streamPosition ?? 0, url: playerConfiguration.url), autoPlay: autoPlay, playPosition: playPosition, area: view.safeAreaLayoutGuide)
    }
    
    func switchToLocalPlayback() {
        if playbackMode == .local {
            return
        }
        var playPosition: TimeInterval = TimeInterval(playerConfiguration.lastPosition)
        var paused: Bool = false
        var ended: Bool = false
        if playbackMode == .remote {
            playPosition = castMediaController.lastKnownStreamPosition
            paused = (castMediaController.lastKnownPlayerState == .paused)
            ended = (castMediaController.lastKnownPlayerState == .idle)
        }
        populateMediaInfo((!paused && !ended), playPosition: playPosition)
        sessionManager.currentCastSession?.remoteMediaClient?.remove(self)
        playbackMode = .local
        playerView.playbackMode = playbackMode
    }
    
    func switchToRemotePlayback() {
        if playbackMode == .remote {
            return
        }
        // If we were playing locally, load the local media on the remote player
        if playbackMode == .local, (playerView.playerState != .stopped) {
            let mediaLoadRequestDataBuilder = GCKMediaLoadRequestDataBuilder()
            mediaLoadRequestDataBuilder.mediaInformation = buildMediaInfo(position: playerView.streamPosition ?? 0, url: playerConfiguration.url)
            mediaLoadRequestDataBuilder.autoplay = true
            mediaLoadRequestDataBuilder.startTime = playerView.streamPosition ?? 0
            mediaLoadRequestDataBuilder.credentials = "user-credentials"
            mediaLoadRequestDataBuilder.atvCredentials = "atv-user-credentials"
            
            let request = sessionManager.currentCastSession?.remoteMediaClient?.loadMedia(with: mediaLoadRequestDataBuilder.build())
            request?.delegate = self
        }
        sessionManager.currentCastSession?.remoteMediaClient?.add(self)
        sessionManager.currentSession?.remoteMediaClient?.add(self)
        playbackMode = .remote
        playerView.playbackMode = playbackMode
        playerView.stop()
        if playbackMode == .remote {
            let remoteMediaClient = sessionManager.currentSession?.remoteMediaClient
            playerRate = remoteMediaClient?.mediaStatus?.playbackRate ?? 1.0
            if remoteMediaClient?.mediaStatus?.mediaInformation?.contentURL != URL(string: url!){
                loadRemoteMedia(position: TimeInterval(0))
            }
        }
    }
    
    private func loadRemoteMedia(position: TimeInterval){
        if sessionManager == nil {
            return
        }
        let mediaLoadRequestDataBuilder = GCKMediaLoadRequestDataBuilder()
        if playbackMode == .local {
            mediaLoadRequestDataBuilder.mediaInformation = buildMediaInfo(position: position, url: url ?? "")
            mediaLoadRequestDataBuilder.startTime = position
        } else {
            let castSession = sessionManager.currentCastSession
            if castSession != nil {
                let remoteMediaClient = sessionManager.currentSession?.remoteMediaClient
                mediaLoadRequestDataBuilder.mediaInformation = buildMediaInfo(position: position, url: url ?? "")
                mediaLoadRequestDataBuilder.startTime = position
            }
        }
        mediaLoadRequestDataBuilder.autoplay = true
        mediaLoadRequestDataBuilder.credentials = "user-credentials"
        mediaLoadRequestDataBuilder.atvCredentials = "atv-user-credentials"
        let request = sessionManager.currentCastSession?.remoteMediaClient?.loadMedia(with: mediaLoadRequestDataBuilder.build())
        request?.delegate = self
    }
    
    private func buildMediaInfo(position: Double, url : String)-> GCKMediaInformation {
        /*GCKMediaMetadata configuration*/
        let metadata = GCKMediaMetadata()
        metadata.setString(title ?? "", forKey: kGCKMetadataKeyTitle)
        /*Loading media to cast by creating a media request*/
        let mediaInfoBuilder = GCKMediaInformationBuilder(contentURL: URL(string:
                                                                            url)!)
        mediaInfoBuilder.streamType = GCKMediaStreamType.buffered
        mediaInfoBuilder.contentType = "videos/m3u8"
        mediaInfoBuilder.metadata = metadata
        mediaInfoBuilder.streamDuration = position
        return mediaInfoBuilder.build()
    }
    
    func playbackRateRemote(playbackRate: Float){
        let castSession = sessionManager.currentCastSession
        if castSession != nil {
            let remoteMediaClient = sessionManager.currentSession?.remoteMediaClient
            remoteMediaClient?.setPlaybackRate(-Float(playbackRate))
        }
    }
    
    private func addVideosLandscapeConstraints() {
        portraitConstraints.deActivate()
        landscapeConstraints.append(contentsOf: playerView.edgesToSuperview())
    }
    
    private func addVideoPortaitConstraints() {
        landscapeConstraints.deActivate()
        portraitConstraints.append(contentsOf: playerView.center(in: view))
        portraitConstraints.append(contentsOf: playerView.edgesToSuperview())
    }
    
    func isCheckPlay(){
        let castSession = sessionManager.currentCastSession
        if castSession != nil {
            let remoteMediaClient = sessionManager.currentSession?.remoteMediaClient
            playerRate = remoteMediaClient?.mediaStatus?.playbackRate ?? 1.0
            playerView.setPlayButton(isPlay: remoteMediaClient?.mediaStatus?.playerState == .playing)
            let position = Float(remoteMediaClient?.approximateStreamPosition() ?? 0)
            self.playerView.setDuration(position: position)
        }
    }
    
    func skipForwardButtonPressed() {
        let castSession = sessionManager.currentCastSession
        if castSession != nil {
            let remoteClient = castSession?.remoteMediaClient
            if let position = remoteClient?.approximateStreamPosition() {
                let options = GCKMediaSeekOptions()
                options.interval = position + 10
                remoteClient?.seek(with: options)
            }
        } else {
            
        }
    }
    
    func skipBackButtonPressed() {
        let castSession = sessionManager.currentCastSession
        if castSession != nil {
            let remoteClient = castSession?.remoteMediaClient
            if let position = remoteClient?.approximateStreamPosition() {
                let options = GCKMediaSeekOptions()
                options.interval = position - 10
                remoteClient?.seek(with: options)
            }
        } else {
            
        }
    }
    
    func sliderValueChanged(value: Float) {
        let castSession = sessionManager.currentCastSession
        if castSession != nil {
            let remoteClient = castSession?.remoteMediaClient
            let options = GCKMediaSeekOptions()
            options.interval = TimeInterval(value)
            remoteClient?.seek(with: options)
        }
    }
    
    func volumeChanged(value: Float){
        let castSession = sessionManager.currentCastSession
        if castSession != nil {
            let remoteClient = castSession?.remoteMediaClient
            remoteClient?.setStreamVolume(value)
        }
    }
    
    func playButtonPressed() {
        let castSession = sessionManager.currentCastSession
        if castSession != nil {
            let remoteMediaClient = sessionManager.currentSession?.remoteMediaClient
            if (remoteMediaClient?.mediaStatus?.playerState == .playing) {
                remoteMediaClient?.pause()
            } else {
                remoteMediaClient?.play()
            }
            playerView.setPlayButton(isPlay: remoteMediaClient?.mediaStatus?.playerState != .playing)
        }
    }
    
    func showPressed() {
        let vc = ProgramViewController()
        vc.modalPresentationStyle = .custom
        vc.programInfo = self.playerConfiguration.programsInfoList
        vc.menuHeight = self.playerConfiguration.programsInfoList.isEmpty ? 250 : UIScreen.main.bounds.height * 0.75
        if !(vc.programInfo.isEmpty) {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func close(duration : Double){
        if UIApplication.shared.statusBarOrientation == .landscapeLeft || UIApplication.shared.statusBarOrientation == .landscapeRight {
            changeOrientation()
        }
        self.dismiss(animated: true, completion: nil)
        delegate?.getDuration(duration: duration)
    }
    
    func changeOrientation(){
        var value = UIInterfaceOrientation.landscapeRight.rawValue
        if UIApplication.shared.statusBarOrientation == .landscapeLeft || UIApplication.shared.statusBarOrientation == .landscapeRight {
            value = UIInterfaceOrientation.portrait.rawValue
        }
        if #available(iOS 16.0, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                       return
            }
            self.setNeedsUpdateOfSupportedInterfaceOrientations()
            windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: (UIApplication.shared.statusBarOrientation == .landscapeLeft || UIApplication.shared.statusBarOrientation == .landscapeRight) ? .portrait : .landscapeRight)){
                        error in
                        print(error)
                        print(windowScene.effectiveGeometry)
            }
        } else {
            UIDevice.current.setValue(value, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
    
    func updateSeasonNum(index:Int) {
        selectedSeason = index
    }
    
    //MARK: - ****** SEASONS *******
    func episodesButtonPressed(){
        let episodeVC = EpisodeCollectionUI()
        episodeVC.modalPresentationStyle = .custom
        episodeVC.seasons = self.seasons
        episodeVC.delegate = self
        episodeVC.selectedSeasonIndex = selectedSeason
        self.present(episodeVC, animated: true, completion: nil)
    }
    
    func settingsPressed() {
        let vc = SettingVC()
        vc.modalPresentationStyle = .custom
        vc.delegete = self
        vc.speedDelegate = self
        vc.settingModel = [
            SettingModel(leftIcon: Svg.settings.uiImage, title: qualityLabelText, configureLabel: selectedQualityText),
            SettingModel(leftIcon: Svg.playSpeed.uiImage, title: speedLabelText, configureLabel:  selectedSpeedText)
        ]
        self.present(vc, animated: true, completion: nil)
    }
    
    func togglePictureInPictureMode() {
        if pipController.isPictureInPictureActive {
            pipController.stopPictureInPicture()
        } else {
            pipController.startPictureInPicture()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "pip" {
            if self.pipController.isPictureInPictureActive {
                self.playerView.isHiddenPiP(isPiP: true)
            } else {
                self.playerView.isHiddenPiP(isPiP: false)
            }
        }
    }
    
    // settings bottom sheet tapped
    func onSettingsBottomSheetCellTapped(index: Int) {
        switch index {
        case 0:
            showQualityBottomSheet()
            break
        case 1:
            showSpeedBottomSheet()
            break
        case 2:
            //            showSubtitleBottomSheet()
            break
        case 3:
            //            showAudioTrackBottomSheet()
            break
        default:
            break
        }
    }
    
    //    //MARK: - Bottom Sheets Configurations
    // bottom sheet tapped
    func onBottomSheetCellTapped(index: Int, type : BottomSheetType) {
        switch type {
        case .quality:
            let resList = resolutions ?? ["480p":playerConfiguration.url]
            self.selectedQualityText = sortedResolutions[index]
            let url = resList[sortedResolutions[index]]
            self.playerView.changeQuality(url: url)
            self.url = url
            if playbackMode == .remote {
                self.loadRemoteMedia(position: sessionManager.currentSession?.remoteMediaClient?.approximateStreamPosition() ?? 0)
            }
            break
        case .speed:
            self.playerRate = Float(speedList[index])!
            self.selectedSpeedText = isRegular  ? "\(self.playerRate)x(Обычный)" : "\(self.playerRate)x"
            if playbackMode == .local {
                self.playerView.changeSpeed(rate: self.playerRate)
            } else {
                self.playbackRateRemote(playbackRate: self.playerRate)
            }
            break
        case .subtitle:
            break
        case .audio:
            break
        }
    }
    
    func showQualityBottomSheet(){
        let bottomSheetVC = BottomSheetViewController()
        bottomSheetVC.modalPresentationStyle = .overCurrentContext
        bottomSheetVC.items = sortedResolutions
        bottomSheetVC.labelText = qualityLabelText
        bottomSheetVC.cellDelegate = self
        bottomSheetVC.bottomSheetType = .quality
        bottomSheetVC.selectedIndex = sortedResolutions.firstIndex(of: selectedQualityText) ?? 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.present(bottomSheetVC, animated: false, completion:nil)
        }
    }
    
    func showSpeedBottomSheet(){
        let bottomSheetVC = BottomSheetViewController()
        bottomSheetVC.modalPresentationStyle = .custom
        bottomSheetVC.items = speedList
        bottomSheetVC.labelText = speedLabelText
        bottomSheetVC.cellDelegate = self
        bottomSheetVC.bottomSheetType = .speed
        bottomSheetVC.selectedIndex = speedList.firstIndex(of: "\(self.playerRate)") ?? 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.present(bottomSheetVC, animated: false, completion:nil)
        }
    }
    
    func getMegogoStream(parameters:[String:String], id:String) -> MegogoStreamResponse? {
        var megogoResponse:MegogoStreamResponse?
        let _url:String = playerConfiguration.baseUrl+"megogo/stream"
        let result = Networking.sharedInstance.getMegogoStream(_url, token: self.playerConfiguration.authorization, sessionId: id, parameters: parameters)
        switch result {
        case .failure(let error):
            print(error)
            break
        case .success(let success):
            megogoResponse = success
            break
        }
        return megogoResponse
        
    }
    
    func getPremierStream(episodeId:String) -> PremierStreamResponse?{
        let _url : String = playerConfiguration.baseUrl+"premier/videos/\(playerConfiguration.videoId)/episodes/\(episodeId)/stream"
        var premierSteamResponse: PremierStreamResponse?
        let result = Networking.sharedInstance.getPremierStream(_url, token: playerConfiguration.authorization, sessionId: playerConfiguration.sessionId)
        switch result {
        case .failure(let error):
            print(error)
        case .success(let success):
            premierSteamResponse = success
        }
        return premierSteamResponse
    }
    
    func playSeason(_resolutions : [String:String],startAt:Int64?,_episodeIndex:Int,_seasonIndex:Int ){
        self.selectedSeason = _seasonIndex
        self.selectSesonNum = _episodeIndex
        self.resolutions = SortFunctions.sortWithKeys(_resolutions)
        let isFinded = resolutions?.contains(where: { (key, value) in
            if key == self.selectedQualityText {
                return true
            }
            return false
        }) ?? false
        let title = seasons[_seasonIndex].movies[_episodeIndex].title ?? ""
        if isFinded {
            let videoUrl = self.resolutions?[selectedQualityText]
            guard videoUrl != nil else{
                return
            }
            guard URL(string: videoUrl!) != nil else {
                return
            }
            if self.playerConfiguration.url != videoUrl!{
                if playbackMode == .local{
                    self.playerView.changeUrl(url: videoUrl, title: "S\(_seasonIndex + 1)" + " " + "E\(_episodeIndex + 1)" + " \u{22}\(title)\u{22}" )
                    self.url = videoUrl
                } else {
                    self.title = "S\(_seasonIndex + 1)" + " " + "E\(_episodeIndex + 1)" + " \u{22}\(title)\u{22}"
                    self.url = videoUrl
                    self.loadRemoteMedia(position: TimeInterval(0))
                }
            } else {
                print("ERROR")
            }
            return
        } else if !self.resolutions!.isEmpty {
            if playbackMode == .local {
                let videoUrl = Array(resolutions!.values)[0]
                self.playerView.changeUrl(url: videoUrl, title: title)
                self.url = videoUrl
            } else {
                let videoUrl = Array(resolutions!.values)[0]
                self.url = videoUrl
                self.loadRemoteMedia(position: TimeInterval(0))
            }
            return
        }
    }
}

// MARK: - GCKRemoteMediaClientListener
extension VideoPlayerViewController : GCKRemoteMediaClientListener {
    func remoteMediaClient(remoteMedia: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        self.refreshContentInformation()
    }
    
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaMetadata: GCKMediaMetadata?) {
        
    }
    
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        self.refreshContentInformation()
    }
    
    func remoteMediaClient(_ client: GCKRemoteMediaClient, didReceive queueItems: [GCKMediaQueueItem]) {
        
    }
    
    fileprivate func refreshContentInformation(){
        let remoteMedia = self.sessionManager?.currentSession?.remoteMediaClient
        let position = Float(remoteMedia?.approximateStreamPosition() ?? 0)
        self.playerView.setDuration(position: position)
    }
    
}

// MARK: - GCKSessionManagerListener
extension VideoPlayerViewController: GCKSessionManagerListener {
    func sessionManager(_ sessionManager: GCKSessionManager, willStart session: GCKCastSession) {
        
    }
    
    func sessionManager(_: GCKSessionManager, didStart session: GCKSession) {
        print("MediaViewController: sessionManager didStartSession \(session)")
        self.switchToRemotePlayback()
    }
    
    func sessionManager(_ sessionManager: GCKSessionManager, didFailToStart session: GCKCastSession, withError error: Error) {
    }
    
    func sessionManager(_: GCKSessionManager, didResumeSession session: GCKSession) {
        print("MediaViewController: sessionManager didResumeSession \(session)")
        self.switchToRemotePlayback()
    }
    
    func sessionManager(_: GCKSessionManager, didEnd _: GCKSession, withError error: Error?) {
        print("session ended with error: \(String(describing: error))")
        self.switchToLocalPlayback()
    }
    
    func sessionManager(_ sessionManager: GCKSessionManager, willEnd session: GCKCastSession) {
        
    }
}

extension VideoPlayerViewController: QualityDelegate, SpeedDelegate, EpisodeDelegate {
    
    func onEpisodeCellTapped(seasonIndex: Int, episodeIndex: Int) {
        var resolutions: [String:String] = [:]
        var startAt :Int64?
        let episodeId : String = seasons[seasonIndex].movies[episodeIndex].id ?? ""
        if playerConfiguration.isMegogo {
            let parameters : [String:String] = ["video_id":episodeId,"access_token":self.playerConfiguration.megogoAccessToken]
            var success : MegogoStreamResponse?
            success = self.getMegogoStream(parameters: parameters,id: episodeId)
            if success != nil {
                
                resolutions[self.playerConfiguration.autoText] = success?.data.src
                success?.data.bitrates.forEach({ bitrate in
                    resolutions["\(bitrate.bitrate)p"] = bitrate.src
                })
                startAt = Int64(success?.data.playStartTime ?? 0)
                self.playSeason(_resolutions: resolutions, startAt: startAt, _episodeIndex: episodeIndex, _seasonIndex: seasonIndex)
            }
        }
        if playerConfiguration.isPremier {
            var success : PremierStreamResponse?
            success = self.getPremierStream(episodeId: episodeId)
            if success != nil {
                success?.fileInfo.forEach({ file in
                    if file.quality == "auto"{
                        resolutions[self.playerConfiguration.autoText] = file.fileName
                    } else {
                        resolutions["\(file.quality)"] = file.fileName
                    }
                })
                startAt = 0
                self.playSeason(_resolutions: resolutions, startAt: startAt, _episodeIndex: episodeIndex, _seasonIndex: seasonIndex)
            }
        }
        if !playerConfiguration.isMegogo && !playerConfiguration.isPremier {
            seasons[seasonIndex].movies[episodeIndex].resolutions.map { (key: String, value: String) in
                resolutions[key] = value
                startAt = 0
            }
            self.playSeason(_resolutions: resolutions, startAt: startAt, _episodeIndex: episodeIndex, _seasonIndex: seasonIndex)
        }
    }
    
    func speedBottomSheet() {
        showSpeedBottomSheet()
    }
    func qualityBottomSheet() {
        showQualityBottomSheet()
    }
}
// 1170
