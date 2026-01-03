# Story 2.1: Accented Notes with Hold-Then-Tap Gesture

Status: ready-for-dev

---

## Story

As a **user**,
I want **to create accented notes by holding for ≥400ms then tapping**,
So that **I can add dynamic emphasis to my patterns**.

---

## Acceptance Criteria

**Given** the grid is displayed
**When** I hold my finger on the grid for ≥400ms then tap a pixel
**Then** an accented note is placed with velocity=accent (FR2)
**And** the accented note displays at full brightness (100% opacity)
**And** the accented note plays at 2× volume compared to normal notes (FR14)
**And** a tooltip "ACCENT!" appears during the gesture (FR41)
**And** haptic feedback confirms the accent (iOS only, FR65)

---

## Requirements References

**Functional Requirements:**
- FR2: Users can create accented notes with hold-then-tap gesture
- FR14: System can synthesize notes with 3 velocity levels (normal/accent/sustain)
- FR41: System can display gesture-specific tooltips during interaction
- FR65: iOS provides haptic feedback on note placement

**Non-Functional Requirements:**
- NFR2: Touch response latency <300ms (hold detection + visual feedback)
- NFR45: 60 FPS visual rendering maintained during gesture
- NFR66: Distinct haptic responses per gesture type

**Dependencies:**
- **Story 1.1 (COMPLETE):** Pixel grid rendering
- **Story 1.2 (COMPLETE):** Note data model and tap gesture handling
- **Story 1.3 (COMPLETE):** Audio synthesis engine (needs velocity support)
- **Story 1.4 (COMPLETE):** Playback loop for testing accent volume
- **Story 1.5 (COMPLETE):** Color rendering (accents display at 100% opacity)

---

## Tasks / Subtasks

- [ ] Task 1: Extend Note model to support accent velocity (AC: velocity=accent)
  - [ ] Verify Note.velocity enum has .accent case (should exist from Story 1.2)
  - [ ] Update default note placement to use .normal velocity
  - [ ] Add accent note placement with .accent velocity

- [ ] Task 2: Implement hold-then-tap gesture recognition (AC: ≥400ms hold)
  - [ ] Add gesture state tracking to PixelGridUIView
  - [ ] Implement touchesBegan to start hold timer
  - [ ] Implement touchesMoved to track finger position
  - [ ] Implement touchesEnded with 400ms threshold logic
  - [ ] Distinguish between tap (<400ms) and hold-then-tap (≥400ms)
  - [ ] Cancel gesture if finger moves >10 pixels during hold

- [ ] Task 3: Update audio synthesis for velocity support (AC: 2× volume for accents)
  - [ ] Modify AudioEngine.triggerNote() to accept velocity parameter
  - [ ] Map velocity enum to amplitude: normal=0.6, accent=1.0
  - [ ] Test accent notes play at 2× volume (0.6 → 1.0 = 1.67× actual)
  - [ ] Ensure no audio clipping with accent notes

- [ ] Task 4: Implement visual brightness for accents (AC: 100% opacity)
  - [ ] Modify PixelGridUIView.draw() to check note velocity
  - [ ] Render normal notes at current color
  - [ ] Render accent notes with alpha=1.0 (full brightness)
  - [ ] Test visual distinction is clear at small pixel sizes

- [ ] Task 5: Implement tooltip display (AC: "ACCENT!" tooltip)
  - [ ] Create TooltipOverlay view component
  - [ ] Show "ACCENT!" tooltip during hold phase (≥400ms)
  - [ ] Position tooltip near touch location
  - [ ] Auto-hide tooltip after note placement
  - [ ] Use pixel-font rendering (future: Story 5.x will provide font)

- [ ] Task 6: Implement haptic feedback (AC: iOS haptic on accent)
  - [ ] Use UIImpactFeedbackGenerator(style: .heavy) for accents
  - [ ] Trigger haptic at hold threshold (400ms mark)
  - [ ] Ensure haptic is distinct from normal tap feedback

- [ ] Task 7: Integration testing (AC: All criteria met)
  - [ ] Test hold-then-tap creates accent note
  - [ ] Test tap (<400ms) creates normal note
  - [ ] Test accent displays at full brightness
  - [ ] Test accent plays at 2× volume during playback
  - [ ] Test tooltip appears and hides correctly
  - [ ] Test haptic feedback triggers
  - [ ] Test gesture cancels if finger moves during hold

---

## Dev Notes

### Previous Story Intelligence

**From Story 1.1 (Pixel Grid Rendering):**
- ✅ PixelGridUIView handles touch events via touchesBegan/Moved/Ended
- ✅ Coordinate conversion: touch location → (col, row)
- ✅ File location: `Views/PixelGridUIView.swift`

**From Story 1.2 (Note Placement):**
- ✅ Note struct with velocity enum: .normal, .accent, .sustain
- ✅ SequencerViewModel.toggleNote() places notes
- ✅ Pattern → Track → [Note] data model
- ✅ Basic tap gesture (touchesBegan → touchesEnded <300ms)

**From Story 1.3 (Audio Synthesis):**
- ✅ AudioEngine.triggerNote(pitch, velocity) exists
- ✅ Velocity parameter: Float 0.0-1.0
- ✅ Current implementation uses fixed 0.6 velocity
- ✅ **NEEDS UPDATE:** Add velocity mapping from Note.velocity enum

**From Story 1.4 (Playback Loop):**
- ✅ onStepTick() triggers notes during playback
- ✅ Velocity mapping exists: normal=0.6, accent=1.0, sustain=0.8
- ✅ **ALREADY IMPLEMENTED!** Velocity support exists in playback code

**From Story 1.5 (Color Rendering):**
- ✅ colorForPitch() renders notes with chromatic colors
- ✅ Rendering happens in draw(_ rect: CGRect)
- ✅ **NEW REQUIREMENT:** Overlay brightness for accents

**Key Integration Point:**
This is the **first gesture beyond simple tap**! It introduces:
- Gesture state machine (hold timer, threshold detection)
- Velocity-aware audio synthesis
- Visual differentiation (brightness overlay)
- Haptic feedback system
- Tooltip display system

**Files to Modify:**
- `Views/PixelGridUIView.swift` - Add hold gesture recognition
- `Models/Note.swift` - Verify velocity enum (should already exist)
- `ViewModels/SequencerViewModel.swift` - Add placeAccentNote() method
- `Services/AudioEngine.swift` - Verify velocity parameter (already exists)
- `Views/PixelGridUIView.swift` - Add brightness overlay for accents

**Files to Create:**
- `Views/TooltipOverlay.swift` - Gesture tooltip display (simple version for now)
- `Services/HapticsService.swift` - Centralize haptic feedback

### Architecture Context

**Gesture State Machine:**

This story introduces a simple gesture recognizer pattern that will be reused for all future gestures:

```
State: IDLE
  ↓ touchesBegan
State: HOLDING
  ↓ timer reaches 400ms
State: HOLD_THRESHOLD_REACHED
  ↓ touchesEnded
Action: Place ACCENT note

OR:

State: IDLE
  ↓ touchesBegan
State: HOLDING
  ↓ touchesEnded before 400ms
Action: Place NORMAL note (existing Story 1.2 behavior)
```

**Gesture Timing Requirements:**
- **Tap**: touchesBegan → touchesEnded <400ms = normal note
- **Hold-then-tap**: touchesBegan → 400ms threshold → touchesEnded = accent note
- **Cancel**: Movement >10 pixels during hold = cancel gesture

**Why 400ms threshold?**
- iOS standard for long-press: 500ms
- Our threshold: 400ms (faster for musical interaction)
- Haptic fires at 400ms to give user feedback before release
- Tooltip appears at 400ms to confirm accent mode

### Technical Requirements

**Hold Gesture Recognition Implementation:**

```swift
// Views/PixelGridUIView.swift
class PixelGridUIView: UIView {
    // ... existing properties ...

    // Gesture state tracking
    private var gestureStartTime: Date?
    private var gestureStartLocation: CGPoint?
    private var isHoldGesture: Bool = false

    private let HOLD_THRESHOLD: TimeInterval = 0.4  // 400ms
    private let MOVEMENT_THRESHOLD: CGFloat = 10.0  // 10 pixels

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        gestureStartTime = Date()
        gestureStartLocation = location
        isHoldGesture = false

        // Start hold timer
        DispatchQueue.main.asyncAfter(deadline: .now() + HOLD_THRESHOLD) { [weak self] in
            self?.checkHoldThreshold(at: location)
        }
    }

    private func checkHoldThreshold(at originalLocation: CGPoint) {
        guard let startTime = gestureStartTime,
              let startLocation = gestureStartLocation else { return }

        let elapsed = Date().timeIntervalSince(startTime)

        // Check if still holding at original location
        if elapsed >= HOLD_THRESHOLD {
            let currentLocation = /* get current touch location */
            let movement = hypot(currentLocation.x - startLocation.x,
                               currentLocation.y - startLocation.y)

            if movement < MOVEMENT_THRESHOLD {
                // Hold threshold reached!
                isHoldGesture = true

                // Show tooltip "ACCENT!"
                showTooltip(text: "ACCENT!", at: startLocation)

                // Trigger haptic feedback
                triggerHapticFeedback(style: .heavy)
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Convert to grid coordinates
        let col = Int(location.x / (pixelSize + gapSize))
        let row = Int(location.y / (pixelSize + gapSize))

        // Validate melody track bounds (rows 2-7)
        guard col >= 0, col < 44, row >= 2, row <= 7 else {
            resetGestureState()
            return
        }

        // Place note with appropriate velocity
        let velocity: Note.Velocity = isHoldGesture ? .accent : .normal
        viewModel?.placeNote(col: col, row: row, velocity: velocity)

        // Hide tooltip
        hideTooltip()

        // Reset gesture state
        resetGestureState()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetGestureState()
        hideTooltip()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let startLocation = gestureStartLocation else { return }

        let currentLocation = touch.location(in: self)
        let movement = hypot(currentLocation.x - startLocation.x,
                           currentLocation.y - startLocation.y)

        // Cancel gesture if moved too far
        if movement > MOVEMENT_THRESHOLD {
            resetGestureState()
            hideTooltip()
        }
    }

    private func resetGestureState() {
        gestureStartTime = nil
        gestureStartLocation = nil
        isHoldGesture = false
    }
}
```

**SequencerViewModel Enhancement:**

```swift
// ViewModels/SequencerViewModel.swift
class SequencerViewModel: ObservableObject {
    @Published var pattern: Pattern = Pattern()
    // ... existing properties ...

    // NEW: Place note with specific velocity
    func placeNote(col: Int, row: Int, velocity: Note.Velocity) {
        let pitch = pitchForRow(row)

        // Remove existing note at this column (one note per step rule)
        if let existingIndex = pattern.tracks[.melody]!.notes.firstIndex(where: { $0.col == col }) {
            pattern.tracks[.melody]!.notes.remove(at: existingIndex)
        }

        // Add new note with specified velocity
        let note = Note(col: col, row: row, pitch: pitch, velocity: velocity)
        pattern.tracks[.melody]!.notes.append(note)

        print("Placed \(velocity.rawValue) note at (\(col), \(row)) pitch=\(pitch)")
    }

    private func pitchForRow(_ row: Int) -> Int {
        let melodyRowOffset = row - 2  // Rows 2-7 → offsets 0-5
        let basePitch = 69  // A4 (MIDI)
        return basePitch - melodyRowOffset
    }
}
```

**Audio Engine Velocity Mapping:**

```swift
// Services/AudioEngine.swift (already exists from Story 1.4!)
// This code ALREADY EXISTS in Story 1.4's playback implementation
// Just needs to be used during manual note placement too

func onStepTick(step: Int) {
    currentStep = step

    for track in pattern.tracks.values {
        let notesAtStep = track.notes.filter { $0.col == step }
        for note in notesAtStep {
            let velocity: Float = {
                switch note.velocity {
                case .normal: return 0.6
                case .accent: return 1.0  // ✅ 2× volume (0.6 → 1.0)
                case .sustain: return 0.8
                }
            }()
            audioEngine.triggerNote(pitch: note.pitch, velocity: velocity)

            // ... rest of note-off logic ...
        }
    }
}
```

**Visual Brightness Overlay for Accents:**

```swift
// Views/PixelGridUIView.swift
override func draw(_ rect: CGRect) {
    guard let context = UIGraphicsGetCurrentContext() else { return }

    // ... existing background rendering ...

    for row in 0..<MusicalConstants.ROWS {
        for col in 0..<MusicalConstants.COLS {
            let x = CGFloat(col) * (pixelSize + gapSize)
            let y = CGFloat(row) * (pixelSize + gapSize)
            let pixelRect = CGRect(x: x, y: y, width: pixelSize, height: pixelSize)

            // ... existing music key pixel rendering ...

            if let note = getNoteAt(col: col, row: row) {
                // Base color (chromatic or harmonic mode)
                let noteColor = MusicalConstants.colorForPitch(note.pitch, mode: colorMappingMode)

                // ✅ NEW: Apply brightness based on velocity
                let finalColor: UIColor
                switch note.velocity {
                case .normal:
                    finalColor = noteColor  // Standard brightness
                case .accent:
                    finalColor = noteColor  // Full brightness (100% opacity already default)
                case .sustain:
                    finalColor = noteColor.withAlphaComponent(0.8)  // Slightly dimmed
                }

                context.setFillColor(finalColor.cgColor)
                context.fill(pixelRect)

                // ✅ ALTERNATIVE: Add white overlay for accents (more visible)
                if note.velocity == .accent {
                    context.setFillColor(UIColor.white.withAlphaComponent(0.2).cgColor)
                    context.fill(pixelRect)
                }
            }

            // ... existing playhead rendering ...
        }
    }
}
```

**Tooltip Display (Simple Version):**

```swift
// Views/TooltipOverlay.swift
import SwiftUI

struct TooltipOverlay: View {
    let text: String
    let position: CGPoint
    @Binding var isVisible: Bool

    var body: some View {
        if isVisible {
            Text(text)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .padding(4)
                .background(Color.black.opacity(0.8))
                .cornerRadius(4)
                .position(x: position.x, y: position.y - 30)  // Above touch point
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.2), value: isVisible)
        }
    }
}

// Integration in PixelGridUIView (via UIViewRepresentable parent)
// Use @State var tooltipText: String = ""
// Use @State var tooltipVisible: Bool = false
// Use @State var tooltipPosition: CGPoint = .zero
```

**Haptics Service:**

```swift
// Services/HapticsService.swift
import UIKit

class HapticsService {
    static let shared = HapticsService()

    private var impactGenerator: UIImpactFeedbackGenerator?

    private init() {
        impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactGenerator?.prepare()
    }

    func triggerTap() {
        impactGenerator?.impactOccurred(intensity: 0.5)
    }

    func triggerAccent() {
        let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
        heavyGenerator.prepare()
        heavyGenerator.impactOccurred(intensity: 1.0)
    }

    func triggerHold() {
        let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
        mediumGenerator.prepare()
        mediumGenerator.impactOccurred(intensity: 0.8)
    }
}
```

### Performance Requirements

**Gesture Recognition Performance:**
- Hold threshold detection: <5ms overhead
- Tooltip rendering: <2ms per frame
- Haptic feedback: <10ms latency (iOS system handles this)
- Total gesture overhead: <20ms (well under 300ms touch response budget)

**Visual Rendering:**
- Brightness overlay adds <1ms per accent note
- Tooltip adds <5ms when visible
- **Total:** Still maintain 60 FPS (16.67ms budget)

### Testing Requirements

**Manual Testing Checklist:**
- [ ] Tap pixel (<400ms) → creates normal note
- [ ] Hold pixel (≥400ms) then release → creates accent note
- [ ] Accent note visually brighter than normal note
- [ ] Accent note plays louder during playback (2× volume)
- [ ] Tooltip "ACCENT!" appears at 400ms mark
- [ ] Tooltip disappears after note placed
- [ ] Haptic feedback triggers at 400ms mark
- [ ] Haptic is distinct from normal tap feedback
- [ ] Move finger >10 pixels during hold → gesture cancels
- [ ] Works on all melody track rows (2-7)

**Timing Validation:**
- [ ] Use timer to verify 400ms threshold accuracy
- [ ] Test on iPhone SE (slower device)
- [ ] Test on iPhone 15 Pro Max (faster device)
- [ ] Verify no false positives (tap registered as hold)
- [ ] Verify no false negatives (hold registered as tap)

**Volume Testing:**
- [ ] Record playback with normal notes only
- [ ] Record playback with accent notes only
- [ ] Analyze waveforms: accent should be ~1.67× amplitude (0.6→1.0)
- [ ] Verify no audio clipping with accents

**Integration Testing:**
- [ ] Test with chromatic color mode
- [ ] Test with harmonic color mode
- [ ] Test during active playback (can place accents while playing)
- [ ] Test undo/redo with accent notes (future Story 8.x)

**Unit Testing:**
```swift
import XCTest
@testable import PixelBoop

class HoldGestureTests: XCTestCase {
    func testGestureThreshold() {
        let gridView = PixelGridUIView()

        // Simulate hold gesture
        let startTime = Date()
        gridView.simulateTouch(began: CGPoint(x: 100, y: 100))

        // Wait 500ms
        Thread.sleep(forTimeInterval: 0.5)

        gridView.simulateTouch(ended: CGPoint(x: 100, y: 100))

        // Verify accent note was placed
        XCTAssertTrue(gridView.lastPlacedNoteVelocity == .accent)
    }

    func testGestureCancel() {
        let gridView = PixelGridUIView()

        gridView.simulateTouch(began: CGPoint(x: 100, y: 100))
        gridView.simulateTouch(moved: CGPoint(x: 115, y: 100))  // 15 pixels

        XCTAssertTrue(gridView.gestureWasCancelled)
    }
}
```

### Known Constraints & Gotchas

**Timer Management:**
- Use `DispatchQueue.main.asyncAfter` for hold threshold
- **GOTCHA:** Timer may fire after touchesEnded if user releases quickly
- **FIX:** Check gesture state in timer callback, cancel if already ended

**Movement Threshold:**
- 10 pixels = comfortable tolerance for finger stability
- Too strict (<5px) = accidental cancellations
- Too loose (>20px) = allows unintended drags

**Velocity Mapping:**
- Normal: 0.6 (60% volume)
- Accent: 1.0 (100% volume)
- **RATIO:** 1.0/0.6 = 1.67× (not exactly 2×, but close enough)
- **ALTERNATIVE:** Use 0.5 and 1.0 for exact 2× ratio

**Tooltip Positioning:**
- Position 30 pixels above touch point
- **GOTCHA:** May go off-screen at top rows
- **FIX:** Adjust Y position based on touch location

**Haptic Battery Impact:**
- Haptic feedback drains battery
- Heavy haptic (accent) uses more power than medium (tap)
- **MITIGATION:** User can disable haptics in settings (future Story 10.x)

### Epic 2 Context

**This is Story 1 of 8 in Epic 2: Gesture Vocabulary**

Epic 2 introduces the gesture language that makes PixelBoop unique:
- ✅ **Story 2.1:** Hold-then-tap (accents) ← YOU ARE HERE
- Story 2.2: Horizontal drag (arpeggios)
- Story 2.3: Vertical drag (chords)
- Story 2.4: Diagonal drag (phrases)
- Story 2.5: Hold-and-drag (sustained notes with ADSR)
- Story 2.6: Double-tap (erase)
- Story 2.7: Scrub gesture (clear all)
- Story 2.8: Pattern length configuration

**Gesture Recognition Foundation:**
This story establishes the **gesture state machine pattern** that all future gestures will follow:
1. Track gesture start time and location
2. Detect gesture type based on timing/movement
3. Provide visual feedback (tooltip)
4. Provide haptic feedback
5. Execute musical action

**Reusable Patterns for Future Stories:**
- Tooltip system → reused for all gesture tooltips
- Haptic service → reused for all gesture types
- Gesture state tracking → template for drag gestures
- Timing thresholds → hold vs. tap logic

---

## Project Context Reference

See `docs/project-context.md` for:
- iOS gesture recognition best practices
- UITouch event handling patterns
- Haptic feedback guidelines
- Performance profiling for gesture interactions

---

## Dev Agent Record

### Agent Model Used

(To be filled by dev agent)

### Implementation Notes

(To be filled by dev agent during implementation)

### Completion Checklist

- [ ] All acceptance criteria met
- [ ] Hold gesture recognition working (≥400ms)
- [ ] Accent notes placed correctly
- [ ] Accent notes display at full brightness
- [ ] Accent notes play at 2× volume
- [ ] Tooltip "ACCENT!" displays correctly
- [ ] Haptic feedback triggers
- [ ] Gesture cancels on movement
- [ ] Tap (<400ms) still creates normal notes
- [ ] 60 FPS maintained
- [ ] No audio clipping
- [ ] Tested on iPhone SE and iPhone 15 Pro Max
- [ ] No warnings or errors in Xcode
- [ ] Ready for code review

### File List

(To be filled by dev agent - list all files created/modified)
