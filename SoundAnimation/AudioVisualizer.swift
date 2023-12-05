//
//  AudioVisualizer.swift
//  SoundAnimation
//
//  Created by iPHTech 23 on 23/11/23.
//


import UIKit
import AVFoundation

class AudioVisualizerView1: UIView {

    private var audioEngine: AVAudioEngine!
    private var playerNode: AVAudioPlayerNode!
    private var audioFile: AVAudioFile!
    private var displayLink: CADisplayLink!
    private var barLayers: [CALayer] = []
    
    private let numberOfBars = 20
    private let barWidth: CGFloat = 7.0
    private let barCornerRadius: CGFloat = 3.0
    private let spacing: CGFloat = 5.0
    private let maxBarHeight: CGFloat = 300.0
    
    private var audioFileName: String = ""
    
    init(frame: CGRect, audioFileName: String) {
        super.init(frame: frame)
        self.audioFileName = audioFileName
        setupUI()
        setupAudioEngine { isSetupComplete in
            if isSetupComplete {
                self.setupDisplayLink()
            }
        }
        
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupAudioEngine { isSetupComplete in
            if isSetupComplete {
                self.setupDisplayLink()
            }
        }
    }

    private func setupUI() {
        backgroundColor = .black

        // Create bar layers
        for i in 0..<numberOfBars {
            let barLayer = CALayer()
            barLayer.backgroundColor = randomColor().cgColor
            barLayer.frame = CGRect(x: CGFloat(i) * (barWidth + spacing) + 50, y: 0, width: barWidth, height: maxBarHeight)
            barLayer.cornerRadius = barCornerRadius
            layer.addSublayer(barLayer)
            barLayers.append(barLayer)
        }
    }

    private func setupAudioEngine(completion: @escaping ((Bool) -> Void)) {
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        audioEngine.attach(playerNode)
        
        guard let url = URL(string: self.audioFileName) else {
            return
        }
        do {
            audioFile = try AVAudioFi
        } catch {
            print("Error loading audio file: \(error.localizedDescription)")
        }

        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: audioFile.processingFormat)
        try? audioEngine.start()
    }

    private func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateBars))
        displayLink.add(to: .main, forMode: .common)
    }

//    @objc private func updateBars() {
//        let bufferSize = 1024
//        let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(bufferSize))!
//
//        do {
//            try audioFile.read(into: buffer)
//
//            let channelData = buffer.floatChannelData?[0]
//
//            let fft = FFT(bufferSize: bufferSize, sampleRate: Float(audioFile.processingFormat.sampleRate))
//            fft.fftForward(input: channelData)
//
//            // You can now use the FFT data to update the bar heights based on different frequency bands.
//            let frequencyBands = fft.calculateFrequencyBands()
//
//            for i in 0..<numberOfBars {
//                let barHeight = CGFloat(frequencyBands[i]) * maxBarHeight
//                barLayers[i].bounds.size.height = barHeight
//            }
//        } catch {
//            print("Error reading audio file: \(error.localizedDescription)")
//        }
//    }

    
    @objc private func updateBars() {
        // Read audio samples and update bar heights
        let bufferSize = 1024
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(bufferSize))!

        do {
            try audioFile.read(into: buffer)
            
            let channelData = buffer.floatChannelData?[0]

            for i in 0..<numberOfBars {
                let barHeight = CGFloat(abs(CGFloat(channelData?[i] ?? 0.0)) * maxBarHeight)
                barLayers[i].bounds.size.height = barHeight
                print(barHeight)
            }
        } catch {
            print("Error reading audio file: \(error.localizedDescription)")
        }
    }

    func play() {
        playerNode.scheduleFile(audioFile, at: nil, completionHandler: nil)
        playerNode.play()
    }
    
    func randomColor() -> UIColor {
        let randomRed = CGFloat(drand48())
        let randomGreen = CGFloat(drand48())
        let randomBlue = CGFloat(drand48())
        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }

}

