# Story 1.5: Color-Coded Note Rendering by Chromatic Pitch

Status: ready-for-dev

---

## Story

As a **user**,
I want **notes to display in different colors based on their pitch**,
So that **I can visually distinguish between different notes**.

---

## Acceptance Criteria

**Given** notes are placed on the melody track
**When** the grid is rendered in chromatic mode (default)
**Then** each note displays with its chromatic color (FR38):
- C=#ff0000 (red), C#=#ff4500, D=#ff8c00, D#=#ffc800
- E=#ffff00 (yellow), F=#9acd32, F#=#00ff00 (green)
- G=#00ffaa, G#=#00ffff (cyan), A=#00aaff (blue)
- A#=#0055ff, B=#8a2be2 (purple)
**And** note colors match the prototype exactly (CR4)
**And** colors remain consistent across all device displays

**Given** the user long-presses (≥600ms) on the music key pixel (row 0, col 0)
**When** the long press is detected
**Then** the color mapping mode toggles between chromatic and harmonic
**And** all notes immediately re-render with the new color scheme
**And** a tooltip "CHROMATIC" or "HARMONIC" appears confirming the mode
**And** the selected mode persists across app sessions

**Given** the grid is rendered in harmonic mode (circle of fifths)
**When** notes are displayed
**Then** each note displays with its harmonic color following the circle of fifths:
- C=#ff0000 (red), G=#ff4500 (red-orange), D=#ff8c00 (orange)
- A=#ffc800 (orange-yellow), E=#ffff00 (yellow), B=#9acd32 (yellow-green)
- F#=#00ff00 (green), C#=#00ffaa (green-cyan), G#=#00ffff (cyan)
- D#=#00aaff (cyan-blue), A#=#0055ff (blue), F=#8a2be2 (purple)
**And** harmonically related notes (perfect fifths) appear adjacent in color spectrum
**And** the circle of fifths progression aids music theory learning

---

## Requirements References

**Functional Requirements:**
- FR38: System can render color-coded notes based on chromatic pitch
- FR37: System can display a 44×24 pixel grid interface (from Story 1.1)

**Non-Functional Requirements:**
- NFR45: 60 FPS visual rendering maintained during interaction
- CR4: Cross-platform pattern compatibility (color values must match web version)

**Dependencies:**
- **Story 1.1 (COMPLETE):** Pixel grid rendering foundation with PixelGridUIView
- **Story 1.2 (COMPLETE):** Note data model with pitch field (MIDI note numbers)
- **Story 1.3 (COMPLETE):** Audio synthesis (provides pitch-to-frequency reference)
- **Story 1.4 (COMPLETE):** Playback loop (colors must work during playback)

---

## Tasks / Subtasks

- [ ] Task 1: Create dual color mapping system (AC: Chromatic + Harmonic modes)
  - [ ] Define UIColor extension with hex initializer
  - [ ] Create NOTE_COLORS_CHROMATIC array with 12 chromatic colors
  - [ ] Create NOTE_COLORS_HARMONIC array with 12 circle-of-fifths colors
  - [ ] Create CIRCLE_OF_FIFTHS mapping array [0,7,2,9,4,11,6,1,8,3,10,5] (C,G,D,A,E,B,F#,C#,G#,D#,A#,F)
  - [ ] Add NOTE_NAMES array for debugging/logging
  - [ ] Add ColorMappingMode enum: .chromatic, .harmonic

- [ ] Task 2: Implement color mode state management (AC: Toggle persists)
  - [ ] Add colorMappingMode property to SequencerViewModel (@Published)
  - [ ] Implement toggleColorMode() method
  - [ ] Save mode to UserDefaults on toggle
  - [ ] Load mode from UserDefaults on app launch
  - [ ] Default to .chromatic mode for first-time users

- [ ] Task 3: Implement long-press gesture on music key pixel (AC: ≥600ms triggers toggle)
  - [ ] Add UILongPressGestureRecognizer to PixelGridUIView
  - [ ] Set minimum press duration to 0.6 seconds
  - [ ] Detect long press at row 0, col 0 (music key pixel)
  - [ ] Call viewModel.toggleColorMode() on successful long press
  - [ ] Display tooltip "CHROMATIC" or "HARMONIC" on mode change
  - [ ] Provide haptic feedback on mode toggle (UIImpactFeedbackGenerator)

- [ ] Task 4: Update PixelGridUIView rendering (AC: Notes display with active color scheme)
  - [ ] Implement colorForPitch(_ pitch: Int, mode: ColorMappingMode) -> UIColor
  - [ ] For chromatic mode: use pitch % 12 as direct index
  - [ ] For harmonic mode: use CIRCLE_OF_FIFTHS[pitch % 12] as index
  - [ ] Modify draw(_ rect: CGRect) to read colorMappingMode from ViewModel
  - [ ] Ensure colors are vivid and distinguishable at small pixel sizes
  - [ ] Test color accuracy matches specifications

- [ ] Task 5: Render music key pixel indicator (AC: Visual cue for toggle)
  - [ ] Draw music key pixel at row 0, col 0 with special indicator
  - [ ] Use pulsing animation or border to hint at interactivity
  - [ ] Display current mode icon/color on the pixel
  - [ ] Ensure indicator doesn't obscure grid functionality

- [ ] Task 6: Validate cross-platform color compatibility (AC: Match web version)
  - [ ] Compare iOS rendered colors with prototype_sequencer.jsx NOTE_COLORS
  - [ ] Test on iPhone SE (smallest screen) for color clarity
  - [ ] Test on iPhone 15 Pro Max for color consistency
  - [ ] Verify sRGB color space handling for consistent display
  - [ ] Test both chromatic and harmonic modes

- [ ] Task 7: Performance validation (AC: 60 FPS maintained)
  - [ ] Profile rendering with Instruments Core Animation
  - [ ] Ensure color lookup adds <1ms overhead per frame (both modes)
  - [ ] Test with full 44-column pattern (all notes colored)
  - [ ] Test mode toggle performance (should be instant)
  - [ ] Verify no performance regression from Story 1.1

---

## Dev Notes

### Previous Story Intelligence

**From Story 1.1 (Pixel Grid Rendering):**
- ✅ PixelGridUIView.swift renders 44×24 grid using CoreGraphics
- ✅ drawRect pattern established: iterate rows/cols, fill pixel rects
- ✅ 60 FPS rendering validated with Instruments
- ✅ File location: `Views/PixelGridUIView.swift`

**From Story 1.2 (Note Placement):**
- ✅ Note struct includes `pitch: Int` field (MIDI note numbers 0-127)
- ✅ pitchForRow() function converts grid row to MIDI pitch
- ✅ Pattern → Track → [Note] data model established
- ✅ SequencerViewModel.pattern is @Published for reactive updates
- ✅ Basic note rendering already implemented (used simplified colors)

**From Story 1.3 (Audio Synthesis):**
- ✅ Pitch-to-frequency conversion: `freq = 440.0 * pow(2.0, (pitch - 69) / 12.0)`
- ✅ MIDI note 69 = A4 = 440Hz (reference pitch)
- ✅ Chromatic scale: 12 semitones per octave

**From Story 1.4 (Playback Loop):**
- ✅ Playhead rendering adds white overlay during playback
- ✅ setNeedsDisplay() triggers re-render on pattern changes
- ✅ isPlaying and currentStep properties control visual state

**Key Integration Point:**
This story **replaces** the simplified color logic from Story 1.2 with the production-ready 12-color chromatic palette. It's the final visual polish for Epic 1, completing the "Instant Music Creation" experience.

**Files to Modify:**
- `Views/PixelGridUIView.swift` - Update colorForPitch() function
- `Models/MusicalConstants.swift` (create if doesn't exist) - Centralize NOTE_COLORS and NOTE_NAMES

**Files Already Created:**
- Story 1.1: `Views/PixelGridUIView.swift`, `Views/PixelGridView.swift`
- Story 1.2: `Models/Note.swift`, `Models/Track.swift`, `Models/Pattern.swift`
- Story 1.2: `ViewModels/SequencerViewModel.swift`
- Story 1.3: `Services/AudioEngine.swift`, `Audio/AudioEngine.cpp`
- Story 1.4: `Services/PlaybackTimer.swift`

### Architecture Context

**Chromatic Color Theory:**
- **12 chromatic notes** per octave: C, C#, D, D#, E, F, F#, G, G#, A, A#, B
- **MIDI pitch modulo 12** maps to chromatic position (e.g., MIDI 60, 72, 84 = C)
- **Color wheel mapping**: 30° per semitone (360° ÷ 12 = 30°)
- **Hue progression**: Red → Orange → Yellow → Green → Cyan → Blue → Purple

**iOS Color Space Considerations:**
- Use **sRGB color space** for consistent cross-device rendering
- UIColor defaults to sRGB in modern iOS (15+)
- Hex colors from web prototype are already sRGB values
- No color space conversion needed (web and iOS both sRGB)

**Performance Implications:**
- Color lookup: O(1) array access (pitch % 12)
- No heap allocations (pre-allocated UIColor array)
- CoreGraphics setFillColor is fast (<0.1ms per call)
- **Total overhead:** <1ms per frame for full 44-column pattern

### Technical Requirements

**Dual Color Mapping System:**

```swift
// CRITICAL: These hex values MUST match prototype_sequencer.jsx exactly!
// See: docs/prototype_sequencer.jsx lines 5-9
extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        r = (int >> 16) & 0xFF
        g = (int >> 8) & 0xFF
        b = int & 0xFF
        self.init(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: 1.0
        )
    }
}

// Color mapping mode enum
enum ColorMappingMode: String, Codable {
    case chromatic  // Sequential: C, C#, D, D#, E, F, F#, G, G#, A, A#, B
    case harmonic   // Circle of fifths: C, G, D, A, E, B, F#, C#, G#, D#, A#, F
}

// Rainbow colors (same hex values, different pitch assignments)
let RAINBOW_COLORS: [UIColor] = [
    UIColor(hex: "#ff0000"),  // Red
    UIColor(hex: "#ff4500"),  // Red-Orange
    UIColor(hex: "#ff8c00"),  // Orange
    UIColor(hex: "#ffc800"),  // Orange-Yellow
    UIColor(hex: "#ffff00"),  // Yellow
    UIColor(hex: "#9acd32"),  // Yellow-Green
    UIColor(hex: "#00ff00"),  // Green
    UIColor(hex: "#00ffaa"),  // Green-Cyan
    UIColor(hex: "#00ffff"),  // Cyan
    UIColor(hex: "#00aaff"),  // Cyan-Blue
    UIColor(hex: "#0055ff"),  // Blue
    UIColor(hex: "#8a2be2"),  // Purple
]

// Chromatic mode: Direct pitch → color mapping
// Index = chromatic position (C=0, C#=1, D=2, etc.)
let NOTE_COLORS_CHROMATIC: [UIColor] = RAINBOW_COLORS  // Same as original

// Harmonic mode: Circle of fifths → color mapping
// Maps pitch to position in circle of fifths, then to rainbow color
// Circle of fifths: C(0°) → G(30°) → D(60°) → A(90°) → E(120°) → B(150°) → F#(180°) → C#(210°) → G#(240°) → D#(270°) → A#(300°) → F(330°)
let CIRCLE_OF_FIFTHS: [Int] = [
    0,   // C  → position 0 (Red)
    7,   // C# → position 7 (Green-Cyan)
    2,   // D  → position 2 (Orange)
    9,   // D# → position 9 (Cyan-Blue)
    4,   // E  → position 4 (Yellow)
    11,  // F  → position 11 (Purple)
    6,   // F# → position 6 (Green)
    1,   // G  → position 1 (Red-Orange)
    8,   // G# → position 8 (Cyan)
    3,   // A  → position 3 (Orange-Yellow)
    10,  // A# → position 10 (Blue)
    5,   // B  → position 5 (Yellow-Green)
]

let NOTE_NAMES = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

// Dual-mode color lookup
func colorForPitch(_ pitch: Int, mode: ColorMappingMode) -> UIColor {
    let chromaticIndex = pitch % 12

    switch mode {
    case .chromatic:
        // Direct mapping: C=red, C#=red-orange, D=orange, etc.
        return RAINBOW_COLORS[chromaticIndex]

    case .harmonic:
        // Circle of fifths mapping: C=red, G=red-orange, D=orange, A=orange-yellow, etc.
        let harmonicPosition = CIRCLE_OF_FIFTHS[chromaticIndex]
        return RAINBOW_COLORS[harmonicPosition]
    }
}

func nameForPitch(_ pitch: Int) -> String {
    let chromaticIndex = pitch % 12
    let octave = (pitch / 12) - 1  // MIDI note 60 = C4
    return "\(NOTE_NAMES[chromaticIndex])\(octave)"
}
```

**Circle of Fifths Explanation:**

The **circle of fifths** is a fundamental music theory concept showing harmonic relationships between notes. Notes separated by a perfect fifth (7 semitones) are harmonically related.

**Why This Matters:**
- **Harmonic Color Mode** makes harmonically related notes appear visually similar (adjacent colors)
- **Educational Value:** Users learn music theory by seeing harmonic relationships visually
- **Composition Aid:** Chord progressions (I-IV-V, etc.) have cohesive color patterns

**Circle of Fifths Progression:**
```
C → G → D → A → E → B → F# → C# → G# → D# → A# → F → (back to C)
↓   ↓   ↓   ↓   ↓   ↓    ↓     ↓     ↓     ↓     ↓    ↓
Red RO  Org OY  Yel YG   Grn   GC    Cyn   CB    Blu  Pur
```

**Example Harmonic Relationships:**
- C major chord (C-E-G): Red, Yellow, Red-Orange (warm colors cluster)
- A minor chord (A-C-E): Orange-Yellow, Red, Yellow (cohesive palette)
- Perfect fifth (C-G): Red → Red-Orange (adjacent colors = harmonic relationship)

**State Management in SequencerViewModel:**

```swift
// ViewModels/SequencerViewModel.swift
class SequencerViewModel: ObservableObject {
    @Published var pattern: Pattern = Pattern()
    @Published var isPlaying: Bool = false
    @Published var currentStep: Int = 0
    @Published var colorMappingMode: ColorMappingMode = .chromatic  // ✅ NEW

    private let audioEngine = AudioEngine()
    private let playbackTimer = PlaybackTimer()

    init() {
        // Load persisted color mode preference
        loadColorModePreference()

        do {
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }

    // ✅ NEW: Toggle color mapping mode
    func toggleColorMode() {
        colorMappingMode = (colorMappingMode == .chromatic) ? .harmonic : .chromatic
        saveColorModePreference()

        // Trigger UI update
        objectWillChange.send()

        print("Color mode toggled to: \(colorMappingMode.rawValue)")
    }

    // ✅ NEW: Persist color mode preference
    private func saveColorModePreference() {
        UserDefaults.standard.set(colorMappingMode.rawValue, forKey: "colorMappingMode")
    }

    // ✅ NEW: Load color mode preference
    private func loadColorModePreference() {
        if let savedMode = UserDefaults.standard.string(forKey: "colorMappingMode"),
           let mode = ColorMappingMode(rawValue: savedMode) {
            colorMappingMode = mode
        } else {
            colorMappingMode = .chromatic  // Default for first-time users
        }
    }

    // ... rest of existing ViewModel code (play, stop, etc.)
}
```

**Updated PixelGridUIView Rendering:**

```swift
// Views/PixelGridUIView.swift
class PixelGridUIView: UIView {
    var pattern: Pattern?
    var currentStep: Int = 0
    var isPlaying: Bool = false
    var colorMappingMode: ColorMappingMode = .chromatic  // ✅ NEW
    weak var viewModel: SequencerViewModel?  // For mode toggle callback

    private var longPressGestureRecognizer: UILongPressGestureRecognizer!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGestureRecognizers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGestureRecognizers()
    }

    // ✅ NEW: Setup long-press gesture for mode toggle
    private func setupGestureRecognizers() {
        longPressGestureRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongPress(_:))
        )
        longPressGestureRecognizer.minimumPressDuration = 0.6  // 600ms
        addGestureRecognizer(longPressGestureRecognizer)
    }

    // ✅ NEW: Handle long-press on music key pixel (row 0, col 0)
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }

        let location = gesture.location(in: self)
        let col = Int(location.x / (pixelSize + gapSize))
        let row = Int(location.y / (pixelSize + gapSize))

        // Check if long-press is on music key pixel (row 0, col 0)
        if row == 0 && col == 0 {
            // Toggle color mode
            viewModel?.toggleColorMode()

            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()

            // TODO: Show tooltip "CHROMATIC" or "HARMONIC" (Story 5.x)

            // Trigger re-render
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        // Draw background
        context.setFillColor(MusicalConstants.BACKGROUND_COLOR.cgColor)
        context.fill(rect)

        // Draw grid pixels with dual-mode color support
        for row in 0..<MusicalConstants.ROWS {
            for col in 0..<MusicalConstants.COLS {
                let x = CGFloat(col) * (pixelSize + gapSize)
                let y = CGFloat(row) * (pixelSize + gapSize)
                let pixelRect = CGRect(x: x, y: y, width: pixelSize, height: pixelSize)

                // ✅ NEW: Special rendering for music key pixel (row 0, col 0)
                if row == 0 && col == 0 {
                    drawMusicKeyPixel(context: context, rect: pixelRect)
                    continue
                }

                // Check if there's a note at this position
                if let note = getNoteAt(col: col, row: row) {
                    // ✅ UPDATED: Use dual-mode color based on current mode
                    let noteColor = MusicalConstants.colorForPitch(note.pitch, mode: colorMappingMode)
                    context.setFillColor(noteColor.cgColor)
                    context.fill(pixelRect)
                }

                // Draw playhead overlay (from Story 1.4)
                if isPlaying && col == currentStep {
                    context.setFillColor(UIColor.white.withAlphaComponent(0.2).cgColor)
                    context.fill(pixelRect)
                }
            }
        }
    }

    // ✅ NEW: Render music key pixel with mode indicator
    private func drawMusicKeyPixel(context: CGContext, rect: CGRect) {
        // Background: Show current mode color
        let modeColor: UIColor = (colorMappingMode == .chromatic)
            ? UIColor(hex: "#ff0000")  // Red for chromatic (C is red)
            : UIColor(hex: "#ff0000")  // Red for harmonic (C is still red)

        context.setFillColor(modeColor.cgColor)
        context.fill(rect)

        // Pulsing border to indicate interactivity
        context.setStrokeColor(UIColor.white.withAlphaComponent(0.5).cgColor)
        context.setLineWidth(1.0)
        context.stroke(rect)

        // Optional: Add subtle icon/indicator (future enhancement)
    }

    // Helper: Get note at grid position
    private func getNoteAt(col: Int, row: Int) -> Note? {
        guard let pattern = pattern else { return nil }

        // Check all tracks for note at this position
        for track in pattern.tracks.values {
            if let note = track.notes.first(where: { $0.col == col && $0.row == row }) {
                return note
            }
        }
        return nil
    }
}
```

**SwiftUI Bridge Update:**

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
        uiView.colorMappingMode = viewModel.colorMappingMode  // ✅ NEW
        uiView.setNeedsDisplay()
    }
}
```

**File Organization Strategy:**

Create `Models/MusicalConstants.swift` to centralize musical constants:

```swift
// Models/MusicalConstants.swift
import UIKit

/// Musical constants and color mappings for PixelBoop
/// Cross-platform compatibility: Color values MUST match prototype_sequencer.jsx
enum MusicalConstants {
    // Grid dimensions (from Story 1.1)
    static let COLS = 44
    static let ROWS = 24
    static let GAP_SIZE: CGFloat = 1.0
    static let BACKGROUND_COLOR = UIColor(hex: "#0a0a0a")

    // Rainbow colors (same 12 colors, different assignments by mode)
    static let RAINBOW_COLORS: [UIColor] = [
        UIColor(hex: "#ff0000"),  // Red
        UIColor(hex: "#ff4500"),  // Red-Orange
        UIColor(hex: "#ff8c00"),  // Orange
        UIColor(hex: "#ffc800"),  // Orange-Yellow
        UIColor(hex: "#ffff00"),  // Yellow
        UIColor(hex: "#9acd32"),  // Yellow-Green
        UIColor(hex: "#00ff00"),  // Green
        UIColor(hex: "#00ffaa"),  // Green-Cyan
        UIColor(hex: "#00ffff"),  // Cyan
        UIColor(hex: "#00aaff"),  // Cyan-Blue
        UIColor(hex: "#0055ff"),  // Blue
        UIColor(hex: "#8a2be2"),  // Purple
    ]

    // Circle of fifths mapping: pitch index → rainbow color position
    static let CIRCLE_OF_FIFTHS: [Int] = [
        0,   // C  → Red
        7,   // C# → Green-Cyan
        2,   // D  → Orange
        9,   // D# → Cyan-Blue
        4,   // E  → Yellow
        11,  // F  → Purple
        6,   // F# → Green
        1,   // G  → Red-Orange
        8,   // G# → Cyan
        3,   // A  → Orange-Yellow
        10,  // A# → Blue
        5,   // B  → Yellow-Green
    ]

    static let NOTE_NAMES = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

    // Scale definitions (for future stories)
    static let SCALES = [
        "major": [0, 2, 4, 5, 7, 9, 11],
        "minor": [0, 2, 3, 5, 7, 8, 10],
        "penta": [0, 2, 4, 7, 9],
    ]

    // Dual-mode color lookup
    static func colorForPitch(_ pitch: Int, mode: ColorMappingMode) -> UIColor {
        let chromaticIndex = pitch % 12

        switch mode {
        case .chromatic:
            return RAINBOW_COLORS[chromaticIndex]
        case .harmonic:
            let harmonicPosition = CIRCLE_OF_FIFTHS[chromaticIndex]
            return RAINBOW_COLORS[harmonicPosition]
        }
    }

    static func nameForPitch(_ pitch: Int) -> String {
        let chromaticIndex = pitch % 12
        let octave = (pitch / 12) - 1
        return "\(NOTE_NAMES[chromaticIndex])\(octave)"
    }
}
```

### Cross-Platform Compatibility

**Critical Requirement (CR4):**
iOS colors MUST match web version exactly for pattern import/export compatibility.

**Prototype Reference:**
```javascript
// docs/prototype_sequencer.jsx lines 5-9
const NOTE_COLORS = {
  0: '#ff0000', 1: '#ff4500', 2: '#ff8c00', 3: '#ffc800',
  4: '#ffff00', 5: '#9acd32', 6: '#00ff00', 7: '#00ffaa',
  8: '#00ffff', 9: '#00aaff', 10: '#0055ff', 11: '#8a2be2',
};
```

**Validation Strategy:**
1. Export pattern from iOS
2. Import into web version
3. Visual comparison: colors must be identical
4. Hex value validation: screenshot both platforms, use color picker to verify RGB values

**sRGB Color Space Consistency:**
- Web browsers use sRGB color space by default
- iOS UIColor uses sRGB in extended color space mode (iOS 10+)
- Hex values are sRGB by definition (web standard)
- **Result:** Direct hex → UIColor conversion is safe and accurate

### UX Design Rationale

**From UX Design Specification:**

**Chromatic Color Wheel Mapping:**
- Each of 12 chromatic notes maps to 30° on color wheel (360° ÷ 12)
- Progression follows musical circle of fifths AND rainbow spectrum
- Red (C) → Yellow (E) → Green (F#) → Blue (A#) → Purple (B) → Red (C)

**Visual Distinguishability:**
- Minimum color separation: 30° hue difference
- High saturation (80-100%) for vividness at small pixel sizes
- Brightness: 100% for normal notes, dimmed for accents/sustains (future stories)

**Accessibility Considerations:**
- Color is NOT the only differentiator (grid position also conveys pitch)
- High contrast with dark background (#0a0a0a) ensures visibility
- Future: Option to overlay note names for color-blind users (Story 5.x)

### Performance Requirements

**60 FPS Rendering Target:**
- Each frame budget: 16.67ms (1000ms / 60fps)
- Color lookup overhead: <0.1ms per note
- CoreGraphics fill operation: <0.5ms for full 44-column pattern
- **Total rendering budget:** <5ms per frame (well under 16.67ms)

**Optimization Techniques:**
- Pre-allocate NOTE_COLORS array (no heap allocations in draw loop)
- Use modulo operator (%) for fast chromatic index calculation
- Cache UIColor.cgColor for reuse within frame
- No gradient calculations (solid fills only)

**Performance Testing Checklist:**
- [ ] Profile with Instruments Core Animation
- [ ] Verify FPS stays at 60 during note placement
- [ ] Test with full 44-column pattern (all notes colored)
- [ ] Measure color lookup time (should be <0.1ms)
- [ ] Test on iPhone SE 2nd gen (slowest target device)

### Testing Requirements

**Manual Testing Checklist:**
- [ ] Place notes in melody track (rows 2-7)
- [ ] Verify each row displays different chromatic color
- [ ] Compare colors with prototype in web browser
- [ ] Test on iPhone SE (smallest screen) for color clarity
- [ ] Test on iPhone 15 Pro Max for color consistency
- [ ] Place notes during playback → colors render correctly
- [ ] Rapid note placement → 60 FPS maintained
- [ ] Take screenshot → color picker verify hex values match

**Chromatic Color Validation:**
- [ ] C (MIDI 60, 72, 84) → Red (#ff0000)
- [ ] C# (MIDI 61, 73) → Red-Orange (#ff4500)
- [ ] D (MIDI 62, 74) → Orange (#ff8c00)
- [ ] E (MIDI 64) → Yellow (#ffff00)
- [ ] F# (MIDI 66) → Green (#00ff00)
- [ ] A (MIDI 69) → Cyan-Blue (#00aaff)
- [ ] B (MIDI 71) → Purple (#8a2be2)

**Cross-Platform Compatibility Testing:**
- [ ] Export pattern from iOS (JSON)
- [ ] Import into web prototype
- [ ] Visual comparison: colors identical?
- [ ] Hex value validation: screenshot both platforms
- [ ] Use Digital Color Meter (macOS) to verify RGB values

**Unit Testing:**
```swift
import XCTest
@testable import PixelBoop

class ChromaticColorTests: XCTestCase {
    func testColorForPitch_C() {
        let color = MusicalConstants.colorForPitch(60)  // C4
        // UIColor to hex validation (test helper needed)
        XCTAssertEqual(color.hexString, "#ff0000")
    }

    func testColorForPitch_Octaves() {
        let c3 = MusicalConstants.colorForPitch(48)  // C3
        let c4 = MusicalConstants.colorForPitch(60)  // C4
        let c5 = MusicalConstants.colorForPitch(72)  // C5
        // All C notes should have same color
        XCTAssertEqual(c3, c4)
        XCTAssertEqual(c4, c5)
    }

    func testNameForPitch() {
        XCTAssertEqual(MusicalConstants.nameForPitch(60), "C4")
        XCTAssertEqual(MusicalConstants.nameForPitch(69), "A4")
        XCTAssertEqual(MusicalConstants.nameForPitch(71), "B4")
    }
}
```

**Integration Testing:**
- [ ] Test with SequencerViewModel pattern updates
- [ ] Verify @Published pattern triggers color re-render
- [ ] Test with playback loop (Story 1.4 integration)
- [ ] Confirm playhead overlay doesn't obscure note colors

### Known Constraints & Gotchas

**UIColor Hex Initializer:**
- Swift standard library doesn't include hex initializer
- Must implement custom `UIColor(hex:)` convenience init
- Watch for leading "#" handling and case sensitivity

**Modulo Operator Behavior:**
- Swift modulo preserves sign: `-1 % 12 = -1` (not 11)
- For MIDI pitches (always positive), standard % is safe
- If negative pitches possible, use: `((pitch % 12) + 12) % 12`

**Color Space Gotchas:**
- UIColor defaults to extended sRGB on iOS 10+
- Hex colors are sRGB by definition
- No color space conversion needed
- Display P3 devices will auto-convert sRGB (no action needed)

**Performance:**
- Don't call `colorForPitch` multiple times per note per frame
- Cache color value if used multiple times in same draw call
- Pre-compute colors for all 128 MIDI notes if performance issues arise

**SwiftUI vs UIKit:**
- This story uses UIKit (PixelGridUIView with CoreGraphics)
- If migrating to SwiftUI Canvas in future, use `Color(UIColor(hex:))`
- SwiftUI Color and UIColor are interchangeable via initializers

### Prototype Reference

**Web Prototype Implementation:**
See `docs/prototype_sequencer.jsx`:
- Lines 5-9: NOTE_COLORS exact hex values (MUST match)
- Lines 11-12: NOTE_NAMES for debugging
- Rendering proven functional with Canvas 2D context

**Color Usage in Prototype:**
```javascript
// Prototype rendering (Canvas 2D)
const color = NOTE_COLORS[note.pitch % 12];
ctx.fillStyle = color;
ctx.fillRect(x, y, pixelSize, pixelSize);
```

**iOS Equivalent:**
```swift
// iOS rendering (CoreGraphics)
let color = MusicalConstants.colorForPitch(note.pitch)
context.setFillColor(color.cgColor)
context.fill(pixelRect)
```

### Epic 1 Completion Context

**This is the final story in Epic 1!**

Epic 1: Instant Music Creation Progress:
- ✅ Story 1.1: 44×24 pixel grid rendering
- ✅ Story 1.2: Note placement with tap gesture
- ✅ Story 1.3: Real-time audio synthesis
- ✅ Story 1.4: Continuous playback loop
- 🎯 Story 1.5: Chromatic color rendering (YOU ARE HERE!)

**What Epic 1 Delivers:**
A fully functional music sequencer where users can:
1. See the pixel grid
2. Tap to place notes
3. Hear synthesized sound
4. Press play and hear the loop
5. See colored notes that represent pitch

**Next Steps After Epic 1:**
- Epic 1 Retrospective (optional)
- Epic 2: Gesture Vocabulary (hold-accent, drag gestures)
- Epic 3: Musical Intelligence (scale snapping, chord voicing)

---

## Project Context Reference

See `docs/project-context.md` for:
- Swift coding standards (naming, formatting, documentation)
- CoreGraphics best practices for custom rendering
- Color management and color space handling
- Cross-platform compatibility requirements
- Testing strategies and coverage expectations

---

## Dev Agent Record

### Agent Model Used

(To be filled by dev agent)

### Implementation Notes

(To be filled by dev agent during implementation)

### Completion Checklist

- [ ] All acceptance criteria met
- [ ] MusicalConstants.swift created with NOTE_COLORS array
- [ ] UIColor hex initializer implemented
- [ ] colorForPitch() function working correctly
- [ ] PixelGridUIView updated to use chromatic colors
- [ ] Cross-platform color validation complete
- [ ] Colors match prototype hex values exactly
- [ ] 60 FPS maintained with full pattern
- [ ] Tested on iPhone SE and iPhone 15 Pro Max
- [ ] Unit tests passing
- [ ] No warnings or errors in Xcode
- [ ] Ready for code review

### File List

(To be filled by dev agent - list all files created/modified)
