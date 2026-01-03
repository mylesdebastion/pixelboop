# Story 1.3: Real-Time Audio Synthesis for Melody Notes

Status: ready-for-dev

---

## Story

As a **user**,
I want **to hear synthesized sound immediately when notes trigger**,
So that **I get instant audio feedback on my musical creation**.

---

## Acceptance Criteria

**Given** notes are placed on the melody track
**When** the playback engine triggers a note
**Then** a sine wave tone is synthesized (FR12)
**And** the frequency matches the note's chromatic pitch (A4=440Hz base)
**And** audio latency is <10ms tap-to-sound (NFR1)
**And** the tone has a 2000Hz lowpass filter
**And** ADSR envelope: attack 0.01s, release min(duration*0.3, 0.15s)
**And** audio plays without pops, clicks, or glitches (NFR39)

---

## Requirements References

**Functional Requirements:**
- FR12: System can synthesize notes in real-time with track-specific timbres (sine for melody)

**Non-Functional Requirements:**
- NFR1: Audio latency <10ms tap-to-sound (professional audio standard)
- NFR39: Glitch-free audio playback (no pops, clicks, buffer underruns)
- NFR3: <5% battery drain per 30 minutes (optimized audio rendering)

**Critical Audio Constraints:**
- **<10ms latency requires C/C++ audio thread** (Swift audio processing too slow)
- No memory allocations on audio thread (real-time safety)
- No locks on audio thread (priority inversion risk)
- No Swift runtime calls from C++ audio callback

**Dependencies:**
- **Story 1.2 (REQUIRED):** Pattern model with notes must exist
- **Story 1.4 (ENHANCEMENT):** Playback loop will trigger audio synthesis

---

## Tasks / Subtasks

- [ ] Task 1: Set up AVFoundation audio session (AC: Audio session configured)
  - [ ] Configure AVAudioSession for playback category
  - [ ] Set sample rate to 44.1kHz
  - [ ] Request buffer size 256 samples (5.8ms latency)
  - [ ] Enable background audio mode in Info.plist

- [ ] Task 2: Create C++ audio engine core (AC: <10ms latency)
  - [ ] Create AudioEngine.hpp/cpp with renderCallback
  - [ ] Implement Oscillator.hpp/cpp with sine wave generator
  - [ ] Implement ADSREnvelope.hpp/cpp for attack/release
  - [ ] Create LockFreeQueue.hpp for thread-safe state updates

- [ ] Task 3: Create Swift wrapper for audio engine (AC: Swift API)
  - [ ] Create Services/AudioEngine.swift
  - [ ] Bridge C++ AudioEngine to Swift via Obj-C++
  - [ ] Add PixelBoop-Bridging-Header.h
  - [ ] Implement start(), stop(), triggerNote(pitch, velocity) methods

- [ ] Task 4: Integrate audio engine with SequencerViewModel (AC: Notes trigger audio)
  - [ ] Add AudioEngine instance to SequencerViewModel
  - [ ] Call audioEngine.triggerNote() when playback hits note step
  - [ ] Calculate MIDI pitch from Note.pitch field
  - [ ] Map velocity to amplitude (normal=0.6, accent=1.0, sustain=0.8)

- [ ] Task 5: Performance validation (AC: <10ms, glitch-free)
  - [ ] Measure audio latency with Instruments Audio profiler
  - [ ] Validate no buffer underruns during playback
  - [ ] Test on iPhone SE (slowest target device)
  - [ ] Verify no pops/clicks on note triggers

---

## Dev Notes

### Previous Story Intelligence

**From Story 1.1 (Pixel Grid):**
- ✅ 60 FPS rendering validated
- ✅ UIKit + SwiftUI hybrid architecture proven

**From Story 1.2 (Note Placement):**
- ✅ Pattern model created (Pattern → Track → Note)
- ✅ Note struct has pitch field (MIDI note number 0-127)
- ✅ SequencerViewModel manages pattern state
- ✅ MVVM data flow established

**Key Insight:**
Story 1.2 created the data model. This story adds audio playback when notes are triggered by the playback engine (Story 1.4 will add the actual playback loop).

**Files Created in Previous Stories:**
- `Models/Note.swift` - has pitch field (MIDI)
- `Models/Track.swift` - has notes array
- `Models/Pattern.swift` - complete pattern state
- `ViewModels/SequencerViewModel.swift` - state management

**Files to Create in This Story:**
- `Audio/AudioEngine.hpp` - C++ header
- `Audio/AudioEngine.cpp` - C++ implementation
- `Audio/Oscillator.hpp/cpp` - Sine wave generator
- `Audio/ADSREnvelope.hpp/cpp` - Envelope generator
- `Audio/LockFreeQueue.hpp` - Thread-safe queue
- `Services/AudioEngine.swift` - Swift wrapper
- `Supporting/PixelBoop-Bridging-Header.h` - C++ bridge

### Architecture Context

**Why C/C++ for Audio:**
Swift's automatic reference counting (ARC) and memory management create unpredictable latency spikes that make <10ms audio impossible. Professional audio engines use C/C++ with:
- No heap allocations on audio thread
- No locks (priority inversion risk)
- Fixed-size pre-allocated buffers
- Lock-free data structures for thread communication

**Audio Thread Safety Architecture:**
```
Main Thread (Swift)                    Audio Thread (C++)
─────────────────                      ──────────────────
SequencerViewModel                     AudioEngine::renderCallback
  │                                       │
  ├─ triggerNote(pitch, velocity)        │
  │     │                                 │
  │     ▼                                 │
  │  LockFreeQueue.push()                 │
  │     │                                 │
  │     │  (atomic write)                 │
  │     └──────────────────────────────▶  │
  │                                       │
  │                               LockFreeQueue.pop()
  │                                       │
  │                                  Voice allocation
  │                                       │
  │                              Oscillator.renderSamples()
  │                                       │
  │                              ADSR.applyEnvelope()
  │                                       │
  │                              Mix to output buffer
  │                                       ▼
  │                               AVAudioEngine output
```

### Technical Requirements

**AVAudioSession Configuration:**
```swift
// Services/AudioEngine.swift
func setupAudioSession() {
    let session = AVAudioSession.sharedInstance()
    try? session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
    try? session.setPreferredSampleRate(44100.0)
    try? session.setPreferredIOBufferDuration(256.0 / 44100.0) // 5.8ms @ 44.1kHz
    try? session.setActive(true)
}
```

**C++ Oscillator Implementation:**
```cpp
// Audio/Oscillator.cpp
class SineOscillator {
private:
    double phase = 0.0;
    double phaseIncrement = 0.0;
    const double sampleRate = 44100.0;

public:
    void setFrequency(double frequency) {
        phaseIncrement = (2.0 * M_PI * frequency) / sampleRate;
    }

    float renderSample() {
        float sample = std::sin(phase);
        phase += phaseIncrement;
        if (phase >= 2.0 * M_PI) {
            phase -= 2.0 * M_PI;
        }
        return sample;
    }

    void renderSamples(float* buffer, int numSamples) {
        for (int i = 0; i < numSamples; i++) {
            buffer[i] = renderSample();
        }
    }
};
```

**ADSR Envelope Implementation:**
```cpp
// Audio/ADSREnvelope.cpp
class ADSREnvelope {
private:
    enum Stage { IDLE, ATTACK, SUSTAIN, RELEASE };
    Stage stage = IDLE;
    float currentLevel = 0.0f;
    float attackTime = 0.01f;  // 10ms attack
    float releaseTime = 0.15f; // 150ms release
    const float sampleRate = 44100.0f;

public:
    void noteOn() {
        stage = ATTACK;
        currentLevel = 0.0f;
    }

    void noteOff() {
        stage = RELEASE;
    }

    float getNextSample() {
        switch (stage) {
            case ATTACK: {
                currentLevel += 1.0f / (attackTime * sampleRate);
                if (currentLevel >= 1.0f) {
                    currentLevel = 1.0f;
                    stage = SUSTAIN;
                }
                return currentLevel;
            }
            case SUSTAIN:
                return 1.0f;
            case RELEASE: {
                currentLevel -= 1.0f / (releaseTime * sampleRate);
                if (currentLevel <= 0.0f) {
                    currentLevel = 0.0f;
                    stage = IDLE;
                }
                return currentLevel;
            }
            case IDLE:
            default:
                return 0.0f;
        }
    }
};
```

**MIDI Pitch to Frequency Conversion:**
```cpp
// MIDI note 69 = A4 = 440Hz
double midiToFrequency(int midiNote) {
    return 440.0 * std::pow(2.0, (midiNote - 69) / 12.0);
}
```

**Lock-Free Queue (Single Producer, Single Consumer):**
```cpp
// Audio/LockFreeQueue.hpp
template<typename T, size_t SIZE>
class LockFreeQueue {
private:
    T buffer[SIZE];
    std::atomic<size_t> writeIndex{0};
    std::atomic<size_t> readIndex{0};

public:
    bool push(const T& item) {
        size_t currentWrite = writeIndex.load(std::memory_order_relaxed);
        size_t nextWrite = (currentWrite + 1) % SIZE;
        if (nextWrite == readIndex.load(std::memory_order_acquire)) {
            return false; // Queue full
        }
        buffer[currentWrite] = item;
        writeIndex.store(nextWrite, std::memory_order_release);
        return true;
    }

    bool pop(T& item) {
        size_t currentRead = readIndex.load(std::memory_order_relaxed);
        if (currentRead == writeIndex.load(std::memory_order_acquire)) {
            return false; // Queue empty
        }
        item = buffer[currentRead];
        readIndex.store((currentRead + 1) % SIZE, std::memory_order_release);
        return true;
    }
};

struct NoteEvent {
    int pitch;
    float velocity;
    bool isNoteOn; // true = note on, false = note off
};

using NoteQueue = LockFreeQueue<NoteEvent, 256>;
```

**AVAudioEngine Integration:**
```swift
// Services/AudioEngine.swift
import AVFoundation

class AudioEngine {
    private let engine = AVAudioEngine()
    private var audioUnit: AVAudioUnit?
    private var cppEngine: UnsafeMutableRawPointer? // C++ AudioEngine instance

    func start() throws {
        setupAudioSession()

        // Create C++ audio engine (via bridging header)
        cppEngine = AudioEngine_create()

        // Configure AVAudioEngine with custom rendering callback
        let mainMixer = engine.mainMixerNode
        let outputFormat = mainMixer.outputFormat(forBus: 0)

        // Install tap for custom rendering
        mainMixer.installTap(onBus: 0, bufferSize: 256, format: outputFormat) { [weak self] buffer, time in
            guard let self = self, let cpp = self.cppEngine else { return }

            // Call C++ render callback
            let audioBuffer = buffer.audioBufferList.pointee.mBuffers
            AudioEngine_render(cpp, audioBuffer.mData?.assumingMemoryBound(to: Float.self), Int32(audioBuffer.mDataByteSize / 4))
        }

        try engine.start()
    }

    func stop() {
        engine.stop()
        if let cpp = cppEngine {
            AudioEngine_destroy(cpp)
            cppEngine = nil
        }
    }

    func triggerNote(pitch: Int, velocity: Float) {
        guard let cpp = cppEngine else { return }
        AudioEngine_triggerNote(cpp, Int32(pitch), velocity)
    }

    func releaseNote(pitch: Int) {
        guard let cpp = cppEngine else { return }
        AudioEngine_releaseNote(cpp, Int32(pitch))
    }
}
```

**Bridging Header:**
```objc
// Supporting/PixelBoop-Bridging-Header.h
#ifndef PixelBoop_Bridging_Header_h
#define PixelBoop_Bridging_Header_h

#ifdef __cplusplus
extern "C" {
#endif

// C interface to C++ AudioEngine
void* AudioEngine_create(void);
void AudioEngine_destroy(void* engine);
void AudioEngine_render(void* engine, float* buffer, int numSamples);
void AudioEngine_triggerNote(void* engine, int pitch, float velocity);
void AudioEngine_releaseNote(void* engine, int pitch);

#ifdef __cplusplus
}
#endif

#endif
```

**C++ AudioEngine with C Bridge:**
```cpp
// Audio/AudioEngine.cpp
#include "AudioEngine.hpp"
#include "Oscillator.hpp"
#include "ADSREnvelope.hpp"
#include "LockFreeQueue.hpp"
#include <array>

class AudioEngineImpl {
private:
    static constexpr int MAX_VOICES = 8;

    struct Voice {
        SineOscillator oscillator;
        ADSREnvelope envelope;
        int pitch = -1;
        bool active = false;
    };

    std::array<Voice, MAX_VOICES> voices;
    NoteQueue noteQueue;

public:
    void render(float* buffer, int numSamples) {
        // Clear buffer
        std::fill(buffer, buffer + numSamples, 0.0f);

        // Process note events from queue
        NoteEvent event;
        while (noteQueue.pop(event)) {
            if (event.isNoteOn) {
                allocateVoice(event.pitch, event.velocity);
            } else {
                releaseVoice(event.pitch);
            }
        }

        // Render all active voices
        for (auto& voice : voices) {
            if (!voice.active) continue;

            for (int i = 0; i < numSamples; i++) {
                float sample = voice.oscillator.renderSample();
                float envelope = voice.envelope.getNextSample();
                buffer[i] += sample * envelope;

                // Deactivate voice if envelope finished
                if (envelope == 0.0f && voice.envelope.isIdle()) {
                    voice.active = false;
                }
            }
        }

        // Apply master volume (prevent clipping)
        float masterVolume = 0.3f;
        for (int i = 0; i < numSamples; i++) {
            buffer[i] *= masterVolume;
            // Soft clipping
            if (buffer[i] > 1.0f) buffer[i] = 1.0f;
            if (buffer[i] < -1.0f) buffer[i] = -1.0f;
        }
    }

    void triggerNote(int pitch, float velocity) {
        NoteEvent event;
        event.pitch = pitch;
        event.velocity = velocity;
        event.isNoteOn = true;
        noteQueue.push(event);
    }

    void releaseNote(int pitch) {
        NoteEvent event;
        event.pitch = pitch;
        event.velocity = 0.0f;
        event.isNoteOn = false;
        noteQueue.push(event);
    }

private:
    void allocateVoice(int pitch, float velocity) {
        // Find inactive voice
        for (auto& voice : voices) {
            if (!voice.active) {
                voice.pitch = pitch;
                voice.active = true;
                voice.oscillator.setFrequency(midiToFrequency(pitch));
                voice.envelope.noteOn();
                return;
            }
        }
        // Voice stealing: steal oldest voice if all busy
        voices[0].pitch = pitch;
        voices[0].oscillator.setFrequency(midiToFrequency(pitch));
        voices[0].envelope.noteOn();
    }

    void releaseVoice(int pitch) {
        for (auto& voice : voices) {
            if (voice.active && voice.pitch == pitch) {
                voice.envelope.noteOff();
                return;
            }
        }
    }

    double midiToFrequency(int midiNote) {
        return 440.0 * std::pow(2.0, (midiNote - 69) / 12.0);
    }
};

// C interface implementation
extern "C" {
    void* AudioEngine_create() {
        return new AudioEngineImpl();
    }

    void AudioEngine_destroy(void* engine) {
        delete static_cast<AudioEngineImpl*>(engine);
    }

    void AudioEngine_render(void* engine, float* buffer, int numSamples) {
        static_cast<AudioEngineImpl*>(engine)->render(buffer, numSamples);
    }

    void AudioEngine_triggerNote(void* engine, int pitch, float velocity) {
        static_cast<AudioEngineImpl*>(engine)->triggerNote(pitch, velocity);
    }

    void AudioEngine_releaseNote(void* engine, int pitch) {
        static_cast<AudioEngineImpl*>(engine)->releaseNote(pitch);
    }
}
```

### Performance Requirements

**Audio Latency Budget: <10ms**
- Input latency: 0ms (triggered programmatically, not from user input in this story)
- Audio buffer: 256 samples @ 44.1kHz = 5.8ms
- Processing overhead: <2ms (C++ render callback)
- Output latency: ~2ms (hardware)
- **Total: ~9.8ms** (within budget)

**Real-Time Safety Checklist:**
- ✅ No heap allocations on audio thread
- ✅ No locks (use lock-free queue instead)
- ✅ No Swift runtime calls from C++
- ✅ Fixed-size pre-allocated buffers
- ✅ No system calls on audio thread
- ✅ No file I/O on audio thread

### Testing Requirements

**Manual Testing Checklist:**
- [ ] Tap note → hear sine wave tone immediately
- [ ] Different row taps → different pitches (chromatic scale)
- [ ] No audio pops or clicks on note trigger
- [ ] No audio glitches during rapid note placement
- [ ] Audio continues when app backgrounded (Story 10.4 validation)
- [ ] No crackling or distortion

**Performance Testing:**
- [ ] Measure audio latency with Instruments Audio profiler
- [ ] Verify <10ms tap-to-sound (requires Story 1.4 playback integration)
- [ ] Check CPU usage <20% during playback
- [ ] Test on iPhone SE 2nd gen (slowest device)
- [ ] Validate no buffer underruns in Console logs

**Unit Testing (C++):**
- [ ] Test Oscillator frequency accuracy (A4 = 440Hz)
- [ ] Test ADSR envelope timing (attack 10ms, release 150ms)
- [ ] Test LockFreeQueue thread safety (stress test)
- [ ] Test voice allocation (8 simultaneous notes)

### Integration Notes

**Story 1.4 Will Add:**
- Playback loop that calls audioEngine.triggerNote() on each step
- Play/stop button functionality
- BPM-based timing with Timer/CADisplayLink

**This Story's Scope:**
- Audio engine infrastructure only
- Manual testing by calling triggerNote() programmatically
- No playback loop yet (Story 1.4)

### Cross-Platform Compatibility

**Web Audio API Equivalent:**
The web version uses Web Audio API with similar architecture:
- OscillatorNode (sine wave) ≈ C++ SineOscillator
- GainNode with envelope ≈ C++ ADSREnvelope
- AudioContext.currentTime ≈ C++ sample-accurate timing

**Critical Difference:**
- Web: ~20ms latency (Web Audio API + browser overhead)
- iOS: <10ms latency (C++ direct AVFoundation access)

### Known Constraints & Gotchas

**C++ Compilation:**
- Add `.cpp` files to Xcode project (not `.hpp` headers)
- Set C++ Language Dialect to "GNU++17" in Build Settings
- Enable "Objective-C Bridging Header" in Build Settings

**Audio Session Interruptions:**
- Story 10.5 will handle phone calls/notifications
- For now, audio session is configured but not resilient

**Buffer Size Trade-offs:**
- 256 samples = 5.8ms latency (chosen)
- 128 samples = 2.9ms latency (higher CPU usage, battery drain)
- 512 samples = 11.6ms latency (exceeds <10ms requirement)

**Voice Polyphony:**
- 8 simultaneous voices should be sufficient for melody track
- Chords/bass tracks will share the voice pool (Story 4.x)

---

## Project Context Reference

See `docs/project-context.md` for:
- C++ coding standards and conventions
- Audio thread safety best practices
- AVFoundation integration patterns
- Performance profiling guidelines

---

## Dev Agent Record

### Agent Model Used

(To be filled by dev agent)

### Implementation Notes

(To be filled by dev agent during implementation)

### Completion Checklist

- [ ] All acceptance criteria met
- [ ] AVAudioSession configured correctly
- [ ] C++ audio engine compiles and links
- [ ] Bridging header working
- [ ] Swift wrapper functional
- [ ] Audio latency <10ms validated
- [ ] No audio glitches or pops
- [ ] Real-time safety verified (no allocations/locks)
- [ ] Tested on iPhone SE
- [ ] No warnings or errors in Xcode
- [ ] Ready for code review

### File List

(To be filled by dev agent - list all files created/modified)
