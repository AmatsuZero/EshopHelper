//
//  SSBPlayerView.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/2/2.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit
import SnapKit
import MediaPlayer

protocol SSBPlayerViewDelegate: class {
    func playerView(_ playerView: SSBPlayerView, willFullscreen isFullscreen: Bool)
    func playerView(didTappedClose playerView: SSBPlayerView)
    func playerView(didDisplayControl playerView: SSBPlayerView)
    
    func onEnterFullScreen(_ player: SSBPlayerView)
    func oneExitFullScreen(_ player: SSBPlayerView)
}

extension SSBPlayerViewDelegate {
    func playerView(_ playerView: SSBPlayerView, willFullscreen isFullscreen: Bool) {}
    func playerView(didTappedClose playerView: SSBPlayerView) {}
    func playerView(didDisplayControl playerView: SSBPlayerView) {}
    func onEnterFullScreen(_ player: SSBPlayerView) {}
    func oneExitFullScreen(_ player: SSBPlayerView) {}
}

class SSBPlayerView: UIView {
    
    enum PanGestureDirection {
        case vertical
        case horizontal
    }
    
    weak var player : SSBPlayer?
    var controlViewDuration : TimeInterval = 5.0  /// default 5.0
    fileprivate(set) var playerLayer : AVPlayerLayer?
    fileprivate(set) var isFullScreen = false
    fileprivate(set) var isTimeSliding = false
    fileprivate(set) var isDisplayControl  = true {
        didSet {
            if isDisplayControl != oldValue {
                delegate?.playerView(didDisplayControl: self)
            }
        }
    }
    
    weak var delegate : SSBPlayerViewDelegate?
    
    // top view
    var topView : UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        return view
    }()
    
    var titleLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        label.font = UIFont.boldSystemFont(ofSize: 16.0)
        return label
    }()
    
    var closeButton : UIButton = {
        let button = UIButton(type: .custom)
        return button
    }()
    
    // bottom view
    var bottomView : UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        return view
    }()
    var timeSlider = SSBPlayerSlider ()
    var loadingIndicator = SSBPlayerLoadingIndicator()
    var fullscreenButton = UIButton(type: .custom)
    var timeLabel = UILabel()
    var playButton = UIButton(type: .custom)
    var volumeSlider : UISlider!
    var replayButton = UIButton(type: .custom)
    fileprivate(set) var panGestureDirection = PanGestureDirection.horizontal
    var isVolume = false
    var sliderSeekTimeValue = TimeInterval.nan
    fileprivate var timer = Timer()
    fileprivate weak var parentView : UIView?
    fileprivate var viewFrame = CGRect.zero
    
    // GestureRecognizer
    var singleTapGesture = UITapGestureRecognizer()
    var doubleTapGesture = UITapGestureRecognizer()
    var panGesture = UIPanGestureRecognizer()
    
    override init(frame: CGRect) {
        self.playerLayer = AVPlayerLayer(player: nil)
        super.init(frame: frame)
        addDeviceOrientationNotifications()
        addGestureRecognizer()
        configurationVolumeSlider()
        configurationUI()
    }
    
    public convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        timer.invalidate()
        playerLayer?.removeFromSuperlayer()
        NotificationCenter.default.removeObserver(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateDisplayerView(frame: bounds)
    }
    
    func setPlayer(player: SSBPlayer) {
        self.player = player
    }
    
    func reloadPlayerLayer() {
        playerLayer = AVPlayerLayer(player: player?.player)
        layer.insertSublayer(playerLayer!, at: 0)
        updateDisplayerView(frame: bounds)
        timeSlider.isUserInteractionEnabled = player?.mediaFormat != .m3u8
        reloadGravity()
    }
    
    func playStateDidChange(_ state: SSBPlayer.PlayerState) {
        playButton.isSelected = state == .playing
        replayButton.isHidden = !(state == .playFinished)
        replayButton.isHidden = !(state == .playFinished)
        if state == .playing || state == .playFinished {
            setupTimer()
        }
        if state == .playFinished {
            loadingIndicator.isHidden = true
        }
    }
    
    func bufferStateDidChange(_ state: SSBPlayer.PlayerBufferstate) {
        if state == .buffering {
            loadingIndicator.isHidden = false
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.isHidden = true
            loadingIndicator.stopAnimating()
        }
        var current = formatSecondsToString((player?.currentDuration)!)
        if (player?.totalDuration.isNaN)! {  // HLS
            current = "00:00"
        }
        if state == .readyToPlay && !isTimeSliding {
            timeLabel.text = "\(current + " / " +  (formatSecondsToString((player?.totalDuration)!)))"
        }
    }
    
    func bufferedDidChange(_ bufferedDuration: TimeInterval, totalDuration: TimeInterval) {
        timeSlider.setProgress(Float(bufferedDuration / totalDuration), animated: true)
    }
    
    
    func playerDurationDidChange(_ currentDuration: TimeInterval, totalDuration: TimeInterval) {
        var current = formatSecondsToString(currentDuration)
        if totalDuration.isNaN {  // HLS
            current = "00:00"
        }
        if !isTimeSliding {
            timeLabel.text = "\(current + " / " +  (formatSecondsToString(totalDuration)))"
            timeSlider.value = Float(currentDuration / totalDuration)
        }
    }
    
    func configurationUI() {
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        configurationTopView()
        configurationBottomView()
        configurationReplayButton()
        setupViewAutoLayout()
    }
    
    func reloadPlayerView() {
        playerLayer = AVPlayerLayer(player: nil)
        timeSlider.value = Float(0)
        timeSlider.setProgress(0, animated: false)
        replayButton.isHidden = true
        isTimeSliding = false
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        timeLabel.text = "--:-- / --:--"
        reloadPlayerLayer()
    }
    
    func displayControlView(_ isDisplay:Bool) {
        if isDisplay {
            displayControlAnimation()
        } else {
            hiddenControlAnimation()
        }
    }
    
    func play() {
        playButton.isSelected = true
    }
    
    func pause() {
        playButton.isSelected = false
    }
    
    func displayControlAnimation() {
        bottomView.isHidden = false
        topView.isHidden = false
        isDisplayControl = true
        UIView.animate(withDuration: 0.5, animations: {
            self.bottomView.alpha = 1
            self.topView.alpha = 1
        }) { _ in
            self.setupTimer()
        }
    }
    internal func hiddenControlAnimation() {
        timer.invalidate()
        isDisplayControl = false
        UIView.animate(withDuration: 0.5, animations: {
            self.bottomView.alpha = 0
            self.topView.alpha = 0
        }) { _ in
            self.bottomView.isHidden = true
            self.topView.isHidden = true
        }
    }
    
    func setupTimer() {
        timer.invalidate()
        timer = Timer.ssbPlayerScheduledTimerWithTimeInterval(self.controlViewDuration,
                                                              block: {  [weak self]  in
                                                                guard let self = self else { return }
                                                                self.displayControlView(false)
            }, repeats: false)
    }
    
    func addDeviceOrientationNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationWillChange(_:)), name: UIApplication.willChangeStatusBarOrientationNotification, object: nil)
    }
    
    func configurationVolumeSlider() {
        let volumeView = MPVolumeView()
        if let view = volumeView.subviews.first as? UISlider {
            volumeSlider = view
        }
    }
}

// MARK: - public
extension SSBPlayerView {
    
    func updateDisplayerView(frame: CGRect) {
        playerLayer?.frame = frame
    }
    
    func reloadGravity() {
        guard let mode = player?.gravityMode else {
            return
        }
        switch mode {
        case .resize:
            playerLayer?.videoGravity = .resize
        case .resizeAspect:
            playerLayer?.videoGravity = .resizeAspect
        case .resizeAspectFill:
            playerLayer?.videoGravity = .resizeAspectFill
        }
    }
    
    func enterFullscreen() {
        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        if statusBarOrientation == .portrait{
            parentView = (self.superview)!
            viewFrame = self.frame
        }
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        if let delegate = self.delegate {
            delegate.onEnterFullScreen(self)
        }
    }
    
    func exitFullscreen() {
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        if let delegate = self.delegate {
            delegate.oneExitFullScreen(self)
        }
    }
    
    func playFailed(_ error: SSBPlayer.PlayerError) {
        // error
    }
    
    func formatSecondsToString(_ seconds: TimeInterval) -> String {
        if seconds.isNaN {
            return "00:00"
        }
        let interval = Int(seconds)
        let sec = Int(seconds.truncatingRemainder(dividingBy: 60))
        let min = interval / 60
        return String(format: "%02d:%02d", min, sec)
    }
}


// MARK: - GestureRecognizer
extension SSBPlayerView {
    
    func addGestureRecognizer() {
        singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(onSingleTapGesture(_:)))
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.numberOfTouchesRequired = 1
        singleTapGesture.delegate = self
        addGestureRecognizer(singleTapGesture)
        
        doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(onDoubleTapGesture(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.numberOfTouchesRequired = 1
        doubleTapGesture.delegate = self
        addGestureRecognizer(doubleTapGesture)
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPanGesture(_:)))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
        
        singleTapGesture.require(toFail: doubleTapGesture)
    }
    
}

// MARK: - UIGestureRecognizerDelegate
extension SSBPlayerView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldReceive touch: UITouch) -> Bool {
        return touch.view as? SSBPlayerView != nil
    }
}

// MARK: - Event
extension SSBPlayerView {
    
    @objc func timeSliderValueChanged(_ sender: SSBPlayerSlider) {
        isTimeSliding = true
        if let duration = player?.totalDuration {
            let currentTime = Double(sender.value) * duration
            timeLabel.text = "\(formatSecondsToString(currentTime) + " / " +  (formatSecondsToString(duration)))"
        }
    }
    
    @objc func timeSliderTouchDown(_ sender: SSBPlayerSlider) {
        isTimeSliding = true
        timer.invalidate()
    }
    
    @objc func timeSliderTouchUpInside(_ sender: SSBPlayerSlider) {
        isTimeSliding = true
        
        if let duration = player?.totalDuration {
            let currentTime = Double(sender.value) * duration
            player?.seekTime(currentTime, completion: { [weak self] (finished) in
                guard let strongSelf = self else { return }
                if finished {
                    strongSelf.isTimeSliding = false
                    strongSelf.setupTimer()
                }
            })
            timeLabel.text = "\(formatSecondsToString(currentTime) + " / " +  (formatSecondsToString(duration)))"
        }
    }
    
    @objc func onPlayerButton(_ sender: UIButton) {
        if !sender.isSelected {
            player?.play()
        } else {
            player?.pause()
        }
    }
    
    @objc func onFullscreen(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        isFullScreen = sender.isSelected
        if isFullScreen {
            enterFullscreen()
        } else {
            exitFullscreen()
        }
    }
    
    
    /// Single Tap Event
    ///
    /// - Parameter gesture: Single Tap Gesture
    @objc open func onSingleTapGesture(_ gesture: UITapGestureRecognizer) {
        isDisplayControl = !isDisplayControl
        displayControlView(isDisplayControl)
    }
    
    /// Double Tap Event
    ///
    /// - Parameter gesture: Double Tap Gesture
    @objc open func onDoubleTapGesture(_ gesture: UITapGestureRecognizer) {
        guard let state = player?.state else {
            return
        }
        switch state {
        case .playing:
            player?.pause()
        case .paused:
            player?.play()
        default:
            break
        }
    }
    
    @objc func onPanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let location = gesture.location(in: self)
        let velocity = gesture.velocity(in: self)
        switch gesture.state {
        case .began:
            let x = abs(translation.x)
            let y = abs(translation.y)
            if x < y {
                panGestureDirection = .vertical
                isVolume = location.x > bounds.width / 2
            } else if x > y, player?.mediaFormat != .m3u8 {
                panGestureDirection = .horizontal
            }
        case .changed:
            switch panGestureDirection {
            case .horizontal where player?.currentDuration != 0:
                sliderSeekTimeValue = panGestureHorizontal(velocity.x)
            case .vertical:
                panGestureVertical(velocity.y)
            default: break
            }
        case .ended:
            switch panGestureDirection {
            case .horizontal where !sliderSeekTimeValue.isNaN:
                player?.seekTime(sliderSeekTimeValue, completion: { [weak self] finished in
                    guard let self = self else { return }
                    if finished {
                        self.isTimeSliding = false
                        self.setupTimer()
                    }
                })
            case .vertical: isVolume = false
            default: break
            }
        default: break
        }
    }
    
    internal func panGestureHorizontal(_ velocityX: CGFloat) -> TimeInterval {
        displayControlView(true)
        isTimeSliding = true
        timer.invalidate()
        let value = timeSlider.value
        if  player?.currentDuration != nil,
            let totalDuration = player?.totalDuration {
            let sliderValue = (TimeInterval(value) *  totalDuration) + TimeInterval(velocityX) / 100.0 * (TimeInterval(totalDuration) / 400)
            timeSlider.setValue(Float(sliderValue/totalDuration), animated: true)
            return sliderValue
        } else {
            return .nan
        }
        
    }
    
    func panGestureVertical(_ velocityY: CGFloat) {
        isVolume ? (volumeSlider.value -= Float(velocityY / 10000))
            : (UIScreen.main.brightness -= velocityY / 10000)
    }
    
    @objc func onCloseView(_ sender: UIButton) {
        delegate?.playerView(didTappedClose: self)
    }
    
    @objc internal func onReplay(_ sender: UIButton) {
        player?.replaceVideo((player?.contentURL)!)
        player?.play()
    }
    
    @objc func deviceOrientationWillChange(_ sender: Notification) {
        let orientation = UIDevice.current.orientation
        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        if statusBarOrientation == .portrait, superview != nil {
            parentView = superview
            viewFrame = frame
        }
        switch orientation {
        case .landscapeLeft: onDeviceOrientation(true, orientation: .landscapeLeft)
        case .landscapeRight: onDeviceOrientation(true, orientation: .landscapeRight)
        case .portrait: onDeviceOrientation(false, orientation: .portrait)
        case .portraitUpsideDown: onDeviceOrientation(false, orientation: .portraitUpsideDown)
        default: return
        }
    }
    
    func onDeviceOrientation(_ fullScreen: Bool, orientation: UIInterfaceOrientation) {
        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        if orientation == statusBarOrientation {
            switch orientation {
            case .landscapeLeft where superview != nil:
                let rectInWindow = convert(bounds, to: UIApplication.shared.keyWindow)
                removeFromSuperview()
                frame = rectInWindow
                UIApplication.shared.keyWindow?.addSubview(self)
                snp.remakeConstraints { $0.size.equalToSuperview() }
            default:
                break
            }
        } else {
            switch orientation {
            case .landscapeRight, .landscapeLeft:
                guard superview != nil else { return }
                let rectInWindow = convert(bounds, to: UIApplication.shared.keyWindow)
                removeFromSuperview()
                frame = rectInWindow
                UIApplication.shared.keyWindow?.addSubview(self)
                snp.remakeConstraints { $0.size.equalToSuperview() }
            case .portrait where parentView != nil:
                removeFromSuperview()
                parentView!.addSubview(self)
                let frame = parentView!.convert(viewFrame, to: UIApplication.shared.keyWindow)
                snp.remakeConstraints { (make) in
                    make.center.equalToSuperview()
                    make.size.equalTo(frame.size)
                }
                viewFrame = .zero
                parentView = nil
            default:
                break
            }
        }
        isFullScreen = fullScreen
        fullscreenButton.isSelected = fullScreen
        delegate?.playerView(self, willFullscreen: isFullScreen)
    }
}

//MARK: - UI autoLayout
extension SSBPlayerView {
    
    func configurationReplayButton() {
        addSubview(replayButton)
        let replayImage = UIImage(named: "VGPlayer_ic_replay")!
        replayButton.setImage(replayImage.newImage(scaledToSize: .init(width: 30, height: 30)), for: .normal)
        replayButton.addTarget(self, action: #selector(onReplay(_:)), for: .touchUpInside)
        replayButton.isHidden = true
    }
    
    func configurationTopView() {
        addSubview(topView)
        titleLabel.text = ""
        topView.addSubview(titleLabel)
        let closeImage = UIImage(named: "VGPlayer_ic_nav_back")
        closeButton.setImage(closeImage?.newImage(scaledToSize: .init(width: 15, height: 20)), for: .normal)
        closeButton.addTarget(self, action: #selector(onCloseView(_:)), for: .touchUpInside)
        topView.addSubview(closeButton)
    }
    
    func configurationBottomView() {
        addSubview(bottomView)
        timeSlider.addTarget(self, action: #selector(timeSliderValueChanged(_:)),
                             for: .valueChanged)
        timeSlider.addTarget(self, action: #selector(timeSliderTouchUpInside(_:)), for: .touchUpInside)
        timeSlider.addTarget(self, action: #selector(timeSliderTouchDown(_:)), for: .touchDown)
        loadingIndicator.lineWidth = 1.0
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        addSubview(loadingIndicator)
        bottomView.addSubview(timeSlider)
        
        let playImage = UIImage(named: "VGPlayer_ic_play")!
        let pauseImage = UIImage(named: "VGPlayer_ic_pause")!
        
        playButton.setImage(playImage.newImage(scaledToSize: .init(width: 15, height: 15)),
                            for: .normal)
        playButton.setImage(pauseImage.newImage(scaledToSize: .init(width: 15, height: 15)), for: .selected)
        playButton.addTarget(self, action: #selector(onPlayerButton(_:)), for: .touchUpInside)
        bottomView.addSubview(playButton)
        
        timeLabel.textAlignment = .center
        timeLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        timeLabel.font = .systemFont(ofSize: 12.0)
        timeLabel.text = "--:-- / --:--"
        bottomView.addSubview(timeLabel)
        
        let enlargeImage = UIImage(named: "VGPlayer_ic_fullscreen")!
        let narrowImage = UIImage(named: "VGPlayer_ic_fullscreen_exit")!
        fullscreenButton.setImage(enlargeImage.newImage(scaledToSize: .init(width: 15, height: 15)), for: .normal)
        fullscreenButton.setImage(narrowImage.newImage(scaledToSize: .init(width: 15, height: 15)), for: .selected)
        fullscreenButton.addTarget(self, action: #selector(onFullscreen(_:)), for: .touchUpInside)
        bottomView.addSubview(fullscreenButton)
    }
    
    func setupViewAutoLayout() {
        replayButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        // top view layout
        topView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(64)
        }
        closeButton.snp.makeConstraints { make in
            make.left.equalTo(topView).offset(10)
            make.top.equalTo(topView).offset(28)
            make.height.width.equalTo(30)
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(closeButton.snp.right).offset(20)
            make.centerY.equalTo(closeButton)
        }
        
        // bottom view layout
        bottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(52)
        }
        
        playButton.snp.makeConstraints { make in
            make.left.equalTo(bottomView).offset(20)
            make.height.width.equalTo(25)
            make.centerY.equalTo(bottomView)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.right.equalTo(fullscreenButton.snp.left).offset(-10)
            make.centerY.equalTo(playButton)
            make.height.equalTo(30)
        }
        
        timeSlider.snp.makeConstraints { make in
            make.centerY.equalTo(playButton)
            make.right.equalTo(timeLabel.snp.left).offset(-10)
            make.left.equalTo(playButton.snp.right).offset(25)
            make.height.equalTo(25)
        }
        
        fullscreenButton.snp.makeConstraints { make in
            make.centerY.equalTo(playButton)
            make.right.equalTo(bottomView).offset(-10)
            make.height.width.equalTo(30)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(30)
        }
    }
}
