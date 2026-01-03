# Story 1.4: Continuous Playback Loop with Visual Playhead

Status: ready-for-dev

---

## Story

As a **user**,
I want **to press play and hear my pattern loop continuously**,
So that **I can listen to the music I've created**.

---

## Acceptance Criteria

**Given** notes are placed on the melody track
**When** I press the play button (row 0, col 2-3)
**Then** the pattern plays from step 0 to pattern end (FR16)
**And** playback loops seamlessly back to step 0 (FR16)
**And** a visual playhead highlights the current step (FR39)
**And** the playhead moves in sync with audio timing
**And** pressing stop halts playback immediately (FR17)
**And** playback maintains exact tempo with zero drift

---

## Requirements References

**Functional Requirements:**
- FR16: System can play patterns in a continuous loop
- FR17: Users can start and stop pattern playback
- FR39: System can display a visual playhead during pattern playback

**Non-Functional Requirements:**
- NFR4: Tempo accuracy ±0.1% (zero drift over 5 minutes)
- NFR45: 60 FPS visual rendering maintained during playback

**Dependencies:**
- **Story 1.1 (REQUIRED):** Pixel grid rendering for playhead visualization
- **Story 1.2 (REQUIRED):** Pattern model with notes
- **Story 1.3 (REQUIRED):** Audio engine for sound synthesis

---

## Tasks / Subtasks

- [ ] Task 1: Add play/stop state to SequencerViewModel (AC: State management)
  - [ ] Add @Published var isPlaying: Bool property
  - [ ] Add @Published var currentStep: Int property (0-31)
  - [ ] Implement play() method
  - [ ] Implement stop() method

- [ ] Task 2: Implement tempo-accurate timing engine (AC: Zero drift)
  - [ ] Create PlaybackTimer class using CADisplayLink or Timer
  - [ ] Calculate step duration from BPM (e.g., 120 BPM = 125ms per 16th note)
  - [ ] Implement sample-accurate scheduling (avoid cumulative drift)
  - [ ] Advance currentStep on each tick

- [ ] Task 3: Integrate audio synthesis with playback (AC: Notes trigger on steps)
  - [ ] Read pattern.tracks[.melody].notes on each step
  - [ ] Filter notes at currentStep column
  - [ ] Call audioEngine.triggerNote() for each note
  - [ ] Call audioEngine.releaseNote() after note duration

- [ ] Task 4: Render visual playhead (AC: Synced with audio)
  - [ ] Update PixelGridUIView to highlight current step column
  - [ ] Draw playhead as vertical column overlay (subtle highlight)
  - [ ] Update playhead position when currentStep changes
  - [ ] Maintain 60 FPS during playhead animation

- [ ] Task 5: Implement loop logic (AC: Seamless looping)
  - [ ] When currentStep reaches pattern.length, reset to 0
  - [ ] Continue playback without audio gap
  - [ ] Handle pattern length changes during playback

---

## Dev Notes

### Previous Story Intelligence

**From Story 1.1 (Pixel Grid):**
- ✅ PixelGridUIView renders 44×24 grid
- ✅ setNeedsDisplay() updates work efficiently

**From Story 1.2 (Note Placement):**
- ✅ Pattern model: Pattern → Track → Note
- ✅ SequencerViewModel manages pattern state
- ✅ Note struct has col, pitch, velocity fields

**From Story 1.3 (Audio Synthesis):**
- ✅ AudioEngine.swift wrapper created
- ✅ triggerNote(pitch, velocity) method available
- ✅ releaseNote(pitch) method for note-off
- ✅ <10ms audio latency validated

**Key Integration Point:**
This story brings together all previous stories:
- Grid rendering (Story 1.1) → playhead visualization
- Pattern data (Story 1.2) → notes to trigger
- Audio engine (Story 1.3) → sound synthesis
- **Result:** Complete functional sequencer!

**Files to Modify:**
- `ViewModels/SequencerViewModel.swift` - Add playback state and timing
- `Views/PixelGridUIView.swift` - Add playhead rendering
- `Views/PixelGridView.swift` - Pass currentStep to UIView

**Files to Create:**
- `Services/PlaybackTimer.swift` - Tempo-accurate timing engine

### Architecture Context

**Playback Architecture:**
```
User Taps Play Button
  ↓
SequencerViewModel.play()
  ↓
PlaybackTimer starts (CADisplayLink @ 60fps)
  ↓
Every step duration (e.g., 125ms @ 120 BPM):
  ↓
currentStep increments (0 → 1 → 2 → ... → 15 → 0)
  ↓
Read pattern.tracks[.melody].notes
  ↓
Filter notes where note.col == currentStep
  ↓
For each note: audioEngine.triggerNote(pitch, velocity)
  ↓
@Published currentStep change triggers SwiftUI update
  ↓
PixelGridView updates → PixelGridUIView renders playhead
```

**Timing Accuracy Strategy:**
Avoid cumulative drift by calculating absolute time, not relative intervals:
```swift
// ❌ WRONG - cumulative drift
var nextStepTime = Date()
timer.schedule {
    nextStepTime += stepDuration  // Drift accumulates!
    advanceStep()
}

// ✅ CORRECT - absolute time reference
let startTime = Date()
var stepIndex = 0
timer.schedule {
    let expectedTime = startTime + (stepDuration * Double(stepIndex))
    let actualTime = Date()
    let drift = actualTime - expectedTime

    if drift < stepDuration {
        advanceStep()
        stepIndex += 1
    }
}
```

### Technical Requirements

**BPM to Step Duration Conversion:**
```swift
// 120 BPM = 120 quarter notes per minute
// 1 quarter note = 4 sixteenth notes
// 1 minute = 60 seconds
// Step duration for 16th note steps:
// (60 seconds / 120 BPM) / 4 sixteenths = 0.125 seconds = 125ms

func stepDuration(bpm: Int) -> TimeInterval {
    let quarterNoteDuration = 60.0 / Double(bpm)
    let sixteenthNoteDuration = quarterNoteDuration / 4.0
    return sixteenthNoteDuration
}

// Examples:
// 60 BPM: 250ms per step
// 120 BPM: 125ms per step
// 200 BPM: 75ms per step
```

**PlaybackTimer Implementation:**
```swift
// Services/PlaybackTimer.swift
import Foundation
import QuartzCore

class PlaybackTimer {
    private var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval = 0
    private var stepDuration: TimeInterval = 0
    private var currentStepIndex: Int = 0
    private var onTick: ((Int) -> Void)?

    func start(bpm: Int, patternLength: Int, onTick: @escaping (Int) -> Void) {
        self.stepDuration = calculateStepDuration(bpm: bpm)
        self.onTick = onTick
        self.currentStepIndex = 0

        displayLink = CADisplayLink(target: self, selector: #selector(tick))
        displayLink?.add(to: .main, forMode: .common)
        startTime = CACurrentMediaTime()
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
        currentStepIndex = 0
    }

    @objc private func tick(displayLink: CADisplayLink) {
        let currentTime = CACurrentMediaTime()
        let elapsed = currentTime - startTime

        // Calculate which step we should be on
        let expectedStep = Int(elapsed / stepDuration)

        // Only advance if we've reached the next step
        if expectedStep > currentStepIndex {
            currentStepIndex = expectedStep
            onTick?(currentStepIndex % patternLength)  // Loop at pattern end
        }
    }

    private func calculateStepDuration(bpm: Int) -> TimeInterval {
        return (60.0 / Double(bpm)) / 4.0  // Quarter note / 4 = sixteenth note
    }
}
```

**SequencerViewModel Playback Integration:**
```swift
class SequencerViewModel: ObservableObject {
    @Published var pattern: Pattern = Pattern()
    @Published var isPlaying: Bool = false
    @Published var currentStep: Int = 0

    private let audioEngine = AudioEngine()
    private let playbackTimer = PlaybackTimer()

    init() {
        do {
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }

    func play() {
        guard !isPlaying else { return }
        isPlaying = true
        currentStep = 0

        playbackTimer.start(bpm: pattern.bpm, patternLength: pattern.length) { [weak self] step in
            self?.onStepTick(step: step)
        }
    }

    func stop() {
        guard isPlaying else { return }
        isPlaying = false
        playbackTimer.stop()
        currentStep = 0
    }

    private func onStepTick(step: Int) {
        currentStep = step

        // Trigger notes at current step
        for track in pattern.tracks.values {
            let notesAtStep = track.notes.filter { $0.col == step }
            for note in notesAtStep {
                let velocity: Float = {
                    switch note.velocity {
                    case .normal: return 0.6
                    case .accent: return 1.0
                    case .sustain: return 0.8
                    }
                }()
                audioEngine.triggerNote(pitch: note.pitch, velocity: velocity)

                // Schedule note-off for non-sustain notes
                if note.velocity != .sustain {
                    let noteDuration = calculateStepDuration(bpm: pattern.bpm) * 0.8
                    DispatchQueue.main.asyncAfter(deadline: .now() + noteDuration) {
                        self.audioEngine.releaseNote(pitch: note.pitch)
                    }
                }
            }
        }
    }

    private func calculateStepDuration(bpm: Int) -> TimeInterval {
        return (60.0 / Double(bpm)) / 4.0
    }
}
```

**Playhead Rendering in PixelGridUIView:**
```swift
override func draw(_ rect: CGRect) {
    guard let context = UIGraphicsGetCurrentContext() else { return }

    // Draw background
    context.setFillColor(backgroundColor.cgColor)
    context.fill(rect)

    // Draw grid pixels with notes
    for row in 0..<ROWS {
        for col in 0..<COLS {
            let x = CGFloat(col) * (pixelSize + gapSize)
            let y = CGFloat(row) * (pixelSize + gapSize)
            let pixelRect = CGRect(x: x, y: y, width: pixelSize, height: pixelSize)

            // Check if there's a note at this position
            if let note = getNoteAt(col: col, row: row) {
                let noteColor = colorForPitch(note.pitch)
                context.setFillColor(noteColor.cgColor)
                context.fill(pixelRect)
            }

            // Draw playhead overlay (subtle highlight on current step column)
            if isPlaying && col == currentStep {
                context.setFillColor(UIColor.white.withAlphaComponent(0.2).cgColor)
                context.fill(pixelRect)
            }
        }
    }
}
```

**SwiftUI Integration:**
```swift
// Views/PixelGridView.swift
struct PixelGridView: UIViewRepresentable {
    @ObservedObject var viewModel: SequencerViewModel

    func makeUIView(context: Context) -> PixelGridUIView {
        let view = PixelGridUIView()
        view.viewModel = viewModel
        return view
    }

    func updateUIView(_ uiView: PixelGridUIView, context: Context) {
        uiView.pattern = viewModel.pattern
        uiView.currentStep = viewModel.currentStep
        uiView.isPlaying = viewModel.isPlaying
        uiView.setNeedsDisplay()
    }
}
```

### Performance Requirements

**Timing Accuracy: ±0.1% over 5 minutes**
- 120 BPM: 125ms per step
- 5 minutes = 300 seconds
- At 16 steps per pattern: 300s / (125ms * 16) = 150 loops
- Acceptable drift: 300s * 0.001 = 0.3s over 5 minutes
- CADisplayLink provides ~60fps accuracy, sufficient for this requirement

**60 FPS Rendering:**
- Playhead rendering adds minimal overhead (<1ms)
- Use selective redraws (only update playhead column if needed)
- Profile with Instruments Core Animation

**CPU Usage Target:**
- Playback loop: <5% CPU
- Audio synthesis: <15% CPU (from Story 1.3)
- Visual rendering: <10% CPU (from Story 1.1)
- **Total: <30% CPU during active playback**

### Testing Requirements

**Manual Testing Checklist:**
- [ ] Tap play button → pattern starts playing
- [ ] Hear notes in correct sequence (step 0 → 1 → 2 → ...)
- [ ] Playhead moves across grid in sync with audio
- [ ] Pattern loops seamlessly (no gap at loop point)
- [ ] Tap stop button → playback halts immediately
- [ ] Play again → starts from step 0
- [ ] Change BPM → timing updates correctly
- [ ] Works with different pattern lengths (8, 16, 24, 32 steps)

**Timing Accuracy Test:**
- [ ] Play pattern for 5 minutes at 120 BPM
- [ ] Record audio output
- [ ] Analyze timing drift (should be <0.3s over 5 minutes)
- [ ] Use DAW or audio analysis tool to measure

**Performance Testing:**
- [ ] CPU usage <30% during playback
- [ ] 60 FPS maintained during playback
- [ ] No audio dropouts or glitches
- [ ] Test on iPhone SE 2nd gen (slowest device)

**Unit Testing:**
- [ ] Test stepDuration calculation for various BPMs
- [ ] Test loop logic (step 15 → step 0 @ 16-step pattern)
- [ ] Test pattern length changes (8, 16, 24, 32)
- [ ] Test play/stop state transitions

### Integration Notes

**Play Button UI (Future Story):**
This story assumes a temporary play button will be added to row 0, columns 2-3 for testing. Story 5.2 will add proper control buttons with pixel-font labels.

**For Now:**
Add a simple tap handler in row 0 that calls viewModel.play() or viewModel.stop().

**Playhead Visualization:**
- Use subtle white overlay (20% opacity) to avoid obscuring note colors
- Story 5.1 will enhance with animated effects
- Consider column-wide highlight vs. single-pixel marker

### Cross-Platform Compatibility

**Web Version Timing:**
The web prototype uses `setInterval` for timing, which has ~10ms accuracy. iOS CADisplayLink provides much better accuracy (~16ms @ 60fps, but sample-accurate scheduling via absolute time calculation).

**Pattern Playback Equivalence:**
- Both platforms must play same pattern at same BPM identically
- Step duration calculation must match exactly
- Loop timing must be seamless on both platforms

### Known Constraints & Gotchas

**CADisplayLink vs. Timer:**
- CADisplayLink: Synced to screen refresh (60fps), better for animations
- Timer: Independent timing, can be more accurate for audio
- **Recommendation:** Use CADisplayLink for smooth playhead, calculate absolute step timing to avoid drift

**Main Thread Playback:**
- Playback timer runs on main thread (acceptable for MVP)
- Audio synthesis happens on audio thread (Story 1.3)
- Future optimization: Move step scheduling to background thread

**Pattern Length Changes:**
- If user changes pattern length during playback, handle gracefully
- If currentStep >= new length, reset to 0
- Don't crash or glitch audio

**BPM Range Validation:**
- Min: 60 BPM (250ms per step)
- Max: 200 BPM (75ms per step)
- Validate BPM input in UI (Story 9.1)

---

## Project Context Reference

See `docs/project-context.md` for:
- Timing and scheduling best practices
- CADisplayLink usage patterns
- Audio-visual synchronization strategies
- Performance profiling guidelines

---

## Dev Agent Record

### Agent Model Used

(To be filled by dev agent)

### Implementation Notes

(To be filled by dev agent during implementation)

### Completion Checklist

- [ ] All acceptance criteria met
- [ ] Play/stop functionality working
- [ ] Playhead renders and moves correctly
- [ ] Audio triggers on correct steps
- [ ] Timing accuracy validated (±0.1%)
- [ ] Seamless looping (no gaps)
- [ ] 60 FPS maintained
- [ ] CPU usage <30%
- [ ] Tested on iPhone SE
- [ ] No warnings or errors
- [ ] Ready for code review

### File List

(To be filled by dev agent - list all files created/modified)
