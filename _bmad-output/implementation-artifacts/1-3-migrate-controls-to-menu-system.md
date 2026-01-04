# Story 1.3: Implement Row 0 Controls (Pixel-Only)

Status: ready-for-dev

---

## Story

As a **user**,
I want **to access playback, tempo, and editing controls through Row 0 of the pixel grid**,
So that **I can control my musical creation using the same pixel-based interface as note editing**.

---

## Acceptance Criteria

**Given** the pixel grid is displayed (Story 1.1 and 1.2 complete)
**When** I interact with Row 0 controls
**Then** the Play/Stop button (cols 0-2) toggles playback state (FR12, FR13)
**And** Undo/Redo buttons (cols 4-5) reverse/restore recent actions (FR78, FR79)
**And** Scale selectors (cols 7-9) allow changing musical scale (FR28, FR29)
**And** Root note selectors (cols 11-22) allow choosing chromatic root note
**And** Ghost toggle (col 24) enables/disables ghost note preview
**And** BPM controls (cols 26-28) allow tempo adjustment from 40-240 BPM (FR26)
**And** Pattern length controls (cols 30-32) set loop length (8-32 steps)
**And** Clear button (cols 40-43) erases all pattern data
**And** all controls provide haptic feedback on interaction (FR59)
**And** controls have VoiceOver accessibility labels (NFR49)
**And** controls work identically on hardware controllers (FR107)
**And** control rendering maintains 60 FPS performance (NFR1)

---

## Requirements References

**Functional Requirements:**
- FR12: Users can start pattern playback at current BPM
- FR13: Users can stop pattern playback
- FR26: Users can set global BPM (40-240 range, 1 BPM increments)
- FR28: Users can select musical scale from presets
- FR29: System provides 8+ common scales (Major, Minor, Pentatonic, etc.)
- FR78: Users can undo last action (64-action history)
- FR79: Users can redo previously undone action
- FR107: Menu system works identically on hardware controllers

**Non-Functional Requirements:**
- NFR1: Visual rendering at 60 FPS on target devices
- NFR49: All interactive UI elements must have VoiceOver accessibility labels
- NFR59: Haptic feedback on user interactions

---

## Tasks / Subtasks

- [ ] Task 1: Create SequencerViewModel for domain state
  - [ ] Create SequencerViewModel.swift in ViewModels folder
  - [ ] Add @Published playback state (isPlaying: Bool)
  - [ ] Add @Published BPM state (bpm: Int = 120, range 40-240)
  - [ ] Add @Published scale state (currentScale: Scale = .major)
  - [ ] Add @Published root note state (rootNote: Note = .C)
  - [ ] Add @Published ghost notes state (showGhostNotes: Bool = true)
  - [ ] Add @Published pattern length state (patternLength: Int = 16)
  - [ ] Implement togglePlayback() method
  - [ ] Implement setBPM(_ value: Int) with validation
  - [ ] Implement setScale(_ scale: Scale) method
  - [ ] Implement setRootNote(_ note: Note) method
  - [ ] Implement toggleGhostNotes() method
  - [ ] Implement setPatternLength(_ length: Int) with validation (8-32)
  - [ ] Implement clearPattern() method
  - [ ] Add UndoManager integration
  - [ ] Write unit tests for SequencerViewModel

- [ ] Task 2: Add Row 0 control rendering to PixelGridUIView
  - [ ] Modify PixelGridUIView to accept SequencerViewModel reference
  - [ ] Add drawControlsRow0() method in draw(_:)
  - [ ] Render Play/Stop button at cols 0-2 (green when stopped, red when playing)
  - [ ] Render Undo button at col 4 (dim when canUndo=false)
  - [ ] Render Redo button at col 5 (dim when canRedo=false)
  - [ ] Render Scale selectors at cols 7-9 (major/minor/penta with color coding)
  - [ ] Render Root note selectors at cols 11-22 (12 chromatic notes with NOTE_COLORS)
  - [ ] Render Ghost toggle at col 24 (bright when enabled, dim when disabled)
  - [ ] Render BPM display at cols 26-28 using 3×5 pixel font
  - [ ] Render Pattern length at cols 30-32 using 3×5 pixel font
  - [ ] Render Clear button at cols 40-43 (red warning color)

- [ ] Task 3: Add Row 0 tap gesture handling
  - [ ] Modify handleTap() to detect Row 0 taps
  - [ ] Map tap location to control column ranges
  - [ ] Call viewModel.togglePlayback() for cols 0-2
  - [ ] Call viewModel.undo() for col 4
  - [ ] Call viewModel.redo() for col 5
  - [ ] Call viewModel.setScale() for cols 7-9 based on column
  - [ ] Call viewModel.setRootNote() for cols 11-22 based on column
  - [ ] Call viewModel.toggleGhostNotes() for col 24
  - [ ] Implement BPM increment/decrement for cols 26-28
  - [ ] Implement pattern length controls for cols 30-32
  - [ ] Call viewModel.clearPattern() for cols 40-43
  - [ ] Add haptic feedback for all control taps
  - [ ] Add VoiceOver announcements for control changes

- [ ] Task 4: Port NOTE_COLORS from prototype
  - [ ] Create Color constants for 12 chromatic notes
  - [ ] Map colors from prototype_sequencer.jsx (lines 17-30)
  - [ ] Use UIColor equivalents in PixelGridUIView
  - [ ] Apply colors to root note selectors (cols 11-22)

- [ ] Task 5: Implement state persistence
  - [ ] Save BPM to UserDefaults on change
  - [ ] Save scale and root note to UserDefaults
  - [ ] Save ghost notes toggle to UserDefaults
  - [ ] Save pattern length to UserDefaults
  - [ ] Load saved state on SequencerViewModel init
  - [ ] Write tests for state persistence

- [ ] Task 6: Create domain models
  - [ ] Create Scale enum (Major, Minor, Pentatonic) in Models folder
  - [ ] Add scale.intervals property for semitone offsets
  - [ ] Create Note enum (C, C#, D, etc.) with 12 chromatic notes
  - [ ] Add note.displayName for VoiceOver labels
  - [ ] Write unit tests for domain models

- [ ] Task 7: Testing and validation
  - [ ] Write unit tests for SequencerViewModel state management
  - [ ] Build project successfully (no compilation errors)
  - [ ] VoiceOver labels implemented on all Row 0 controls
  - [ ] Haptic feedback on all control interactions
  - [ ] State persistence via UserDefaults
  - [ ] Visual validation of Row 0 control rendering
  - [ ] Performance test: 60 FPS maintained with controls
  - [ ] Test on multiple device sizes

---

## Dev Notes

### Architecture Context

**CRITICAL - Pixel-Only Architecture:**
- ❌ NEVER use SwiftUI Text, Button, Picker for controls
- ❌ NEVER create separate View components (PlayStopButtonView, BPMControlView, etc.)
- ✅ ALL controls rendered within PixelGridUIView using CoreGraphics
- ✅ Row 0 (first row) of 44×24 grid dedicated to controls
- ✅ Use 3×5 pixel font for text (BPM values, pattern length)
- ✅ Use pixel art color coding for controls (green=play, red=stop/clear, etc.)

**MVVM Pattern:**
- **Model**: Scale, Note enums (musical domain models)
- **ViewModel**: SequencerViewModel (domain state management, NO SwiftUI dependencies)
- **View**: PixelGridUIView (unified pixel rendering including Row 0 controls)

**Component Hierarchy:**
```
ContentView (SwiftUI wrapper)
└── PixelGridView (UIViewRepresentable)
    └── PixelGridUIView (UIKit + CoreGraphics)
        ├── SequencerViewModel (@ObservedObject) - domain state
        ├── Row 0: Controls (pixel-rendered)
        │   ├── Cols 0-2: Play/Stop
        │   ├── Cols 4-5: Undo/Redo
        │   ├── Cols 7-9: Scale selectors
        │   ├── Cols 11-22: Root note selectors
        │   ├── Col 24: Ghost toggle
        │   ├── Cols 26-28: BPM display
        │   ├── Cols 30-32: Pattern length
        │   └── Cols 40-43: Clear button
        ├── Menu Column (leftmost 1-5 cols): Placeholder from Story 1.2
        └── Rows 1-23: Sequencer grid (future stories)
```

### Technical Requirements

**SequencerViewModel State:**
```swift
import Foundation
import Combine

@MainActor
class SequencerViewModel: ObservableObject {
    // Playback State
    @Published var isPlaying: Bool = false

    // Tempo State
    @Published var bpm: Int = 120 // Range: 40-240

    // Musical Scale State
    @Published var currentScale: Scale = .major
    @Published var rootNote: Note = .C

    // UI State
    @Published var showGhostNotes: Bool = true
    @Published var patternLength: Int = 16 // Range: 8-32

    // Undo/Redo
    private let undoManager = UndoManager()

    func togglePlayback() {
        isPlaying.toggle()
        // TODO: Start/stop audio engine (Story 2.x)
        saveState()
    }

    func setBPM(_ value: Int) {
        guard value >= 40 && value <= 240 else { return }
        registerUndo(oldValue: bpm, keyPath: \.bpm)
        bpm = value
        saveState()
    }

    func setScale(_ scale: Scale) {
        registerUndo(oldValue: currentScale, keyPath: \.currentScale)
        currentScale = scale
        saveState()
    }

    func setRootNote(_ note: Note) {
        registerUndo(oldValue: rootNote, keyPath: \.rootNote)
        rootNote = note
        saveState()
    }

    func toggleGhostNotes() {
        showGhostNotes.toggle()
        saveState()
    }

    func setPatternLength(_ length: Int) {
        guard length >= 8 && length <= 32 else { return }
        registerUndo(oldValue: patternLength, keyPath: \.patternLength)
        patternLength = length
        saveState()
    }

    func clearPattern() {
        // TODO: Clear all notes from grid (Story 1.5+)
    }

    func undo() {
        undoManager.undo()
    }

    func redo() {
        undoManager.redo()
    }

    var canUndo: Bool { undoManager.canUndo }
    var canRedo: Bool { undoManager.canRedo }

    // State Persistence
    init() {
        loadState()
    }

    private func saveState() {
        UserDefaults.standard.set(bpm, forKey: "sequencer.bpm")
        UserDefaults.standard.set(currentScale.rawValue, forKey: "sequencer.scale")
        UserDefaults.standard.set(rootNote.rawValue, forKey: "sequencer.rootNote")
        UserDefaults.standard.set(showGhostNotes, forKey: "sequencer.ghostNotes")
        UserDefaults.standard.set(patternLength, forKey: "sequencer.patternLength")
    }

    private func loadState() {
        bpm = UserDefaults.standard.integer(forKey: "sequencer.bpm")
        if bpm < 40 || bpm > 240 { bpm = 120 }

        if let scaleRaw = UserDefaults.standard.string(forKey: "sequencer.scale"),
           let scale = Scale(rawValue: scaleRaw) {
            currentScale = scale
        }

        let rootNoteRaw = UserDefaults.standard.integer(forKey: "sequencer.rootNote")
        if let note = Note(rawValue: rootNoteRaw) {
            rootNote = note
        }

        showGhostNotes = UserDefaults.standard.bool(forKey: "sequencer.ghostNotes")

        patternLength = UserDefaults.standard.integer(forKey: "sequencer.patternLength")
        if patternLength < 8 || patternLength > 32 { patternLength = 16 }
    }

    private func registerUndo<T>(oldValue: T, keyPath: ReferenceWritableKeyPath<SequencerViewModel, T>) {
        undoManager.registerUndo(withTarget: self) { target in
            let currentValue = target[keyPath: keyPath]
            target[keyPath: keyPath] = oldValue
            target.registerUndo(oldValue: currentValue, keyPath: keyPath)
        }
    }
}
```

### Row 0 Control Layout (from prototype)

**Column Mapping:**
```
Row 0 Control Layout:
├── Cols 0-2:   Play/Stop (3-pixel wide button)
├── Col 3:      Gap
├── Col 4:      Undo button
├── Col 5:      Redo button
├── Col 6:      Gap
├── Col 7:      Major scale selector
├── Col 8:      Minor scale selector
├── Col 9:      Pentatonic scale selector
├── Col 10:     Gap
├── Cols 11-22: Root note selectors (12 chromatic notes, C to B)
├── Col 23:     Gap
├── Col 24:     Ghost notes toggle
├── Col 25:     Gap
├── Cols 26-28: BPM display (3×5 pixel font, e.g., "120")
├── Col 29:     Gap
├── Cols 30-32: Pattern length (3×5 pixel font, e.g., "16")
├── Cols 33-39: Gap
├── Cols 40-43: Clear button (4-pixel wide, red warning)
```

**Color Coding (from prototype):**
```swift
// Note colors (chromatic wheel)
let NOTE_COLORS: [UIColor] = [
    UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0),   // C - Red
    UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0),   // C# - Orange
    UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0),   // D - Yellow
    UIColor(red: 0.5, green: 1.0, blue: 0.0, alpha: 1.0),   // D# - Yellow-Green
    UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0),   // E - Green
    UIColor(red: 0.0, green: 1.0, blue: 0.5, alpha: 1.0),   // F - Cyan-Green
    UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0),   // F# - Cyan
    UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0),   // G - Sky Blue
    UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0),   // G# - Blue
    UIColor(red: 0.5, green: 0.0, blue: 1.0, alpha: 1.0),   // A - Purple
    UIColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0),   // A# - Magenta
    UIColor(red: 1.0, green: 0.0, blue: 0.5, alpha: 1.0)    // B - Pink-Red
]

// Control colors
let COLOR_PLAY = UIColor(red: 0.27, green: 1.0, blue: 0.27, alpha: 1.0)  // #44ff44
let COLOR_STOP = UIColor(red: 1.0, green: 0.27, blue: 0.27, alpha: 1.0)  // #ff4444
let COLOR_SCALE_MAJOR = UIColor(red: 1.0, green: 0.67, blue: 0.0, alpha: 1.0)  // #ffaa00
let COLOR_SCALE_MINOR = UIColor(red: 0.0, green: 0.67, blue: 1.0, alpha: 1.0)  // #00aaff
let COLOR_SCALE_PENTA = UIColor(red: 0.67, green: 0.0, blue: 1.0, alpha: 1.0)  // #aa00ff
let COLOR_ACTIVE = UIColor(red: 0.53, green: 0.53, blue: 0.53, alpha: 1.0)  // #888
let COLOR_INACTIVE = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)  // #333
```

### Pixel Rendering Implementation

**Add to PixelGridUIView:**
```swift
// Add property to hold ViewModel reference
private var sequencerViewModel: SequencerViewModel?

// Modify init to accept ViewModel
func configure(viewModel: SequencerViewModel) {
    self.sequencerViewModel = viewModel
    setNeedsDisplay()
}

// Add Row 0 rendering in draw(_:)
private func drawControlsRow0(context: CGContext) {
    guard let viewModel = sequencerViewModel else { return }

    let row = 0
    let baseY = CGFloat(row) * (pixelSize + GAP_SIZE)

    // Play/Stop button (cols 0-2)
    let playColor = viewModel.isPlaying ? COLOR_STOP : COLOR_PLAY
    for col in 0..<3 {
        let x = menuWidth + dividerWidth + CGFloat(col) * (pixelSize + GAP_SIZE)
        let pixelRect = CGRect(x: x, y: baseY, width: pixelSize, height: pixelSize)
        context.setFillColor(playColor.cgColor)
        context.fill(pixelRect)
    }

    // Undo button (col 4)
    let undoColor = viewModel.canUndo ? COLOR_ACTIVE : COLOR_INACTIVE
    let x4 = menuWidth + dividerWidth + CGFloat(4) * (pixelSize + GAP_SIZE)
    context.setFillColor(undoColor.cgColor)
    context.fill(CGRect(x: x4, y: baseY, width: pixelSize, height: pixelSize))

    // Redo button (col 5)
    let redoColor = viewModel.canRedo ? COLOR_ACTIVE : COLOR_INACTIVE
    let x5 = menuWidth + dividerWidth + CGFloat(5) * (pixelSize + GAP_SIZE)
    context.setFillColor(redoColor.cgColor)
    context.fill(CGRect(x: x5, y: baseY, width: pixelSize, height: pixelSize))

    // Scale selectors (cols 7-9)
    let majorColor = viewModel.currentScale == .major ? COLOR_SCALE_MAJOR : dimColor(COLOR_SCALE_MAJOR)
    let x7 = menuWidth + dividerWidth + CGFloat(7) * (pixelSize + GAP_SIZE)
    context.setFillColor(majorColor.cgColor)
    context.fill(CGRect(x: x7, y: baseY, width: pixelSize, height: pixelSize))

    let minorColor = viewModel.currentScale == .minor ? COLOR_SCALE_MINOR : dimColor(COLOR_SCALE_MINOR)
    let x8 = menuWidth + dividerWidth + CGFloat(8) * (pixelSize + GAP_SIZE)
    context.setFillColor(minorColor.cgColor)
    context.fill(CGRect(x: x8, y: baseY, width: pixelSize, height: pixelSize))

    let pentaColor = viewModel.currentScale == .pentatonic ? COLOR_SCALE_PENTA : dimColor(COLOR_SCALE_PENTA)
    let x9 = menuWidth + dividerWidth + CGFloat(9) * (pixelSize + GAP_SIZE)
    context.setFillColor(pentaColor.cgColor)
    context.fill(CGRect(x: x9, y: baseY, width: pixelSize, height: pixelSize))

    // Root note selectors (cols 11-22)
    for noteIndex in 0..<12 {
        let col = 11 + noteIndex
        let isSelected = noteIndex == viewModel.rootNote.rawValue
        let noteColor = isSelected ? NOTE_COLORS[noteIndex] : dimColor(NOTE_COLORS[noteIndex])
        let x = menuWidth + dividerWidth + CGFloat(col) * (pixelSize + GAP_SIZE)
        context.setFillColor(noteColor.cgColor)
        context.fill(CGRect(x: x, y: baseY, width: pixelSize, height: pixelSize))
    }

    // Ghost toggle (col 24)
    let ghostColor = viewModel.showGhostNotes ? COLOR_ACTIVE : COLOR_INACTIVE
    let x24 = menuWidth + dividerWidth + CGFloat(24) * (pixelSize + GAP_SIZE)
    context.setFillColor(ghostColor.cgColor)
    context.fill(CGRect(x: x24, y: baseY, width: pixelSize, height: pixelSize))

    // BPM display (cols 26-28) - use 3×5 pixel font
    let bpmText = String(viewModel.bpm)
    let x26 = menuWidth + dividerWidth + CGFloat(26) * (pixelSize + GAP_SIZE)
    drawPixelText(context: context, text: bpmText, baseX: x26, baseY: baseY)

    // Pattern length display (cols 30-32)
    let lengthText = String(viewModel.patternLength)
    let x30 = menuWidth + dividerWidth + CGFloat(30) * (pixelSize + GAP_SIZE)
    drawPixelText(context: context, text: lengthText, baseX: x30, baseY: baseY)

    // Clear button (cols 40-43)
    let clearColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0) // Red warning
    for col in 40..<44 {
        let x = menuWidth + dividerWidth + CGFloat(col) * (pixelSize + GAP_SIZE)
        context.setFillColor(clearColor.cgColor)
        context.fill(CGRect(x: x, y: baseY, width: pixelSize, height: pixelSize))
    }
}

private func dimColor(_ color: UIColor) -> UIColor {
    // Reduce alpha or brightness for inactive state
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    color.getRed(&r, green: &g, blue: &b, alpha: &a)
    return UIColor(red: r * 0.3, green: g * 0.3, blue: b * 0.3, alpha: a)
}

// Modify handleTap to include Row 0 controls
@objc private func handleTap(_ gesture: UITapGestureRecognizer) {
    guard let viewModel = sequencerViewModel else { return }

    let location = gesture.location(in: self)

    // Calculate which column was tapped
    let adjustedX = location.x - menuWidth - dividerWidth
    let col = Int(adjustedX / (pixelSize + GAP_SIZE))
    let row = Int(location.y / (pixelSize + GAP_SIZE))

    // Row 0: Controls
    if row == 0 {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()

        switch col {
        case 0...2: // Play/Stop
            viewModel.togglePlayback()
            generator.impactOccurred()
            let announcement = viewModel.isPlaying ? "Pattern playing" : "Pattern stopped"
            UIAccessibility.post(notification: .announcement, argument: announcement)

        case 4: // Undo
            viewModel.undo()
            generator.impactOccurred()
            UIAccessibility.post(notification: .announcement, argument: "Action undone")

        case 5: // Redo
            viewModel.redo()
            generator.impactOccurred()
            UIAccessibility.post(notification: .announcement, argument: "Action redone")

        case 7: // Major scale
            viewModel.setScale(.major)
            generator.impactOccurred()
            UIAccessibility.post(notification: .announcement, argument: "Scale changed to Major")

        case 8: // Minor scale
            viewModel.setScale(.minor)
            generator.impactOccurred()
            UIAccessibility.post(notification: .announcement, argument: "Scale changed to Minor")

        case 9: // Pentatonic scale
            viewModel.setScale(.pentatonic)
            generator.impactOccurred()
            UIAccessibility.post(notification: .announcement, argument: "Scale changed to Pentatonic")

        case 11...22: // Root notes
            let noteIndex = col - 11
            if let note = Note(rawValue: noteIndex) {
                viewModel.setRootNote(note)
                generator.impactOccurred()
                UIAccessibility.post(notification: .announcement, argument: "Root note changed to \(note.displayName)")
            }

        case 24: // Ghost toggle
            viewModel.toggleGhostNotes()
            generator.impactOccurred()
            let ghostAnnouncement = viewModel.showGhostNotes ? "Ghost notes enabled" : "Ghost notes disabled"
            UIAccessibility.post(notification: .announcement, argument: ghostAnnouncement)

        case 26...28: // BPM controls
            // TODO: Implement BPM increment/decrement based on which pixel
            break

        case 30...32: // Pattern length controls
            // TODO: Implement pattern length controls
            break

        case 40...43: // Clear button
            viewModel.clearPattern()
            generator.impactOccurred()
            UIAccessibility.post(notification: .announcement, argument: "Pattern cleared")

        default:
            break
        }

        setNeedsDisplay()
        return
    }

    // ... existing menu column tap handling
}
```

### Musical Domain Models

**Scale Enum:**
```swift
enum Scale: String, CaseIterable, Codable {
    case major = "Major"
    case minor = "Minor"
    case pentatonic = "Pentatonic"

    var displayName: String { rawValue }

    // Semitone intervals from root
    var intervals: [Int] {
        switch self {
        case .major: return [0, 2, 4, 5, 7, 9, 11]
        case .minor: return [0, 2, 3, 5, 7, 8, 10]
        case .pentatonic: return [0, 2, 4, 7, 9]
        }
    }
}
```

**Note Enum:**
```swift
enum Note: Int, CaseIterable, Codable {
    case C = 0, Cs, D, Ds, E, F, Fs, G, Gs, A, As, B

    var displayName: String {
        switch self {
        case .C: return "C"
        case .Cs: return "C♯"
        case .D: return "D"
        case .Ds: return "D♯"
        case .E: return "E"
        case .F: return "F"
        case .Fs: return "F♯"
        case .G: return "G"
        case .Gs: return "G♯"
        case .A: return "A"
        case .As: return "A♯"
        case .B: return "B"
        }
    }
}
```

### Accessibility Requirements

**VoiceOver Labels:**
- Play button (stopped): "Play pattern"
- Stop button (playing): "Stop pattern"
- Undo button: "Undo last action" (disabled: "No actions to undo")
- Redo button: "Redo action" (disabled: "No actions to redo")
- Major scale: "Major scale"
- Minor scale: "Minor scale"
- Pentatonic scale: "Pentatonic scale"
- Root notes: "C", "C♯", "D", etc.
- Ghost toggle: "Ghost notes enabled/disabled"
- BPM: "BPM: 120"
- Pattern length: "Pattern length: 16 steps"
- Clear button: "Clear all pattern data"

**VoiceOver Announcements:**
- On play: "Pattern playing"
- On stop: "Pattern stopped"
- On undo: "Action undone"
- On redo: "Action redone"
- On scale change: "Scale changed to Major"
- On root note change: "Root note changed to C♯"
- On ghost toggle: "Ghost notes enabled/disabled"
- On pattern clear: "Pattern cleared"

### Hardware Controller Compatibility

**Design Constraints (FR107):**
- All Row 0 controls accessible via direct tap on pixel
- No swipe gestures required
- Multi-pixel buttons (Play/Stop, Clear) detect tap on any pixel in range
- Compatible with future hardware grid controllers (Erae Touch 2, Launchpad)

### Performance Requirements

**60 FPS Target:**
- Row 0 control rendering must not drop frames
- Use CoreGraphics hardware-accelerated drawing
- State changes trigger minimal re-renders (only affected pixels)
- Haptic feedback on background thread

**Optimization:**
- Cache color values to avoid repeated calculations
- Minimize setNeedsDisplay() calls (only on actual state changes)
- Use direct pixel filling instead of complex drawing operations

### Testing Strategy

**Unit Tests:**
- SequencerViewModel playback state toggles correctly
- BPM validation (40-240 range)
- Scale and root note state management
- Pattern length validation (8-32 range)
- Undo/Redo stack behavior (64-action history)
- State persistence (save/load UserDefaults)

**Visual Tests:**
- Tap Play → green changes to red, state updates
- Tap Stop → red changes to green, state updates
- Tap Undo → previous state restored, button dims when empty
- Tap Redo → undone action reapplied, button dims when empty
- Tap scale selector → color highlights selected scale
- Tap root note → color highlights selected note
- Tap Ghost → toggles bright/dim state
- BPM display updates with 3×5 pixel font
- Pattern length display updates correctly

**Device Testing:**
- iPhone SE: Verify Row 0 controls clearly visible and tappable
- iPhone 15 Pro Max: Verify pixel sizing scales correctly
- iPad: Verify controls adapt to larger screen

### Known Constraints

**Audio Engine Integration:**
- This story implements UI controls only
- Actual audio playback implemented in Story 2.x (Phase 2)
- Play/Stop button state managed here, audio engine integration later
- BPM and Scale changes stored in ViewModel, applied to audio in Phase 2

**Undo/Redo Scope:**
- This story implements undo/redo infrastructure
- Initially supports BPM, Scale, Root Note, Pattern Length changes
- Pixel editing undo/redo added in Story 1.5+

**Control Refinement:**
- BPM increment/decrement controls need UI design (tap left/right thirds?)
- Pattern length controls need UI design (similar to BPM)
- May add tooltips or visual feedback in future stories

### Integration Points

**Dependencies:**
- Story 1.1 must be complete (44×24 pixel grid renders)
- Story 1.2 must be complete (menu column placeholder exists)

**Blocks:**
- Story 1.5 (Pixel Editing) depends on SequencerViewModel structure
- Story 2.1 (Audio Playback) depends on playback state management
- Story 2.2 (BPM Control) depends on BPM state management
- Story 2.3 (Musical Scale) depends on scale state management

**Menu Column Note:**
- Story 1.2 menu column remains as visual placeholder
- Future stories may add functional controls to menu
- Row 0 controls are primary interface for MVP

---

## Project Context Reference

See `docs/project-context.md` for:
- **UI Rendering Architecture (CRITICAL)**: Pixel-only constraint, NO SwiftUI components
- Complete coding standards and conventions
- Swift concurrency and thread safety rules
- UIKit integration patterns
- Accessibility requirements (WCAG 2.1 AA)
- Testing strategies and best practices

See `docs/prototype_sequencer.jsx` for:
- **Row 0 control layout reference** (lines 676-713)
- 3×5 pixel font definitions (lines 49-101)
- NOTE_COLORS chromatic wheel (lines 17-30)
- Control action handlers (lines 924-968)

---

## Dev Agent Record

### Agent Model Used

_To be filled by dev agent_

### Implementation Notes

_To be filled by dev agent during implementation_

### Completion Checklist

- [ ] All acceptance criteria met
- [ ] Code follows Swift style guidelines
- [ ] Pixel-only architecture maintained (NO SwiftUI components)
- [ ] VoiceOver labels on all controls
- [ ] Haptic feedback on all interactions
- [ ] Performance validated (60 FPS)
- [ ] Tested on multiple device sizes
- [ ] Unit tests passing
- [ ] No warnings or errors in Xcode
- [ ] Ready for code review

### File List

**To be created:**
- `pixelboop/ViewModels/SequencerViewModel.swift`
- `pixelboop/Models/Scale.swift`
- `pixelboop/Models/Note.swift`
- `pixelboopTests/SequencerViewModelTests.swift`
- `pixelboopTests/ScaleTests.swift`
- `pixelboopTests/NoteTests.swift`

**To be modified:**
- `pixelboop/Views/PixelGridUIView.swift` (add Row 0 rendering, tap handling)
- `pixelboop/Views/PixelGridView.swift` (pass SequencerViewModel to UIView)
- `pixelboop/ContentView.swift` (create and pass SequencerViewModel)

### Change Log

- 2026-01-03: Story created as part of Sprint Change Proposal (Adaptive Menu Column System)
- 2026-01-03: Story updated to pixel-only architecture after Story 1.2 re-implementation
  - Removed all SwiftUI component references (PlayStopButtonView, BPMControlView, etc.)
  - Changed from menu column controls to Row 0 pixel-rendered controls
  - Aligned with working prototype in docs/prototype_sequencer.jsx
  - Maintained SequencerViewModel for domain state (NO SwiftUI dependencies)
  - All UI rendering via CoreGraphics in PixelGridUIView
