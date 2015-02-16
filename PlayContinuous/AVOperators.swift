//
//  AVOperators.swift
//  BufferTest
//
//  Created by Gregory Wieber on 2/16/15.
//  Copyright (c) 2015 Apposite. All rights reserved.
//

import AVFoundation

func sinePhaseIncrementWithFreq(freq: Double, #sampleRate: Double) -> Double {
    return (2.0 * M_PI * freq) / sampleRate
}

func + (left: AVAudioTime, right: Int) -> (AVAudioTime) {
    return AVAudioTime(sampleTime: left.sampleTime + right, atRate: left.sampleRate)
}

func + (left: Int, right: AVAudioTime) -> (AVAudioTime) {
    return right + left
}