# Story 1.2: Single Note Placement with Tap Gesture

Status: ready-for-dev

---

## Story

As a **user**,
I want **to tap any pixel on the melody track to place a note**,
So that **I can start creating musical patterns immediately**.

---

## Acceptance Criteria

**Given** the pixel grid is displayed
**When** I tap a pixel in rows 2-7 (melody track)
**Then** a colored note appears at that grid position (FR1)
**And** the note is color-coded by chromatic pitch (FR38)
**And** the tap gesture completes in <300ms
**And** only one note can exist per step (column) on the melody track
**And** tapping the same position again toggles the note off

---

## Requirements References

**Functional Requirements:**
- FR1: Users can place single notes on the grid by tapping pixels
- FR38: System can render color-coded notes based on chromatic pitch

**Non-Functional Requirements:**
- NFR2: Touch response latency <300ms (tap to visual feedback)
- NFR45: 60 FPS visual rendering maintained during interaction

**Dependencies:**
- **Story 1.1 (REQUIRED):** Pixel grid must be rendered before touch handling
- **Story 1.5 (ENHANCEMENT):** Full chromatic color-coding (this story uses simplified colors)

---

## Tasks / Subtasks

- [ ] Task 1: Create Pattern data model (AC: Note storage structure)
  - [ ] Define Note struct (col, row, pitch, velocity, sustainEnvelope)
  - [ ] Define Track model (notes array, trackType enum)
  - [ ] Define Pattern model (4 tracks, bpm, scale, length)
  - [ ] Implement Codable for JSON serialization (cross-platform)

- [ ] Task 2: Create SequencerViewModel (AC: MVVM state management)
  - [ ] Create @Published pattern: Pattern property
  - [ ] Implement addNote(col, row) method with toggle logic
  - [ ] Implement removeNote(col, row) method
  - [ ] Calculate pitch from row index (chromatic scale, A4=440Hz base)

- [ ] Task 3: Implement touch handling in PixelGridUIView (AC: <300ms tap)
  - [ ] Override touchesBegan to detect tap location
  - [ ] Convert touch point to (col, row) coordinates
  - [ ] Validate touch is in melody track (rows 2-7)
  - [ ] Call viewModel.addNote() or removeNote() based on toggle logic

- [ ] Task 4: Update grid rendering to display notes (AC: Colored pixels)
  - [ ] Read pattern.tracks[melody].notes from ViewModel
  - [ ] Render filled pixels at note positions
  - [ ] Apply chromatic color coding (simplified 12-color palette)
  - [ ] Maintain 60 FPS during note placement

- [ ] Task 5: Wire up SwiftUI → UIKit data flow (AC: Reactive updates)
  - [ ] Pass ViewModel as @ObservedObject to PixelGridView
  - [ ] Update PixelGridUIView when pattern changes
  - [ ] Trigger setNeedsDisplay() on note add/remove

---

## Dev Notes

### Previous Story Intelligence

**From Story 1.1 (Pixel Grid Rendering):**
- ✅ PixelGridUIView.swift created with 44×24 grid rendering
- ✅ PixelGridView.swift bridges UIKit → SwiftUI
- ✅ Pixel size calculation working (6-20px responsive)
- ✅ 60 FPS rendering validated on iPhone SE
- ✅ File structure: Views/PixelGridUIView.swift, Views/PixelGridView.swift

**Key Learnings from Story 1.1:**
- UIKit touch handling required (SwiftUI gestures insufficient for pixel precision)
- CoreGraphics drawRect pattern proven performant
- setNeedsDisplay() selective updates maintain 60 FPS

**Files to Modify:**
- `Views/PixelGridUIView.swift` - Add touch handling, note rendering
- `Views/PixelGridView.swift` - Pass ViewModel to UIView

**Files to Create:**
- `Models/Note.swift` - Note data structure
- `Models/Track.swift` - Track model with note array
- `Models/Pattern.swift` - Complete pattern state
- `ViewModels/SequencerViewModel.swift` - MVVM state management

### Architecture Context

**MVVM Data Flow:**
```
User Tap
  ↓
PixelGridUIView.touchesBegan (UIKit)
  ↓
Convert touch → (col, row)
  ↓
SequencerViewModel.addNote(col, row) (Logic Layer)
  ↓
Pattern.tracks[melody].notes.append/remove (Model)
  ↓
@Published pattern change triggers SwiftUI update
  ↓
PixelGridView.updateUIView called (Bridge)
  ↓
PixelGridUIView.setNeedsDisplay() (Render)
  ↓
drawRect renders note pixels (Visual)
```

### Technical Requirements

**Touch Coordinate Conversion:**
```swift
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let location = touch.location(in: self)

    // Convert pixel coordinates to grid (col, row)
    let col = Int(location.x / (pixelSize + gapSize))
    let row = Int(location.y / (pixelSize + gapSize))

    // Validate bounds
    guard col >= 0, col < 44, row >= 2, row <= 7 else { return }

    // Call ViewModel
    viewModel.toggleNote(col: col, row: row)
}
```

**Pitch Calculation (Chromatic Scale):**
```swift
// Melody track uses rows 2-7 (6 rows = 6 semitones)
// Row 2 = highest pitch, Row 7 = lowest pitch
// Base: A4 = 440Hz (MIDI note 69)

func pitchForRow(_ row: Int) -> Int {
    let melodyRowOffset = row - 2  // 0-5 range
    let basePitch = 69  // A4 (MIDI)
    return basePitch - melodyRowOffset  // Descending pitch (row 2 = A4, row 7 = E4)
}
```

**Chromatic Color Palette (Simplified):**
```swift
// From prototype: 12 colors for chromatic notes (C, C#, D, D#, E, F, F#, G, G#, A, A#, B)
let NOTE_COLORS: [UIColor] = [
    UIColor(hex: "#ff0000"),  // C  - Red
    UIColor(hex: "#ff4500"),  // C# - Red-Orange
    UIColor(hex: "#ff8c00"),  // D  - Dark Orange
    UIColor(hex: "#ffc800"),  // D# - Orange-Yellow
    UIColor(hex: "#ffff00"),  // E  - Yellow
    UIColor(hex: "#9acd32"),  // F  - Yellow-Green
    UIColor(hex: "#00ff00"),  // F# - Green
    UIColor(hex: "#00ffaa"),  // G  - Green-Cyan
    UIColor(hex: "#00ffff"),  // G# - Cyan
    UIColor(hex: "#00aaff"),  // A  - Cyan-Blue
    UIColor(hex: "#0055ff"),  // A# - Blue
    UIColor(hex: "#8a2be2"),  // B  - Purple
]

func colorForPitch(_ pitch: Int) -> UIColor {
    let chromaticIndex = pitch % 12
    return NOTE_COLORS[chromaticIndex]
}
```

**Note Toggle Logic:**
```swift
class SequencerViewModel: ObservableObject {
    @Published var pattern: Pattern = Pattern()

    func toggleNote(col: Int, row: Int) {
        let pitch = pitchForRow(row)

        // Check if note exists at this column
        if let existingIndex = pattern.tracks[.melody].notes.firstIndex(where: { $0.col == col }) {
            // Remove existing note (toggle off)
            pattern.tracks[.melody].notes.remove(at: existingIndex)
        } else {
            // Add new note (toggle on)
            let note = Note(col: col, row: row, pitch: pitch, velocity: .normal)
            pattern.tracks[.melody].notes.append(note)
        }
    }
}
```

### Data Model Structure

**Note Model:**
```swift
struct Note: Codable, Equatable {
    let col: Int        // Grid column (0-43)
    let row: Int        // Grid row (0-23)
    let pitch: Int      // MIDI pitch (0-127)
    let velocity: Velocity  // normal, accent, sustain
    var sustainEnvelope: SustainEnvelope?  // Optional ADSR (Story 2.5)

    enum Velocity: String, Codable {
        case normal = "normal"
        case accent = "accent"
        case sustain = "sustain"
    }
}

struct SustainEnvelope: Codable {
    let attack: Double
    let decay: Double
    let sustain: Double
    let release: Double
}
```

**Track Model:**
```swift
enum TrackType: String, Codable {
    case melody = "melody"
    case chords = "chords"
    case bass = "bass"
    case rhythm = "rhythm"
}

struct Track: Codable {
    let type: TrackType
    var notes: [Note] = []
}
```

**Pattern Model:**
```swift
struct Pattern: Codable {
    var tracks: [TrackType: Track] = [
        .melody: Track(type: .melody),
        .chords: Track(type: .chords),
        .bass: Track(type: .bass),
        .rhythm: Track(type: .rhythm)
    ]
    var bpm: Int = 120
    var scale: String = "major"  // major, minor, penta
    var rootNote: String = "C"   // C, C#, D, etc.
    var length: Int = 16         // 8, 16, 24, 32 steps
}
```

### Performance Requirements

**Touch Response Target: <300ms**
- Touch detection: <5ms (UIKit touchesBegan)
- Coordinate conversion: <1ms (simple arithmetic)
- ViewModel update: <10ms (array append/remove)
- SwiftUI update propagation: <50ms (@Published trigger)
- UIKit setNeedsDisplay: <5ms (mark dirty)
- drawRect execution: <5ms (incremental pixel render)
- **Total: ~76ms (well under 300ms budget)**

**60 FPS Maintenance:**
- Only redraw changed pixels (dirty rectangle optimization)
- Batch multiple taps within same frame
- Profile with Instruments if >5ms per tap

### Testing Requirements

**Manual Testing Checklist:**
- [ ] Tap melody row 2 → colored note appears
- [ ] Tap same position → note disappears (toggle off)
- [ ] Tap melody row 7 → different colored note appears
- [ ] Tap outside melody rows (0-1, 8-23) → no note placed
- [ ] Tap same column twice on different rows → only one note persists
- [ ] Rapid tapping → all taps register correctly
- [ ] Visual feedback appears in <300ms
- [ ] 60 FPS maintained during interaction

**Unit Testing:**
- [ ] Test `toggleNote(col, row)` logic (add/remove)
- [ ] Test `pitchForRow()` calculation (rows 2-7 → pitches)
- [ ] Test `colorForPitch()` chromatic mapping (0-11 → colors)
- [ ] Test Note model Codable encoding/decoding

**Integration Testing:**
- [ ] Touch → ViewModel → View update flow
- [ ] Multiple notes on melody track
- [ ] Notes persist across screen rotation (future)

### Cross-Platform Compatibility

**Pattern JSON Format:**
```json
{
  "tracks": {
    "melody": {
      "type": "melody",
      "notes": [
        {"col": 0, "row": 3, "pitch": 67, "velocity": "normal"},
        {"col": 4, "row": 5, "pitch": 65, "velocity": "normal"}
      ]
    },
    "chords": {"type": "chords", "notes": []},
    "bass": {"type": "bass", "notes": []},
    "rhythm": {"type": "rhythm", "notes": []}
  },
  "bpm": 120,
  "scale": "major",
  "rootNote": "C",
  "length": 16
}
```

**CRITICAL:** This JSON structure must exactly match web version for import/export compatibility.

### Prototype Reference

**Web Prototype Implementation:**
See `docs/prototype_sequencer.jsx`:
- Lines 6-10: NOTE_COLORS chromatic palette (use exact same hex values)
- Lines 20-24: SCALES definition (major, minor, penta intervals)
- Touch handling proven functional on web Canvas
- Toggle logic: tap same position removes note

**Gesture Recognition Timing:**
- Tap threshold: <300ms from touchesBegan to touchesEnded
- Hold threshold: ≥400ms (not needed for this story, but documented for Story 2.1)

### Known Constraints & Gotchas

**One Note Per Step Rule:**
- Only one note allowed per column on melody track
- If user taps column 5 row 2, then taps column 5 row 3, replace the first note
- Implementation: `notes.firstIndex(where: { $0.col == col })` finds existing

**Row → Pitch Mapping:**
- Melody rows 2-7 map to descending pitches (row 2 = highest)
- This is inverted from musical staff convention (intentional for visual clarity)
- Future stories will apply scale snapping to constrain pitches

**SwiftUI + UIKit Bridging:**
- Cannot pass closures directly through UIViewRepresentable
- Use @ObservedObject ViewModel pattern for two-way binding
- Coordinator pattern may be needed for complex interactions (Story 2.x)

**Performance Optimization:**
- Avoid redrawing entire grid on every note change
- Use `setNeedsDisplay(dirtyRect)` with specific pixel bounds
- Consider offscreen bitmap cache for static grid structure

---

## Project Context Reference

See `docs/project-context.md` for:
- Swift coding standards (naming, formatting, documentation)
- MVVM architecture patterns
- Testing requirements and strategies
- Cross-platform JSON schema specifications

---

## Dev Agent Record

### Agent Model Used

(To be filled by dev agent)

### Implementation Notes

(To be filled by dev agent during implementation)

### Completion Checklist

- [ ] All acceptance criteria met
- [ ] Pattern model created and tested
- [ ] ViewModel state management working
- [ ] Touch handling functional (<300ms)
- [ ] Note rendering with chromatic colors
- [ ] Toggle logic working correctly
- [ ] 60 FPS maintained during interaction
- [ ] Unit tests passing
- [ ] No warnings or errors in Xcode
- [ ] Ready for code review

### File List

(To be filled by dev agent - list all files created/modified)
