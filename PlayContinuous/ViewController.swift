//
//  ViewController.swift
//  BufferTest
//
//  Created by Gregory Wieber on 2/13/15.
//  Copyright (c) 2015 Apposite. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    let engine = AVAudioEngine()
    var player: AVAudioPlayerNode!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        player = AVAudioPlayerNode()
        let playerFormat = player.outputFormatForBus(0)
        let sampleRate:AVAudioFrameCount = AVAudioFrameCount(playerFormat.sampleRate)
        let bufferPair = BufferPair(format: playerFormat, sampleRate: sampleRate, bufferLength: 1024)
        engine.attachNode(player)
        engine.connect(player, to: engine.outputNode, format: playerFormat)
        var error:NSError? = nil
        engine.startAndReturnError(&error)
        
        player.playContinuously(bufferPair: bufferPair) { buffer, time in
            let phaseIncrement = sinePhaseIncrementWithFreq(440.0, sampleRate:Double(sampleRate))
            var phase = phaseIncrement * Double(time.sampleTime)

            for i in 0..<Int(buffer.frameLength) {
                phase += phaseIncrement
                let sample = sin(phase)
                let channelCount = Int(buffer.format.channelCount)
                
                for channel in 0..<channelCount {
                    buffer.floatChannelData[channel][i] = Float(sample)
                }
            }
        }
    }

    @IBAction func stopPlayer(sender: AnyObject) {
        player.stop()
    }
}
