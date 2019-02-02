//
//  ViewController.swift
//  CustomAudioPlayer
//
//  Created by Ventuno Technologies on 02/02/19.
//  Copyright © 2019 Ventuno Technologies. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController {

    var player:AVPlayer?
    var playerItem:AVPlayerItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //let audioURl = URL(string: "http://www.largesound.com/ashborytour/sound/brobob.mp3")
        
        let audioURl = URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3")
        
        
        do {
            
             playerItem = AVPlayerItem(url: audioURl!)
            
            self.player = try AVPlayer(playerItem:playerItem)
            player!.volume = 1.0
            player!.play()
        } catch let error as NSError {
            self.player = nil
            print(error.localizedDescription)
        } catch {
            print("AVAudioPlayer init failed")
        }

        
        
        
            let audioSession = AVAudioSession.sharedInstance()
            do{
                if #available(iOS 10.0, *) {
                    try! audioSession.setCategory(.playback, mode: .moviePlayback)
                   

                }
                else {
                    // Workaround until https://forums.swift.org/t/using-methods-marked-unavailable-in-swift-4-2/14949 isn't fixed
                    audioSession.perform(NSSelectorFromString("setCategory:error:"), with: AVAudioSession.Category.playback)
                }
                 try! audioSession.setActive(true)
            }
        
        setupRemoteTransportControls()
        setupNowPlaying()
    }
    
    
    func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] event in
            if self.player?.rate == 0.0 {
                self.player?.play()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] event in
            if self.player?.rate == 1.0 {
                self.player?.pause()
                return .success
            }
            return .commandFailed
        }
    }

    func setupNowPlaying() {
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = "My Movie"
        
        if let image = UIImage(named: "lockscreen") {
            if #available(iOS 10.0, *) {
                nowPlayingInfo[MPMediaItemPropertyArtwork] =
                    MPMediaItemArtwork(boundsSize: image.size) { size in
                        return image
                }
            } else {
                // Fallback on earlier versions
            }
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playerItem?.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = playerItem?.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player?.rate
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    
    
    @IBAction func playAudio(_ sender: Any) {
        player?.pause()
    }
}

