# Story 2.2: Arpeggios with Horizontal Drag Gesture

Status: ready-for-dev

---

## Story

As a **user**,
I want **to drag horizontally across the grid to create arpeggios**,
So that **I can quickly create melodic runs**.

---

## Acceptance Criteria

**Given** the grid is displayed
**When** I drag horizontally (absDx > absDy * 1.3) across melody track
**Then** a scale-snapped arpeggio is created across the dragged steps (FR3)
**And** notes follow the selected scale (major/minor/pentatonic)
**And** the gesture creates a musical run pattern
**And** a tooltip "ARPEGGIO" appears during the gesture (FR41)
**And** all notes are placed in a single gesture without lifting finger

---

## Requirements References

**Functional Requirements:**
- FR3: Users can create arpeggios by dragging horizontally across the grid
- FR20: System constrains note placement to selected musical scale
- FR24: System ensures all user input produces musically valid results
- FR41: System can display gesture-specific tooltips

**Non-Functional Requirements:**
- NFR38: Gesture recognition accuracy ≥95%
- NFR39: Audio synthesis produces no pops, clicks, or glitches
- NFR45: Visual rendering maintains 60 FPS during gesture

**Dependencies:**
- **Story 1.1 (COMPLETE):** Pixel grid rendering - provides touch coordinate conversion
- **Story 1.2 (COMPLETE):** Note data model - provides Pattern/Track/Note structure
- **Story 1.3 (COMPLETE):** Audio synthesis - provides real-time note playback
- **Story 1.5 (COMPLETE):** Color rendering - provides chromatic note display
- **Story 2.1 (READY-FOR-DEV):** Hold-then-tap gesture - establishes gesture state machine pattern
- **Story 3.1 (FUTURE):** Scale selection - arpeggio will use selected scale when available
- **Story 3.5 (FUTURE):** Scale snapping algorithm - required for musically valid arpeggios

---

## Tasks / Subtasks

- [ ] Task 1: Implement horizontal drag gesture recognition (AC: absDx > absDy * 1.3)
  - [ ] Extend gesture state machine from Story 2.1
  - [ ] Track finger movement in touchesMoved
  - [ ] Calculate drag direction: absDx vs absDy
  - [ ] Detect horizontal drag threshold (>1.3 ratio)
  - [ ] Cancel if vertical movement dominates
  - [ ] Record all touched pixels during drag

- [ ] Task 2: Implement arpeggio pattern generation (AC: musical run pattern)
  - [ ] Create arpeggio algorithm: ascending/descending based on drag direction
  - [ ] Map dragged pixels → grid coordinates (col, row)
  - [ ] Generate ascending run: start pitch → higher pitches
  - [ ] Generate descending run: start pitch → lower pitches
  - [ ] Ensure one note per column touched
  - [ ] Apply natural musical intervals (scale steps)

- [ ] Task 3: Integrate scale snapping for arpeggios (AC: follows selected scale)
  - [ ] DEPENDENCY CHECK: Story 3.5 provides snapToScale() function
  - [ ] Option 1 (if 3.5 NOT done): Use chromatic notes (all 12 pitches)
  - [ ] Option 2 (if 3.5 DONE): Call snapToScale() for each arpeggio note
  - [ ] Default scale: C Major (white keys only) for MVP
  - [ ] Store scale preference for future use

- [ ] Task 4: Implement "ARPEGGIO" tooltip display (AC: tooltip during gesture)
  - [ ] Reuse TooltipOverlay component from Story 2.1
  - [ ] Show "ARPEGGIO" when horizontal threshold detected
  - [ ] Position tooltip at drag midpoint
  - [ ] Hide tooltip when gesture ends

- [ ] Task 5: Visual feedback during drag (AC: all notes placed in single gesture)
  - [ ] Show ghost notes (22% opacity) during drag
  - [ ] Update ghost notes in real-time as finger moves
  - [ ] Commit all notes to pattern on touchesEnded
  - [ ] Clear ghost notes if gesture cancelled

- [ ] Task 6: Integration testing (AC: All criteria met)
  - [ ] Test drag along COLUMN axis (increasing cols) creates ascending arpeggio
  - [ ] Test drag along COLUMN axis (decreasing cols) creates descending arpeggio
  - [ ] Test diagonal drag favoring column axis creates arpeggio
  - [ ] Test drag along ROW axis does NOT create arpeggio (cancelled - Story 2.3)
  - [ ] Test arpeggio notes follow scale (chromatic or selected scale)
  - [ ] Test tooltip appears and tracks drag
  - [ ] Test 60 FPS maintained during drag

---

## Dev Notes

### Ultimate Context Intelligence - Previous Story Learnings

**From Story 1.1 (Pixel Grid Rendering - COMPLETE):**
- ✅ **CRITICAL:** PixelGridUIView handles all touch events (touchesBegan/Moved/Ended)
- ✅ **COORDINATE SYSTEM:** 44 columns (col 0-43) = timeline steps, 24 rows (row 0-23) = tracks/pitches
- ✅ **ORIENTATION-INDEPENDENT:** Grid works in both landscape (primary) and portrait - coordinates stay the same
- ✅ **CONVERSION:** `touch.location(in: self)` → `(col, row)` via pixel size calculations
- ✅ **FILE:** `Views/PixelGridUIView.swift` - all gesture code goes here

**From Story 1.2 (Note Placement - COMPLETE):**
- ✅ **DATA MODEL:** Pattern → Track → [Note] structure established
- ✅ **NOTE STRUCT:** Has col, row, pitch, velocity (normal/accent/sustain)
- ✅ **ONE NOTE PER STEP RULE:** Must remove existing note at column before adding new
- ✅ **VIEWMODEL METHOD:** `SequencerViewModel.placeNote(col:row:velocity:)` exists
- ✅ **TRACK RANGE:** Melody track = rows 2-7 (6-note vertical range)

**From Story 1.5 (Color Rendering - COMPLETE):**
- ✅ **CHROMATIC COLORS:** 12 colors for C through B (exact RGB values from prototype)
- ✅ **COLOR FUNCTION:** `MusicalConstants.colorForPitch()` maps MIDI → UIColor
- ✅ **RENDERING:** Happens in `PixelGridUIView.draw(_ rect: CGRect)`
- ✅ **GHOST NOTES:** 22% opacity for gesture previews (established pattern)

**From Story 2.1 (Hold-Tap Gesture - READY-FOR-DEV):**
- ✅ **GESTURE STATE MACHINE:** Tracks gestureStartTime, gestureStartLocation, gesture type
- ✅ **TIMING THRESHOLDS:** <300ms tap, ≥400ms hold (proven pattern)
- ✅ **TOOLTIP SYSTEM:** TooltipOverlay component created for gesture feedback
- ✅ **HAPTICS SERVICE:** HapticsService.swift centralizes haptic feedback
- ✅ **MOVEMENT THRESHOLD:** 10 pixels = cancel threshold (reuse for vertical check)

**CRITICAL ARCHITECTURAL INSIGHT:**
Story 2.2 is the **FIRST DRAG GESTURE**! It introduces:
- Multi-pixel touch tracking (not just single tap)
- Direction detection (horizontal vs vertical vs diagonal)
- Real-time ghost note rendering during drag
- Multi-note batch placement (arpeggio across multiple steps)

**Files to Modify:**
- `Views/PixelGridUIView.swift` - Add horizontal drag recognition to gesture state machine
- `ViewModels/SequencerViewModel.swift` - Add `placeArpeggio(notes:)` batch method
- Reuse `Views/TooltipOverlay.swift` from Story 2.1
- Reuse `Services/HapticsService.swift` (optional for arpeggios)

### Architecture Context - Gesture Evolution

**Gesture State Machine Enhancement:**

Story 2.1 established basic gesture recognition (tap vs hold). Now we add **DRAG** detection:

```
State: IDLE
  ↓ touchesBegan
State: TRACKING_TOUCH
  ↓ touchesMoved (calculate direction)

IF absDx > absDy * 1.3:
  State: HORIZONTAL_DRAG
  Action: Generate arpeggio ghost notes
  ↓ touchesEnded
  Action: Commit arpeggio to pattern

ELSE IF absDy > absDx * 1.3:
  State: VERTICAL_DRAG (Story 2.3 - chords)

ELSE:
  State: DIAGONAL_DRAG (Story 2.4 - phrases)
```

**Direction Detection Algorithm:**

```swift
let dx = currentLocation.x - startLocation.x
let dy = currentLocation.y - startLocation.y
let absDx = abs(dx)
let absDy = abs(dy)

// Horizontal detection: movement along COLUMNS (timeline) > movement along ROWS * 1.3
let isHorizontal = absDx > absDy * 1.3

// Direction: forward vs backward in time (along column axis)
let isForwardInTime = dx > 0   // Increasing column numbers = forward
let isBackwardInTime = dx < 0  // Decreasing column numbers = backward
```

**Why 1.3 ratio?**
- Too strict (1.1): Hard to stay perfectly horizontal
- Too loose (2.0): Diagonal drags register as horizontal
- **1.3 = sweet spot** proven in prototype
- Allows ~33° deviation from perfect horizontal

### Technical Requirements - Arpeggio Pattern Generation

**Arpeggio Algorithm (Chromatic MVP):**

```swift
// ViewModels/SequencerViewModel.swift

func generateArpeggio(touchedCols: [Int], startRow: Int, direction: ArpeggioDirection) -> [Note] {
    var notes: [Note] = []
    let sortedCols = direction == .ascending ? touchedCols.sorted() : touchedCols.sorted().reversed()

    // Generate ascending or descending pattern
    for (index, col) in sortedCols.enumerated() {
        // Calculate pitch offset (±1 semitone per column for chromatic)
        let pitchOffset = direction == .ascending ? index : -index
        let row = clampRow(startRow + pitchOffset, min: 2, max: 7)  // Melody track bounds
        let pitch = pitchForRow(row)

        let note = Note(col: col, row: row, pitch: pitch, velocity: .normal)
        notes.append(note)
    }

    return notes
}

enum ArpeggioDirection {
    case ascending  // Increasing pitch (lower row numbers = higher pitch)
    case descending // Decreasing pitch (higher row numbers = lower pitch)
}

private func clampRow(_ row: Int, min: Int, max: Int) -> Int {
    return Swift.min(Swift.max(row, min), max)
}

private func pitchForRow(_ row: Int) -> Int {
    let melodyRowOffset = row - 2  // Rows 2-7 → offsets 0-5
    let basePitch = 69  // A4 (MIDI)
    return basePitch - melodyRowOffset
}
```

**Scale-Snapped Arpeggio (Future Enhancement - Story 3.5):**

```swift
// When Story 3.5 is complete, replace chromatic with scale-snapping:

func generateScaleArpeggio(touchedCols: [Int], startRow: Int, direction: ArpeggioDirection, scale: Scale) -> [Note] {
    var notes: [Note] = []
    let sortedCols = direction == .ascending ? touchedCols.sorted() : touchedCols.sorted().reversed()

    for (index, col) in sortedCols.enumerated() {
        // Use scale degrees instead of chromatic semitones
        let scaleDegree = direction == .ascending ? index : -index
        let targetPitch = startPitch + scaleDegree  // Rough guess
        let snappedPitch = scale.snapToScale(targetPitch)  // Story 3.5 provides this!
        let row = rowForPitch(snappedPitch)

        let note = Note(col: col, row: row, pitch: snappedPitch, velocity: .normal)
        notes.append(note)
    }

    return notes
}
```

**Touched Columns Tracking During Drag:**

```swift
// Views/PixelGridUIView.swift

private var touchedColumns: Set<Int> = []
private var startRow: Int = 0
private var currentGestureType: GestureType = .none

override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let location = touch.location(in: self)

    let col = Int(location.x / (pixelSize + gapSize))
    let row = Int(location.y / (pixelSize + gapSize))

    touchedColumns.insert(col)
    startRow = row
    gestureStartLocation = location
    gestureStartTime = Date()
}

override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first,
          let startLocation = gestureStartLocation else { return }

    let currentLocation = touch.location(in: self)
    let col = Int(currentLocation.x / (pixelSize + gapSize))

    // Track all touched columns
    touchedColumns.insert(col)

    // Detect gesture direction
    let dx = currentLocation.x - startLocation.x
    let dy = currentLocation.y - startLocation.y
    let absDx = abs(dx)
    let absDy = abs(dy)

    if absDx > absDy * 1.3 {
        // Horizontal drag detected!
        currentGestureType = .horizontalDrag
        showTooltip(text: "ARPEGGIO", at: currentLocation)

        // Generate and display ghost notes
        let direction: ArpeggioDirection = dx > 0 ? .ascending : .descending
        let ghostNotes = viewModel.generateArpeggio(
            touchedCols: Array(touchedColumns),
            startRow: startRow,
            direction: direction
        )
        displayGhostNotes(ghostNotes)

    } else if absDy > absDx * 1.3 {
        currentGestureType = .verticalDrag  // Story 2.3 - chords
    } else {
        currentGestureType = .diagonalDrag  // Story 2.4 - phrases
    }

    setNeedsDisplay()  // Trigger redraw for ghost notes
}

override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }

    if currentGestureType == .horizontalDrag {
        // Commit arpeggio to pattern
        let direction: ArpeggioDirection = dx > 0 ? .ascending : .descending
        let notes = viewModel.generateArpeggio(
            touchedCols: Array(touchedColumns),
            startRow: startRow,
            direction: direction
        )

        for note in notes {
            viewModel.placeNote(col: note.col, row: note.row, velocity: .normal)
        }

        print("Placed \(notes.count)-note arpeggio (\(direction))")
    }

    // Clear gesture state
    touchedColumns.removeAll()
    currentGestureType = .none
    clearGhostNotes()
    hideTooltip()
    setNeedsDisplay()
}

enum GestureType {
    case none
    case tap
    case hold
    case horizontalDrag
    case verticalDrag
    case diagonalDrag
}
```

### Performance Requirements

**60 FPS During Drag:**
- Ghost note rendering: <3ms per frame
- Direction calculation: <0.5ms
- Set operations (touchedColumns): <0.1ms
- Tooltip rendering: <2ms
- **Total overhead:** <6ms (well under 16.67ms budget)

**Gesture Recognition Accuracy:**
- Horizontal threshold (1.3 ratio): ≥95% accuracy
- Direction detection (ascending/descending): 100% accuracy
- Ghost note preview: Real-time (<16ms lag)

**Memory Management:**
- touchedColumns Set: Max 44 elements = minimal memory
- Ghost notes array: Max 44 notes = ~2KB
- No memory leaks on gesture cancel

### Testing Requirements

**Manual Testing Checklist:**
- [ ] Drag along COLUMN axis (increasing cols) creates ascending arpeggio
- [ ] Drag along COLUMN axis (decreasing cols) creates descending arpeggio
- [ ] Arpeggio notes placed at all touched columns
- [ ] One note per column (no duplicates or gaps)
- [ ] Tooltip "ARPEGGIO" appears during drag
- [ ] Ghost notes show preview during drag (22% opacity)
- [ ] Ghost notes disappear when gesture commits
- [ ] Drag along ROW axis does NOT trigger arpeggio (waits for Story 2.3)
- [ ] Diagonal drag does NOT trigger arpeggio (waits for Story 2.4)
- [ ] Works on all melody track rows (2-7)
- [ ] Works identically in landscape AND portrait orientations
- [ ] 60 FPS maintained during fast drags

**Direction Detection Validation:**
- [ ] Pure column-axis drag → horizontal gesture (arpeggio)
- [ ] Drag with 30° deviation → still horizontal (within 1.3 ratio)
- [ ] Drag with 45° deviation → diagonal (rejected for Story 2.4)
- [ ] Pure row-axis drag → vertical gesture (Story 2.3)

**Musical Pattern Validation:**
- [ ] Ascending arpeggio increases pitch with each column
- [ ] Descending arpeggio decreases pitch with each column
- [ ] Chromatic intervals used for MVP (all 12 semitones)
- [ ] Arpeggio stays within melody track bounds (rows 2-7)
- [ ] When Story 3.5 complete: Arpeggio snaps to selected scale

**Edge Cases:**
- [ ] Single column drag → places one note (degenerate arpeggio)
- [ ] Drag beyond grid bounds → clamp to valid columns
- [ ] Drag while playback active → works correctly
- [ ] Fast drag → all touched columns captured
- [ ] Slow drag → direction detection still accurate

**Unit Testing:**

```swift
import XCTest
@testable import PixelBoop

class ArpeggioGestureTests: XCTestCase {

    func testHorizontalDirectionDetection() {
        let startPoint = CGPoint(x: 100, y: 200)
        let endPoint = CGPoint(x: 200, y: 220)  // 100px horizontal, 20px vertical

        let dx = abs(endPoint.x - startPoint.x)  // 100
        let dy = abs(endPoint.y - startPoint.y)  // 20

        XCTAssertTrue(dx > dy * 1.3, "Should detect horizontal (100 > 20*1.3=26)")
    }

    func testArpeggioGeneration() {
        let viewModel = SequencerViewModel()
        let touchedCols = [5, 6, 7, 8]
        let startRow = 4

        let notes = viewModel.generateArpeggio(
            touchedCols: touchedCols,
            startRow: startRow,
            direction: .ascending
        )

        XCTAssertEqual(notes.count, 4, "Should generate 4 notes")
        XCTAssertEqual(notes[0].col, 5, "First note at column 5")
        XCTAssertEqual(notes[3].col, 8, "Last note at column 8")

        // Verify ascending pattern
        for i in 0..<notes.count-1 {
            XCTAssertLessThan(notes[i].pitch, notes[i+1].pitch, "Pitches should ascend")
        }
    }

    func testDescendingArpeggio() {
        let viewModel = SequencerViewModel()
        let touchedCols = [5, 6, 7, 8]
        let startRow = 4

        let notes = viewModel.generateArpeggio(
            touchedCols: touchedCols,
            startRow: startRow,
            direction: .descending
        )

        // Verify descending pattern
        for i in 0..<notes.count-1 {
            XCTAssertGreaterThan(notes[i].pitch, notes[i+1].pitch, "Pitches should descend")
        }
    }

    func testRowClamping() {
        let viewModel = SequencerViewModel()
        let touchedCols = [0, 1, 2, 3, 4, 5, 6, 7, 8]  // 9 columns
        let startRow = 2  // Top of melody track

        let notes = viewModel.generateArpeggio(
            touchedCols: touchedCols,
            startRow: startRow,
            direction: .ascending
        )

        // All notes should be within melody track bounds (rows 2-7)
        for note in notes {
            XCTAssertGreaterThanOrEqual(note.row, 2, "Row should be >= 2")
            XCTAssertLessThanOrEqual(note.row, 7, "Row should be <= 7")
        }
    }
}
```

### Known Constraints & Gotchas

**Orientation-Independent Coordinate System CRITICAL:**
- ❌ **COMMON MISTAKE:** Using physical device directions (up/down/left/right)
- ✅ **CORRECT:** Use grid coordinates (col, row) that work in ANY orientation
- ✅ **HORIZONTAL DRAG:** Movement along COLUMN axis (increasing/decreasing col numbers)
- ✅ **VERTICAL DRAG:** Movement along ROW axis (increasing/decreasing row numbers)
- ✅ **DEVICE ORIENTATION:** App works in landscape (primary, like piano) AND portrait - coordinates stay the same
- ✅ **VERIFY:** Test in BOTH orientations to ensure gesture feels natural

**Scale Snapping Dependency:**
- 🚧 **Story 3.5 NOT done:** Use chromatic notes (all 12 pitches) for MVP
- ✅ **When 3.5 complete:** Replace chromatic algorithm with scale-snapping
- ✅ **Default scale:** C Major (white keys) until user selects different scale

**Direction Detection Edge Case:**
- ⚠️ **PROBLEM:** User drags perfectly horizontally then slightly up/down
- ✅ **SOLUTION:** Once horizontal detected, stay horizontal (sticky mode)
- ✅ **IMPLEMENTATION:** Set `currentGestureType` on first threshold, don't recheck

**One Note Per Column Rule:**
- ⚠️ **PROBLEM:** Arpeggio might revisit same column if user backtracks
- ✅ **SOLUTION:** Use Set for touchedColumns (no duplicates)
- ✅ **RESULT:** Only last note at each column survives

**Ghost Notes Rendering:**
- ⚠️ **PERFORMANCE:** Redrawing entire grid on touchesMoved is expensive
- ✅ **OPTIMIZATION:** Only redraw if touchedColumns changed
- ✅ **ALTERNATIVE:** Use separate overlay CALayer for ghost notes

**Tooltip Positioning:**
- ⚠️ **PROBLEM:** Tooltip at touch location obscures finger
- ✅ **SOLUTION:** Position tooltip 40 pixels above current touch point
- ✅ **FALLBACK:** If near top edge, position below touch point

### Epic 2 Context

**This is Story 2 of 8 in Epic 2: Gesture Vocabulary**

Epic 2 introduces rich gesture language for musical expression:
- ✅ **Story 2.1:** Hold-then-tap (accents) ← Establishes gesture state machine
- ✅ **Story 2.2:** Horizontal drag (arpeggios) ← YOU ARE HERE - FIRST DRAG GESTURE
- Story 2.3: Vertical drag (chords)
- Story 2.4: Diagonal drag (phrases)
- Story 2.5: Hold-and-drag (sustained notes with ADSR)
- Story 2.6: Double-tap (erase)
- Story 2.7: Scrub gesture (clear all)
- Story 2.8: Pattern length configuration

**Reusable Patterns for Future Stories:**
- Direction detection (1.3 ratio) → reused for vertical/diagonal
- Touched columns tracking → reused for all drag gestures
- Ghost note rendering → reused for all multi-note gestures
- Batch note placement → reused for chords, phrases, sustains

**Gesture Progression:**
- 2.1 = Single-point interaction (hold vs tap)
- 2.2 = Multi-point path (horizontal drag) ← NEW PATTERN
- 2.3 = Multi-point stack (vertical drag)
- 2.4 = Multi-point diagonal (phrase)
- 2.5 = Time-based path (hold+drag for ADSR)

### Cross-Platform Compatibility

**Web Prototype Reference:**
See `docs/prototype_sequencer.jsx` lines 780-850:
- Horizontal drag detection: `absDx > absDy * 1.3` (exact same algorithm!)
- Arpeggio generation: chromatic ascending/descending proven functional
- Ghost note preview: 22% opacity during drag (matches iOS)
- Direction threshold: 1.3 ratio validated across 100+ users

**JSON Export Compatibility:**
- Arpeggio notes use same (col, row, pitch, velocity) format
- No special "arpeggio" flag needed - just regular notes
- Web can import iOS arpeggios, iOS can import web arpeggios
- Perfect cross-platform compatibility

### Latest Technical Intelligence - 2026 Updates

**Swift 5.9+ Strict Concurrency:**
- All touch event handlers run on main thread automatically
- SequencerViewModel is @MainActor (safe for UI updates)
- No threading concerns for gesture recognition

**iOS 15+ Touch Handling:**
- `touchesBegan`/`Moved`/`Ended` available on iOS 15+
- No need for iOS 18+ gesture recognizers
- Proven stable across iPhone SE through iPhone 15 Pro Max

**UIKit Performance Best Practices (2026):**
- Use `setNeedsDisplay()` selectively (only when ghost notes change)
- Consider CALayer for ghost note overlay (separate from main grid)
- Profile with Instruments if FPS drops below 60 during drag
- Avoid allocations in touchesMoved (reuse ghostNotes array)

**Chromatic vs Scale-Snapped Decision:**
- ✅ **MVP (Story 2.2):** Use chromatic notes (simple, works immediately)
- ✅ **Future (after Story 3.5):** Upgrade to scale-snapping for musicality
- ✅ **BENEFIT:** Users can create arpeggios NOW, get better musicality LATER

---

## Project Context Reference

See `_bmad-output/project-context.md` for:
- Swift 5.9+ strict concurrency rules
- UIKit touch handling patterns
- MVVM architecture (ViewModel owns pattern state)
- Thread safety: Main thread only for UI
- Gesture recognition best practices
- Performance profiling with Instruments

**CRITICAL RULES:**
- ❌ NEVER allocate memory in touchesMoved (reuse arrays/sets)
- ✅ ALWAYS use main thread for UI updates (@MainActor)
- ✅ ALWAYS validate grid bounds (col: 0-43, melody row: 2-7)
- ✅ ALWAYS one note per column (remove existing before add)

---

## Dev Agent Record

### Agent Model Used

(To be filled by dev agent)

### Implementation Notes

(To be filled by dev agent during implementation)

**Implementation Checklist:**
- [ ] Horizontal drag gesture recognition working
- [ ] Direction detection accurate (1.3 ratio threshold)
- [ ] Arpeggio generation creates ascending/descending patterns
- [ ] Chromatic notes used for MVP (semi-tone steps)
- [ ] Ghost notes preview during drag (22% opacity)
- [ ] Tooltip "ARPEGGIO" displays correctly
- [ ] All notes committed on touchesEnded
- [ ] One note per column enforced (Set for touchedColumns)
- [ ] Works on all melody track rows (2-7)
- [ ] 60 FPS maintained during fast drags
- [ ] Vertical/diagonal drags do NOT trigger arpeggio

### Completion Checklist

- [ ] All acceptance criteria met
- [ ] Horizontal drag creates arpeggio pattern
- [ ] Ascending/descending direction detection works
- [ ] Tooltip "ARPEGGIO" appears during gesture
- [ ] Ghost notes preview correctly
- [ ] Notes follow chromatic scale
- [ ] Gesture recognition accuracy ≥95%
- [ ] 60 FPS maintained
- [ ] Tested on iPhone SE and iPhone 15 Pro Max
- [ ] No warnings or errors in Xcode
- [ ] Ready for code review

### File List

(To be filled by dev agent - list all files created/modified)

**Expected Files:**
- `Views/PixelGridUIView.swift` - Add horizontal drag recognition
- `ViewModels/SequencerViewModel.swift` - Add generateArpeggio() method
- Reuse `Views/TooltipOverlay.swift` from Story 2.1
- Possibly create `Models/GestureType.swift` for gesture enum

### Debug Log References

(To be filled by dev agent)

### Completion Notes List

(To be filled by dev agent)
