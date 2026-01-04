//
//  AudioEngine.swift
//  pixelboop
//
//  Audio synthesis engine using AVAudioEngine
//  Matches prototype's Web Audio API implementation
//

import AVFoundation
import Combine
import Foundation

// MARK: - Drum Types (from prototype lines 33-47)

enum DrumType: Int, CaseIterable {
    case kick = 0
    case kick2 = 1
    case lowTom = 2
    case snare = 3
    case snare2 = 4
    case rimshot = 5
    case clap = 6
    case closedHat = 7
    case openHat = 8
    case crash = 9
    case ride = 10
    case cowbell = 11
}

// MARK: - Audio Engine

@MainActor
class AudioEngine: ObservableObject {

    private var audioEngine: AVAudioEngine
    private var mixer: AVAudioMixerNode
    private let sampleRate: Double = 44100.0

    // Track base MIDI notes (from prototype line 1468)
    private let baseNotes: [TrackType: Int] = [
        .melody: 60,  // Middle C
        .chords: 48,  // C3
        .bass: 36,    // C2
        .rhythm: 0    // N/A - drums
    ]

    @Published var isRunning = false

    init() {
        audioEngine = AVAudioEngine()
        mixer = audioEngine.mainMixerNode
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("AudioSession setup failed: \(error)")
        }
    }

    func start() {
        guard !isRunning else { return }
        do {
            try audioEngine.start()
            isRunning = true
        } catch {
            print("AudioEngine start failed: \(error)")
        }
    }

    func stop() {
        audioEngine.stop()
        isRunning = false
    }

    // MARK: - Note Playback (from prototype lines 1406-1460)

    /// Play a tonal note (melody, chords, bass)
    func playNote(track: TrackType, noteIndex: Int, velocity: Int, duration: Double) {
        guard track != .rhythm else { return }
        guard let baseNote = baseNotes[track] else { return }

        start()

        let midiNote = baseNote + noteIndex
        let frequency = midiToFrequency(midiNote)
        let amplitude = Float(0.08 * Double(velocity))

        // Generate audio buffer
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount

        guard let channelData = buffer.floatChannelData?[0] else { return }

        // Waveform and filter based on track type (from prototype lines 1432-1448)
        let waveform: WaveformType
        let filterFreq: Float

        switch track {
        case .melody:
            waveform = .sine
            filterFreq = 2000
        case .chords:
            waveform = .triangle
            filterFreq = 1500
        case .bass:
            waveform = .sawtooth
            filterFreq = 400
        case .rhythm:
            waveform = .triangle
            filterFreq = 1000
        }

        // Envelope parameters
        let attackTime = duration > 0.2 ? 0.02 : 0.01
        let releaseTime = min(duration * 0.3, 0.15)

        // Generate samples with envelope
        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            let phase = t * Double(frequency)

            // Waveform
            var sample: Float
            switch waveform {
            case .sine:
                sample = sin(Float(phase * 2 * .pi))
            case .triangle:
                let p = Float(phase.truncatingRemainder(dividingBy: 1.0))
                sample = 4.0 * abs(p - 0.5) - 1.0
            case .sawtooth:
                sample = 2.0 * Float(phase.truncatingRemainder(dividingBy: 1.0)) - 1.0
            }

            // Simple low-pass filter approximation
            let filterFactor = min(1.0, filterFreq / Float(frequency * 4))
            sample *= filterFactor

            // Envelope
            var envelope: Float = 1.0
            if t < attackTime {
                envelope = Float(t / attackTime)
            } else if t > duration - releaseTime {
                envelope = Float((duration - t) / releaseTime)
            }

            channelData[i] = sample * amplitude * envelope
        }

        playBuffer(buffer)
    }

    // MARK: - Drum Playback (from prototype lines 1176-1403)

    func playDrum(_ drumType: DrumType, velocity: Int = 1) {
        start()

        let vol = Float(0.15 * Double(velocity))
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!

        switch drumType {
        case .kick, .kick2:
            playKick(type: drumType, volume: vol, format: format)
        case .lowTom:
            playTom(volume: vol, format: format)
        case .snare, .snare2:
            playSnare(type: drumType, volume: vol, format: format)
        case .rimshot:
            playRimshot(volume: vol, format: format)
        case .clap:
            playClap(volume: vol, format: format)
        case .closedHat:
            playHat(open: false, volume: vol, format: format)
        case .openHat:
            playHat(open: true, volume: vol, format: format)
        case .crash:
            playCrash(volume: vol, format: format)
        case .ride:
            playRide(volume: vol, format: format)
        case .cowbell:
            playCowbell(volume: vol, format: format)
        }
    }

    // MARK: - Drum Synthesis Methods

    private func playKick(type: DrumType, volume: Float, format: AVAudioFormat) {
        let duration = 0.3
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        guard let data = buffer.floatChannelData?[0] else { return }

        let startFreq: Double = type == .kick ? 150 : 120

        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            // Frequency sweep from startFreq to 30 Hz
            let freq = startFreq * pow(30 / startFreq, t / 0.1)
            let sample = sin(Float(t * freq * 2 * .pi))
            // Amplitude envelope
            let envelope = Float(exp(-t * 10))
            data[i] = sample * volume * 1.5 * envelope
        }

        playBuffer(buffer)
    }

    private func playTom(volume: Float, format: AVAudioFormat) {
        let duration = 0.25
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        guard let data = buffer.floatChannelData?[0] else { return }

        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            let freq = 100 * pow(60 / 100, t / 0.15)
            let sample = sin(Float(t * freq * 2 * .pi))
            let envelope = Float(exp(-t * 8))
            data[i] = sample * volume * envelope
        }

        playBuffer(buffer)
    }

    private func playSnare(type: DrumType, volume: Float, format: AVAudioFormat) {
        let duration = 0.15
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        guard let data = buffer.floatChannelData?[0] else { return }

        let toneFreq: Float = type == .snare ? 180 : 200
        let noiseFilterFreq: Float = type == .snare ? 1000 : 1500

        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate

            // Noise component (high-pass filtered)
            let noise = Float.random(in: -1...1) * (noiseFilterFreq / 2000)
            let noiseEnvelope = Float(exp(-t * 15)) * 0.8

            // Tone component
            let tone = sin(Float(t * Double(toneFreq) * 2 * .pi))
            let toneEnvelope = Float(exp(-t * 25)) * 0.5

            data[i] = (noise * noiseEnvelope + tone * toneEnvelope) * volume
        }

        playBuffer(buffer)
    }

    private func playRimshot(volume: Float, format: AVAudioFormat) {
        let duration = 0.05
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        guard let data = buffer.floatChannelData?[0] else { return }

        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            // Triangle wave at 800 Hz
            let phase = Float((t * 800).truncatingRemainder(dividingBy: 1.0))
            let sample = 4.0 * abs(phase - 0.5) - 1.0
            let envelope = Float(exp(-t * 40))
            data[i] = sample * volume * 0.5 * envelope
        }

        playBuffer(buffer)
    }

    private func playClap(volume: Float, format: AVAudioFormat) {
        let duration = 0.12
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        guard let data = buffer.floatChannelData?[0] else { return }

        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            // Multiple bursts
            var sample: Float = 0
            for b in 0..<3 {
                let burstStart = Double(b) * 0.015
                if t >= burstStart && t < burstStart + 0.02 {
                    let noise = Float.random(in: -1...1)
                    let burstEnvelope = Float(exp(-(t - burstStart) * 50))
                    sample += noise * burstEnvelope * 0.6
                }
            }
            data[i] = sample * volume
        }

        playBuffer(buffer)
    }

    private func playHat(open: Bool, volume: Float, format: AVAudioFormat) {
        let duration: Double = open ? 0.25 : 0.05
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        guard let data = buffer.floatChannelData?[0] else { return }

        let decayRate: Double = open ? 4 : 40
        let filterFactor: Float = open ? 0.35 : 0.4

        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            // High-frequency noise
            let noise = Float.random(in: -1...1)
            // Simple high-pass: bias towards higher frequencies
            let filtered = noise * 0.6
            let envelope = Float(exp(-t * decayRate))
            data[i] = filtered * volume * filterFactor * envelope
        }

        playBuffer(buffer)
    }

    private func playCrash(volume: Float, format: AVAudioFormat) {
        let duration = 0.5
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        guard let data = buffer.floatChannelData?[0] else { return }

        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            let noise = Float.random(in: -1...1) * 0.5
            let envelope = Float(exp(-t * 4))
            data[i] = noise * volume * 0.5 * envelope
        }

        playBuffer(buffer)
    }

    private func playRide(volume: Float, format: AVAudioFormat) {
        let duration = 0.4
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        guard let data = buffer.floatChannelData?[0] else { return }

        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            // Two triangle waves
            let p1 = Float((t * 350).truncatingRemainder(dividingBy: 1.0))
            let p2 = Float((t * 620).truncatingRemainder(dividingBy: 1.0))
            let osc1 = 4.0 * abs(p1 - 0.5) - 1.0
            let osc2 = sin(Float(t * 620 * 2 * .pi))
            let envelope = Float(exp(-t * 5))
            data[i] = (osc1 + osc2) * 0.5 * volume * 0.25 * envelope
        }

        playBuffer(buffer)
    }

    private func playCowbell(volume: Float, format: AVAudioFormat) {
        let duration = 0.15
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        buffer.frameLength = frameCount
        guard let data = buffer.floatChannelData?[0] else { return }

        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            // Two square waves at 560 and 845 Hz
            let sq1: Float = sin(Float(t * 560 * 2 * .pi)) > 0 ? 1 : -1
            let sq2: Float = sin(Float(t * 845 * 2 * .pi)) > 0 ? 1 : -1
            let envelope = Float(exp(-t * 13))
            data[i] = (sq1 + sq2) * 0.5 * volume * 0.25 * envelope
        }

        playBuffer(buffer)
    }

    // MARK: - Buffer Playback

    private func playBuffer(_ buffer: AVAudioPCMBuffer) {
        let playerNode = AVAudioPlayerNode()
        audioEngine.attach(playerNode)
        audioEngine.connect(playerNode, to: mixer, format: buffer.format)

        playerNode.scheduleBuffer(buffer) {
            DispatchQueue.main.async {
                self.audioEngine.detach(playerNode)
            }
        }

        playerNode.play()
    }

    // MARK: - Helpers

    private func midiToFrequency(_ midi: Int) -> Double {
        return 440.0 * pow(2.0, Double(midi - 69) / 12.0)
    }

    private enum WaveformType {
        case sine, triangle, sawtooth
    }
}
