---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8]
inputDocuments:
  - _bmad-output/prd.md
  - docs/prototype_sequencer.jsx
workflowType: 'architecture'
project_name: 'pixelboop'
user_name: 'Myles'
date: '2026-01-02'
lastStep: 8
status: 'complete'
completedAt: '2026-01-02'
---

# Architecture Decision Document

_This document builds collaboratively through step-by-step discovery. Sections are appended as we work through each architectural decision together._

## Project Context Analysis

### Requirements Overview

**Functional Requirements (66 Total):**

PixelBoop iOS requires implementation of a complete gesture-based music sequencer with:

- **Pattern Creation & Editing (FR1-FR11):** 11 gesture types including tap, hold-accent, horizontal drag (arpeggios), vertical drag (chords), diagonal drag (phrases), hold+drag (sustained notes with ADSR), double-tap erase, and scrub-to-clear
- **Audio Synthesis & Playback (FR12-FR19):** Real-time synthesis with track-specific timbres (sine, triangle, sawtooth), 12 synthesized drum sounds, 3-level velocity system (normal/accent/sustain), ADSR envelope rendering, background audio continuation
- **Musical Intelligence (FR20-FR24):** Scale snapping (major/minor/pentatonic), 12 chromatic root notes, automatic chord voicing, bass fifth/root patterns, musical correctness guarantees
- **Pattern Management (FR25-FR32):** Local save/load, pattern library browsing, auto-save, JSON export to iOS Files app, cross-platform import from web version, metadata preservation
- **History & Reversibility (FR33-FR36):** 50-level undo/redo with double-swipe gestures
- **Visual Feedback (FR37-FR45):** 44×24 pixel grid rendering at 60 FPS, color-coded chromatic notes, pixel-font tooltips, playhead animations, ghost notes, step markers
- **Control & Configuration (FR46-FR53):** 60-200 BPM tempo, scale/root selection, 8-32 step patterns, track mute/solo, keyboard shortcuts
- **Track Management (FR54-FR59):** 4 independent tracks (melody, chords, bass, rhythm/drums) with distinct sonic identities
- **Offline & Storage (FR60-FR63):** 100% offline functionality, local device storage, preference persistence
- **Haptic Feedback (FR64-FR66):** Tactile feedback on note placement, gesture-specific haptic responses, beat-synchronized pulses

**Non-Functional Requirements (41+ iOS-Specific):**

**Performance Targets:**
- Audio Latency: <10ms tap-to-sound (professional audio standard) - requires C/C++ audio thread with AVFoundation
- Visual Rendering: 60 FPS sustained on iPhone 12+, functional on iPhone SE 2nd gen
- Battery Consumption: <5% drain per 30 minutes active use
- App Size: <50MB download
- Crash-Free Rate: >99.5% sessions (monitored via Xcode Organizer, MetricKit)

**iOS App Store Compliance (Mandatory 2024+):**
- **Privacy Manifest (NFR45-48):** `PrivacyInfo.xcprivacy` file declaring zero data collection, UserDefaults API usage with approved reason CA92.1
- **Accessibility (NFR49-56):** VoiceOver labels on all controls, Dynamic Type support in settings, WCAG 2.1 AA color contrast (4.5:1 normal, 3:1 large text), disclosure of limited motor accessibility due to gesture-based nature
- **SDK Requirements (NFR57-60):** Xcode 16+, iOS 18+ SDK, deployment target iOS 15+, Swift 5.9+
- **Technical Compliance (NFR61-67):** Background audio mode declared, IPv6 compatibility (automatic - no network calls), crash-free rate >99.5%
- **Submission Assets (NFR68-76):** App icons (all sizes), launch screen, screenshots (6.7", 6.5", 5.5" iPhones), 30-second App Preview video, privacy policy URL
- **TestFlight Beta (NFR77-80):** Internal beta (1-2 weeks, 5-10 testers), external beta (4-8 weeks, 20-50 musicians), zero critical bugs in final 2 weeks

**Cross-Platform Compatibility:**
- Pattern data format must match web version (JSON structure compatibility)
- Gesture interpretation must produce identical musical output (behavioral parity)
- Export from web → import to iOS must work seamlessly
- Shared musical intelligence algorithms (scale snapping, chord voicing logic)

**Security & Privacy:**
- Local-only storage (no cloud sync in MVP)
- Zero data collection (no analytics, no tracking)
- Privacy Nutrition Label: "Data Not Collected"
- COPPA compliant (safe for children under 13)

### Scale & Complexity

**Project Complexity: Medium-High**

Complexity drivers:
- **High:** Real-time audio synthesis with <10ms latency requirement (requires C/C++ audio callback optimization)
- **Medium-High:** Gesture recognition system with 11+ gesture types requiring 95%+ accuracy
- **Medium-High:** Cross-platform behavioral consistency (pattern compatibility with web version)
- **Medium:** 60 FPS pixel grid rendering with simultaneous audio playback
- **Medium:** iOS App Store compliance requirements (Privacy Manifest, Accessibility, TestFlight beta process)

**Primary Domain: iOS Native Creative Tool**
- Audio Engineering: Professional-grade low-latency synthesis
- UI/UX: Custom gesture-based interface with haptic feedback
- Data Management: Local pattern library with export capability
- Cross-Platform: Shared algorithm specification with web implementation

**Estimated Architectural Components:**
- Audio Engine Module (AVFoundation + C/C++ synthesis)
- Gesture Recognition System (touch handling + interpretation algorithms)
- Musical Intelligence Layer (scale snapping, chord voicing, pattern generation)
- Pattern Data Model & Storage (CoreData or File System with JSON serialization)
- Grid Rendering Engine (SwiftUI/UIKit/CoreGraphics for 60 FPS)
- Haptic Feedback Controller (UIFeedbackGenerator integration)
- App Store Compliance Layer (Privacy Manifest, Accessibility, background audio)

### Technical Constraints & Dependencies

**Platform Constraints:**
- iOS 15+ deployment target (supports iPhone SE 2nd gen and newer)
- Built with iOS 18+ SDK, Xcode 16+ (App Store requirement)
- Swift 5.9+ language version
- AVFoundation framework for audio (no third-party audio libraries in MVP)

**Performance Constraints:**
- <10ms audio latency requires C/C++ audio thread (Swift audio processing too slow)
- 60 FPS rendering requires optimized CoreGraphics or Metal (SwiftUI Canvas may need profiling)
- <5% battery drain requires audio engine suspension when stopped, rendering optimization during idle

**Cross-Platform Compatibility Constraints:**
- Pattern JSON format must exactly match web version structure
- Gesture interpretation logic must produce bit-identical musical output (same gesture → same notes)
- Musical intelligence algorithms (scale snapping, chord intervals) must be deterministic and platform-agnostic

**App Store Compliance Constraints:**
- Privacy Manifest mandatory (rejection without it)
- VoiceOver support required for basic app navigation
- TestFlight beta testing required before public launch (4-8 weeks minimum)
- $0.99 price point uses App Store transaction system (no custom payment handling)

**Storage Constraints:**
- 100% offline functionality (no network dependency after download)
- Local-only storage (IndexedDB not available on iOS - must use UserDefaults/CoreData/FileSystem)
- No cloud sync in MVP (iCloud integration deferred to Phase 3)

**Audio Constraints:**
- Background audio playback requires `UIBackgroundModes` declaration
- Audio session interruption handling (calls, notifications, other apps)
- No licensed samples (all sounds synthesized to avoid copyright concerns)

### Cross-Cutting Concerns Identified

**1. Audio Latency Management**
- C/C++ audio callback required for <10ms target
- Real-time thread priority configuration
- Buffer size optimization vs battery consumption
- Glitch-free playback during UI interactions (separate audio thread from main thread)

**2. Pattern Data Compatibility**
- JSON schema design shared with web version
- Serialization/deserialization correctness
- Version compatibility strategy for future format changes
- Export to iOS Files app integration (UIDocumentPickerViewController)

**3. Gesture Recognition Accuracy**
- Touch state machine (touchesBegan → touchesMoved → touchesEnded)
- Timing threshold tuning (<300ms tap, ≥400ms hold)
- Direction vector calculation for drag gestures
- False positive prevention (scrub vs intentional drag, double-tap vs two separate taps)
- Multi-touch handling for simultaneous track editing

**4. Performance Optimization**
- Audio thread must never block or glitch (highest priority)
- 60 FPS rendering target (dirty rectangle updates, offscreen buffering)
- Battery optimization (suspend audio engine when stopped, reduce rendering during idle)
- Memory management (pattern undo history size limits, efficient data structures)

**5. iOS App Store Compliance**
- Privacy Manifest file creation and API usage declaration
- Accessibility implementation (VoiceOver labels, Dynamic Type, contrast validation)
- TestFlight beta coordination (musician testers, feedback collection)
- App Review Guidelines compliance (4.2.1 uniqueness, no placeholder features)

**6. Cross-Platform Behavioral Consistency**
- Gesture interpretation algorithm specification (shared between web and iOS)
- Musical intelligence determinism (same input → same output across platforms)
- Pattern playback equivalence (same pattern sounds identical on web vs iOS)
- Visual consistency (same colors, animations, timing across platforms)

**7. Testing Strategy**
- Audio latency measurement and validation (<10ms requirement)
- Gesture accuracy testing (95%+ correct interpretation)
- Cross-device compatibility (iPhone SE 2nd gen through iPhone 15 Pro Max)
- Pattern import/export validation (web → iOS → web round-trip)
- Battery drain measurement (target: <5% per 30 minutes)

### Existing Implementation Reference

**Web Version (audiolux jam repo):**
- Functional React prototype (`prototype_sequencer.jsx`, 1,611 lines) demonstrates:
  - ✅ Gesture recognition algorithms proven functional
  - ✅ Web Audio API synthesis performs adequately
  - ✅ 44×24 pixel grid rendering works
  - ✅ Pattern state management with 50-level undo/redo
  - ✅ Musical intelligence (scale snapping, chord voicing) implemented
  - ✅ Core gesture vocabulary validated by users

**iOS Implementation Focus:**
- Port gesture interpretation logic to Swift (or maintain shared algorithm specification)
- Implement AVFoundation + C/C++ audio engine for <10ms latency
- Native iOS UI with CoreGraphics/SwiftUI for 60 FPS rendering
- Haptic feedback integration (not available on web)
- iOS-specific compliance (Privacy Manifest, Accessibility, TestFlight)
- Pattern format compatibility with web version for seamless import/export

## Starter Template Evaluation

### Primary Technology Domain

**iOS Native Application** - Real-time audio creative tool with custom gesture-based interface

Unlike web development with CLI starters (create-react-app, create-next-app), iOS development uses Xcode project templates with foundational architectural decisions made upfront.

### Technical Preferences Analysis

Based on PixelBoop's requirements for <10ms audio latency, 60 FPS rendering, and complex gesture recognition, the following technical decisions were evaluated:

| Decision Area | Options Considered | Selected | Rationale |
|---------------|-------------------|----------|-----------|
| UI Framework | SwiftUI, UIKit, Hybrid | **Hybrid** | SwiftUI shell + UIKit pixel grid for precise gesture handling |
| Architecture | MVVM, MVC, Clean | **MVVM** | Natural fit for SwiftUI, reactive updates for real-time playback |
| Audio Engine | Pure Swift, Swift+C++, Obj-C++ | **Swift + C/C++** | Required for <10ms latency on real-time audio thread |
| Code Sharing | Port JS, Specification, Shared C++ | **Specification** | Document algorithms formally, implement natively per platform |

### Selected Starter: Xcode SwiftUI App Template + C++ Audio Core

**Rationale for Selection:**

1. **SwiftUI App template** provides modern app lifecycle, state management, and future iOS compatibility
2. **UIKit integration** (via UIViewRepresentable) enables precise touch handling for the pixel grid
3. **C++ audio core** achieves professional <10ms latency impossible with pure Swift
4. **Manual structure setup** gives full control over MVVM organization and module boundaries

**Initialization Command:**

```bash
# Create via Xcode 16+:
# File → New → Project → iOS → App
#
# Configuration:
#   Product Name: PixelBoop
#   Team: [Your Team]
#   Organization Identifier: com.audiolux
#   Bundle Identifier: com.audiolux.pixelboop
#   Interface: SwiftUI
#   Language: Swift
#   Storage: None
#   Include Tests: ✓ (Unit + UI)
#
# Deployment Target: iOS 15.0
# Build SDK: iOS 18+
```

### Architectural Decisions Provided by Starter

**Language & Runtime:**
- Swift 5.9+ with strict concurrency checking enabled
- C/C++ integration via bridging header for audio engine
- iOS 15+ deployment target (iPhone SE 2nd gen minimum)
- Built with iOS 18+ SDK per App Store requirements

**UI Framework Configuration:**
- SwiftUI App lifecycle (@main, WindowGroup)
- UIViewRepresentable wrapper for custom UIKit pixel grid view
- ObservableObject pattern for reactive state management
- Combine framework for event streams (playback position, touch events)

**Project Structure:**

```
PixelBoop/
├── App/
│   ├── PixelBoopApp.swift              # @main entry point
│   └── ContentView.swift               # Root navigation
├── Models/
│   ├── Pattern.swift                   # Pattern data structure (JSON-compatible)
│   ├── Track.swift                     # Track with notes array
│   ├── Note.swift                      # Note with velocity, step, pitch
│   └── MusicalConstants.swift          # Scales, chords, drum mappings
├── ViewModels/
│   ├── SequencerViewModel.swift        # Main sequencer state + playback control
│   ├── GestureInterpreter.swift        # Gesture → musical notes algorithm
│   ├── MenuViewModel.swift             # Menu state (collapsed/expanded) (FR102-107)
│   └── PatternLibraryViewModel.swift   # Pattern save/load/browse
├── Views/
│   ├── SequencerView.swift             # Main sequencer SwiftUI container
│   ├── PixelGridView.swift             # UIViewRepresentable wrapper
│   ├── PixelGridUIView.swift           # UIKit custom view (Core Graphics rendering)
│   ├── MenuColumnView.swift            # Collapsible menu column UI (FR102-107)
│   ├── ControlButtonView.swift         # Reusable control buttons for menu
│   ├── ControlRowView.swift            # Play/stop, scale, BPM controls
│   └── TooltipOverlay.swift            # Pixel-font tooltip rendering
├── Services/
│   ├── AudioEngine.swift               # Swift wrapper for C++ audio
│   ├── HapticsService.swift            # UIFeedbackGenerator integration
│   └── StorageService.swift            # UserDefaults + File System
├── Audio/
│   ├── AudioEngine.hpp                 # C++ header
│   ├── AudioEngine.cpp                 # C++ synthesis implementation
│   ├── Oscillator.hpp/cpp              # Sine, triangle, sawtooth generators
│   ├── DrumSynth.hpp/cpp               # 12 drum sound synthesizers
│   ├── ADSREnvelope.hpp/cpp            # Attack-decay-sustain-release
│   └── LockFreeQueue.hpp               # Thread-safe state communication
├── Resources/
│   ├── Assets.xcassets                 # App icons, colors
│   ├── PrivacyInfo.xcprivacy           # Privacy manifest (required)
│   └── Info.plist                      # Background audio, etc.
├── Supporting/
│   ├── PixelBoop-Bridging-Header.h     # C++ bridging header
│   └── Constants.swift                 # Grid dimensions, timing thresholds
└── Tests/
    ├── PixelBoopTests/                 # Unit tests
    │   ├── GestureInterpreterTests.swift
    │   ├── MusicalIntelligenceTests.swift
    │   └── PatternSerializationTests.swift
    └── PixelBoopUITests/               # UI tests
        └── SequencerUITests.swift
```

**Build Configuration:**
- Debug: Optimizations disabled, assertions enabled, audio buffer 512 samples
- Release: Full optimization (-O), assertions disabled, audio buffer 256 samples
- Background Modes: Audio enabled (UIBackgroundModes)
- Capabilities: None required for MVP (no push, no iCloud, no HealthKit)

**Grid Specifications:**

The 44×24 pixel grid is the core visual canvas for PixelBoop, with responsive sizing that fills vertical canvas space and an adaptive menu column system.

```swift
// Grid Constants
let COLS = 44  // Timeline steps (vertical on portrait)
let ROWS = 24  // Tracks/pitches (horizontal on portrait)
let GAP_SIZE: CGFloat = 1.0  // 1px gaps between pixels
let BACKGROUND_COLOR = UIColor(hex: "#0a0a0a")  // Dark background

// Pixel Sizing Strategy (FR37, FR102)
// OLD (Story 1.1): pixelSize = floor(min(availableWidth, availableHeight))
// NEW (Sprint Change 2026-01-03): Fill vertical canvas 100%
let pixelSize = floor(availableHeight / CGFloat(ROWS))  // Maximize vertical space
let gridWidth = CGFloat(COLS) * pixelSize + CGFloat(COLS - 1) * GAP_SIZE
let gridHeight = CGFloat(ROWS) * pixelSize + CGFloat(ROWS - 1) * GAP_SIZE

// Menu Column Layout (FR103-107)
let menuWidth = availableWidth - gridWidth  // Remaining horizontal space
let collapsedMenuWidth: CGFloat = 60  // Icon-only column width
let expandedMenuWidth: CGFloat = 250  // Full controls width

// Layout: [44-col grid] + [1px separator] + [menu column]
// Menu adapts: collapsed (compact devices) or expanded (spacious devices)
```

**Menu Column Interaction Pattern (FR104-107):**
- **Collapsed State:** Single column (~60px) with icon-only buttons, vertically stacked
- **Expanded State:** Multi-column (~250px) with full labeled controls
- **Transition:** Tap anywhere in menu column to toggle collapsed ↔ expanded
- **Hardware Compatibility:** No edge-swipe gestures (works with grid controllers)

**Row Allocation (for reference):**
- Row 0: Control buttons (may be deprecated in favor of menu column)
- Row 1: Step markers
- Rows 2-7: Melody track (6 rows)
- Rows 8-13: Chords track (6 rows)
- Rows 14-17: Bass track (4 rows)
- Rows 18-21: Rhythm track (4 rows)
- Rows 22-23: Pattern overview (2 rows)

**Audio Architecture:**

```
┌─────────────────────────────────────────────────────────────────┐
│                        Main Thread (Swift)                       │
│  ┌─────────────────┐    ┌──────────────────┐    ┌────────────┐ │
│  │ SequencerVM     │───▶│ GestureInterpreter│───▶│ Pattern    │ │
│  │ - tracks        │    │ - interpretGesture│    │ - tracks[] │ │
│  │ - currentStep   │    │ - snapToScale     │    │ - metadata │ │
│  │ - isPlaying     │    │ - getChordNotes   │    │            │ │
│  └────────┬────────┘    └──────────────────┘    └────────────┘ │
│           │                                                      │
│           ▼ (atomic state updates)                              │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │              Lock-Free State Queue                          ││
│  │  - currentStep, BPM, pattern snapshot for audio thread      ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Audio Thread (C/C++)                          │
│  ┌─────────────────┐    ┌──────────────────┐    ┌────────────┐ │
│  │ AudioEngine     │───▶│ Oscillators      │───▶│ Output     │ │
│  │ - renderCallback│    │ - sine/tri/saw   │    │ Buffer     │ │
│  │ - voiceManager  │    │ - ADSR envelopes │    │ (256 samp) │ │
│  │ - drumSynth     │    │ - DrumSynth      │    │            │ │
│  └─────────────────┘    └──────────────────┘    └────────────┘ │
│                                                                  │
│  Constraints: No allocations, no locks, no Swift runtime calls  │
│  Buffer: 256 samples @ 44.1kHz = 5.8ms latency                  │
└─────────────────────────────────────────────────────────────────┘
```

**Development Experience:**
- Hot reload: SwiftUI previews for non-audio views
- Debugging: Xcode Instruments for audio thread profiling
- Testing: XCTest for unit tests, XCUITest for UI automation
- Audio debugging: AUGraph inspection, latency measurement tools

**Testing Infrastructure:**
- Unit tests for gesture interpretation (same input → same output)
- Unit tests for musical intelligence (scale snapping, chord voicing)
- Unit tests for pattern serialization (JSON round-trip)
- UI tests for basic sequencer interactions
- Manual testing for audio latency measurement

### Post-Initialization Setup Checklist

After creating the Xcode project, complete these setup steps:

1. **Add C++ Support**
   - Create `PixelBoop-Bridging-Header.h`
   - Add to Build Settings → Swift Compiler → Objective-C Bridging Header
   - Create `Audio/` folder with `.hpp` and `.cpp` files

2. **Configure Audio Capabilities**
   - Info.plist: Add `UIBackgroundModes` with `audio` value
   - Add AVFoundation.framework to Link Binary With Libraries

3. **Create Privacy Manifest**
   - Add `PrivacyInfo.xcprivacy` to Resources
   - Declare `NSPrivacyAccessedAPICategoryUserDefaults` with reason `CA92.1`
   - Declare zero data collection

4. **Set Deployment Target**
   - General → Minimum Deployments → iOS 15.0
   - Build Settings → iOS Deployment Target → 15.0

5. **Configure Build Settings**
   - Enable strict concurrency checking
   - Set C++ Language Dialect to C++17
   - Enable whole module optimization for Release

6. **Create MVVM Folder Structure**
   - Create folders: Models, ViewModels, Views, Services, Audio, Supporting
   - Move default files to appropriate locations

**Note:** Project initialization and setup should be the first implementation story in Sprint 1.

## Core Architectural Decisions

### Decision Priority Analysis

**Critical Decisions (Block Implementation):**
- Pattern Storage: File System (JSON) + UserDefaults
- Audio Thread Communication: Lock-Free Ring Buffer
- Gesture State Management: ObservableObject + @Published

**Important Decisions (Shape Architecture):**
- Pattern Data Model: Codable Structs
- Error Handling: Swift Result<T, Error>
- Testing Strategy: Unit tests + Manual testing

**Deferred Decisions (Post-MVP):**
- Advanced audio features (reverb, EQ)
- Cloud sync capabilities
- Collaborative editing features

### Data Architecture

**Pattern Storage:**
- Primary: File System (JSON format in Documents/)
  - Rationale: Matches web version export format, enables cross-platform compatibility
  - Version: iOS 15+ FileManager API
  - Affects: FR49 (Save Patterns), FR50 (Load Patterns), FR52 (Export/Import)
- Secondary: UserDefaults for preferences
  - Rationale: BPM, scale selection, UI state
  - Affects: User experience continuity

**Pattern Data Model:**
```swift
struct Pattern: Codable {
    var id: UUID
    var tracks: [Track]
    var metadata: PatternMetadata
    var version: String
}

struct Track: Codable {
    var type: TrackType
    var pixels: [PixelState]
    var instrument: InstrumentConfig
}
```
- Rationale: Codable for JSON compatibility, strongly typed for safety
- Affects: All pattern operations, cross-platform compatibility

### State Management

**Gesture State:**
- Pattern: ObservableObject + @Published properties
- Rationale: SwiftUI reactive updates, clear separation of concerns
- Implementation:
```swift
class GridViewModel: ObservableObject {
    @Published var activePixels: Set<PixelCoordinate>
    @Published var gestureState: GestureRecognitionState
}
```
- Affects: FR1-FR11 (Gesture Recognition), FR12-FR24 (Musical Intelligence)

### Audio & Communication Patterns

**Audio Thread Communication:**
- Pattern: Lock-Free Ring Buffer (C++)
- Rationale: Real-time audio constraint (no locks, no allocations)
- Version: Custom implementation using std::atomic
- Implementation:
```cpp
template<typename T, size_t Size>
class LockFreeRingBuffer {
    std::atomic<size_t> writePos{0};
    std::atomic<size_t> readPos{0};
    std::array<T, Size> buffer;
};
```
- Affects: NFR2 (Audio Latency <10ms), FR25-FR35 (Audio Synthesis)

### Error Handling

**Strategy:**
- Pattern: Swift Result<T, Error> for recoverable errors
- Rationale: Explicit error handling, type-safe propagation
- Implementation:
```swift
enum PatternError: Error {
    case fileNotFound
    case invalidFormat
    case audioEngineFailure
}

func loadPattern(id: UUID) -> Result<Pattern, PatternError> {
    // Implementation
}
```
- Affects: All I/O operations, audio initialization, pattern operations

**Logging:**
- Pattern: OSLog framework (iOS system logging)
- Rationale: Zero-cost when disabled, privacy-aware, performance monitoring
- Affects: NFR17 (Logging), debugging, App Store compliance

### Testing Strategy

**Unit Testing:**
- Scope: Business logic, data models, gesture algorithms
- Framework: XCTest
- Coverage Target: ≥70% for critical paths
- Affects: All FR validation

**Manual Testing:**
- Scope: Gesture UX, audio quality, performance
- Rationale: Subjective user experience requires human validation
- Process: TestFlight beta (4-8 weeks minimum)
- Affects: NFR1 (60 FPS), NFR2 (Audio Latency), NFR4-NFR7 (Accessibility)

### Decision Impact Analysis

**Implementation Sequence:**
1. Audio engine initialization (C++ core)
2. Lock-free ring buffer implementation
3. Pattern data model + Codable conformance
4. File system storage layer
5. Gesture state management (ObservableObject)
6. Error handling + logging infrastructure
7. Unit test framework setup

**Cross-Component Dependencies:**
- Audio engine ← Lock-free buffer ← Gesture state
- Pattern storage ← Data model ← JSON compatibility
- Error handling → All I/O operations
- Testing framework → All components

## Implementation Patterns & Consistency Rules

### Pattern Categories Defined

**Critical Conflict Points Identified:** 7 areas where AI agents could make different choices

### Naming Patterns

**Swift Files:**
- Types: `PascalCase` (GridViewModel, PatternStorage)
- Files: Match type name (`GridViewModel.swift`)
- Variables/functions: `camelCase` (activePixels, loadPattern)
- Protocols: Descriptive suffix (`Codable`, `PatternStorageDelegate`)

**C++ Files:**
- Classes: `PascalCase` (AudioEngine, LockFreeRingBuffer)
- Files: Match class (`AudioEngine.hpp/cpp`)
- Functions: `camelCase` (renderAudio, processBuffer)
- Members: `camelCase` with trailing underscore (`writePos_`)

**JSON Fields:**
- Pattern format: `camelCase` (matches Swift Codable defaults)
- Example: `{"trackType": "melody", "noteVelocity": 2}`

### Structure Patterns

**Project Organization:**
```
Models/           # Data structures (Pattern, Track, Note)
ViewModels/       # ObservableObject classes
Views/            # SwiftUI views + UIViewRepresentable
Services/         # Swift wrappers (AudioEngine, Storage, Haptics)
Audio/            # Pure C++ (.hpp/.cpp)
Tests/            # XCTest (PixelBoopTests/, PixelBoopUITests/)
```

**Test Placement:**
- Unit tests: Separate `PixelBoopTests/` target
- UI tests: Separate `PixelBoopUITests/` target
- Audio tests: Manual (latency measurement in TestFlight)

### Communication Patterns

**Thread Safety:**
- Main → Audio: Lock-free ring buffer (C++), atomic writes only
- Audio → Main: Publish on main queue via `DispatchQueue.main.async`
- Rule: Audio thread NEVER allocates, locks, or calls Swift runtime

**State Updates:**
- ViewModels: Always use `@Published` for SwiftUI bindings
- Manual updates: Only when `@Published` insufficient (batch updates)
- Rule: All UI state changes on main thread

### Format Patterns

**API/Data Formats:**
- Pattern JSON: `{"id": "uuid", "tracks": [...], "metadata": {...}}`
- Error format: Swift `Result<T, Error>` in code, log messages use `OSLog`
- Dates: ISO 8601 strings in JSON (`"2026-01-02T12:34:56Z"`)

**Swift/C++ Bridge:**
- Primitives: Direct pass (Int32, Float, Bool)
- Strings: `std::string` → Swift `String` via bridging
- Pointers: Opaque pointers only, Swift never dereferences C++ objects directly

### Process Patterns

**Error Handling:**
- Swift domain: `Result<Pattern, PatternError>` for I/O
- C++ domain: Return codes (0 = success, -1 = error)
- Audio thread: No errors, fail-safe (silence on invalid state)

**Initialization Sequence:**
1. Audio engine (C++) setup before app launch
2. Pattern storage after audio ready
3. ViewModels after storage ready
4. SwiftUI views last

### Enforcement Guidelines

**All AI Agents MUST:**
- Use exact type names from architecture document
- Follow thread safety rules (no Swift on audio thread)
- Match JSON field names for web compatibility
- Place tests in designated directories
- Use `@Published` for all observable state

**Pattern Examples:**

**Good:**
```swift
// Correct: PascalCase type, camelCase property
class GridViewModel: ObservableObject {
    @Published var activePixels: Set<PixelCoordinate>
}
```

**Anti-Pattern:**
```swift
// Wrong: snake_case, direct mutation
class grid_view_model {
    var active_pixels: [Int]  // Should be Set<PixelCoordinate>
}
```

## Project Structure & Boundaries

### Complete Project Directory Structure

```
PixelBoop/
├── PixelBoop.xcodeproj/
│   └── project.pbxproj
├── App/
│   ├── PixelBoopApp.swift                    # @main, audio engine init
│   └── ContentView.swift                     # Root navigation
├── Models/
│   ├── Pattern.swift                         # FR49-52: Codable pattern data
│   ├── Track.swift                           # FR54-59: 4 track types
│   ├── Note.swift                            # Note with pitch, velocity, step
│   ├── GestureState.swift                    # FR1-11: Gesture state machine
│   └── MusicalConstants.swift                # FR20-24: Scales, chords, intervals
├── ViewModels/
│   ├── SequencerViewModel.swift              # FR12-19: Playback, state
│   ├── GestureInterpreter.swift              # FR1-11: Gesture → notes
│   ├── MenuViewModel.swift                   # FR102-107: Menu state (collapsed/expanded)
│   ├── PatternLibraryViewModel.swift         # FR25-32: Save/load/browse
│   └── HistoryManager.swift                  # FR33-36: 50-level undo/redo
├── Views/
│   ├── SequencerView.swift                   # FR37-45: Main UI container
│   ├── PixelGridView.swift                   # UIViewRepresentable wrapper
│   ├── PixelGridUIView.swift                 # FR1-11: Touch handling (UIKit)
│   ├── MenuColumnView.swift                  # FR102-107: Collapsible menu column UI
│   ├── ControlButtonView.swift               # Reusable control buttons for menu
│   ├── ControlRowView.swift                  # FR46-53: BPM, scale, controls
│   ├── PatternLibraryView.swift              # FR25-32: Pattern browser
│   └── TooltipOverlay.swift                  # FR37-45: Pixel-font overlays
├── Services/
│   ├── AudioEngineService.swift              # Swift wrapper for C++ audio
│   ├── HapticsService.swift                  # FR64-66: UIFeedbackGenerator
│   └── StorageService.swift                  # FR60-63: FileManager + UserDefaults
├── Audio/
│   ├── AudioEngine.hpp                       # C++ header (public interface)
│   ├── AudioEngine.cpp                       # FR12-19: AVAudioEngine render
│   ├── Oscillator.hpp                        # Sine, triangle, sawtooth
│   ├── Oscillator.cpp
│   ├── DrumSynth.hpp                         # FR12-19: 12 drum sounds
│   ├── DrumSynth.cpp
│   ├── ADSREnvelope.hpp                      # Envelope generator
│   ├── ADSREnvelope.cpp
│   └── LockFreeRingBuffer.hpp                # Thread communication
├── Resources/
│   ├── Assets.xcassets/                      # App icons, colors
│   ├── PrivacyInfo.xcprivacy                 # NFR45-48: Privacy manifest
│   └── Info.plist                            # Background audio, etc.
├── Supporting/
│   ├── PixelBoop-Bridging-Header.h           # C++ → Swift bridge
│   └── Constants.swift                       # Grid size (44×24), thresholds
├── PixelBoopTests/
│   ├── GestureInterpreterTests.swift         # FR1-11 validation
│   ├── MusicalIntelligenceTests.swift        # FR20-24 validation
│   ├── PatternSerializationTests.swift       # JSON round-trip
│   └── HistoryManagerTests.swift             # Undo/redo validation
└── PixelBoopUITests/
    └── SequencerUITests.swift                # Basic navigation tests
```

### Architectural Boundaries

**Swift ↔ C++ Boundary:**
- `Services/AudioEngineService.swift` ↔ `Audio/AudioEngine.hpp`
- Swift calls C++ via bridging header
- C++ returns primitives only (Float, Int32, Bool)
- No shared memory; use lock-free queue

**Main Thread ↔ Audio Thread:**
- `ViewModels/*` ──(LockFreeRingBuffer)──► `Audio/*`
- Main thread: Pattern edits, UI state
- Audio thread: Real-time synthesis only
- Communication: Atomic state snapshots

**UI ↔ ViewModel Boundary:**
- `Views/*` ──(@Published bindings)──► `ViewModels/*`
- Views observe ViewModels via `@Published`
- Views call ViewModel methods for actions
- No direct Model access from Views

### FR Category to File Mapping

| FR Category | Primary Files | Count |
|-------------|---------------|-------|
| Gesture Recognition (FR1-11) | GestureInterpreter.swift, PixelGridUIView.swift, GestureState.swift | 11 |
| Audio Synthesis (FR12-19) | Audio/*.cpp, AudioEngineService.swift | 8 |
| Musical Intelligence (FR20-24) | MusicalConstants.swift, GestureInterpreter.swift | 5 |
| Pattern Management (FR25-32) | PatternLibraryViewModel.swift, StorageService.swift | 8 |
| History (FR33-36) | HistoryManager.swift | 4 |
| Visual Feedback (FR37-45) | Views/*.swift, PixelGridUIView.swift | 9 |
| Controls (FR46-53) | ControlRowView.swift, SequencerViewModel.swift | 8 |
| Tracks (FR54-59) | Track.swift, SequencerViewModel.swift | 6 |
| Offline/Storage (FR60-63) | StorageService.swift | 4 |
| Haptics (FR64-66) | HapticsService.swift | 3 |
| Responsive Interface (FR102-107) | MenuColumnView.swift, MenuViewModel.swift, PixelGridUIView.swift | 6 |

### Data Flow

```
Touch Event → PixelGridUIView → GestureInterpreter → SequencerViewModel
                                      ↓
                              MusicalConstants (scale snap)
                                      ↓
                              Pattern (state update)
                                      ↓
                         LockFreeRingBuffer → AudioEngine → Output
```

### Integration Points

**Internal Communication:**
- SwiftUI → UIKit: UIViewRepresentable (PixelGridView wraps PixelGridUIView)
- ViewModel → Audio: LockFreeRingBuffer for thread-safe state transfer
- Storage → ViewModel: Async file I/O with Result callbacks

**External Integrations:**
- iOS Files app: UIDocumentPickerViewController for pattern export/import
- System haptics: UIFeedbackGenerator (UIImpactFeedbackGenerator, UISelectionFeedbackGenerator)
- Background audio: AVAudioSession configuration

**No External Network:**
- 100% offline operation
- No analytics, no cloud sync (MVP)
- Privacy Manifest declares zero data collection

## Architecture Validation Results

### Coherence Validation ✅

**Decision Compatibility:**
All architectural decisions work together coherently. Swift 5.9 + C++17 + iOS 15+ are fully compatible. MVVM pattern aligns with SwiftUI, lock-free buffer supports audio thread constraints, and Codable structs enable JSON compatibility with web version.

**Pattern Consistency:**
Implementation patterns directly support architectural decisions. Naming conventions (PascalCase types, camelCase properties) match Swift standards. Thread safety rules (no Swift on audio thread) enforce the C++ audio architecture. All patterns reinforce the hybrid Swift/C++ approach.

**Structure Alignment:**
Project structure supports all architectural decisions. Separate Audio/ folder for C++ isolates real-time code. Services/ provides Swift wrappers for thread boundary. MVVM folders (Models/, ViewModels/, Views/) align with chosen architecture pattern.

### Requirements Coverage Validation ✅

**Functional Requirements Coverage (72/72):**
- FR1-11 (Gesture Recognition): GestureInterpreter.swift, PixelGridUIView.swift, GestureState.swift
- FR12-19 (Audio Synthesis): Audio/*.cpp, AudioEngineService.swift
- FR20-24 (Musical Intelligence): MusicalConstants.swift, GestureInterpreter.swift
- FR25-32 (Pattern Management): PatternLibraryViewModel.swift, StorageService.swift
- FR33-36 (History): HistoryManager.swift
- FR37-45 (Visual Feedback): Views/*.swift, PixelGridUIView.swift
- FR46-53 (Controls): ControlRowView.swift, SequencerViewModel.swift
- FR54-59 (Tracks): Track.swift, SequencerViewModel.swift
- FR60-63 (Offline/Storage): StorageService.swift
- FR64-66 (Haptics): HapticsService.swift
- FR102-107 (Responsive Interface): MenuColumnView.swift, MenuViewModel.swift, PixelGridUIView.swift

**Non-Functional Requirements Coverage (41+ addressed):**
- NFR1 (60 FPS): CoreGraphics rendering + dirty rectangle optimization
- NFR2 (<10ms latency): C++ audio thread + 256-sample buffer @ 44.1kHz = 5.8ms
- NFR3-4 (Battery, Size): Audio engine suspension, build optimization
- NFR45-48 (Privacy): PrivacyInfo.xcprivacy with zero data collection
- NFR49-56 (Accessibility): VoiceOver support, Dynamic Type, WCAG 2.1 AA
- NFR57-60 (SDK): Xcode 16+, iOS 18+ SDK, iOS 15+ deployment
- NFR77-80 (TestFlight): 4-8 week beta process with manual testing

### Implementation Readiness Validation ✅

**Decision Completeness:**
All critical architectural decisions documented with specific versions (Swift 5.9, C++17, iOS 15+ deployment, iOS 18+ SDK). Implementation patterns cover naming, threading, error handling, and data flow. Technology choices verified and compatible.

**Structure Completeness:**
Complete project directory structure with 30+ files mapped to functional requirements. All integration boundaries defined (Swift↔C++, Main↔Audio, UI↔ViewModel). Clear data flow from touch events through synthesis to audio output.

**Pattern Completeness:**
7 critical conflict points addressed (Swift/C++ naming, threading, JSON format, state management, error handling, initialization sequence, test organization). Concrete examples provided for correct patterns and anti-patterns.

### Gap Analysis Results

**No Critical Gaps Identified**

**Minor Future Enhancements:**
- Accessibility testing methodology (manual for MVP, automation post-launch)
- Performance profiling instrumentation (Xcode Instruments during development)
- Cross-platform JSON compatibility test suite (validate web↔iOS round-trip)

### Architecture Completeness Checklist

**✅ Requirements Analysis**
- [x] Project context thoroughly analyzed (66 FRs, 41+ NFRs)
- [x] Scale and complexity assessed (Medium-High complexity)
- [x] Technical constraints identified (iOS 15+, <10ms latency, App Store compliance)
- [x] Cross-cutting concerns mapped (audio latency, pattern compatibility, gesture accuracy, performance, compliance, testing)

**✅ Architectural Decisions**
- [x] Critical decisions documented with versions (Pattern Storage, Audio Thread Communication, Gesture State)
- [x] Technology stack fully specified (Swift 5.9, C++17, Xcode 16, iOS 15+/18+)
- [x] Integration patterns defined (Lock-free ring buffer, ObservableObject, Result<T,E>)
- [x] Performance considerations addressed (<10ms audio, 60 FPS, <5% battery)

**✅ Implementation Patterns**
- [x] Naming conventions established (Swift PascalCase/camelCase, C++ PascalCase/camelCase_)
- [x] Structure patterns defined (MVVM folders, Audio/ separation, Tests/ organization)
- [x] Communication patterns specified (Thread safety rules, @Published bindings)
- [x] Process patterns documented (Error handling, initialization sequence)

**✅ Project Structure**
- [x] Complete directory structure defined (30+ files)
- [x] Component boundaries established (Swift↔C++, Main↔Audio, UI↔ViewModel)
- [x] Integration points mapped (UIViewRepresentable, LockFreeRingBuffer, UIDocumentPicker)
- [x] Requirements to structure mapping complete (66 FRs → specific files)

### Architecture Readiness Assessment

**Overall Status:** ✅ READY FOR IMPLEMENTATION

**Confidence Level:** HIGH

All architectural decisions are coherent, comprehensive, and validated. The project already has Xcode initialization complete with basic SwiftUI template. Implementation can begin immediately with C++ audio core setup.

**Key Strengths:**
- Clear separation of concerns: Swift UI layer / C++ audio engine
- All 66 functional requirements have architectural homes
- Lock-free pattern prevents audio thread glitches
- Web compatibility via JSON format with Codable
- iOS App Store compliance built into architecture

**Areas for Future Enhancement:**
- Advanced audio features (reverb, EQ, filters) post-MVP
- Cloud sync capabilities (iCloud integration) Phase 2
- Collaborative pattern editing (multi-device) future consideration
- Automated accessibility testing framework

### Implementation Handoff

**AI Agent Guidelines:**
- Follow all architectural decisions exactly as documented
- Use implementation patterns consistently across all components
- Respect project structure and file/folder boundaries
- Refer to this document for all architectural questions
- Maintain thread safety rules strictly (no Swift on audio thread)

**First Implementation Priority:**
Xcode project already initialized. Next steps:
1. Add C++ support (bridging header, build settings)
2. Create Audio/ folder with C++ audio engine core
3. Implement lock-free ring buffer for thread communication
4. Add Privacy Manifest (PrivacyInfo.xcprivacy)
5. Configure background audio mode
6. Create MVVM folder structure

## Architecture Completion Summary

### Workflow Completion

**Architecture Decision Workflow:** COMPLETED ✅  
**Total Steps Completed:** 8  
**Date Completed:** 2026-01-02  
**Document Location:** `_bmad-output/planning-artifacts/architecture.md`

### Final Architecture Deliverables

**📋 Complete Architecture Document**
- All architectural decisions documented with specific versions
- Implementation patterns ensuring AI agent consistency
- Complete project structure with all files and directories
- Requirements to architecture mapping (66 FRs → 30+ files)
- Validation confirming coherence and completeness

**🏗️ Implementation Ready Foundation**
- 15+ architectural decisions made (technology stack, data storage, threading, state management, error handling)
- 7 implementation patterns defined (naming, structure, communication, format, process)
- 10 architectural components specified (Models, ViewModels, Views, Services, Audio, Resources, Supporting, Tests)
- 66 functional requirements fully supported
- 41+ non-functional requirements addressed

**📚 AI Agent Implementation Guide**
- Technology stack with verified versions (Swift 5.9, C++17, iOS 15+/18+, Xcode 16)
- Consistency rules that prevent implementation conflicts (thread safety, naming conventions, JSON compatibility)
- Project structure with clear boundaries (Swift↔C++, Main↔Audio, UI↔ViewModel)
- Integration patterns and communication standards (lock-free buffer, @Published, Result<T,E>)

### Implementation Handoff

**For AI Agents:**
This architecture document is your complete guide for implementing PixelBoop. Follow all decisions, patterns, and structures exactly as documented.

**First Implementation Priority:**
Xcode project already initialized at `pixelboop/` and `pixelboop.xcodeproj/`. 

Next steps:
1. Add C++ support via bridging header
2. Create Audio/ folder with C++ audio engine
3. Implement lock-free ring buffer
4. Add Privacy Manifest (PrivacyInfo.xcprivacy)
5. Configure background audio mode
6. Create MVVM folder structure

**Development Sequence:**
1. Set up C++ integration and audio core architecture
2. Implement data models (Pattern, Track, Note) with Codable
3. Build gesture recognition system (GestureInterpreter + PixelGridUIView)
4. Create audio synthesis engine (Audio/*.cpp)
5. Implement UI layer (SwiftUI views + ViewModels)
6. Add pattern storage and management
7. Integrate haptics and visual feedback
8. TestFlight beta and App Store submission

### Quality Assurance Checklist

**✅ Architecture Coherence**
- [x] All decisions work together without conflicts
- [x] Technology choices are compatible (Swift 5.9 + C++17 + iOS 15+/18+)
- [x] Patterns support the architectural decisions (MVVM + lock-free + Codable)
- [x] Structure aligns with all choices (MVVM folders + Audio/ separation)

**✅ Requirements Coverage**
- [x] All functional requirements are supported (72/72)
- [x] All non-functional requirements are addressed (41+/41+)
- [x] Cross-cutting concerns are handled (latency, compatibility, compliance)
- [x] Integration points are defined (3 major boundaries)

**✅ Implementation Readiness**
- [x] Decisions are specific and actionable (versions, patterns, examples)
- [x] Patterns prevent agent conflicts (7 conflict points addressed)
- [x] Structure is complete and unambiguous (30+ files mapped)
- [x] Examples are provided for clarity (Good/Anti-pattern code samples)

### Project Success Factors

**🎯 Clear Decision Framework**  
Every technology choice was made collaboratively with clear rationale. Swift + C++ hybrid architecture addresses <10ms latency requirement while maintaining iOS best practices.

**🔧 Consistency Guarantee**  
Implementation patterns and rules ensure that multiple AI agents will produce compatible, consistent code. Thread safety rules prevent audio glitches, naming conventions ensure maintainability, JSON format enables web compatibility.

**📋 Complete Coverage**  
All 66 functional requirements and 41+ non-functional requirements are architecturally supported, with clear mapping from business needs (gesture recognition, audio synthesis, pattern management) to technical implementation (specific Swift/C++ files).

**🏗️ Solid Foundation**  
The Xcode SwiftUI template combined with C++ audio core provides a production-ready foundation. MVVM architecture follows iOS best practices, lock-free buffer prevents real-time audio issues, and Privacy Manifest ensures App Store compliance.

---

**Architecture Status:** ✅ READY FOR IMPLEMENTATION

**Next Phase:** Begin implementation using the architectural decisions and patterns documented herein.

**Document Maintenance:** Update this architecture when major technical decisions are made during implementation.
