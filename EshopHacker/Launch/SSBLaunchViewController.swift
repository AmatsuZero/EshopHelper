//
//  SSBLaunchViewController.swift
//  EshopHacker
//
//  Created by Jiang,Zhenhua on 2019/1/29.
//  Copyright © 2019 Daubert. All rights reserved.
//

import UIKit
import AVKit

class SSBLaunchViewController: UIViewController {
    
    private let loadingView = SSBLaunchView(frame: UIScreen.main.bounds)
    
    override func loadView() {
        view = loadingView
    }
    
    private lazy var audioPlayer: AVAudioPlayer? = {
        guard let filePath = Bundle.main.path(forResource: "eShop Load", ofType: "wav") else {
            return nil
        }
        let url = URL(fileURLWithPath: filePath)
        let player = try? AVAudioPlayer(contentsOf: url)
        player?.numberOfLoops = -1 // 无限播放
        return player
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if audioPlayer?.isPlaying == false {
            audioPlayer?.play()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if audioPlayer?.isPlaying == true {
            audioPlayer?.pause()
        }
    }
    
    deinit {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}
