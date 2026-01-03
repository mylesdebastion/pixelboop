# Story 1.3: Migrate Controls to Menu System

Status: ready-for-dev

---

## Story

As a **user**,
I want **to access playback, tempo, and editing controls through the menu column interface**,
So that **I can control my musical creation without controls occupying valuable grid space**.

---

## Acceptance Criteria

**Given** the collapsible menu column UI is implemented (Story 1.2)
**When** I interact with the menu controls
**Then** the Play/Stop button toggles playback state (FR12, FR13)
**And** the BPM control allows tempo adjustment from 40-240 BPM (FR26)
**And** the Scale selector allows changing musical scale (FR28, FR29)
**And** Undo/Redo buttons reverse/restore recent actions (FR78, FR79)
**And** all controls display correctly in both collapsed (icon-only) and expanded (labeled) menu states (FR105, FR106)
**And** controls provide haptic feedback on interaction (FR59)
**And** controls have VoiceOver accessibility labels (NFR49)
**And** controls work identically on hardware controllers (FR107)

---

## Requirements References

**Functional Requirements:**
- FR12: Users can start pattern playback at current BPM
- FR13: Users can stop pattern playback
- FR26: Users can set global BPM (40-240 range, 1 BPM increments)
- FR28: Users can select musical scale from presets
- FR29: System provides 8+ common scales (Major, Minor, Dorian, etc.)
- FR78: Users can undo last action (64-action history)
- FR79: Users can redo previously undone action
- FR105: Menu column displays icon-only controls in collapsed state
- FR106: Menu column displays full labeled controls in expanded state
- FR107: Menu system works identically on hardware controllers

**Non-Functional Requirements:**
- NFR1: Visual rendering at 60 FPS on target devices
- NFR49: All interactive UI elements must have VoiceOver accessibility labels
- NFR59: Haptic feedback on user interactions

---

## Tasks / Subtasks

- [ ] Task 1: Implement Play/Stop button functionality
  - [ ] Create PlayStopButtonView component
  - [ ] Add playback state to SequencerViewModel (@Published isPlaying: Bool)
  - [ ] Implement togglePlayback() method
  - [ ] Wire Play/Stop button to viewModel.togglePlayback()
  - [ ] Add icon switching (play.fill ↔ stop.fill)
  - [ ] Add VoiceOver labels ("Play pattern", "Stop pattern")
  - [ ] Add haptic feedback (UIImpactFeedbackGenerator.medium)
  - [ ] Write unit tests for playback state management

- [ ] Task 2: Implement BPM control
  - [ ] Create BPMControlView component
  - [ ] Add BPM state to SequencerViewModel (@Published bpm: Int = 120)
  - [ ] Implement setBPM(_ value: Int) method with validation (40-240 range)
  - [ ] Add collapsed state display (numeric value only)
  - [ ] Add expanded state controls (value + increment/decrement buttons)
  - [ ] Add VoiceOver labels ("BPM: 120", "Increase BPM", "Decrease BPM")
  - [ ] Add haptic feedback on BPM change
  - [ ] Write unit tests for BPM state management

- [ ] Task 3: Implement Scale selector
  - [ ] Create ScaleSelectorView component
  - [ ] Define Scale enum (Major, NaturalMinor, HarmonicMinor, Dorian, Phrygian, Lydian, Mixolydian, Locrian)
  - [ ] Add scale state to SequencerViewModel (@Published currentScale: Scale = .major)
  - [ ] Add root note state (@Published rootNote: Note = .C)
  - [ ] Implement setScale(_ scale: Scale) method
  - [ ] Add collapsed state display (root note + scale abbreviation, e.g., "C♯ Maj")
  - [ ] Add expanded state controls (root picker + scale dropdown)
  - [ ] Add VoiceOver labels ("Scale: C♯ Major", "Select root note", "Select scale type")
  - [ ] Add haptic feedback on scale change
  - [ ] Write unit tests for scale state management

- [ ] Task 4: Implement Undo/Redo buttons
  - [ ] Create UndoRedoButtonsView component
  - [ ] Add UndoManager integration to SequencerViewModel
  - [ ] Implement undo() and redo() methods
  - [ ] Add visual state (disabled when no actions available)
  - [ ] Add VoiceOver labels ("Undo last action", "Redo action")
  - [ ] Add haptic feedback (UINotificationFeedbackGenerator.success)
  - [ ] Write unit tests for undo/redo stack management

- [ ] Task 5: Integrate controls into MenuColumnView
  - [ ] Update MenuColumnView to include PlayStopButtonView
  - [ ] Add BPMControlView to menu layout
  - [ ] Add ScaleSelectorView to menu layout
  - [ ] Add UndoRedoButtonsView to menu layout
  - [ ] Ensure proper spacing and visual hierarchy
  - [ ] Verify controls adapt to collapsed/expanded states
  - [ ] Test layout on iPhone SE, iPhone 15 Pro Max

- [ ] Task 6: State persistence
  - [ ] Persist BPM to UserDefaults
  - [ ] Persist scale and root note to UserDefaults
  - [ ] Load saved state on app launch
  - [ ] Write tests for state persistence

- [ ] Task 7: Testing and validation
  - [ ] Write unit tests for all control ViewModels
  - [ ] Write UI tests for control interactions
  - [ ] Verify VoiceOver announces control states correctly
  - [ ] Test haptic feedback on physical device
  - [ ] Verify controls work in both menu states (collapsed/expanded)
  - [ ] Verify 60 FPS performance maintained
  - [ ] Test on multiple device sizes

---

## Dev Notes

### Architecture Context

**MVVM Pattern:**
- **Model**: Scale, Note enums (musical domain models)
- **ViewModel**: SequencerViewModel (centralized state: playback, BPM, scale, undo/redo)
- **View**: PlayStopButtonView, BPMControlView, ScaleSelectorView, UndoRedoButtonsView

**State Management Strategy:**
```swift
class SequencerViewModel: ObservableObject {
    // Playback State
    @Published var isPlaying: Bool = false

    // Tempo State
    @Published var bpm: Int = 120

    // Musical Scale State
    @Published var currentScale: Scale = .major
    @Published var rootNote: Note = .C

    // Undo/Redo
    private let undoManager = UndoManager()

    func togglePlayback() {
        isPlaying.toggle()
        // TODO: Start/stop audio engine (Story 2.x)
    }

    func setBPM(_ value: Int) {
        guard value >= 40 && value <= 240 else { return }
        registerUndo(oldValue: bpm, newValue: value, keyPath: \.bpm)
        bpm = value
        // TODO: Update audio engine tempo (Story 2.x)
    }

    func setScale(_ scale: Scale, rootNote: Note) {
        registerUndo(oldValue: (currentScale, self.rootNote),
                     newValue: (scale, rootNote))
        currentScale = scale
        self.rootNote = rootNote
        // TODO: Update note mappings (Story 2.x)
    }

    func undo() {
        undoManager.undo()
    }

    func redo() {
        undoManager.redo()
    }
}
```

### Component Specifications

#### PlayStopButtonView
```swift
struct PlayStopButtonView: View {
    @ObservedObject var viewModel: SequencerViewModel
    let isExpanded: Bool

    var body: some View {
        ControlButtonView(
            icon: viewModel.isPlaying ? "stop.fill" : "play.fill",
            label: viewModel.isPlaying ? "Stop" : "Play",
            isExpanded: isExpanded,
            action: {
                HapticFeedback.impact(.medium)
                viewModel.togglePlayback()
            }
        )
        .accessibilityLabel(viewModel.isPlaying ? "Stop pattern" : "Play pattern")
    }
}
```

#### BPMControlView
```swift
struct BPMControlView: View {
    @ObservedObject var viewModel: SequencerViewModel
    let isExpanded: Bool

    var body: some View {
        if isExpanded {
            HStack {
                Text("BPM:")
                Text("\(viewModel.bpm)")
                    .font(.system(.body, design: .monospaced))

                Button("-") { viewModel.setBPM(viewModel.bpm - 1) }
                    .accessibilityLabel("Decrease BPM")

                Button("+") { viewModel.setBPM(viewModel.bpm + 1) }
                    .accessibilityLabel("Increase BPM")
            }
        } else {
            Text("\(viewModel.bpm)")
                .font(.system(.caption, design: .monospaced))
                .accessibilityLabel("BPM: \(viewModel.bpm)")
        }
    }
}
```

#### ScaleSelectorView
```swift
struct ScaleSelectorView: View {
    @ObservedObject var viewModel: SequencerViewModel
    let isExpanded: Bool

    var body: some View {
        if isExpanded {
            VStack(alignment: .leading) {
                HStack {
                    Text("Root:")
                    Picker("", selection: $viewModel.rootNote) {
                        ForEach(Note.allCases) { note in
                            Text(note.displayName).tag(note)
                        }
                    }
                }

                HStack {
                    Text("Scale:")
                    Picker("", selection: $viewModel.currentScale) {
                        ForEach(Scale.allCases) { scale in
                            Text(scale.displayName).tag(scale)
                        }
                    }
                }
            }
        } else {
            Text("\(viewModel.rootNote.displayName) \(viewModel.currentScale.abbreviation)")
                .font(.system(.caption, design: .monospaced))
                .accessibilityLabel("Scale: \(viewModel.rootNote.displayName) \(viewModel.currentScale.displayName)")
        }
    }
}
```

### Musical Domain Models

#### Scale Enum
```swift
enum Scale: String, CaseIterable, Identifiable {
    case major = "Major"
    case naturalMinor = "Natural Minor"
    case harmonicMinor = "Harmonic Minor"
    case dorian = "Dorian"
    case phrygian = "Phrygian"
    case lydian = "Lydian"
    case mixolydian = "Mixolydian"
    case locrian = "Locrian"

    var id: String { rawValue }

    var displayName: String { rawValue }

    var abbreviation: String {
        switch self {
        case .major: return "Maj"
        case .naturalMinor: return "Min"
        case .harmonicMinor: return "HMin"
        case .dorian: return "Dor"
        case .phrygian: return "Phr"
        case .lydian: return "Lyd"
        case .mixolydian: return "Mix"
        case .locrian: return "Loc"
        }
    }

    // Semitone intervals from root
    var intervals: [Int] {
        switch self {
        case .major: return [0, 2, 4, 5, 7, 9, 11]
        case .naturalMinor: return [0, 2, 3, 5, 7, 8, 10]
        case .harmonicMinor: return [0, 2, 3, 5, 7, 8, 11]
        case .dorian: return [0, 2, 3, 5, 7, 9, 10]
        case .phrygian: return [0, 1, 3, 5, 7, 8, 10]
        case .lydian: return [0, 2, 4, 6, 7, 9, 11]
        case .mixolydian: return [0, 2, 4, 5, 7, 9, 10]
        case .locrian: return [0, 1, 3, 5, 6, 8, 10]
        }
    }
}
```

#### Note Enum
```swift
enum Note: Int, CaseIterable, Identifiable {
    case C = 0, Cs, D, Ds, E, F, Fs, G, Gs, A, As, B

    var id: Int { rawValue }

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

### Haptic Feedback Integration

```swift
class HapticFeedback {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}
```

### State Persistence Strategy

```swift
extension SequencerViewModel {
    func saveState() {
        UserDefaults.standard.set(bpm, forKey: "sequencer.bpm")
        UserDefaults.standard.set(currentScale.rawValue, forKey: "sequencer.scale")
        UserDefaults.standard.set(rootNote.rawValue, forKey: "sequencer.rootNote")
    }

    func loadState() {
        bpm = UserDefaults.standard.integer(forKey: "sequencer.bpm")
        if bpm < 40 || bpm > 240 { bpm = 120 } // Default fallback

        if let scaleRaw = UserDefaults.standard.string(forKey: "sequencer.scale"),
           let scale = Scale(rawValue: scaleRaw) {
            currentScale = scale
        }

        let rootNoteRaw = UserDefaults.standard.integer(forKey: "sequencer.rootNote")
        if let note = Note(rawValue: rootNoteRaw) {
            rootNote = note
        }
    }
}
```

### Undo/Redo Implementation

```swift
extension SequencerViewModel {
    private func registerUndo<T>(oldValue: T, newValue: T, keyPath: ReferenceWritableKeyPath<SequencerViewModel, T>) {
        undoManager.registerUndo(withTarget: self) { target in
            target[keyPath: keyPath] = oldValue
            target.registerUndo(oldValue: newValue, newValue: oldValue, keyPath: keyPath)
        }
    }

    var canUndo: Bool {
        undoManager.canUndo
    }

    var canRedo: Bool {
        undoManager.canRedo
    }
}
```

### Accessibility Requirements

**VoiceOver Labels:**
- Play button (stopped): "Play pattern"
- Stop button (playing): "Stop pattern"
- BPM control (collapsed): "BPM: 120"
- BPM increment: "Increase BPM"
- BPM decrement: "Decrease BPM"
- Scale display (collapsed): "Scale: C♯ Major"
- Root note picker: "Select root note, C♯"
- Scale type picker: "Select scale type, Major"
- Undo button: "Undo last action" (disabled state: "No actions to undo")
- Redo button: "Redo action" (disabled state: "No actions to redo")

**VoiceOver Announcements:**
- On play: Announce "Pattern playing"
- On stop: Announce "Pattern stopped"
- On BPM change: Announce "BPM changed to 125"
- On scale change: Announce "Scale changed to D Major"
- On undo: Announce "Action undone"
- On redo: Announce "Action redone"

### Hardware Controller Compatibility

**Design Constraints (FR107):**
- All controls must be accessible via direct tap (no edge-swipe gestures)
- Menu toggle works with single tap on menu area
- BPM increment/decrement buttons clearly tappable
- Scale selectors use pickers (not swipe gestures)
- Compatible with future hardware grid controllers (Erae Touch 2, Launchpad)

### Performance Requirements

**60 FPS Target:**
- Control interactions must not drop frames
- State updates trigger minimal re-renders
- Use SwiftUI's `.animation()` modifier for smooth transitions
- Haptic feedback should not block UI thread

**Optimization:**
- ViewModels use `@Published` only for UI-impacting state
- Control components rendered once per state change
- Avoid complex view hierarchies in control components

### Testing Strategy

**Unit Tests:**
- SequencerViewModel playback state toggles correctly
- BPM validation (40-240 range)
- Scale and root note state management
- Undo/Redo stack behavior (64-action history)
- State persistence (save/load UserDefaults)

**UI Tests:**
- Tap Play → state changes to playing
- Tap Stop → state changes to stopped
- Increment BPM → value increases by 1
- Decrement BPM → value decreases by 1
- Change scale → UI updates correctly
- Tap Undo → previous state restored
- Tap Redo → undone action reapplied
- Controls display correctly in collapsed state
- Controls display correctly in expanded state
- VoiceOver announces control states

**Device Testing:**
- iPhone SE: Verify controls readable in collapsed menu
- iPhone 15 Pro Max: Verify expanded menu controls well-spaced
- iPad: Verify menu adapts appropriately

### Known Constraints

**Audio Engine Integration:**
- This story implements UI controls only
- Actual audio playback functionality implemented in Story 2.x (Phase 2)
- Play/Stop button state managed here, audio engine integration later
- BPM and Scale changes stored in ViewModel, applied to audio in Phase 2

**Undo/Redo Scope:**
- This story implements undo/redo infrastructure
- Initially supports BPM and Scale changes only
- Pixel editing undo/redo added in later stories (Story 1.5+)

**Control Placement:**
- This story migrates controls from original Row 0 concept to menu column
- Row 0 of grid becomes available for pattern data (Step markers, etc.)
- Control layout in menu follows UX spec vertical ordering

### Integration Points

**Dependencies:**
- Story 1.2 must be complete (MenuColumnView and ControlButtonView exist)
- MenuViewModel must be accessible to pass expanded state

**Blocks:**
- Story 1.5 (Pixel Editing) depends on SequencerViewModel structure
- Story 2.1 (Audio Playback) depends on playback state management
- Story 2.2 (BPM Control) depends on BPM state management
- Story 2.3 (Musical Scale) depends on scale state management

---

## Project Context Reference

See `docs/project-context.md` for:
- Complete coding standards and conventions
- SwiftUI and UIKit integration patterns
- Accessibility requirements (WCAG 2.1 AA)
- Testing strategies and best practices
- iOS-specific compliance requirements

---

## Dev Agent Record

### Agent Model Used

_To be filled by dev agent_

### Implementation Notes

_To be filled by dev agent during implementation_

### Completion Checklist

- [ ] All acceptance criteria met
- [ ] Code follows Swift style guidelines
- [ ] VoiceOver labels on all controls
- [ ] Haptic feedback on all interactions
- [ ] Performance validated (60 FPS)
- [ ] Tested on multiple device sizes
- [ ] Unit tests passing
- [ ] UI tests passing
- [ ] No warnings or errors in Xcode
- [ ] Ready for code review

### File List

**To be created:**
- `pixelboop/ViewModels/SequencerViewModel.swift`
- `pixelboop/Views/Controls/PlayStopButtonView.swift`
- `pixelboop/Views/Controls/BPMControlView.swift`
- `pixelboop/Views/Controls/ScaleSelectorView.swift`
- `pixelboop/Views/Controls/UndoRedoButtonsView.swift`
- `pixelboop/Models/Scale.swift`
- `pixelboop/Models/Note.swift`
- `pixelboop/Services/HapticFeedback.swift`
- `pixelboopTests/SequencerViewModelTests.swift`
- `pixelboopUITests/ControlInteractionTests.swift`

**To be modified:**
- `pixelboop/Views/MenuColumnView.swift` (integrate control views)
- `pixelboop/Views/SequencerView.swift` (pass SequencerViewModel to components)

### Change Log

- 2026-01-03: Story created as part of Sprint Change Proposal (Adaptive Menu Column System)
