//
//  ContinousPlayer.swift
//  BufferTest
//
//  Created by Gregory Wieber on 2/16/15.
//  Copyright (c) 2015 Apposite. All rights reserved.
//

import AVFoundation

struct BufferPair {
    
    let format: AVAudioFormat
    let sampleRate: AVAudioFrameCount
    let bufferLength: AVAudioFrameCount
    let bufferA: AVAudioPCMBuffer
    let bufferB: AVAudioPCMBuffer
    
    init(format: AVAudioFormat, sampleRate: AVAudioFrameCount, bufferLength: AVAudioFrameCount) {
        self.format = format
        self.sampleRate = sampleRate
        self.bufferLength = bufferLength
        bufferA =  AVAudioPCMBuffer(PCMFormat: format, frameCapacity: bufferLength)
        bufferA.frameLength = bufferLength
        bufferB =  AVAudioPCMBuffer(PCMFormat: format, frameCapacity: bufferLength)
        bufferB.frameLength = bufferLength
    }
}

extension AVAudioPlayerNode {
    
    typealias RenderFunctionType = (AVAudioPCMBuffer, AVAudioTime) -> ()
    
    func playContinuously(#bufferPair: BufferPair, renderFunction f: RenderFunctionType) {
        let queue = dispatch_queue_create("com.swerve.buffer", nil) // FIXME: unique ID
        
        dispatch_async(queue) {
            let now = AVAudioTime(sampleTime: 0, atRate: Double(bufferPair.sampleRate)) // TODO: SR from player?
            let offsetTime = now + Int(bufferPair.bufferA.frameLength)
            self.scheduleBufferContinously(bufferPair.bufferA, startTime:now, renderFunction: f)
            self.scheduleBufferContinously(bufferPair.bufferB, startTime:offsetTime, renderFunction: f)
            
            self.play()
        }
    }
    
    func scheduleBufferContinously(buffer: AVAudioPCMBuffer, startTime: AVAudioTime, renderFunction f: RenderFunctionType) {
        f(buffer, startTime)
        
        self.scheduleBuffer(buffer, atTime: startTime, options: AVAudioPlayerNodeBufferOptions.Interrupts) {
            let nextTime = startTime + Int(buffer.frameLength)
            self.scheduleBufferContinously(buffer, startTime: nextTime, renderFunction: f)
        }
    }
}
