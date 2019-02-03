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
        var error : Error?
        var playerItemErrorLogEvent : [AVPlayerItemErrorLogEvent]?
        var extendedLogData : Data?
        var extendedLogDataStringEncoding : UInt?
        
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
    
    
    public enum PlayerMediaFormat : String {
        case unknown
        case mpeg4
        case m3u8
        case mov
        case m4v
        case error
        
        init(_ URL: URL?) {
            guard let path = URL?.absoluteString else {
                self = .unknown
                return
            }
            if path.contains(".mp4") {
                self = .mpeg4
            } else if path.contains(".m3u8") {
                self = .m3u8
            } else if path.contains(".mov") {
                self = .mov
            } else if path.contains(".m4v") {
                self = .m4v
            } else {
                self = .unknown
            }
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
    
    var bufferState : PlayerBufferstate = .none {
        didSet {
            guard bufferState != oldValue else { return }
            displayView.bufferStateDidChange(bufferState)
            delegate?.player(self, bufferStateDidChange: bufferState)
        }
    }
    
    var displayView : SSBPlayerView
    var gravityMode = VideoGravityMode.resizeAspect
    var backgroundMode = PlayerBackgroundMode.autoPlayAndPaused
    var bufferInterval : TimeInterval = 2.0
    weak var delegate : SSBPlayerDelegate?
    fileprivate(set) var mediaFormat : PlayerMediaFormat
    fileprivate(set) var totalDuration : TimeInterval = 0.0
    fileprivate(set) var currentDuration : TimeInterval = 0.0
    fileprivate(set) var buffering = false
    fileprivate(set) var player : AVPlayer? {
        willSet{ removePlayerObservers() }
        didSet { addPlayerObservers() }
    }
    
    var timeObserver: Any?
    fileprivate(set) var playerItem : AVPlayerItem? {
        willSet {
            removePlayerItemObservers()
            removePlayerNotifations()
        }
        didSet {
            addPlayerItemObservers()
            addPlayerNotifications()
        }
    }
    
    fileprivate(set) var playerAsset : AVURLAsset?
    fileprivate(set) var contentURL : URL?
    fileprivate(set) var error = PlayerError()
    fileprivate var seeking  = false
    
    init(URL: URL? = nil, playerView: SSBPlayerView? = nil) {
        mediaFormat = PlayerMediaFormat(URL)
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
            let keys = ["tracks", "playable"];
            playerItem = AVPlayerItem(asset: playerAsset!, automaticallyLoadedAssetKeys: keys)
        } else {
            // remote add cache
            //            playerItem = resourceLoaderManager.playerItem(URL)
        }
        player = AVPlayer(playerItem: playerItem)
        displayView.reloadPlayerView()
    }
    
    func addPlayerObservers() {
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
        timeObserver = player?.addPeriodicTimeObserver(forInterval: .init(value: 1, timescale: 1),
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
        mediaFormat = SSBPlayer.PlayerMediaFormat(URL)
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
private var playerItemContext = 0

extension SSBPlayer {
    
    func addPlayerItemObservers() {
        let options = NSKeyValueObservingOptions([.new, .initial])
        playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: options, context: &playerItemContext)
        playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: options, context: &playerItemContext)
        playerItem?.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.playbackBufferEmpty), options: options, context: &playerItemContext)
    }
    
    func addPlayerNotifications() {
        NotificationCenter.default.addObserver(self, selector: .playerItemDidPlayToEndTime, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: .applicationWillEnterForeground, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: .applicationDidEnterBackground, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    func removePlayerItemObservers() {
        playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges))
        playerItem?.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.playbackBufferEmpty))
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
        
        if let playerLayer = displayView.playerLayer  {
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
        //        if let playerLayer = displayView.playerLayer  {
        //            playerLayer.player = nil
        //        }
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

extension SSBPlayer {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        switch keyPath {
            
        case #keyPath(AVPlayerItem.status):
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            switch status {
            case .unknown:
                startPlayerBuffering()
            case .readyToPlay:
                bufferState = .readyToPlay
            case .failed:
                state = .error
                collectPlayerErrorLogEvent()
                stopPlayerBuffering()
                delegate?.player(self, playerFailed: error)
                displayView.playFailed(error)
            }
            
        case #keyPath(AVPlayerItem.playbackBufferEmpty) where change?[.newKey] as? Bool == true:
            startPlayerBuffering()
            
        case  #keyPath(AVPlayerItem.loadedTimeRanges): // 计算缓冲
            guard let loadedTimeRanges = player?.currentItem?.loadedTimeRanges,
                let bufferTimeRange = loadedTimeRanges.first?.timeRangeValue else {
                    return
            }
            let star = bufferTimeRange.start.seconds         // The start time of the time range.
            let duration = bufferTimeRange.duration.seconds  // The duration of the time range.
            let bufferTime = star + duration
            if let itemDuration = playerItem?.duration.seconds {
                delegate?.player(self, bufferedDidChange: bufferTime, totalDuration: itemDuration)
                displayView.bufferedDidChange(bufferTime, totalDuration: itemDuration)
                totalDuration = itemDuration
                if itemDuration == bufferTime {
                    bufferState = .bufferFinished
                }
            }
            if let currentTime = playerItem?.currentTime().seconds {
                if (bufferTime - currentTime) >= bufferInterval, state != .paused {
                    play()
                }
                if (bufferTime - currentTime) < bufferInterval {
                    bufferState = .buffering
                    buffering = true
                } else {
                    buffering = false
                    bufferState = .readyToPlay
                }
            }
        default:
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
