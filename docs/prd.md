# PixelBoop Multi-Platform Expansion PRD

**Version:** 0.1
**Date:** 2025-12-17
**Author:** Sarah (Product Owner)
**Status:** Draft

---

## 1. Intro Project Analysis and Context

### 1.1 Analysis Source

- **IDE-based fresh analysis** (analyzing `prototype_sequencer.jsx` directly)

### 1.2 Current Project State

**Project Name**: PixelBoop Music Sequencer

**Current State**: A React-based music sequencer prototype with pixel-grid interface. The application is a fully functional mobile-first music creation tool featuring:

- **44×24 pixel grid** interface for visual music programming
- **4-track sequencer** with distinct sonic characteristics:
  - Melody (sine wave synthesis, 6-note range display)
  - Chords (triangle wave, automated chord voicing)
  - Bass (sawtooth with lowpass filter, 4-note range)
  - Rhythm (12 synthesized drum sounds)
- **Gesture-based composition** with intelligent musical interpretation
- **Real-time audio synthesis** using Web Audio API
- **Pattern-based sequencer** supporting 8-32 step patterns at 60-200 BPM

**Primary Purpose**: Enable intuitive music creation on mobile devices through gesture-based interaction, eliminating traditional piano roll complexity.

### 1.3 Available Documentation Analysis

**Available Documentation**: ✗ None (working from prototype code only)

**Recommendation**: Comprehensive code analysis of `prototype_sequencer.jsx` (1,611 lines) performed to extract all functional requirements, technical architecture, and user interaction patterns.

---

### 1.4 Enhancement Scope Definition

**Enhancement Type**:
- ☑ **New Feature Addition** (iOS native app + standalone web app)
- ☑ **Technology Stack Upgrade** (React prototype → iOS Swift + optimized web)

**Enhancement Description**:

Expand the React prototype into two production-ready platforms with 1:1 feature parity:

1. **iOS Native App**: SwiftUI-based native application leveraging iOS audio frameworks (AVFoundation) for superior performance and offline capability
2. **Standalone Web App**: Optimized, production-ready web application with improved performance, PWA support, and mobile-first design

Both platforms will maintain identical gesture systems, musical features, and user experience while optimizing for platform-specific capabilities.

**Impact Assessment**:
- ☑ **Major Impact** (architectural changes required)
  - Shared core logic architecture needed across platforms
  - Platform-specific audio synthesis implementations
  - Unified data/pattern format for cross-platform compatibility

---

### 1.5 Goals and Background Context

**Goals**:
- Create native iOS app with superior audio performance and offline capability
- Build production-ready standalone web app with PWA support
- Achieve 1:1 feature parity across all platforms (React prototype, iOS, Web)
- Establish shared core logic architecture for maintainability
- Enable cross-platform pattern/song sharing via unified data format
- Optimize gesture recognition for each platform's input paradigms
- Maintain sub-10ms audio latency on iOS, sub-20ms on web
- Deliver immersive fullscreen pixel-grid experience with zero external UI elements

**Background Context**:

The React prototype successfully validates the core concept: gesture-based music creation through a pixel grid interface. User feedback demands both a native iOS experience (for performance and offline use) and a polished web version (for accessibility and sharing).

The current prototype demonstrates all core functionality but lacks production architecture, platform optimization, and code sharing strategy. This PRD defines the technical approach to expand from prototype to multi-platform product while establishing maintainable architecture for future development.

**Critical Design Constraint**: The visual appearance and gesture system must be **exactly identical** across all platforms. All UI must exist within the 44×24 pixel grid canvas with no external elements - status information displayed via pixel font tooltips.

---

### 1.6 Change Log

| Change | Date | Version | Description | Author |
|--------|------|---------|-------------|--------|
| Initial PRD | 2025-12-17 | 0.1 | Created PRD from prototype analysis | Sarah (PO) |

---

## 2. Requirements

### 2.1 Functional Requirements

**FR1**: The system shall provide a 44-column × 24-row pixel grid interface as the primary composition canvas (prototype lines 5, 672-677)

**FR2**: The system shall support four distinct musical tracks with dedicated grid rows:
  - Melody track (rows 2-7, 6-note vertical range, sine wave synthesis)
  - Chords track (rows 8-13, 6-note vertical range, triangle wave synthesis with auto-voicing)
  - Bass track (rows 14-17, 4-note vertical range, sawtooth wave with lowpass filter)
  - Rhythm track (rows 18-21, 4-row drum kit, 12 synthesized percussion sounds)

**FR3**: The system shall implement gesture recognition patterns from `interpretGesture()` function (prototype lines 473-605):
  - **Tap** (single touch <300ms): Place single note/drum hit
  - **Hold + Tap** (≥400ms hold): Place accented note (2× velocity)
  - **Horizontal Drag** (`absDx > absDy * 1.3`, line 498): Create musical phrases (arpeggios, runs, walking bass, drum rolls)
  - **Vertical Drag** (`absDy > absDx * 1.3`, line 551): Create chords/stacked notes
  - **Diagonal Drag**: Create melodic phrases with pitch variation
  - **Hold + Drag** (≥400ms + drag, lines 503-515): Create sustained notes with ADSR envelope (velocity 2→3)
  - **Double Tap** (within 300ms, line 976): Erase step
  - **Double Swipe Left** (2 swipes <500ms apart, lines 260-270): Undo
  - **Double Swipe Right**: Redo
  - **Shake** (5+ direction changes within 500ms, line 299): Clear all tracks

**FR4**: The system shall provide musical intelligence features from core logic:
  - Scale snapping (major, minor, pentatonic) using `snapToScale()` algorithm (lines 458-466)
  - Root note selection (12 chromatic notes: C through B)
  - Automatic chord voicing based on selected scale using `getChordNotes()` (lines 468-471, 26-31)
  - Bass fifth/root patterns for vertical gestures

**FR5**: The system shall support pattern sequencing with the following parameters:
  - Pattern length: 8, 12, 16, 20, 24, 28, or 32 steps
  - Tempo: 60-200 BPM in 5 BPM increments
  - Step resolution: 16th notes
  - Loop playback with visual playhead indicator

**FR6**: The system shall synthesize audio in real-time with track-specific timbres from `playNote()` function (lines 1406-1460):
  - Melody: Sine wave oscillator, 2000Hz lowpass filter (line 1435)
  - Chords: Triangle wave oscillator, 1500Hz lowpass filter (line 1439)
  - Bass: Sawtooth wave oscillator, 400Hz lowpass filter (line 1444)
  - Rhythm: 12 unique drum sounds using `playDrum()` function (lines 1176-1403)

**FR7**: The system shall provide track control features:
  - Individual track mute/unmute
  - Solo mode (mute all except selected track)
  - Per-track volume visualization

**FR8**: The system shall implement note velocity system (lines 614, 767-768, 831-845):
  - Velocity 1: Normal note (default opacity ~66%)
  - Velocity 2: Accented note (full brightness, 2× volume)
  - Velocity 3: Sustained note continuation (fading opacity via ADSR, line 824)

**FR9**: The system shall provide visual feedback features from `getPixelGrid()` function (lines 671-922):
  - Real-time playhead with step highlighting
  - Pulse animation on note trigger (100ms, line 1506)
  - Ghost notes (show other tracks' notes at 22% opacity, line 783)
  - Pixel-font tooltips using `PIXEL_FONT` dictionary (lines 50-101) for all user actions
  - Color-coded tracks using `TRACK_COLORS` (lines 14-16) and `NOTE_COLORS` (lines 6-10)

**FR10**: The system shall support undo/redo with 50-level history stack (lines 165-166, 378-404)

**FR11**: The system shall provide control interface (row 0, lines 676-713):
  - Play/Stop toggle
  - Undo/Redo buttons
  - Scale selection (Major/Minor/Pentatonic)
  - Root note picker (12 chromatic notes)
  - Ghost notes toggle
  - BPM up/down controls
  - Pattern length up/down controls
  - Shake indicator (visual feedback during shake gesture)
  - Clear all button

**FR12**: The system shall provide pattern data export/import for cross-platform compatibility using JSON format

**FR13**: The system shall display real-time status information via pixel font tooltips (not external UI):
  - Current root note and scale (when changed)
  - Current BPM (when adjusted)
  - Current pattern length (when adjusted)
  - Gesture feedback (all gesture types, lines 103-133)

**FR14**: The system shall support keyboard shortcuts (web/desktop only, lines 426-448):
  - Space: Play/Stop
  - Cmd/Ctrl+Z: Undo
  - Cmd/Ctrl+Shift+Z: Redo
  - Delete/Backspace: Clear all
  - Arrow Up: Increase BPM
  - Arrow Down: Decrease BPM

**FR15**: ⭐ **NEW** - The system shall provide a **fullscreen immersive grid interface** with zero UI elements outside the 44×24 pixel canvas:
  - **No info bar** above grid (remove prototype lines 1537-1543)
  - **No legend** below grid (remove prototype lines 1585-1607)
  - **Status feedback via tooltips**: BPM displays as "120 BPM" pixel font tooltip (centered, 1200ms duration)
  - **Scale changes** display "C MAJOR" / "D MINOR" / "E PENTA" tooltip
  - **Pattern length changes** display "16 STEPS" / "32 STEPS" tooltip
  - **Grid fills viewport**: 100% available space (accounting for device safe areas)

---

### 2.2 Non-Functional Requirements

**NFR1**: The iOS app shall achieve audio latency below 10ms from gesture to sound output

**NFR2**: The web app shall achieve audio latency below 20ms from gesture to sound output

**NFR3**: The system shall maintain 60 FPS visual performance during playback and user interaction

**NFR4**: The system shall respond to touch input within 16ms (1 frame at 60 FPS)

**NFR5**: The iOS app shall function fully offline with no internet connectivity required

**NFR6**: The web app shall support Progressive Web App (PWA) installation with offline playback capability

**NFR7**: The system shall support responsive display scaling from 320px to 2048px viewport width while maintaining grid aspect ratio

**NFR8**: The system shall calculate pixel size dynamically using prototype formula (lines 231-235): `min(20, max(6, floor((viewport - 20px) / 44 cols)))`

**NFR9**: The system shall prevent pull-to-refresh and other default touch gestures that interfere with music composition (lines 244-252)

**NFR10**: The iOS app shall optimize for battery efficiency, targeting <5% battery drain per 30 minutes of active use

**NFR11**: The system shall use <100MB memory during normal operation

**NFR12**: The system shall persist user patterns locally with automatic save on every change (debounced)

**NFR13**: The system shall load and initialize audio engine within 1 second of app launch

**NFR14**: Pattern data files shall not exceed 50KB for 32-step patterns across all 4 tracks

**NFR15**: The system shall support all iOS devices running iOS 15+ (for native app)

**NFR16**: The system shall support all modern browsers: Chrome 90+, Safari 14+, Firefox 88+, Edge 90+ (for web app)

**NFR17**: ⭐ **NEW** - The system shall prioritize **audio quality and musicality** over technical purity. Synthesis parameters may be adjusted per-platform to achieve the most pleasing timbre on each device's speakers/headphones, while maintaining recognizable equivalence (CR3).

---

### 2.3 Compatibility Requirements

**CR1: Pattern Data Format Compatibility**
All platforms (React prototype, iOS native, standalone web) shall use an identical JSON pattern data format enabling seamless pattern sharing via file export/import. Pattern files shall include track data, BPM, scale, root note, pattern length, and metadata (name, created, modified timestamps).

**CR2: Gesture Vocabulary & Interpretation Consistency** ⭐ **REVISED**

All platforms shall implement gesture recognition from `interpretGesture()` (`prototype_sequencer.jsx` lines 473-605) with **pixel-perfect behavioral consistency**:

**Gesture Classification Thresholds** (must match exactly):
- **Tap**: Touch duration < 300ms (line 496)
- **Hold**: Touch duration ≥ 400ms → velocity = 2 (accent) (line 503, 1050)
- **Double-tap**: Two taps within 300ms, same pixel (line 976) → erase step
- **Horizontal drag**: `absDx > absDy * 1.3` (line 498)
- **Vertical drag**: `absDy > absDx * 1.3` (line 551)
- **Diagonal drag**: All other drag patterns (line 572)
- **Shake**: 5+ direction changes within 500ms (line 299) → clear all
- **Double-swipe**: Two swipes (≥6 steps) in same direction within 500ms (lines 260-270)

**Musical Interpretation Algorithms** (must be identical):
- **Scale snapping**: `snapToScale()` algorithm (lines 458-466) - searches ±5 semitones for closest scale note
- **Chord voicing**: `getChordNotes()` algorithm (lines 468-471) using `CHORD_INTERVALS` (lines 26-31)
- **Gesture-to-notes mapping**: Track-specific logic from `interpretGesture()`:
  - Melody: Scale runs, arpeggios (lines 539-548)
  - Chords: Chord stacks, maj7 arpeggios (lines 488-492, 516-523)
  - Bass: Root+fifth, walking bass (lines 486-487, 524-530)
  - Rhythm: Rolls, fills (lines 482-485, 532-537)

**Sustain Gesture** (lines 503-515):
- Hold (≥400ms) + horizontal drag → sustained notes with velocity markers:
  - First note: velocity = 2 (accent/start)
  - Continuation: velocity = 3 (sustain marker, ADSR fade per line 824)

**CR3: Musical Output Equivalence**
All platforms shall produce **recognizably equivalent** musical output for the same pattern data:
- Identical note frequencies (A4 = 440Hz standard tuning, line 1462)
- Equivalent synthesis parameters (oscillator types, filter frequencies, ADSR envelopes from lines 1432-1456)
- Consistent drum synthesis algorithms (from lines 1176-1403)
- Identical chord voicing algorithms
- **Note**: Per NFR17, platforms may enhance audio quality while maintaining equivalence

**CR4: Pixel-Perfect Visual Consistency** ⭐ **REVISED**

All platforms shall render **mathematically identical visuals** based on `getPixelGrid()` function (lines 671-922):

**Color System** (exact hex values):
- **12 Note Colors** (`NOTE_COLORS`, lines 6-10):
  - C=#ff0000, C#=#ff4500, D=#ff8c00, D#=#ffc800, E=#ffff00, F=#9acd32, F#=#00ff00, G=#00ffaa, G#=#00ffff, A=#00aaff, A#=#0055ff, B=#8a2be2
- **4 Track Colors** (`TRACK_COLORS`, lines 14-16):
  - Melody=#f7dc6f, Chords=#4ecdc4, Bass=#45b7d1, Rhythm=#ff6b6b
- **Background**: #0a0a0a (pure black for OLED efficiency)

**Pixel Font System** (`PIXEL_FONT`, lines 50-101):
- 3×5 pixel character definitions for A-Z, 0-9, symbols
- Must render identically (pixel-for-pixel) across platforms
- Tooltip rendering via `generateTooltipPixels()` function (lines 321-352)

**Animation Timings** (must match exactly):
- Tooltip duration: 1200ms total (line 366)
- Pulse animation: 100ms (line 1506)
- Note glow: 150ms decay (implied from visual feedback)
- Playhead highlight: Instant (no fade)

**Visual Feedback Details**:
- Ghost notes: 22% opacity (#xxxxxx22 alpha, line 783)
- Muted notes: 66% opacity (#xxxxxx66, line 859)
- Accent notes (velocity=2): Full brightness (line 832)
- Sustain notes (velocity=3): ADSR fade using formula `positionInSustain < 0.4 ? 0.85 : max(0.25, 1 - positionInSustain * 0.9)` (line 824)

**Grid Layout** (exact pixel coordinates from lines 624-638, 732-737):
- Row 0: Controls (play, undo, scale, root, ghosts, BPM, length, clear)
- Row 1: Step markers (4-beat divisions)
- Rows 2-7: Melody track (6 rows)
- Rows 8-13: Chords track (6 rows)
- Rows 14-17: Bass track (4 rows)
- Rows 18-21: Rhythm track (4 rows)
- Rows 22-23: Pattern overview (track activity + note colors)

**CR5: Feature Set Parity**
All platforms shall support 100% feature equivalence with no platform-exclusive features, ensuring users can switch platforms without losing functionality or workflow familiarity.

---

## 3. User Interface Enhancement Goals

### 3.1 Integration with Existing UI

**Design System Foundation**: The React prototype establishes a complete visual design language that will be preserved across all platforms:

- **Pixel Grid Aesthetic**: 44×24 monospace pixel grid with 1px gaps creates a retro-digital aesthetic reminiscent of early music hardware
- **Dark Theme Base**: Pure black background (#0a0a0a) with vibrant color accents for maximum OLED efficiency and visual focus
- **Immersive Fullscreen**: Zero UI elements outside pixel grid canvas (FR15) - all status via tooltips
- **Color System**:
  - 12 chromatic note colors (rainbow spectrum: C=red through B=purple)
  - 4 track identity colors (melody=yellow, chords=teal, bass=blue, rhythm=red)
  - Opacity-based state indication (muted=33%, normal=66-100%, accented=100%)
- **Typography**: Custom 3×5 pixel font for all tooltips and text feedback
- **Interaction Feedback**: Immediate visual response to all gestures (pulse animations, tooltip overlays, glow effects)

**Platform-Specific Adaptations**:

**iOS Native**:
- Use SwiftUI with custom `Canvas` view for pixel grid rendering
- Leverage iOS haptic feedback (UIImpactFeedbackGenerator) on note placement and playback
- Adopt iOS safe area insets for notch/Dynamic Island devices
- Use native iOS blur effects for modal overlays (share/export, settings)
- Integrate with iOS Share Sheet for pattern export

**Standalone Web**:
- HTML5 Canvas with 2D rendering context for optimal performance
- CSS for control layout with responsive breakpoints
- Support mouse/trackpad on desktop with hover states
- Use Web Share API for pattern sharing (where supported)
- Add install prompt for PWA capability
- Implement service worker for offline support

**Shared Design Principles**:
- No platform-specific chrome/navigation (fullscreen immersive canvas)
- Identical grid proportions and spacing regardless of device size
- Consistent gesture vocabulary with platform-appropriate feedback
- Preserve exact color values and animation timings
- All status information via pixel font tooltips (no external text)

---

### 3.2 Modified/New Screens and Views

**Primary View (Grid Composer)** - *Enhanced from prototype*:
- 44×24 pixel grid canvas (rows 0-23) - **FULLSCREEN, no external UI**
- Row 0: Control strip (play/stop, undo/redo, scale/root, settings)
- Row 1: Step markers with beat/bar divisions
- Rows 2-7: Melody track grid
- Rows 8-13: Chords track grid
- Rows 14-17: Bass track grid
- Rows 18-21: Rhythm track grid
- Rows 22-23: Pattern overview (track activity + note colors)
- **Status via tooltips**: BPM, scale, length shown as pixel font overlays when changed

**New Screen: Pattern Library** - *New addition*:
- Grid-based pattern browser showing saved patterns as miniature 44×24 thumbnails
- Tap to load, long-press for options (rename, duplicate, delete, share)
- Sort by: Recently modified, Creation date, BPM, Name
- Search/filter by scale, BPM range, track usage

**New Screen: Settings/Preferences** - *New addition*:
- Audio settings: Latency mode (low/normal), master volume
- Visual settings: Ghost notes default, animation intensity
- MIDI output configuration (iOS only, optional)
- Pattern auto-save preferences
- Tutorial/gesture reference
- About/credits

**New Modal: Export/Share** - *New addition*:
- Export pattern as JSON file
- Share to other apps/users (platform share sheet)
- Generate shareable link (future: cloud hosting)

**New Modal: Import Pattern** - *New addition*:
- File picker integration (iOS: native, Web: input type=file)
- Drag-and-drop support (web only)
- Validation and error handling for corrupted files
- Preview before import

---

### 3.3 UI Consistency Requirements

**UC1: Pixel-Perfect Grid Rendering**
All platforms shall render the 44×24 grid with mathematically identical proportions. Pixel size calculation must produce identical visual results using prototype formula (lines 231-235). Grid gap shall always be 1px regardless of pixel size.

**UC2: Color Fidelity**
All platforms shall use identical hex color values from the prototype (lines 6-18). No platform-specific color adjustments or dark mode variants.

**UC3: Animation Timing Consistency**
All platforms shall use identical animation durations from prototype:
- Playhead pulse: 100ms (line 1506)
- Tooltip display: 1200ms total (line 366)
- Note trigger glow: 150ms exponential decay
- Pattern clear animation: 300ms cascading fade

**UC4: Touch Target Sizing**
Despite small pixel sizes (6-20px), all interactive elements shall meet platform accessibility guidelines:
- iOS: Minimum 44×44pt touch targets (Apple HIG)
- Web: Minimum 44×44px touch targets (WCAG 2.1)
- Solution: Extend touch hitboxes beyond visual bounds while maintaining pixel-perfect visuals

**UC5: Responsive Scaling Behavior**
All platforms shall scale the grid proportionally while maintaining aspect ratio:
- Small screens (320px): 6px pixels
- Medium screens (768px): 12-14px pixels
- Large screens (1024px+): 16-20px pixels (capped), centered layout

**UC6: Gesture Recognition Parity**
All platforms shall implement identical gesture recognition thresholds and interpretations per CR2. A user switching from web to iOS mid-composition should experience zero workflow disruption.

---

## 4. Technical Constraints and Integration Requirements

### 4.1 Existing Technology Stack

**Current Prototype (React)**:

| Component | Technology | Version | Notes |
|-----------|------------|---------|-------|
| **Language** | JavaScript (ES6+) | - | React functional components with hooks |
| **Framework** | React | 18.x | Single-component architecture (1,611 lines) |
| **UI Rendering** | React DOM | 18.x | Pixel grid rendered as CSS Grid with div elements |
| **Audio Engine** | Web Audio API | Native browser | Oscillator-based synthesis + noise generation |
| **Build Tool** | Vite | 4.x+ | Fast HMR, ES modules |
| **Styling** | Tailwind CSS | 3.x | Utility-first, responsive classes |
| **State Management** | React useState/useRef | - | Local component state, no external store |
| **Dependencies** | None | - | Zero external libraries beyond React |

**Constraints from Existing Prototype**:
- No TypeScript (plain JavaScript)
- No external audio libraries (pure Web Audio API)
- No state persistence (patterns lost on refresh)
- No backend/server integration
- Single-file monolithic component
- External UI elements (info bar, legend) - to be removed per FR15

---

### 4.2 Integration Approach

**Shared Core Logic Architecture**:

To maintain 1:1 feature parity and reduce code duplication, we use a **shared core logic layer** written in platform-agnostic code:

**Shared Modules** (TypeScript, portable to iOS via Swift translation):

1. **Music Theory Engine** (`music-theory.ts`):
   - Scale definitions and note calculations (from lines 20-24)
   - Chord interval generation (from lines 26-31)
   - Note frequency calculations (MIDI to Hz, line 1462)
   - Scale snapping logic (from lines 458-466)

2. **Gesture Interpreter** (`gesture-interpreter.ts`):
   - Gesture classification algorithms (from lines 473-605)
   - Musical pattern generation from gestures
   - Velocity calculations
   - Gesture threshold constants

3. **Pattern Data Model** (`pattern-model.ts`):
   - Pattern serialization/deserialization (JSON)
   - Track data structures (12 notes × 32 steps)
   - Undo/redo history management (50-level stack, lines 165-166, 378-404)
   - Pattern validation

4. **Synthesis Parameters** (`synthesis-params.ts`):
   - Oscillator types and filter frequencies per track (from lines 1432-1444)
   - ADSR envelope definitions
   - Drum synthesis algorithms as data/recipes (from lines 1176-1403)
   - Audio constants

**Platform-Specific Implementations**:

| Component | iOS Native | Standalone Web |
|-----------|-----------|----------------|
| **Language** | Swift 5.9+ (UI) + C/C++ (audio) | TypeScript 5.x |
| **UI Framework** | SwiftUI | React 18.x |
| **Audio Engine** | AVFoundation (C/C++ audio thread) | Web Audio API (AudioWorklet) |
| **Rendering** | SwiftUI Canvas | HTML5 Canvas 2D |
| **Storage** | FileManager (JSON files) | IndexedDB |
| **Build** | Xcode 15+ | Vite 5.x |
| **Testing** | XCTest | Vitest |

**Integration Strategies**:

**Database Integration Strategy**:
No traditional database required. Pattern storage uses:
- **iOS**: JSON files in app Documents directory, managed via FileManager
- **Web**: IndexedDB for local storage with fallback to localStorage, ServiceWorker caching for offline

**API Integration Strategy**:
No backend API required for MVP. Future cloud sync could add RESTful pattern sharing API.

**Frontend Integration Strategy**:
- **Shared Logic**: TypeScript modules compiled to JavaScript, imported directly by web app, translated to Swift protocols/structs for iOS
- **UI Layer**: Platform-native (SwiftUI vs React), both consume identical data models
- **Audio Layer**: Platform-specific but driven by shared synthesis parameter definitions

**Testing Integration Strategy**:
- **Unit Tests**: Shared logic modules tested in both Jest (web) and XCTest (iOS) to ensure identical behavior
- **Integration Tests**: Platform-specific UI/audio tests
- **Cross-Platform Validation**: Automated tests verify identical pattern output from same gesture input

---

### 4.3 Code Organization and Standards

**Repository Structure** (Monorepo):

```
pixelboop/
├── packages/
│   ├── core/                    # Shared logic (TypeScript)
│   │   ├── music-theory/
│   │   ├── gesture-interpreter/
│   │   ├── pattern-model/
│   │   └── synthesis-params/
│   ├── web/                     # Standalone web app
│   │   ├── src/
│   │   ├── public/
│   │   └── package.json
│   └── ios/                     # iOS native app
│       ├── PixelBoop/
│       ├── PixelBoop.xcodeproj
│       └── Shared/              # Swift translations of core
├── docs/
│   ├── prd.md                   # This document
│   └── architecture.md
└── package.json                 # Monorepo root
```

**Naming Conventions**:
- **Files**: `kebab-case.ts` (web), `PascalCase.swift` (iOS)
- **Functions**: `camelCase` (both platforms)
- **Constants**: `SCREAMING_SNAKE_CASE` (both platforms, e.g., `NOTE_COLORS`, `TRACK_COLORS`)
- **Types/Interfaces**: `PascalCase` (both platforms)

**Coding Standards**:
- **Web**: ESLint + Prettier, Airbnb style guide
- **iOS**: SwiftLint, Swift API Design Guidelines
- **Shared**: Strict type safety (TypeScript strict mode, Swift with minimal `any`)
- **Audio Code**: C/C++ for realtime audio (iOS), AudioWorklet for web
- **Documentation**: JSDoc for TypeScript, DocC for Swift

---

### 4.4 Deployment and Operations

**Build Process Integration**:

**iOS**:
- Xcode Cloud or local Xcode builds
- Archive → TestFlight (beta) → App Store (production)
- Code signing via Apple Developer Portal

**Web**:
- Vite build → static assets (HTML/CSS/JS)
- Asset optimization: minification, tree-shaking, code splitting
- Service worker generation for PWA

**Deployment Strategy**:

**iOS**:
- **Distribution**: Apple App Store (primary), TestFlight (beta testing)
- **Updates**: App Store review process (~1-3 days)
- **Versioning**: Semantic versioning (e.g., 1.0.0)
- **Rollback**: Phased rollout via App Store, can halt if issues detected

**Web**:
- **Hosting**: Vercel / Netlify / Cloudflare Pages (static hosting with CDN)
- **Updates**: Instant deployment, no review process
- **Rollback**: Instant rollback via hosting provider dashboard

**Monitoring and Logging**:

**iOS**:
- Crash reporting: Xcode Organizer
- Analytics: Apple App Analytics (privacy-preserving)
- Performance: Xcode Instruments, MetricKit

**Web**:
- Error tracking: Sentry (JavaScript errors, audio API failures)
- Analytics: Plausible / Fathom (privacy-friendly, GDPR-compliant)
- Performance: Web Vitals (LCP, FID, CLS), Lighthouse CI

---

### 4.5 Risk Assessment and Mitigation

**Technical Risks**:

**RISK 1: Audio Latency Inconsistency Across Platforms**
- **Impact**: High - Core product experience degraded if latency varies significantly
- **Probability**: Medium - Web Audio API has higher latency than AVFoundation
- **Mitigation**:
  - iOS: Use C/C++ audio thread with AVAudioEngine, low-latency configuration
  - Web: Implement AudioWorklet for lower latency
  - Automated latency tests in CI
  - Research sources: [Loopy HD achieved 6-7ms](https://atastypixel.com/developing-loopy-part-2-implementation/), [Buffer optimization guide](https://alistaircooper.medium.com/5-ways-to-optimize-digital-audio-systems-with-core-audio-69ce6aef0d0b)

**RISK 2: Shared Logic Divergence (TypeScript → Swift)**
- **Impact**: High - Breaks feature parity guarantee (CR5)
- **Probability**: Medium - Manual translation introduces human error
- **Mitigation**:
  - Maintain TypeScript as source of truth with 100% test coverage
  - Swift translation validated via identical test suite
  - Automated CI checks ensure test parity

**RISK 3: iOS Audio Thread Safety Violations**
- **Impact**: High - Audio glitches, crashes
- **Probability**: Medium - Swift code on audio thread causes issues
- **Mitigation**:
  - Follow [Four Cardinal Rules](https://atastypixel.com/four-common-mistakes-in-audio-development/): No locks, no Objective-C/Swift, no allocations, no I/O on audio thread
  - Use Realtime Watchdog library to catch violations
  - C/C++ for all audio processing

**Integration Risks**:

**RISK 4: Pattern Data Format Evolution Breaking Compatibility**
- **Impact**: High - Users lose access to saved patterns after updates
- **Probability**: Medium - Format will evolve with new features
- **Mitigation**:
  - Semantic versioning in pattern JSON
  - Migration functions for old formats
  - Automated tests for migration paths

**Deployment Risks**:

**RISK 5: iOS App Store Rejection**
- **Impact**: Medium - Delayed launch
- **Probability**: Low - App is straightforward music creation tool
- **Mitigation**:
  - Review Apple App Store Review Guidelines before submission
  - TestFlight beta testing before submission

**RISK 6: Web App PWA Installation Friction**
- **Impact**: Medium - Users don't realize it's installable
- **Probability**: High - PWA install prompts often dismissed
- **Mitigation**:
  - Prominent "Install" button in settings
  - Tutorial on first launch
  - Full functionality in browser without install

---

## 5. Epic and Story Structure

### 5.1 Epic Approach

**Epic Structure Decision**: **Three Sequential Epics**

**Rationale**: Three distinct platform implementations (shared core, iOS, web) that can be developed and deployed independently:

1. **Epic 1: Shared Core Logic & Data Model** - Foundation for both platforms
2. **Epic 2: iOS Native Application** - First platform implementation
3. **Epic 3: Standalone Web Application** - Second platform implementation

**Why Three Epics**:
- Independent deployment (iOS to App Store, Web to hosting)
- Parallel development potential after Epic 1
- Risk isolation (if iOS delays, web can still launch)
- Clear value milestones (each epic delivers fully functional product)

**Epic Dependency**:
```
Epic 1 (Core) ──→ Epic 2 (iOS)
              └──→ Epic 3 (Web)
```

---

## Epic 1: Shared Core Logic & Data Model

**Epic Goal**: Establish a platform-agnostic core library containing all music theory, gesture interpretation, pattern data models, and synthesis parameter definitions. This foundation ensures 100% feature parity between iOS and web platforms (CR5).

**Integration Requirements**:
- TypeScript modules with 100% test coverage
- Swift protocol definitions for iOS consumption
- JSON schema for pattern data format (CR1)

### Story 1.1: Project Foundation & Monorepo Setup

**As a** developer,
**I want** a monorepo with shared core package and CI/CD infrastructure,
**so that** I can develop shared logic with confidence it will work across platforms.

**Acceptance Criteria**:
1. Monorepo initialized with Turborepo or Nx
2. Three packages created: `@pixelboop/core`, `@pixelboop/web`, `@pixelboop/ios`
3. TypeScript configured with strict mode in `@pixelboop/core`
4. Vitest test runner configured with 100% coverage requirement
5. GitHub Actions CI runs tests on every commit
6. ESLint + Prettier configured

**Integration Verification**:
- IV1: CI pipeline runs successfully on GitHub
- IV2: All three packages build without errors
- IV3: Test coverage report generates

### Story 1.2: Music Theory Engine

**As a** developer,
**I want** a music theory module providing scale/chord/frequency calculations,
**so that** both iOS and web platforms use identical musical logic.

**Acceptance Criteria**:
1. `MusicTheory` class with methods based on prototype logic:
   - `getScaleNotes()` - From `SCALES` dictionary (lines 20-24)
   - `snapToScale()` - Algorithm from lines 458-466
   - `getChordNotes()` - Using `CHORD_INTERVALS` (lines 26-31)
   - `midiToFrequency()` - Formula from line 1462
2. Constants: `NOTE_NAMES`, `SCALES`, `CHORD_INTERVALS`
3. 100% test coverage

**Integration Verification**:
- IV1: Tests verify identical behavior to prototype
- IV2: Bundle size <5KB

### Story 1.3: Gesture Interpretation Engine

**As a** developer,
**I want** a gesture interpreter converting touch patterns into musical note sequences,
**so that** both platforms provide identical musical responses (CR2).

**Acceptance Criteria**:
1. `GestureInterpreter` class implementing logic from prototype lines 473-605:
   - `interpretGesture(start, end, track, velocity): Note[]`
   - All gesture types: tap, hold, horizontal/vertical/diagonal drag
   - Track-specific logic (melody, chords, bass, rhythm)
2. Constants: `GESTURE_THRESHOLDS` (400ms hold, 300ms double-tap, etc.)
3. 100% test coverage (48 combinations: gesture types × tracks)

**Integration Verification**:
- IV1: Output matches prototype `interpretGesture()` function
- IV2: Performance: <1ms execution time

### Story 1.4: Pattern Data Model & History Management

**As a** developer,
**I want** a pattern data model with serialization and undo/redo,
**so that** patterns can be saved/loaded across platforms (CR1).

**Acceptance Criteria**:
1. `Pattern` class: tracks (4×12×32 array), BPM, scale, rootNote, patternLength, metadata
2. Methods: `toJSON()`, `fromJSON()`, `clone()`
3. `PatternHistory` class: `push()`, `undo()`, `redo()` (50-level max, lines 165-166, 378-404)
4. JSON schema validation
5. 100% test coverage

**Integration Verification**:
- IV1: Serialized patterns <50KB (NFR14)
- IV2: History operations <5ms

### Story 1.5: Synthesis Parameter Definitions

**As a** developer,
**I want** exact synthesis parameters from prototype,
**so that** platforms produce equivalent audio (CR3, NFR17).

**Acceptance Criteria**:

1. **Track Parameters** (from `playNote()`, lines 1406-1460):

| Track | Oscillator | Filter | Attack | Release | Code Ref |
|-------|-----------|---------|---------|----------|----------|
| Melody | sine | 2000Hz lowpass | 0.01s | min(dur*0.3, 0.15s) | L1434-1435 |
| Chords | triangle | 1500Hz lowpass | 0.01s | min(dur*0.3, 0.15s) | L1438-1439 |
| Bass | sawtooth | 400Hz lowpass | 0.01s | min(dur*0.3, 0.15s) | L1442-1444 |

2. **Sustain ADSR** (velocity=3, line 824):
   - Fade formula: `positionInSustain < 0.4 ? 0.85 : max(0.25, 1 - positionInSustain * 0.9)`

3. **Drum Recipes** (from `playDrum()`, lines 1176-1403):
   - All 12 drums documented: kick, kick2, lowTom, snare, snare2, rimshot, clap, closedHat, openHat, crash, ride, cowbell
   - Each with algorithm details (frequencies, durations, envelopes)

4. **Note Frequency**: `440 * Math.pow(2, (midiNote - 69) / 12)` (line 1462)

5. Export as `SYNTHESIS_PARAMS` and `DRUM_RECIPES` constants

**Integration Verification**:
- IV1: Values verified against prototype code
- IV2: Listening test: Platforms sound recognizably equivalent
- IV3: Platforms may enhance quality per NFR17 while maintaining equivalence

### Story 1.6: Swift Protocol Definitions for iOS

**As a** developer,
**I want** Swift protocols mirroring TypeScript interfaces,
**so that** iOS can consume shared logic through strongly-typed interfaces.

**Acceptance Criteria**:
1. Swift protocols in `ios/Shared/CoreProtocols.swift`:
   - `MusicTheoryProtocol`, `GestureInterpreterProtocol`, `PatternModelProtocol`
2. Swift structs: `Note`, `Pattern`, `GestureInput`, `SynthParams`
3. Protocol methods match TypeScript signatures
4. Xcode project compiles without errors
5. Unit test scaffolding created

**Integration Verification**:
- IV1: Swift protocols compile in Xcode 15+
- IV2: Signatures match TypeScript exactly

**Epic 1 Complete**: Shared core with 100% test coverage, ready for platform implementation.

---

## Epic 2: iOS Native Application (REVISED)

**Epic Goal**: Build native iOS app with <10ms audio latency (NFR1), offline capability (NFR5), and iOS-native polish. Uses **realtime-safe C/C++ audio architecture** per industry best practices.

**Integration Requirements**:
- Swift for UI, C/C++ for audio thread
- AVFoundation audio engine
- SwiftUI Canvas rendering
- FileManager persistence

### Story 2.1: iOS Project Setup & Core Integration

**Acceptance Criteria**:
1. Xcode project created: `PixelBoop.xcodeproj`
2. Swift package dependency: `@pixelboop/core`
3. Core protocol implementations (Swift)
4. Unit tests pass (match TypeScript behavior)
5. **App runs on physical iOS device** (not just simulator)
6. **Audio test tone plays on iPhone** (validates audio stack)
7. Build configurations: Debug, Release, TestFlight

**Integration Verification**:
- IV1: Swift tests pass (same as TypeScript)
- IV2: Runs on iOS 15+ physical devices
- IV3: Test tone plays without errors

### Story 2.1a: Audio Thread Safety Architecture ⭐ NEW

**As a** iOS developer,
**I want** realtime-safe C/C++ audio separate from Swift UI,
**so that** I achieve professional audio without glitches.

**Acceptance Criteria**:
1. **C/C++ audio files**: `AudioEngine.cpp`, `Synthesis.c`
2. **Four cardinal rules enforced** ([source](https://atastypixel.com/four-common-mistakes-in-audio-development/)):
   - ❌ No locks on audio thread
   - ❌ No Objective-C/Swift on audio thread
   - ❌ No memory allocation on audio thread
   - ❌ No I/O on audio thread
3. Pre-allocated buffer pool (3-buffer strategy)
4. Swift wrapper: `AudioEngineWrapper.swift`
5. **Realtime Watchdog** library integrated
6. Documentation: thread separation explained

**Integration Verification**:
- IV1: Realtime Watchdog runs clean
- IV2: Audio callbacks <1ms (Instruments)
- IV3: Swift UI triggers sounds safely

**References**: [Four Common Mistakes](https://atastypixel.com/four-common-mistakes-in-audio-development/), [Low Latency iOS](https://medium.com/@jim.tompkins/low-latency-audio-in-ios-e4814fac2225)

### Story 2.2: Pixel Grid Rendering System

**Acceptance Criteria**:
1. `PixelGridView.swift` using SwiftUI `Canvas`
2. Grid: 44×24 with 1pt gaps (UC1)
3. Dynamic pixel sizing (prototype formula, lines 231-235)
4. Responsive to device size (iPhone SE to Pro Max + iPad)
5. Safe area insets (notch, Dynamic Island)
6. Colors: 12 note + 4 track (CR4, lines 6-18)
7. 60 FPS (NFR3)
8. Row 0: Control placeholders

**Integration Verification**:
- IV1: Grid proportions match prototype (44:24 ratio)
- IV2: 60 FPS on iPhone 12+ (Instruments)
- IV3: Colors match hex values (visual QA)

### Story 2.3: Touch Gesture Recognition

**Acceptance Criteria**:
1. `GestureRecognizer.swift` handles UIKit touches
2. All gestures from FR3: tap, hold, drag, double-tap, shake
3. Touch coordinates → grid row/col
4. Pass to `GestureEngine` from Epic 1
5. Visual feedback: white preview overlay
6. Haptic feedback (`UIImpactFeedbackGenerator`)
7. Thresholds match prototype (CR2)

**Integration Verification**:
- IV1: Tap (10,5) → GestureEngine receives (10,5)
- IV2: Hold 500ms → velocity=2 detected
- IV3: Response <16ms (NFR4)

### Story 2.4: Pattern Data Persistence

**Acceptance Criteria**:
1. `PatternStorage.swift` using FileManager
2. Patterns saved to Documents as JSON
3. Auto-save (debounced 500ms)
4. Pattern list view (grid thumbnails)
5. Load, delete patterns
6. Export via iOS Share Sheet
7. Import via document picker
8. Default pattern on first launch

**Integration Verification**:
- IV1: Pattern persists after force quit
- IV2: Export→import on different device works (CR1)
- IV3: Storage <50KB per pattern (NFR14)

### Story 2.5a: Basic AVAudioEngine Synthesis ⭐ SPLIT

**Acceptance Criteria**:
1. **C++ AudioEngine** class with AVAudioEngine
2. Audio session: `.playback` category, low-latency
3. **Oscillator synthesis** (C functions): sine, triangle, sawtooth
4. **Drum synthesis** (12 sounds, C implementations from Story 1.5)
5. Basic ADSR envelopes (velocity 1/2/3)
6. **Swift wrapper** exposes `playNote()`
7. Audio plays on **physical device**

**Integration Verification**:
- IV1: Tap grid → hear tone
- IV2: Drum sounds work
- IV3: No glitches (realtime-safe validated)

### Story 2.5b: Audio Latency Optimization & Profiling ⭐ NEW

**Acceptance Criteria**:
1. **Buffer size optimization** ([source](https://alistaircooper.medium.com/5-ways-to-optimize-digital-audio-systems-with-core-audio-69ce6aef0d0b)):
   - Use `AVAudioSession.setPreferredIOBufferDuration()`
   - Test 64, 128, 256 samples at 44.1kHz
   - Target: 64-128 samples = 1.5-6ms latency
2. **Latency measurement** (not estimation):
   - Hardware loopback test OR oscilloscope
   - Document measured latency
3. Audio session mode tuning (`.lowLatency` vs `.default`)
4. CPU optimization: <20% during playback
5. Zero dropouts (5-min stress test)
6. **Achieve <10ms roundtrip** (NFR1)

**Integration Verification**:
- IV1: **Measured latency <10ms** on iPhone 12+ (documented)
- IV2: CPU <20% (Energy Instruments)
- IV3: No dropouts

**References**: [Loopy HD 6-7ms](https://atastypixel.com/developing-loopy-part-2-implementation/), [Buffer guide](https://alistaircooper.medium.com/5-ways-to-optimize-digital-audio-systems-with-core-audio-69ce6aef0d0b)

### Story 2.6: Playback Engine & Sequencer

**Acceptance Criteria**:
1. `Sequencer.swift` implements playback
2. Timer-based step advancement (60-200 BPM)
3. Play/stop button
4. Visual playhead moves
5. Note triggering (calls C++ AudioEngine)
6. Sustain notes (velocity=3 don't retrigger)
7. Mute/solo respected
8. Seamless looping
9. Background playback

**Integration Verification**:
- IV1: 120 BPM plays at exactly 120 BPM
- IV2: No drift after 100 loops
- IV3: CPU <10% during playback

### Story 2.7: Track Controls & Visual Feedback

**Acceptance Criteria**:
1. Track controls: mute (col 0), solo (col 1)
2. Mute/solo logic
3. Visual feedback: playhead pulse (100ms), note glow (150ms), step markers
4. Ghost notes toggle (22% opacity, line 783)
5. Pattern overview rows (22-23)
6. Tooltips using pixel font (lines 50-101)
7. All animations 60 FPS

**Integration Verification**:
- IV1: Mute melody → audio stops, others continue
- IV2: Solo bass → only bass plays
- IV3: Animations synced with audio

### Story 2.7a: Immersive Grid-Only Interface ⭐ NEW

**Acceptance Criteria**:
1. **Remove external UI**:
   - ❌ Info bar (prototype lines 1537-1543) - DELETE
   - ❌ Legend (lines 1585-1607) - DELETE
   - ✅ Grid fills viewport (100%)
2. **Dynamic status tooltips** (pixel font):
   - BPM: "120 BPM" (centered, 1200ms)
   - Scale: "C MAJOR" / "D MINOR" / "E PENTA"
   - Length: "16 STEPS" / "32 STEPS"
   - Root: "ROOT: F#"
   - Clear: "CLEARED!"
   - Undo/Redo: "<<UNDO" / "REDO>>"
3. **Gesture tooltips** (existing, lines 103-133): TAP, ACCENT!, ARPEGGIO, etc.
4. **First-launch tutorial** (optional):
   - "TAP TO PLAY!" (5s) → "DRAG FOR MELODY!" (3s) → dismiss
   - Stored in UserDefaults, show once
5. Fullscreen optimization (no browser chrome on mobile)

**Integration Verification**:
- IV1: No UI outside 44×24 canvas
- IV2: Adjust BPM → "120 BPM" tooltip appears, fades
- IV3: Info bar/legend removed

### Story 2.8: Musical Controls & Undo/Redo

**Acceptance Criteria**:
1. Scale selectors (row 0, cols 7-9)
2. Root note picker (cols 11-22)
3. BPM controls (cols 26-28, range 60-200, step 5)
4. Pattern length (cols 30-32, values 8-32)
5. Undo/redo buttons (cols 4-5, 50-level history)
6. Double-swipe gestures (left=undo, right=redo)
7. Haptic feedback
8. Tooltips on all controls

**Integration Verification**:
- IV1: Change scale → notes snap
- IV2: Undo 5× → redo 5× → returns to original
- IV3: Double-swipe left → undo works

### Story 2.9: Settings Screen & Pattern Management

**Acceptance Criteria**:
1. Settings button (gear icon)
2. Settings sheet: audio latency mode, master volume, ghost notes default, animation intensity, about
3. Pattern library button
4. Pattern library: grid thumbnails, sort (recent/name/BPM), search/filter, tap/long-press actions
5. New pattern button
6. Rename pattern

**Integration Verification**:
- IV1: Change latency → buffer size changes
- IV2: 20 patterns → scrolls at 60 FPS
- IV3: Share → Mail/Messages receive JSON

### Story 2.10: iOS Polish & Extended TestFlight Beta ⭐ REVISED

**Acceptance Criteria**:
1. App icon (1024×1024 + all sizes)
2. Launch screen
3. Metadata: name, bundle ID, version 1.0.0
4. Privacy manifest: no data collection
5. App Store metadata: description, screenshots, keywords, age 4+
6. **Extended TestFlight: 4-8 weeks with 20-50 musicians** ([90-day max](https://developer.apple.com/testflight/)):
   - Week 1-2: Internal (5-10 testers)
   - Week 3-6: External beta (20-50 musicians)
   - Week 7-8: Bug fix sprint
7. **Stability**: No critical bugs in final 2 weeks
8. Accessibility: VoiceOver labels

**Integration Verification**:
- IV1: Passes App Store review guidelines
- IV2: Beta feedback from musicians collected
- IV3: Zero critical bugs final 2 weeks

**Epic 2 Complete**: iOS app with <10ms latency, realtime-safe audio, 4-8 week beta tested, App Store ready.

**Effort**: ~110-130 hours (~2.5-3 weeks)

---

## Epic 3: Standalone Web Application

**Epic Goal**: Build production web app with PWA support (NFR6), <20ms audio latency (NFR2), and pixel-perfect parity with iOS (CR2, CR4, CR5).

**Integration Requirements**:
- TypeScript + React 18.x
- Shared core from Epic 1
- HTML5 Canvas rendering
- Web Audio API with AudioWorklet
- IndexedDB persistence
- Service Worker for PWA

### Story 3.1: Web App Setup & Core Integration

**Acceptance Criteria**:
1. Vite project: `@pixelboop/web`
2. TypeScript strict mode
3. React 18.x + React DOM
4. Shared core: `@pixelboop/core` imported
5. TypeScript imports: `MusicTheoryEngine`, `GestureInterpreter`, `PatternModel`
6. Vite config: output `dist/` with inline CSS/JS
7. Dev server: `localhost:5173`
8. Build: <500KB bundle

**Integration Verification**:
- IV1: Core modules import successfully
- IV2: `npm run build` outputs <500KB
- IV3: Dev hot-reload <1s

### Story 3.2: Canvas-Based Pixel Grid Rendering

**Acceptance Criteria**:
1. **HTML5 Canvas** (performance upgrade from CSS Grid):
   - `<canvas>` with 2D context
   - Render via `context.fillRect()` per pixel
   - Double-buffering
2. Grid layout identical to prototype (lines 671-922)
3. Responsive: 320px-2048px
4. Canvas accounts for `devicePixelRatio` (Retina)
5. Colors exact (CR4, lines 6-18)
6. Pixel font rendering (lines 50-101) on canvas
7. 60 FPS (NFR3): `requestAnimationFrame` loop

**Integration Verification**:
- IV1: Pixel-perfect match to prototype (screenshot)
- IV2: 60 FPS in Chrome DevTools
- IV3: Renders correctly on Retina

### Story 3.3: Touch & Mouse Gesture Recognition

**Acceptance Criteria**:
1. Unified gesture system (mouse + touch)
2. Gesture detection (matches lines 473-605, 970-1110)
3. Canvas coordinate mapping
4. Visual feedback: preview, tooltips
5. Desktop enhancements: hover, keyboard shortcuts (lines 426-448)
6. Mobile optimization: prevent defaults, fast-tap

**Integration Verification**:
- IV1: Tap (10,5) → GestureInterpreter (10,5)
- IV2: Hold 500ms → velocity=2
- IV3: Mouse and touch produce identical gestures

### Story 3.4: Pattern Data Persistence (IndexedDB)

**Acceptance Criteria**:
1. IndexedDB: `PixelBoopDB`, store `patterns`
2. Auto-save (debounced 500ms)
3. Pattern library: thumbnails, sort, load/delete/duplicate/rename
4. Export/Import (CR1): JSON file via `Blob`, file input
5. Web Share API (mobile)
6. Default pattern first-time

**Integration Verification**:
- IV1: Pattern persists after close tab
- IV2: Export→import in different browser works (CR1)
- IV3: IndexedDB <50KB per pattern (NFR14)

### Story 3.5: Web Audio API Synthesis Engine

**Acceptance Criteria**:
1. AudioContext setup (init on first user interaction for iOS Safari)
2. **AudioWorklet** for synthesis: `SynthesizerWorklet.js`
3. Track synthesis (Story 1.5 parameters):
   - Oscillators + BiquadFilters per track
   - Drums: AudioBuffer noise + filtering
4. Audio quality enhancements (NFR17, optional): reverb, compressor
5. Latency target: <20ms (NFR2)

**Integration Verification**:
- IV1: Web vs iOS sounds equivalent (listening test)
- IV2: Latency <20ms (Chrome DevTools Performance)
- IV3: CPU <15% during playback

### Story 3.6: Audio Latency Optimization (Web)

**Acceptance Criteria**:
1. `AudioContext({ latency: 'interactive' })`
2. AudioWorklet (lower latency than ScriptProcessor)
3. Buffer size tuning: test 128, 256, 512 samples
4. Latency compensation: loopback test, document per-browser
5. Browser-specific: Chrome (128), Safari (256), Firefox compatibility
6. **Achieve <20ms** (NFR2): input (~5ms) + processing (~5ms) + output (~10ms)

**Integration Verification**:
- IV1: <20ms on Chrome 90+, Safari 14+, Firefox 88+ (NFR16)
- IV2: Latency documented in README
- IV3: No glitches

### Story 3.7: Playback Engine & Sequencer

**Acceptance Criteria**:
1. **Web Audio Clock** (not `setInterval`): `AudioContext.currentTime`
2. Look-ahead scheduling (~100ms)
3. Sequencer: play/stop, visual playhead
4. Note scheduling: precise trigger times
5. Sustain notes (velocity=3 don't retrigger)
6. Loop precision: no gap, drift monitoring
7. Background playback (tab backgrounded)

**Integration Verification**:
- IV1: 120 BPM exactly (metronome)
- IV2: No drift after 1000 loops
- IV3: Background: audio continues, CPU minimal

### Story 3.7a: Immersive Grid-Only Interface (Web)

**Acceptance Criteria**:
1. **Remove external UI** (same as iOS 2.7a)
2. **Dynamic tooltips**: BPM, scale, length (canvas pixel font)
3. **PWA fullscreen**: meta viewport, request fullscreen API
4. Browser chrome: auto-hide address bar (mobile), centered (desktop)
5. First-launch tutorial (localStorage flag)

**Integration Verification**:
- IV1: No UI outside canvas
- IV2: PWA installed → fullscreen
- IV3: Desktop: centered, responsive

### Story 3.8: PWA Support & Offline Capability

**Acceptance Criteria**:
1. **Web App Manifest** (`manifest.json`): name, icons, display fullscreen, theme #0a0a0a
2. **Service Worker** (`sw.js`): cache-first, offline fallback
3. Install prompt: button triggers `beforeinstallprompt`
4. Offline: app loads, patterns work, audio works
5. Update: service worker detects new version, prompts reload

**Integration Verification**:
- IV1: Install PWA → home screen icon
- IV2: No network → app works (create/play patterns)
- IV3: New version → update prompt

### Story 3.9: Cross-Browser Testing & Polyfills

**Acceptance Criteria**:
1. Target browsers (NFR16): Chrome 90+, Safari 14+, Firefox 88+, Edge 90+
2. Feature detection: AudioContext, AudioWorklet, IndexedDB, ServiceWorker
3. Polyfills/fallbacks:
   - AudioWorklet → ScriptProcessor
   - IndexedDB → localStorage
   - Web Share → download link
4. Browser-specific fixes: Safari suspend, Firefox buffer size
5. Error handling: unsupported browser message
6. Automated testing: BrowserStack / Playwright

**Integration Verification**:
- IV1: Works on all target browsers
- IV2: Audio on Safari iOS works
- IV3: PWA installs on Android Chrome + iOS Safari

### Story 3.10: Production Build & Deployment

**Acceptance Criteria**:
1. Production build: code splitting, Brotli+Gzip, minification, <500KB
2. Hosting: Vercel / Netlify / Cloudflare Pages with CDN, HTTPS
3. CI/CD: GitHub Actions, auto-deploy on merge to `main`, preview deployments
4. Performance: Lighthouse 90+, Web Vitals (LCP <2.5s, FID <100ms, CLS <0.1)
5. Domain: `pixelboop.app`, OG tags, favicon
6. Analytics: Plausible / Fathom (privacy-friendly, no cookies)

**Integration Verification**:
- IV1: Production deploys, loads <2s on 4G
- IV2: Lighthouse 90+ (Performance, A11y, Best Practices, SEO)
- IV3: PWA installs tracked

**Epic 3 Complete**: Production web app with PWA, <20ms latency, Canvas 60 FPS, cross-browser compatible, deployed with CDN.

**Effort**: ~90-110 hours (~2-2.5 weeks)

---

## Project Summary

### All Three Epics Complete

**Epic 1**: Shared Core Logic (35 hours)
**Epic 2**: iOS Native App (110-130 hours)
**Epic 3**: Standalone Web App (90-110 hours)

**Total Project**: ~235-275 hours (~6-7 weeks for small team, or 12-14 weeks for solo developer)

### Key Deliverables

✅ **iOS Native App**:
- <10ms audio latency (measured, not estimated)
- Realtime-safe C/C++ audio architecture
- 4-8 week musician beta testing
- App Store ready

✅ **Standalone Web App**:
- <20ms audio latency
- PWA with offline support
- HTML5 Canvas 60 FPS rendering
- Cross-browser compatible
- Production deployed with CDN

✅ **Shared Core**:
- Platform-agnostic TypeScript modules
- 100% test coverage
- Swift protocol definitions
- JSON pattern format for cross-platform sharing

✅ **Critical Requirements Met**:
- **CR2**: Identical gesture system across platforms (code references from prototype)
- **CR4**: Pixel-perfect visual consistency (exact colors, fonts, animations)
- **CR5**: 100% feature parity (no platform-exclusive features)
- **FR15**: Immersive grid-only interface (no external UI elements)
- **NFR17**: Audio quality prioritized (platforms may enhance while maintaining equivalence)

---

## Next Steps

### For Architect

Review this PRD and create technical architecture document including:
- Detailed monorepo structure
- API contracts between shared core and platforms
- Audio architecture diagrams (iOS C/C++ thread model, Web AudioWorklet)
- Pattern JSON schema specification
- Testing strategy (unit, integration, cross-platform validation)

### For UX Expert

Not needed for MVP - visual design is fully specified in prototype (`prototype_sequencer.jsx`). All UI/UX decisions captured in:
- CR4 (color system, pixel font, animations)
- FR15 (grid-only interface, tooltip status display)
- Story 2.7a / 3.7a (immersive interface implementation)

### For Development Team

**Epic 1** (Core) can start immediately.
**Epic 2** (iOS) and **Epic 3** (Web) can proceed in parallel after Epic 1 completes.

**Key Reference**: All implementations should reference `prototype_sequencer.jsx` line numbers documented throughout this PRD for validation.

---

**End of PRD**