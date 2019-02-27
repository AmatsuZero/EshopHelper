//
//  SSBPlayer.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/2.
//  Copyright © 2019 Daubert. All rights reserved.
//

import AVFoundation

protocol SSBPlayerDelegate: class {

    func player(_ player: SSBPlayer, stateDidChange state: SSBPlayer.PlayerState)
    func player(_ player: SSBPlayer, playerDurationDidChange currentDuration: TimeInterval, totalDuration: TimeInterval)
    func player(_ player: SSBPlayer, bufferStateDidChange state: SSBPlayer.PlayerBufferstate)
    func player(_ player: SSBPlayer, bufferedDidChange bufferedDuration: TimeInterval, totalDuration: TimeInterval)
    func player(_ player: SSBPlayer, playerFailed error: SSBPlayer.PlayerError)
}

extension SSBPlayerDelegate {
    func player(_ player: SSBPlayer, stateDidChange state: SSBPlayer.PlayerState) {}
    func player(_ player: SSBPlayer, playerDurationDidChange currentDuration: TimeInterval, totalDuration: TimeInterval) {}
    func player(_ player: SSBPlayer, bufferStateDidChange state: SSBPlayer.PlayerBufferstate) {}
    func player(_ player: SSBPlayer, bufferedDidChange bufferedDuration: TimeInterval, totalDuration: TimeInterval) {}
    func player(_ player: SSBPlayer, playerFailed error: SSBPlayer.PlayerError) {}
}

class SSBPlayer: NSObject {
    public struct PlayerError: CustomStringConvertible {
        var error: Error?
        var playerItemErrorLogEvent: [AVPlayerItemErrorLogEvent]?
        var extendedLogData: Data?
        var extendedLogDataStringEncoding: UInt?
        public var description: String {
            return """
            VGPlayer Log --------------------------
            error: \(String(describing: error))
            playerItemErrorLogEvent: \(String(describing: playerItemErrorLogEvent))
            extendedLogData: \(String(describing: extendedLogData))
            extendedLogDataStringEncoding \(String(describing: extendedLogDataStringEncoding))
            --------------------------
            """
        }
    }
    public enum PlayerMediaFormat: String {
        case unknown
        case mpeg4 = ".mp4"
        case m3u8 = ".m3u8"
        case mov = ".mov"
        case m4v = ".m4v"
        case error
        init?(_ URL: URL?) {
            guard let ext = URL?.pathExtension else {
                self = .error
                return
            }
            self.init(rawValue: ext)
        }
    }
    public enum PlayerState: Int {
        case none            // default
        case playing
        case paused
        case playFinished
        case error
    }
    public enum PlayerBufferstate: Int {
        case none           // default
        case readyToPlay
        case buffering
        case stop
        case bufferFinished
    }
    public enum VideoGravityMode: Int {
        case resize
        case resizeAspect      // default
        case resizeAspectFill
    }
    public enum PlayerBackgroundMode: Int {
        case suspend
        case autoPlayAndPaused
        case proceed
    }
    var state: PlayerState = .none {
        didSet {
            guard state != oldValue else { return }
            displayView.playStateDidChange(state)
            delegate?.player(self, stateDidChange: state)
        }
    }
    var bufferState: PlayerBufferstate = .none {
        didSet {
            guard bufferState != oldValue else { return }
            displayView.bufferStateDidChange(bufferState)
            delegate?.player(self, bufferStateDidChange: bufferState)
        }
    }

    var displayView: SSBPlayerView
    var gravityMode = VideoGravityMode.resizeAspect
    var backgroundMode = PlayerBackgroundMode.autoPlayAndPaused
    var bufferInterval: TimeInterval = 2.0
    weak var delegate: SSBPlayerDelegate?
    fileprivate(set) var mediaFormat: PlayerMediaFormat
    fileprivate(set) var totalDuration: TimeInterval = 0.0
    fileprivate(set) var currentDuration: TimeInterval = 0.0
    fileprivate(set) var buffering = false
    fileprivate(set) var player: AVPlayer? {
        willSet { removePlayerObservers() }
        didSet { addPlayerObservers() }
    }
    var timeObserver: Any?
    fileprivate(set) var playerItem: AVPlayerItem? {
        willSet {
            removePlayerItemObservers()
            removePlayerNotifations()
        }
        didSet {
            addPlayerItemObservers()
            addPlayerNotifications()
        }
    }
    fileprivate(set) var playerAsset: AVURLAsset?
    fileprivate(set) var contentURL: URL?
    fileprivate(set) var error = PlayerError()
    fileprivate var seeking  = false
    var statusObserver: NSKeyValueObservation?
    var loadTimeRangesObserver: NSKeyValueObservation?
    var playbackBufferEmptyObserver: NSKeyValueObservation?
    init(URL: URL? = nil, playerView: SSBPlayerView? = nil) {
        mediaFormat = PlayerMediaFormat(URL) ?? .error
        contentURL = URL
        displayView = playerView ?? SSBPlayerView()
        super.init()
        if let url = contentURL {
            configurationPlayer(url)
        }
    }
    deinit {
        removePlayerNotifations()
        cleanPlayer()
        displayView.removeFromSuperview()
        NotificationCenter.default.removeObserver(self)
    }
    func configurationPlayer(_ URL: URL) {
        displayView.setPlayer(player: self)
        playerAsset = AVURLAsset(url: URL, options: .none)
        if URL.absoluteString.hasPrefix("file:///") {
            let keys = ["tracks", "playable"]
            playerItem = AVPlayerItem(asset: playerAsset!, automaticallyLoadedAssetKeys: keys)
        } else {
            playerItem = AVPlayerItem(asset: .init(url: URL))
            if #available(iOS 9.0, *) {
                playerItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = true
            }
        }
        player = AVPlayer(playerItem: playerItem)
        displayView.reloadPlayerView()
    }
    func addPlayerObservers() {
        guard let player = self.player else {
            return
        }
        let block: (CMTime) -> Void = { [weak self] _ in
            guard let self = self,
                let currentTime = self.player?.currentTime().seconds,
                let totalDuration = self.player?.currentItem?.duration.seconds else {
                    return
            }
            self.currentDuration = currentTime
            self.delegate?.player(self, playerDurationDidChange: currentTime, totalDuration: totalDuration)
            self.displayView.playerDurationDidChange(currentTime, totalDuration: totalDuration)
        }
        timeObserver = player.addPeriodicTimeObserver(forInterval: .init(value: 1, timescale: 1),
                                                      queue: DispatchQueue.main,
                                                      using: block)
    }
    func removePlayerObservers() {
        guard let observer = timeObserver else {
            return
        }
        player?.removeTimeObserver(observer)
    }
    func replaceVideo(_ URL: URL) {
        reloadPlayer()
        mediaFormat = SSBPlayer.PlayerMediaFormat(URL) ?? .error
        contentURL = URL
        configurationPlayer(URL)
    }
    func reloadPlayer() {
        seeking = false
        totalDuration = 0.0
        currentDuration = 0.0
        error = SSBPlayer.PlayerError()
        state = .none
        buffering = false
        bufferState = .none
        cleanPlayer()
    }
    func cleanPlayer() {
        player?.pause()
        player?.cancelPendingPrerolls()
        player?.replaceCurrentItem(with: nil)
        player = nil
        playerAsset?.cancelLoading()
        playerAsset = nil
        playerItem?.cancelPendingSeeks()
        playerItem = nil
    }
    func play() {
        guard contentURL != nil else { return }
        player?.play()
        state = .playing
        displayView.play()
    }
    func pause() {
        guard state != .paused else {
            return
        }
        player?.pause()
        state = .paused
        displayView.pause()
    }
    func seekTime(_ time: TimeInterval) {
        seekTime(time, completion: nil)
    }
    func seekTime(_ time: TimeInterval, completion: ((Bool) -> Void)?) {
        if time.isNaN || playerItem?.status != .readyToPlay {
            if completion != nil {
                completion!(false)
            }
            return
        }
        let block: (Bool) -> Void = { [weak self] finished in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.seeking = false
                self.stopPlayerBuffering()
                self.play()
                if completion != nil {
                    completion!(finished)
                }
            }
        }
        DispatchQueue.main.async { [weak self]  in
            guard let self = self else { return }
            self.seeking = true
            self.startPlayerBuffering()
            self.playerItem?
                .seek(to: CMTimeMakeWithSeconds(time,
                                                preferredTimescale: Int32(NSEC_PER_SEC)),
                      completionHandler: block)
        }
    }
    private func startPlayerBuffering() {
        pause()
        bufferState = .buffering
        buffering = true
    }
    private func stopPlayerBuffering() {
        bufferState = .stop
        buffering = false
    }
    private func collectPlayerErrorLogEvent() {
        error.playerItemErrorLogEvent = playerItem?.errorLog()?.events
        error.error = playerItem?.error
        error.extendedLogData = playerItem?.errorLog()?.extendedLogData()
        error.extendedLogDataStringEncoding = playerItem?.errorLog()?.extendedLogDataStringEncoding
    }
}

// MARK: - Notifation Selector & KVO
extension SSBPlayer {
    func addPlayerItemObservers() {
        addStatusObserver()
        addLoadedTimeRanges()
        addPlaybackBufferEmptyObserver()
    }
    func addStatusObserver() {
        statusObserver = playerItem?.observe(\.status,
                                             options: [.new, .initial],
                                             changeHandler: { [weak self] (_, change) in
                                                guard let self = self else { return }
                                                let status: AVPlayerItem.Status = change.newValue ?? .unknown
                                                switch status {
                                                case .unknown:
                                                    self.startPlayerBuffering()
                                                case .readyToPlay:
                                                    self.bufferState = .readyToPlay
                                                case .failed:
                                                    self.state = .error
                                                    self.collectPlayerErrorLogEvent()
                                                    self.stopPlayerBuffering()
                                                    self.delegate?.player(self, playerFailed: self.error)
                                                    self.displayView.playFailed(self.error)
                                                }
        })
    }
    func addPlaybackBufferEmptyObserver() {
        playbackBufferEmptyObserver = playerItem?.observe(\.isPlaybackBufferEmpty,
                                                          options: [.new, .initial],
                                                          changeHandler: { [weak self] (_, _) in
                                                            self?.startPlayerBuffering()
        })
    }
    func addLoadedTimeRanges() {
        loadTimeRangesObserver = playerItem?.observe(\.loadedTimeRanges,
                                                     options: [.new, .initial],
                                                     changeHandler: { [weak self] (_, _) in
                                                        guard let self = self,
                                                            let loadedTimeRanges = self.player?.currentItem?.loadedTimeRanges,
                                                            let bufferTimeRange = loadedTimeRanges.first?.timeRangeValue else {
                                                                return
                                                        }
                                                        let star = bufferTimeRange.start.seconds         // The start time of the time range.
                                                        let duration = bufferTimeRange.duration.seconds  // The duration of the time range.
                                                        let bufferTime = star + duration
                                                        if let itemDuration = self.playerItem?.duration.seconds {
                                                            self.delegate?.player(self, bufferedDidChange: bufferTime, totalDuration: itemDuration)
                                                            self.displayView.bufferedDidChange(bufferTime, totalDuration: itemDuration)
                                                            self.totalDuration = itemDuration
                                                            if itemDuration == bufferTime {
                                                                self.bufferState = .bufferFinished
                                                            }
                                                        }
                                                        if let currentTime = self.playerItem?.currentTime().seconds {
                                                            if (bufferTime - currentTime) >= self.bufferInterval,
                                                                self.state != .paused {
                                                                self.play()
                                                            }
                                                            if (bufferTime - currentTime) < self.bufferInterval {
                                                                self.bufferState = .buffering
                                                                self.buffering = true
                                                            } else {
                                                                self.buffering = false
                                                                self.bufferState = .readyToPlay
                                                            }
                                                        }
        })
    }
    func addPlayerNotifications() {
        NotificationCenter.default.addObserver(self, selector: .playerItemDidPlayToEndTime,
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: .applicationWillEnterForeground,
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: .applicationDidEnterBackground,
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }
    func removePlayerItemObservers() {
        statusObserver?.invalidate()
        loadTimeRangesObserver?.invalidate()
        playbackBufferEmptyObserver?.invalidate()
    }
    func removePlayerNotifations() {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    @objc func playerItemDidPlayToEnd(_ notification: Notification) {
        if state != .playFinished {
            state = .playFinished
        }
    }
    @objc func applicationWillEnterForeground(_ notification: Notification) {
        if let playerLayer = displayView.playerLayer {
            playerLayer.player = player
        }
        switch self.backgroundMode {
        case .suspend:
            pause()
        case .autoPlayAndPaused:
            play()
        case .proceed:
            break
        }
    }
    @objc func applicationDidEnterBackground(_ notification: Notification) {
        if let playerLayer = displayView.playerLayer {
            playerLayer.player = nil
        }
        switch self.backgroundMode {
        case .suspend:
            pause()
        case .autoPlayAndPaused:
            pause()
        case .proceed:
            play()
        }
    }
}

// MARK: - Selecter
extension Selector {
    static let playerItemDidPlayToEndTime = #selector(SSBPlayer.playerItemDidPlayToEnd(_:))
    static let applicationWillEnterForeground = #selector(SSBPlayer.applicationWillEnterForeground(_:))
    static let applicationDidEnterBackground = #selector(SSBPlayer.applicationDidEnterBackground(_:))
}
