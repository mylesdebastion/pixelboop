# Pixelboop Project Context

> **A 44×24 pixel grid music sequencer for iPhone with gesture-based note entry.**

## Project Overview

Pixelboop is a landscape-oriented iOS music sequencer that uses a pixel grid interface for creating and playing musical patterns across 4 tracks (Melody, Chords, Bass, Rhythm).

### Key Features
- **44×24 pixel grid interface** - Optimized for landscape iPhone display
- **4-track sequencer** - Melody, Chords, Bass, Rhythm with independent controls
- **Gesture-based input** - Tap, drag, hold, and multi-touch gestures for note entry
- **Real-time playback** - Built-in audio synthesis using Web Audio API patterns
- **Visual feedback** - Tooltips, animations, and color-coded tracks

---

## Technology Stack

### Platform
- **iOS 17.0+** (targeting iOS 18.6.2)
- **Swift 5.9+**
- **SwiftUI** for app structure
- **UIKit** for pixel grid rendering

### Architecture
- **MVVM Pattern** - SequencerViewModel manages state, Views handle UI
- **AVFoundation** - Audio synthesis and playback
- **Core Graphics** - Custom pixel grid rendering

---

## Development Workflow

### iPhone Development
**Complete guide**: [iPhone Development Workflow](./iphone-development-workflow.md)

Quick reference for building and deploying to physical iPhone:

```bash
# Build
xcodebuild -project pixelboop.xcodeproj \
  -scheme pixelboop \
  -configuration Debug \
  -destination 'id=00008130-00040D9C1A41001C' \
  -allowProvisioningUpdates \
  build

# Install
xcrun devicectl device install app \
  --device 00008130-00040D9C1A41001C \
  ~/Library/Developer/Xcode/DerivedData/pixelboop-*/Build/Products/Debug-iphoneos/pixelboop.app
```

See [iphone-development-workflow.md](./iphone-development-workflow.md) for:
- One-time setup (Developer Mode, certificates, signing)
- Troubleshooting common issues
- Command reference
- Tips and best practices

---

## Project Structure

```
pixelboop/
├── pixelboop/                    # Main app target
│   ├── pixelboopApp.swift       # App entry point
│   ├── ContentView.swift        # Main container
│   ├── Models/                  # Data models
│   │   ├── Note.swift
│   │   └── Scale.swift
│   ├── ViewModels/              # Business logic
│   │   └── SequencerViewModel.swift
│   ├── Views/                   # UI components
│   │   ├── PixelGridView.swift       # SwiftUI wrapper
│   │   ├── PixelGridUIView.swift     # UIKit rendering
│   │   └── TooltipSystem.swift
│   ├── Audio/                   # Audio synthesis
│   │   └── AudioEngine.swift
│   └── Gestures/                # Gesture interpretation
│       └── GestureInterpreter.swift
├── pixelboopTests/              # Unit tests
├── docs/                        # Documentation
│   ├── project-context.md              # This file
│   ├── iphone-development-workflow.md  # iPhone dev guide
│   └── prototype_sequencer.jsx         # Original web prototype
└── pixelboop.xcodeproj/         # Xcode project
```

---

## Code Architecture

### Core Components

#### SequencerViewModel
**Location**: `pixelboop/ViewModels/SequencerViewModel.swift`

Central state management for the entire sequencer:
- Pattern data (4 tracks × 12 notes × 32 steps)
- Playback state (BPM, current step, play/pause)
- Musical state (scale, root note)
- UI state (tooltips, gesture preview)
- Track mute/solo
- History management (undo/redo)

**Key Responsibilities**:
- Pattern manipulation
- Audio playback coordination
- Gesture interpretation
- State persistence

#### PixelGridUIView
**Location**: `pixelboop/Views/PixelGridUIView.swift`

Custom UIKit view for rendering the 44×24 pixel grid:
- High-performance Core Graphics rendering
- Touch gesture handling
- Visual effects (glow, tooltips)
- Grid cell color calculations

**Rendering Strategy**:
- Grid stored as `UIColor?[44][24]`
- Draws only visible cells
- Updates on state changes via `setNeedsDisplay()`

#### AudioEngine
**Location**: `pixelboop/Audio/AudioEngine.swift`

Synthesizes audio for all tracks:
- Melodic tracks: Oscillator-based synthesis
- Rhythm track: Percussion synthesis
- ADSR envelopes for sustain
- Real-time note triggering

#### GestureInterpreter
**Location**: `pixelboop/Gestures/GestureInterpreter.swift`

Converts touch gestures to musical notes:
- Single tap → Note or chord
- Horizontal drag → Arpeggio or roll
- Vertical drag → Chord stack
- Hold + drag → Sustained notes
- Track-specific behaviors (drums vs. melody)

---

## Musical Features

### Track Types

#### 1. Melody (Rows 2-7)
- **Range**: 6 visible rows (12 chromatic notes total)
- **Behavior**: Single notes, scale-snapped
- **Gestures**: Tap, run, phrase

#### 2. Chords (Rows 8-13)
- **Range**: 6 visible rows
- **Behavior**: Automatic chord generation (major/minor/maj7)
- **Gestures**: Tap, arpeggio, stack

#### 3. Bass (Rows 14-17)
- **Range**: 4 visible rows
- **Behavior**: Root + 5th interval, walking bass
- **Gestures**: Tap, fifth, walking

#### 4. Rhythm (Rows 18-21)
- **Range**: 4 visible rows (12 drum sounds)
- **Behavior**: Percussion synthesis
- **Drum Kit**: Kick, snare, hats, crash, ride, cowbell, etc.
- **Gestures**: Tap, roll, fill

### Gesture Reference

| Gesture | Behavior | Result |
|---------|----------|--------|
| **Tap** | Single touch down/up | Single note or chord |
| **Hold** | Touch held >400ms | Accent (velocity 2) |
| **Horizontal Drag** | Swipe left/right | Arpeggio, run, or roll |
| **Vertical Drag** | Swipe up/down | Chord stack or multi-hit |
| **Hold + Drag** | Hold then drag | Sustained notes |
| **Double Tap** | Two taps quickly | Erase step |
| **Shake** | Rapid back/forth | Clear all notes |
| **Double Swipe Left** | Two left swipes | Undo |
| **Double Swipe Right** | Two right swipes | Redo |

---

## Development Guidelines

### Code Style
- **Swift naming**: camelCase for variables, PascalCase for types
- **Comments**: Document "why" not "what"
- **Functions**: Single responsibility, max ~50 lines
- **State changes**: Always trigger view updates via `@Published` or `objectWillChange.send()`

### Critical Rules

#### State Updates
When modifying nested properties in `@Published` structs, **reassign the entire struct**:

```swift
// ❌ Wrong - SwiftUI won't detect change
muteState.muted[track]?.toggle()

// ✅ Correct - Triggers view update
var newState = muteState
newState.muted[track]?.toggle()
muteState = newState
```

#### Touch Handling
Touch events must be intercepted before gesture tracking:

```swift
// Check controls first (row 0)
if row == 0 { handleControlTap(col: col); return }

// Check mute/solo (cols 0-1)
if col == 0 || col == 1 { handleMuteSolo(row: row, col: col); return }

// Then start gesture tracking
startGesture(row: row, col: col)
```

#### Gesture Preview
Always create initial preview in `startGesture()` to support single taps:

```swift
func startGesture(row: Int, col: Int) {
    // Create initial preview for tap
    let (notes, gestureType) = GestureInterpreter.interpret(...)
    gesturePreview = notes
    lastGestureType = gestureType
}
```

---

## Testing

### Test Structure
- **Unit Tests**: `pixelboopTests/`
- **Focus**: ViewModel logic, gesture interpretation, pattern manipulation
- **Coverage**: Core business logic

### Running Tests
```bash
# Run all tests
xcodebuild test -project pixelboop.xcodeproj -scheme pixelboop -destination 'platform=iOS Simulator,name=iPhone 15'

# Run specific test
xcodebuild test -project pixelboop.xcodeproj -scheme pixelboop -only-testing:pixelboopTests/SequencerViewModelTests
```

---

## Known Issues & Future Work

### Current Issues
- ✅ Mute/solo now working (fixed 2026-01-03)
- ✅ Tap-to-add notes now reliable (fixed 2026-01-03)

### Future Enhancements
- [ ] Pattern save/load
- [ ] Multiple pattern banks
- [ ] MIDI export
- [ ] Additional drum kits
- [ ] More gesture types
- [ ] Visual waveform display
- [ ] Tempo tap input

---

## References

### Documentation
- [iPhone Development Workflow](./iphone-development-workflow.md) - Complete setup and deployment guide
- [Original Prototype](./prototype_sequencer.jsx) - React web version (reference implementation)
- [Architectural Decisions](./architectural-decisions/) - Key design choices

### External Resources
- [Swift Documentation](https://docs.swift.org/swift-book/)
- [Apple Developer](https://developer.apple.com/documentation/)
- [AVFoundation Guide](https://developer.apple.com/av-foundation/)

---

## Project History

### Implementation Timeline
- **2026-01-02**: Initial one-shot implementation from web prototype
- **2026-01-03**: Bug fixes (mute/solo, tap gestures), iPhone deployment setup

### Key Decisions
- **SwiftUI + UIKit hybrid**: SwiftUI for structure, UIKit for pixel grid performance
- **Direct synthesis**: Built-in audio engine vs. external libraries
- **Gesture-first**: Touch gestures as primary input method

---

**Last Updated**: 2026-01-03
**Project Status**: Active Development
**Current Branch**: `feature/one-shot-implementation`
