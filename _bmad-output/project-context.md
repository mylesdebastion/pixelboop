---
project_name: 'pixelboop'
user_name: 'Myles'
date: '2026-01-03'
sections_completed: ['technology_stack', 'language_rules', 'framework_rules', 'ui_rendering_architecture', 'testing_rules', 'code_quality', 'critical_rules']
status: 'complete'
rule_count: 75
optimized_for_llm: true
---

# Project Context for AI Agents

_This file contains critical rules and patterns that AI agents must follow when implementing code in this project. Focus on unobvious details that agents might otherwise miss._

---

## Technology Stack & Versions

- **Swift:** 5.9+ with strict concurrency checking
- **C++:** C++17 for audio engine (AVFoundation callback)
- **iOS:** Deploy 15+, Build with 18+ SDK
- **Xcode:** 16+
- **UI:** SwiftUI + UIKit hybrid (UIViewRepresentable for grid)
- **Audio:** AVFoundation, 256 samples @ 44.1kHz = 5.8ms latency
- **Storage:** FileManager (JSON) + UserDefaults
- **Testing:** XCTest

## Critical Implementation Rules

### Language-Specific Rules (Swift + C++)

**Thread Safety (CRITICAL):**
- ❌ NEVER call Swift runtime from audio thread (C++ callback)
- ❌ NEVER allocate memory on audio thread
- ❌ NEVER use locks on audio thread
- ✅ Use lock-free ring buffer for Main ↔ Audio communication
- ✅ Return to main thread via `DispatchQueue.main.async` for UI updates

**Naming Conventions:**
- Swift Types: `PascalCase` (GridViewModel)
- Swift properties/methods: `camelCase` (activePixels)
- Swift files: Match type name (GridViewModel.swift)
- C++ classes: `PascalCase` (AudioEngine)
- C++ members: `camelCase_` with trailing underscore (writePos_)
- JSON fields: `camelCase` (matches web version)

**State Management:**
- Always use `@Published` for observable state
- ViewModels must be `ObservableObject`
- Never mutate state directly from Views

**Error Handling:**
- Swift: `Result<T, Error>` for recoverable errors
- C++: Return codes (0 = success, -1 = error)
- Audio thread: Fail-safe to silence (no error handling)
- Logging: Use `OSLog` framework

**Data Serialization:**
- Use `Codable` for Pattern/Track/Note
- JSON format must match web version exactly
- Use `JSONEncoder`/`JSONDecoder` with `.prettyPrinted`

**Swift/C++ Bridging:**
- Only pass primitives (Int32, Float, Bool) across boundary
- Use opaque pointers for C++ objects
- Never share memory directly between Swift and C++

### Framework-Specific Rules

**SwiftUI:**
- Use `@StateObject` for ViewModel ownership in parent
- Use `@ObservedObject` for passed-down ViewModels
- Use `#Preview` macro for Xcode previews

**UIKit Integration (Pixel Grid):**
- Wrap with `UIViewRepresentable` + `Coordinator`
- Touch: `touchesBegan`/`Moved`/`Ended` for gesture detection
- Thresholds: <300ms = tap, ≥400ms = hold

**AVFoundation Audio:**
- Initialize `AVAudioSession` before engine (category: `.playback`)
- Use `AVAudioSourceNode` for C++ render callback
- Buffer: 256 samples @ 44.1kHz = 5.8ms latency
- Handle audio session interruptions

**Background Audio:**
- Declare `UIBackgroundModes: audio` in Info.plist
- Suspend engine when backgrounded (if not playing)

**Haptics:**
- `UIImpactFeedbackGenerator` for note placement
- `UISelectionFeedbackGenerator` for navigation
- Call `prepare()` before triggering

### UI Rendering Architecture (CRITICAL - NON-NEGOTIABLE)

**Pixel-Only UI Constraint:**
- ❌ NEVER use SwiftUI Text, Image, Button, or any native UI components for app content
- ❌ NEVER use SF Symbols (`Image(systemName:)`) for icons
- ❌ NEVER overlay SwiftUI views on top of pixel grid
- ❌ NEVER create separate View components for menu/controls (MenuView, ButtonView, etc.)
- ✅ ALL visual elements rendered within unified `PixelGridUIView` using CoreGraphics
- ✅ Icons rendered as pixel art patterns (e.g., play = 3×3 triangle pixels)
- ✅ Text rendered using 3×5 pixel font (NOT native Text views)
- ✅ Menu controls are leftmost columns of same pixel grid (NOT separate views)

**Core Principle:**
> "The grid IS the interface. Every pixel serves musical purpose. Zero chrome."

**Architectural Pattern:**
```
PixelGridUIView (UIKit + CoreGraphics)
├── Menu Columns (leftmost N columns, e.g., 1 col collapsed, 5 cols expanded)
│   ├── Pixel art icons (play = triangle, stop = square, + = plus, - = minus)
│   └── 3×5 pixel font labels (BPM, scale names, settings)
├── 1px black divider (single pixel column separator)
└── Sequencer Grid (44×24 main canvas)
    ├── Note pixels (color-coded by pitch)
    ├── Playhead (brightened vertical pixel column)
    └── Ghost notes (dimmed pixel previews)

SwiftUI Wrapper (UIViewRepresentable)
└── State management ONLY (NO visual rendering)
```

**Rationale:**
PixelBoop uses "100% Custom Pixel-Based Design System with zero UI elements outside the 44×24 pixel grid" (UX Design Specification). This creates:
- Visual-audio equivalence (grid pixels = musical notes, 1:1 mapping)
- Cross-platform consistency (web Canvas API ≡ iOS CoreGraphics)
- Distinctive retro aesthetic (PICO-8 inspiration)
- Pattern compatibility (JSON exports work between platforms)

**Violation Detection - If You See These, It's WRONG:**
- `Text("label")` → Should be 3×5 pixel font in CoreGraphics
- `Image(systemName: "play.fill")` → Should be pixel art pattern
- Separate `MenuColumnView`, `ControlButtonView` → Should be integrated into PixelGridUIView
- `HStack`/`VStack` containing UI elements → Should be pixel columns/rows
- Any UIKit/SwiftUI view overlaying the grid → Should be part of unified grid

**Implementation Requirements:**
- Single `PixelGridUIView.swift` renders ALL visual elements via `draw(_:)`
- Menu width changes by adding/removing pixel columns (e.g., 1→5 columns)
- All pixels use identical size/gaps (seamless integration)
- 3×5 pixel font glyphs for A-Z, 0-9, symbols (♯, ♭, ▶, ■, +, -)
- Pixel art icon patterns: 3×3 or 5×5 grids (play, stop, settings, etc.)

**References:**
- UX Design Specification: Design System Foundation (lines 759-920)
- Architecture Document: Unified Pixel Grid (Story 1-1 implementation notes)
- ADR 001: Pixel-Only UI Design System (docs/architectural-decisions/)

### Testing Rules

**Organization:**
- Unit tests: `PixelBoopTests/` (XCTest)
- UI tests: `PixelBoopUITests/`
- Audio tests: Manual (TestFlight)

**Test Naming:**
- Pattern: `test_[method]_[scenario]_[expectedResult]()`
- Example: `test_interpretGesture_tapOnGrid_createsNote()`

**Unit Test Coverage:**
- ✅ GestureInterpreter (all 11 gesture types)
- ✅ Musical intelligence (scale snapping, chords)
- ✅ Pattern serialization (JSON web compatibility)
- ✅ HistoryManager (undo/redo)
- ❌ Audio synthesis (manual only)
- ❌ Haptics (device only)

**Coverage Targets:**
- Business logic: ≥70%
- Gesture types: 100%
- JSON fields: 100%

**Manual Testing:**
- Audio latency: <10ms
- Performance: 60 FPS on iPhone SE 2nd gen
- Battery: <5% per 30 minutes

### Code Quality & Style Rules

**Project Structure (MVVM):**
- `App/` - @main entry, root navigation
- `Models/` - Data structures (Codable)
- `ViewModels/` - ObservableObject classes
- `Views/` - SwiftUI + UIViewRepresentable
- `Services/` - Swift wrappers
- `Audio/` - Pure C++ only (no Swift)
- `Resources/` - Assets, plist files
- `Supporting/` - Bridging header, constants

**File Placement:**
- Data types → `Models/`
- Observable state → `ViewModels/`
- UI components → `Views/`
- iOS wrappers → `Services/`
- C++ audio → `Audio/` (never Swift)

**Code Organization:**
- One type per file
- File name = type name
- Keep files <300 lines
- Use `// MARK: -` for sections

**Swift Style:**
- Use `guard` for early returns
- Prefer `let` over `var`
- Mark `private` explicitly
- Trailing closure syntax

**C++ Style:**
- Header guards: `#pragma once`
- No namespace (flat audio structure)
- Prefer `const` and `constexpr`

### Critical Don't-Miss Rules

**Audio Thread Anti-Patterns:**
```cpp
// ❌ NEVER on audio thread:
std::string, std::vector      // Memory allocation
mutex.lock()                  // Thread blocking
swiftCallback()               // Swift runtime

// ✅ ALWAYS:
float buffer[256]             // Stack allocation
std::atomic<T>                // Lock-free only
```

**JSON Web Compatibility:**
- Field names MUST be `camelCase`
- `trackType`, `noteVelocity` - NOT `track_type`
- Test web → iOS → web round-trip

**Grid Constants (match web exactly):**
- Columns: 44 (col 0-43 = timeline steps)
- Rows: 24 (row 0-23 = tracks/pitches)

**Orientation-Independent Design (CRITICAL):**
- ❌ NEVER use device-relative directions (up/down/left/right)
- ✅ ALWAYS use grid coordinates (col, row)
- ✅ App works in landscape (primary, like piano) AND portrait
- ✅ Coordinates stay the same regardless of device orientation
- ✅ "Horizontal drag" = movement along COLUMN axis
- ✅ "Vertical drag" = movement along ROW axis

**Gesture Thresholds:**
- Tap: <300ms
- Hold: ≥400ms
- Double-tap: <500ms window
- Scrub: 5+ direction changes

**Privacy Manifest (required):**
- Include `PrivacyInfo.xcprivacy`
- UserDefaults reason: `CA92.1`
- Data collection: None

**App Store Requirements:**
- Rename `pixelboopApp` → `PixelBoopApp`
- Declare `UIBackgroundModes: audio`
- VoiceOver labels on all controls
- Crash-free: >99.5%

---

## Usage Guidelines

**For AI Agents:**
- Read this file before implementing any code
- Follow ALL rules exactly as documented
- When in doubt, prefer the more restrictive option
- Update this file if new patterns emerge

**For Humans:**
- Keep this file lean and focused on agent needs
- Update when technology stack changes
- Review quarterly for outdated rules
- Remove rules that become obvious over time

Last Updated: 2026-01-03 (Added UI Rendering Architecture section after Story 1.2 architectural violation)
