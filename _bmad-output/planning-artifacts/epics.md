---
stepsCompleted: [1, 2, 3, 4]
validationComplete: true
readyForDevelopment: true
inputDocuments:
  - _bmad-output/prd.md
  - _bmad-output/planning-artifacts/architecture.md
  - _bmad-output/planning-artifacts/ux-design-specification.md
  - docs/prototype_sequencer.jsx
---

# pixelboop - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for pixelboop, decomposing the requirements from the PRD, Architecture, UX Design, and working prototype into implementable stories.

## Requirements Inventory

### Functional Requirements

**Pattern Creation & Editing (FR1-FR11):**
- FR1: Users can place single notes on the grid by tapping pixels
- FR2: Users can create accented notes by holding then tapping (≥400ms hold)
- FR3: Users can create arpeggios by dragging horizontally across the grid
- FR4: Users can create chords by dragging vertically across the grid
- FR5: Users can create melodic phrases by dragging diagonally across the grid
- FR6: Users can create sustained notes with ADSR envelopes by holding and dragging
- FR7: Users can erase individual steps by double-tapping
- FR8: Users can clear all tracks by performing a scrub gesture (rapid left-right motion)
- FR9: Users can create patterns from 8 to 32 steps in length
- FR10: Users can edit patterns across 4 independent tracks (melody, chords, bass, rhythm)
- FR11: Users can create multi-touch gestures simultaneously on different tracks

**Audio Synthesis & Playback (FR12-FR19):**
- FR12: System can synthesize notes in real-time with track-specific timbres (sine, triangle, sawtooth)
- FR13: System can synthesize 12 distinct drum sounds for rhythm track
- FR14: System can apply velocity levels to notes (normal, accent, sustain)
- FR15: System can render ADSR envelope fades for sustained notes
- FR16: System can play patterns in a continuous loop
- FR17: Users can start and stop pattern playback
- FR18: System can maintain audio playback when application is backgrounded (iOS)
- FR19: System can handle audio session interruptions (calls, notifications)

**Musical Intelligence (FR20-FR24):**
- FR20: System can constrain note placement to selected musical scale (major, minor, pentatonic)
- FR21: Users can select from 12 chromatic root notes
- FR22: System can automatically voice chords based on vertical gestures
- FR23: System can generate bass patterns using root and fifth intervals
- FR24: System can ensure all user input produces musically valid results

**Pattern Management (FR25-FR32):**
- FR25: Users can save patterns to local storage
- FR26: Users can load previously saved patterns
- FR27: Users can browse their pattern library
- FR28: System can automatically save pattern changes
- FR29: Users can export patterns as JSON files
- FR30: Users can export patterns to device file system (iOS Files app)
- FR31: System can import patterns created on other platforms (cross-platform compatibility)
- FR32: System can preserve pattern metadata (name, creation date, BPM, scale)

**History & Reversibility (FR33-FR36):**
- FR33: Users can undo their last 50 actions
- FR34: Users can redo previously undone actions
- FR35: Users can undo by double-swiping left
- FR36: Users can redo by double-swiping right

**Visual Feedback & Interface (FR37-FR45):**
- FR37: System can display a 44×24 pixel grid interface
- FR38: System can render color-coded notes based on chromatic pitch
- FR39: System can display a visual playhead during pattern playback
- FR40: System can show dynamic status tooltips (BPM, scale, pattern length) using pixel font
- FR41: System can display gesture-specific tooltips (TAP, ACCENT, ARPEGGIO, CHORD, SUSTAIN, etc.)
- FR42: System can show pulse animations synchronized to tempo
- FR43: System can display ghost notes for gesture previews
- FR44: System can provide step markers and pattern overview visualization
- FR45: System can render all visual elements at 60 FPS on target devices

**Control & Configuration (FR46-FR53):**
- FR46: Users can adjust tempo from 60 to 200 BPM
- FR47: Users can select musical scale type (major, minor, pentatonic)
- FR48: Users can select root note from chromatic scale
- FR49: Users can adjust pattern length (8, 16, 24, 32 steps)
- FR50: Users can mute individual tracks
- FR51: Users can solo individual tracks
- FR52: Users can toggle ghost note visibility
- FR53: Users can use keyboard shortcuts for common actions (Space=play/stop, Cmd+Z=undo, Delete=clear, Arrows=BPM)

**Track Management (FR54-FR59):**
- FR54: Users can create independent musical content on melody track
- FR55: Users can create independent musical content on chords track
- FR56: Users can create independent musical content on bass track
- FR57: Users can create independent musical content on rhythm/drums track
- FR58: System can visually distinguish tracks through color coding
- FR59: Users can view volume indicators per track

**Offline & Storage (FR60-FR63):**
- FR60: System can function completely offline without network connectivity
- FR61: System can store patterns in local device storage
- FR62: System can preserve user preferences across sessions
- FR63: System can maintain 50-level undo history in memory during active session

**Haptic Feedback (FR64-FR66) - iOS Native:**
- FR64: System can provide tactile feedback on note placement (iOS)
- FR65: System can provide distinct haptic responses for different gesture types (iOS)
- FR66: System can synchronize haptic pulses to beat during playback (iOS)

### NonFunctional Requirements

**Performance Requirements:**
- NFR1: Visual rendering at 60 FPS on target devices
- NFR2: Audio latency <10ms tap-to-sound (iOS native), <20ms (web)
- NFR3: Battery consumption <5% drain per 30 minutes active use (iOS)
- NFR4: App size <50MB download (iOS)
- NFR5: Crash-free rate >99.5% sessions

**iOS App Store Compliance (Mandatory 2024+):**
- NFR6: Privacy Manifest (PrivacyInfo.xcprivacy) file declaring zero data collection
- NFR7: Privacy Manifest must declare UserDefaults API usage with approved reason CA92.1
- NFR8: VoiceOver labels on all interactive controls
- NFR9: VoiceOver announces pattern playback state
- NFR10: VoiceOver describes grid interactions
- NFR11: Settings screen supports Dynamic Type
- NFR12: Color contrast meets WCAG 2.1 AA standards (4.5:1 normal, 3:1 large text)
- NFR13: Accessibility Nutrition Labels declare supported features
- NFR14: Development with Xcode 16+
- NFR15: Built with iOS 18+ SDK
- NFR16: Deployment target iOS 15+
- NFR17: Swift 5.9+ language version
- NFR18: Background audio mode declared in UIBackgroundModes
- NFR19: Audio session configured for background playback
- NFR20: IPv6 compatibility (automatic - no network calls)
- NFR21: App icons in all required sizes
- NFR22: Launch screen provided
- NFR23: Screenshots for required device sizes (6.7", 6.5", 5.5" iPhones)
- NFR24: App Preview video (30 seconds demonstrating gesture system)
- NFR25: Privacy Policy URL provided
- NFR26: Internal TestFlight beta (1-2 weeks, 5-10 testers)
- NFR27: External TestFlight beta (4-8 weeks, 20-50 musicians)
- NFR28: Zero critical bugs in final 2 weeks of beta

**Cross-Platform Requirements:**
- NFR29: Pattern JSON format matches web version exactly
- NFR30: Gesture interpretation produces identical musical output across platforms
- NFR31: Pattern export from web imports successfully to iOS
- NFR32: Shared musical intelligence algorithms (scale snapping, chord voicing)

**Security & Privacy:**
- NFR33: Local-only storage (no cloud sync in MVP)
- NFR34: Zero data collection (no analytics, no tracking)
- NFR35: Privacy Nutrition Label: "Data Not Collected"
- NFR36: COPPA compliant (safe for children under 13)

**UX Performance Requirements:**
- NFR37: First gesture produces musically satisfying result within 2 minutes of first use
- NFR38: Gesture recognition accuracy ≥95%
- NFR39: Audio synthesis produces no pops, clicks, or glitches
- NFR40: Visual feedback synchronized with audio events (<16ms lag)
- NFR41: Haptic feedback triggers within 10ms of gesture recognition (iOS)

### Additional Requirements

**From Architecture Document:**

**Starter Template:**
- Xcode SwiftUI App Template with iOS 18+ SDK
- Swift 5.9+ with C++17 hybrid architecture
- MVVM architecture with SwiftUI + UIKit hybrid for pixel grid
- C/C++ audio engine for <10ms latency requirement
- Lock-free ring buffer for thread-safe main↔audio communication

**Project Structure:**
```
PixelBoop/
├── App/ (entry point, root navigation)
├── Models/ (Pattern, Track, Note, GestureState, MusicalConstants)
├── ViewModels/ (SequencerViewModel, GestureInterpreter, PatternLibraryViewModel, HistoryManager)
├── Views/ (SequencerView, PixelGridView, PixelGridUIView, ControlRowView, TooltipOverlay)
├── Services/ (AudioEngineService, HapticsService, StorageService)
├── Audio/ (C++ audio engine: AudioEngine, Oscillators, DrumSynth, ADSREnvelope, LockFreeRingBuffer)
├── Resources/ (Assets, PrivacyInfo.xcprivacy, Info.plist)
├── Supporting/ (Bridging header, Constants)
└── Tests/ (Unit tests, UI tests)
```

**Thread Safety Requirements:**
- Main thread → Audio thread: Lock-free ring buffer, atomic writes only
- Audio thread → Main thread: Publish on main queue via DispatchQueue.main.async
- Audio thread NEVER allocates, locks, or calls Swift runtime
- All UI state changes on main thread only

**Audio Architecture:**
- AVFoundation with C/C++ audio callback for real-time synthesis
- Buffer size: 256 samples @ 44.1kHz = 5.8ms latency
- No allocations, locks, or Swift calls on audio thread
- Lock-free ring buffer for pattern state communication

**From UX Design Specification:**

**Core UX Principles:**
- Visual-audio equivalence: Grid IS the music made visible
- Gesture expresses intent, not precision (forgiveness over pixel-perfect)
- Discovery through progressive depth (hidden features for dopamine rewards)
- Instant gratification, earned mastery
- Patterns over pixels (gestural vocabulary, not manual editing)

**Discovery-Driven UX Requirements:**
- Basic gestures visible via contextual tooltips (TAP, CHORD, ARPEGGIO)
- Advanced gestures hidden for discovery (SUSTAIN, SCRUB, SWIPE-UNDO)
- Visual affordances hint at possibilities without explicit instruction
- No forced tutorials - learning through experimentation

**Multi-Sensory Feedback Loop:**
- Tactile: Touch gestures with haptic feedback (iOS)
- Visual: Color-coded notes, pulse animations, playhead, ghost notes
- Audio: Real-time synthesis with <10ms latency

**Gesture Language as Composable System:**
- New features emerge from combining existing gesture primitives
- No mode switches or menu navigation
- Gesture state machine supports multi-step hold sequences
- Visual feedback indicates gesture "mode" progression

**From Prototype (prototype_sequencer.jsx):**

**Proven Implementation Patterns:**
- 44×24 pixel grid with 1px gaps between pixels
- Row allocation: Row 0 (controls), Row 1 (step markers), Rows 2-7 (melody), Rows 8-13 (chords), Rows 14-17 (bass), Rows 18-21 (rhythm), Rows 22-23 (overview)
- Gesture timing thresholds: <300ms tap, ≥400ms hold
- Scale snapping algorithm proven functional
- Chord voicing intervals: major [0,4,7], minor [0,3,7], maj7 [0,4,7,11], min7 [0,3,7,10]
- Drum mapping: 12 distinct drum types (kick, snare, clap, hats, crash, ride, cowbell, etc.)
- Velocity system: 1=normal, 2=accent, 3=sustain continuation with ADSR fade
- 3×5 pixel font for tooltips

### FR Coverage Map

**Epic 1: Instant Music Creation**
- FR1: Place single notes by tapping pixels
- FR12: Synthesize notes with track-specific timbres
- FR13: Synthesize 12 drum sounds for rhythm
- FR16: Play patterns in continuous loop
- FR17: Start and stop playback
- FR37: Display 44×24 pixel grid
- FR38: Render color-coded notes by pitch
- FR45: Render at 60 FPS

**Epic 2: Gesture Vocabulary**
- FR2: Create accented notes (hold ≥400ms then tap)
- FR3: Create arpeggios (horizontal drag)
- FR4: Create chords (vertical drag)
- FR5: Create melodies (diagonal drag)
- FR6: Create sustained notes with ADSR (hold+drag)
- FR7: Erase steps (double-tap)
- FR8: Clear all tracks (scrub gesture)
- FR9: Pattern length 8-32 steps
- FR14: Apply velocity levels (normal, accent, sustain)
- FR15: Render ADSR envelope fades

**Epic 3: Musical Intelligence**
- FR20: Constrain to selected scale (major, minor, pentatonic)
- FR21: Select from 12 chromatic root notes
- FR22: Automatically voice chords
- FR23: Generate bass patterns (root and fifth)
- FR24: Ensure musically valid results

**Epic 4: Multi-Track Composition**
- FR10: Edit across 4 independent tracks
- FR11: Multi-touch gestures on different tracks
- FR50: Mute individual tracks
- FR51: Solo individual tracks
- FR54: Create content on melody track
- FR55: Create content on chords track
- FR56: Create content on bass track
- FR57: Create content on rhythm track
- FR58: Visually distinguish tracks (color coding)
- FR59: View volume indicators per track

**Epic 5: Visual Feedback & Discovery**
- FR39: Display visual playhead during playback
- FR40: Show dynamic status tooltips (BPM, scale, length) using pixel font
- FR41: Display gesture-specific tooltips (TAP, ACCENT, ARPEGGIO, CHORD, SUSTAIN)
- FR42: Show pulse animations synchronized to tempo
- FR43: Display ghost notes for gesture previews
- FR44: Provide step markers and pattern overview

**Epic 6: Song Structure Intelligence (Basic MVP)**
- FR94: System recognizes musical characteristics (chorus vs verse energy/density)
- FR95: Bottom row blocks represent song sections (intro/verse/chorus/bridge/drop/outro)
- FR96: Intelligent auto-copy with musical variation
- FR97: User navigates between song sections gesturally
- FR98: System suggests song structure based on patterns
- FR99: User overrides/customizes intelligence suggestions
- FR100: Song structure visualization in overview rows
- FR101: Genre/style detection for structural suggestions

**Epic 7: Pattern Library & Export**
- FR25: Save patterns to local storage
- FR26: Load previously saved patterns
- FR27: Browse pattern library
- FR28: Automatically save pattern changes
- FR29: Export patterns as JSON files
- FR30: Export to device file system (iOS Files app)
- FR31: Import patterns from other platforms (cross-platform)
- FR32: Preserve pattern metadata (name, date, BPM, scale)

**Epic 8: History & Reversibility**
- FR33: Undo last 50 actions
- FR34: Redo previously undone actions
- FR35: Undo by double-swiping left
- FR36: Redo by double-swiping right

**Epic 9: Customization & Configuration**
- FR46: Adjust tempo (60-200 BPM)
- FR47: Select musical scale type
- FR48: Select root note from chromatic scale
- FR49: Adjust pattern length (8, 16, 24, 32 steps)
- FR52: Toggle ghost note visibility
- FR53: Keyboard shortcuts (Space, Cmd+Z, Delete, Arrows)
- FR62: Preserve user preferences across sessions

**Epic 10: iOS Native Polish**
- FR18: Background audio playback (iOS)
- FR19: Audio session interruption handling
- FR64: Tactile feedback on note placement (iOS)
- FR65: Distinct haptic responses per gesture type (iOS)
- FR66: Beat-synchronized haptic pulses during playback (iOS)

**Epic 11: Offline-First Architecture**
- FR60: Function completely offline
- FR61: Store patterns in local device storage
- FR63: Maintain 50-level undo history in memory

**Epic 12: MIDI & External Audio Connectivity (Phase 3)**
- FR67: MIDI output per track (4 tracks independently)
- FR68: Per-track MIDI channel selection (1-16)
- FR69: Bluetooth MIDI output
- FR70: USB MIDI output
- FR71: USB audio output
- FR72: MIDI input from external controllers
- FR73: Bluetooth MIDI input
- FR74: MIDI Clock send/receive
- FR75: Transport control (start/stop/continue)
- FR76: Ableton Link sync
- FR77: Clock source selection

**Epic 13: Live Performance & Hardware Integration (Phase 3)**
- FR78: MIDI file export
- FR79: Project save/load with full song state
- FR80: Audio bounce to WAV/MP3
- FR81: Hardware controller support (Erae Touch 2, Launchpad, Push)
- FR82: MPE support for expressive control
- FR83: Controller mapping configuration
- FR84: Scene launching and pattern switching
- FR85: Performance mode with accidental-clear protection
- FR86: WLED output (WiFi LED control)
- FR87: sACN/Art-Net output (network LED panels)
- FR88: DMX lighting control (stage fixtures)
- FR89: Instrument LED guides
- FR90: Protocol support (WLED, sACN, Art-Net, DMX512)
- FR91: Multiple oscillators, filters, effects
- FR92: Audio input for sampling
- FR93: Per-track sound design

## Epic List

### Epic 1: Instant Music Creation
**User Outcome:** Users can tap pixels on the grid and immediately hear synthesized sound, with real-time playback loop.

**FRs covered:** FR1, FR12-13, FR16-17, FR37-38, FR45

**Implementation Notes:**
- 44×24 pixel grid with basic tap gesture
- Single track (melody) to start
- Real-time audio synthesis (<10ms iOS, <20ms web)
- Continuous loop playback
- Visual playhead

**Value Delivered:** Users get immediate dopamine hit - tap, hear music, feel creative.

---

### Epic 2: Gesture Vocabulary for Musical Expression
**User Outcome:** Users can create complex musical patterns using rich gesture vocabulary (accents, arpeggios, chords, melodies, sustains, erase, clear).

**FRs covered:** FR2-9, FR14-15

**Implementation Notes:**
- Hold-then-tap for accents (≥400ms)
- Horizontal drag for arpeggios
- Vertical drag for chords
- Diagonal drag for melodies
- Hold+drag for ADSR sustains
- Double-tap erase, scrub gesture clear
- Pattern length configuration (8, 16, 24, 32 steps)

**Value Delivered:** Users can express musical intent naturally through gestures, not pixel-perfect editing.

---

### Epic 3: Musical Intelligence & Scale Snapping
**User Outcome:** Everything users create sounds musically coherent - notes snap to selected scales, chords voice automatically, bass patterns use intervals.

**FRs covered:** FR20-24

**Implementation Notes:**
- Scale selection (major, minor, pentatonic)
- 12 chromatic root notes
- Automatic chord voicing (major [0,4,7], minor [0,3,7], maj7, min7)
- Bass patterns using root and fifth intervals
- All input produces valid musical results

**Value Delivered:** Users sound like musicians even if they're not - discovery through experimentation.

---

### Epic 4: Multi-Track Composition
**User Outcome:** Users can create layered compositions across 4 independent tracks (melody, chords, bass, rhythm) with mute/solo control.

**FRs covered:** FR10-11, FR50-51, FR54-59

**Implementation Notes:**
- 4 tracks with distinct row allocation (melody: 2-7, chords: 8-13, bass: 14-17, rhythm: 18-21)
- Track-specific timbres (sine, triangle, sawtooth)
- 12 drum sounds for rhythm track
- Multi-touch gestures on different tracks simultaneously
- Per-track mute/solo control
- Color-coded visual distinction

**Value Delivered:** Users can build rich, layered musical arrangements.

---

### Epic 5: Visual Feedback & Discovery System
**User Outcome:** Users receive rich visual feedback showing what's happening, with contextual tooltips that reveal features progressively.

**FRs covered:** FR39-44

**Implementation Notes:**
- Animated playhead during playback
- Contextual tooltips using 3×5 pixel font (BPM, scale, pattern length)
- Gesture-specific tooltips (TAP, ACCENT, ARPEGGIO, CHORD, SUSTAIN)
- Tempo-synchronized pulse animations
- Ghost note previews during gestures
- Step markers and pattern overview visualization
- Discovery-driven UX (basic gestures visible, advanced hidden)

**Value Delivered:** Users understand the system and discover advanced features through dopamine-rewarding exploration.

---

### Epic 6: Song Structure Intelligence (Basic MVP)
**User Outcome:** Users discover/uncover complete songs with intro/verse/chorus/bridge/drop/outro structure - the system intelligently guides them from loops to finished compositions.

**FRs covered:** FR94-101

**Implementation Notes (Basic MVP Scope):**
- **Pattern Recognition (Rule-Based):**
  - Chorus: High note density (>60% grid filled), multiple tracks active
  - Verse: Lower density (<40% filled), melodic focus
  - Intro/Outro: Sparse patterns, single track, lower energy
  - Bridge: Different harmonic content, track combination changes

- **Section Visualization:** Bottom rows (22-23) with color coding:
  - Intro (blue), Verse (green), Chorus (yellow), Bridge (purple), Drop (red), Outro (gray)
  - Pixel-font labels: "INTRO", "VERSE", "CHORU", "BRIDG", "DROP", "OUTRO"

- **Simple Copy-with-Variation:**
  - Chorus → Verse: Reduce velocity 30%, thin out bass/drums
  - Chorus → Bridge: Shift melody notes, change rhythm pattern
  - Verse → Outro: Fade out tracks, simplify to melody only

- **Section Navigation:**
  - Tap bottom row to jump to section
  - Hold to rename/relabel section
  - Drag to rearrange order

- **Basic Song Flow Suggestion:**
  - After 2+ patterns created: "TRY: INTRO → VERSE → CHORUS"
  - User can accept (auto-arrange) or ignore (manual)

**Advanced Features (Phase 2/3 - defer):**
- AI/ML genre detection (EDM vs pop vs hip-hop)
- Intelligent arrangement based on full pattern listening
- Automatic section generation from single pattern
- Advanced variation (harmonic substitution, rhythmic complexity)

**Design Challenges:**
- Balance opinionated suggestions vs user control
- Gesture vocabulary for section navigation/editing
- Real-time pattern analysis without disrupting flow
- Visualizing structure without cluttering 44×24 grid

**Success Criteria:**
Users feel they're **discovering/uncovering** a complete song rather than manually building loops. If users manually decide loop counts, copy/paste sequences, or arrange sections, the intelligence has failed.

**Value Delivered:** PixelBoop becomes the "Intelligent Composer" - transforms loop creation into complete song composition, teaching arrangement through AI-assisted discovery. Immediate differentiation from simple loop sequencers.

---

### Epic 7: Pattern Library & Export
**User Outcome:** Users can save patterns locally, browse their library, export/import as JSON for cross-platform compatibility and sharing.

**FRs covered:** FR25-32

**Implementation Notes:**
- Local device storage for patterns
- Pattern library browser interface
- Automatic save on changes
- JSON export with metadata (name, date, BPM, scale, root)
- iOS Files app integration for export
- Cross-platform import (web patterns work on iOS)
- Pattern metadata preservation

**Value Delivered:** Users can build a library of creations and share with others.

---

### Epic 8: History & Reversibility
**User Outcome:** Users can experiment freely with 50-level undo/redo, including gesture-based undo/redo (double-swipe left/right).

**FRs covered:** FR33-36

**Implementation Notes:**
- 50-level undo stack in active session
- Redo functionality for undone actions
- Double-swipe left gesture for undo
- Double-swipe right gesture for redo
- Memory-based undo history (session-scoped)

**Value Delivered:** Users can experiment without fear of losing work - creative freedom.

---

### Epic 9: Customization & Configuration
**User Outcome:** Users can personalize their experience with tempo control (60-200 BPM), scale/root selection, pattern length, ghost note visibility, and keyboard shortcuts.

**FRs covered:** FR46-49, FR52-53, FR62

**Implementation Notes:**
- BPM slider (60-200 BPM)
- Scale type selector (major, minor, pentatonic)
- Root note selector (12 chromatic notes)
- Pattern length selector (8, 16, 24, 32 steps)
- Ghost note visibility toggle
- Keyboard shortcuts (Space=play/stop, Cmd+Z=undo, Delete=clear, Arrows=BPM)
- Preferences persistence across sessions

**Value Delivered:** Users can tailor the experience to their workflow and musical preferences.

---

### Epic 10: iOS Native Polish & Integration
**User Outcome:** iOS users experience native platform integration with haptic feedback, background audio playback, audio interruption handling, VoiceOver accessibility, and App Store compliance.

**FRs covered:** FR18-19, FR64-66

**NFRs covered:** NFR6-27 (Privacy Manifest, VoiceOver, accessibility, SDK requirements, background modes, App Store requirements)

**Implementation Notes:**
- Privacy Manifest (PrivacyInfo.xcprivacy) declaring zero data collection
- Haptic feedback on note placement (distinct responses per gesture type)
- Beat-synchronized haptic pulses during playback
- Background audio mode (UIBackgroundModes)
- Audio session interruption handling (calls, notifications)
- VoiceOver labels on all controls
- VoiceOver pattern playback announcements
- Dynamic Type support in settings
- WCAG 2.1 AA color contrast
- App icons, launch screen, screenshots
- Internal & external TestFlight beta programs

**Value Delivered:** iOS users get a polished, native-feeling experience that respects platform conventions.

---

### Epic 11: Offline-First Architecture
**User Outcome:** Users can create music completely offline with local storage, no network dependency, and zero data collection for privacy.

**FRs covered:** FR60-63

**NFRs covered:** NFR33-36 (local-only storage, zero data collection, Privacy Nutrition Label, COPPA compliance)

**Implementation Notes:**
- No network calls or cloud dependencies
- All patterns stored in local device storage
- Zero analytics or tracking
- Privacy Nutrition Label: "Data Not Collected"
- COPPA compliant (safe for children under 13)
- 50-level undo history maintained in memory during session

**Value Delivered:** Users have complete privacy and can create anywhere without network connectivity.

---

### Epic 12: MIDI & External Audio Connectivity (Phase 3)
**User Outcome:** Users can integrate PixelBoop with professional studio equipment - trigger external synths via MIDI per track, sync tempo with DAWs and hardware, connect wirelessly via Bluetooth, and route audio through professional interfaces.

**FRs covered:** FR67-77

**Implementation Notes:**
- Per-track MIDI output with independent channel selection (1-16)
- Bluetooth MIDI (wireless to synths, iOS apps, hardware)
- USB MIDI (wired via Lightning/USB-C)
- USB audio output to external interfaces
- Bidirectional MIDI input from controllers
- Global sync: MIDI Clock (send/receive, master/slave), Transport (start/stop/continue), Ableton Link
- Clock source selection: Internal, External MIDI, Ableton Link
- **UX Constraint:** All MIDI/audio configuration via pixel-only interface (no external settings screens)

**Value Delivered:** PixelBoop becomes a serious studio tool - gesture-based composition interface controlling any external sound source, integrated into professional workflows.

---

### Epic 13: Live Performance & Hardware Integration (Phase 3)
**User Outcome:** Users can perform live with hardware controllers (Erae Touch 2, Launchpad, Push), trigger stage lighting synchronized to music, export patterns to DAWs, and switch scenes without accidental clearing.

**FRs covered:** FR78-93

**Implementation Notes:**
- **Export:** MIDI file export for DAWs, audio bounce to WAV/MP3, full project save/load
- **Hardware Controllers:** Bidirectional control (Erae Touch 2, Launchpad, Push), MPE support for expressive control, pixel-UI based controller mapping
- **Live Performance:** Scene launching, pattern switching, performance mode (accidental-clear protection)
- **Lighting Output:** WLED (WiFi LED strips), sACN/E1.31/Art-Net (network LED panels), DMX512 (wired stage fixtures), instrument LED guides, protocol support for all major lighting standards
- **Synthesis Expansion:** Multiple oscillators/filters/effects, audio input for sampling, per-track sound design

**Value Delivered:** PixelBoop becomes a live performance instrument - hardware integration, visual stage production, scene management, and professional audio export.

---

## Epic Stories

### Epic 1: Instant Music Creation

#### Story 1.1: Render 44×24 Pixel Grid Canvas

As a **user**,
I want **to see a 44-column by 24-row pixel grid when I open the app**,
So that **I have a visual canvas for music creation**.

**Acceptance Criteria:**

**Given** the app is launched for the first time
**When** the interface loads
**Then** a 44×24 pixel grid is displayed filling the viewport
**And** pixels have 1px gaps between them
**And** the grid uses dark background (#0a0a0a)
**And** the grid scales responsively based on device size (6-20px pixels)
**And** rendering maintains 60 FPS (FR45)

---

#### Story 1.2: Single Note Placement with Tap Gesture

As a **user**,
I want **to tap any pixel on the melody track to place a note**,
So that **I can start creating musical patterns immediately**.

**Acceptance Criteria:**

**Given** the pixel grid is displayed
**When** I tap a pixel in rows 2-7 (melody track)
**Then** a colored note appears at that grid position (FR1)
**And** the note is color-coded by chromatic pitch (FR38)
**And** the tap gesture completes in <300ms
**And** only one note can exist per step (column) on the melody track
**And** tapping the same position again toggles the note off

---

#### Story 1.3: Real-Time Audio Synthesis for Melody Notes

As a **user**,
I want **to hear synthesized sound immediately when notes trigger**,
So that **I get instant audio feedback on my musical creation**.

**Acceptance Criteria:**

**Given** notes are placed on the melody track
**When** the playback engine triggers a note
**Then** a sine wave tone is synthesized (FR12)
**And** the frequency matches the note's chromatic pitch (A4=440Hz)
**And** audio latency is <10ms on iOS, <20ms on web (NFR1, NFR2)
**And** the tone has a 2000Hz lowpass filter
**And** ADSR envelope: attack 0.01s, release min(duration*0.3, 0.15s)
**And** audio plays without pops, clicks, or glitches (NFR39)

---

#### Story 1.4: Continuous Playback Loop with Visual Playhead

As a **user**,
I want **to press play and hear my pattern loop continuously**,
So that **I can listen to the music I've created**.

**Acceptance Criteria:**

**Given** notes are placed on the melody track
**When** I press the play button (row 0, col 2-3)
**Then** the pattern plays from step 0 to pattern end (FR16)
**And** playback loops seamlessly back to step 0 (FR16)
**And** a visual playhead highlights the current step (FR39)
**And** the playhead moves in sync with audio timing
**And** pressing stop halts playback immediately (FR17)
**And** playback maintains exact tempo with zero drift

---

#### Story 1.5: Color-Coded Note Rendering by Chromatic Pitch

As a **user**,
I want **notes to display in different colors based on their pitch**,
So that **I can visually distinguish between different notes**.

**Acceptance Criteria:**

**Given** notes are placed on the melody track
**When** the grid is rendered
**Then** each note displays with its chromatic color (FR38):
- C=#ff0000 (red), C#=#ff4500, D=#ff8c00, D#=#ffc800
- E=#ffff00 (yellow), F=#9acd32, F#=#00ff00 (green)
- G=#00ffaa, G#=#00ffff (cyan), A=#00aaff (blue)
- A#=#0055ff, B=#8a2be2 (purple)
**And** note colors match the prototype exactly (CR4)
**And** colors remain consistent across all device displays

---

### Epic 2: Gesture Vocabulary for Musical Expression

#### Story 2.1: Accented Notes with Hold-Then-Tap Gesture

As a **user**,
I want **to create accented notes by holding for ≥400ms then tapping**,
So that **I can add dynamic emphasis to my patterns**.

**Acceptance Criteria:**

**Given** the grid is displayed
**When** I hold my finger on the grid for ≥400ms then tap a pixel
**Then** an accented note is placed with velocity=2 (FR2)
**And** the accented note displays at full brightness (100% opacity)
**And** the accented note plays at 2× volume compared to normal notes (FR14)
**And** a tooltip "ACCENT!" appears during the gesture (FR41)
**And** haptic feedback confirms the accent (iOS only, FR65)

---

#### Story 2.2: Arpeggios with Horizontal Drag Gesture

As a **user**,
I want **to drag horizontally across the grid to create arpeggios**,
So that **I can quickly create melodic runs**.

**Acceptance Criteria:**

**Given** the grid is displayed
**When** I drag horizontally (absDx > absDy * 1.3) across melody track
**Then** a scale-snapped arpeggio is created across the dragged steps (FR3)
**And** notes follow the selected scale (major/minor/pentatonic)
**And** the gesture creates a musical run pattern
**And** a tooltip "ARPEGGIO" appears during the gesture (FR41)
**And** all notes are placed in a single gesture without lifting finger

---

#### Story 2.3: Chords with Vertical Drag Gesture

As a **user**,
I want **to drag vertically on the chords track to create stacked notes**,
So that **I can build harmonic content quickly**.

**Acceptance Criteria:**

**Given** the grid is displayed
**When** I drag vertically (absDy > absDx * 1.3) on chords track (rows 8-13)
**Then** automatically voiced chord notes are placed (FR4, FR22)
**And** chord uses intervals from selected scale (major [0,4,7], minor [0,3,7])
**And** chord notes stack vertically on the same step
**And** a tooltip "CHORD" appears during the gesture (FR41)
**And** triangle wave synthesis is used for chord playback (FR12)

---

#### Story 2.4: Melodic Phrases with Diagonal Drag Gesture

As a **user**,
I want **to drag diagonally to create melodic phrases with pitch variation**,
So that **I can compose expressive melodies**.

**Acceptance Criteria:**

**Given** the grid is displayed
**When** I drag diagonally across the melody track
**Then** notes are placed following the diagonal path (FR5)
**And** pitch changes follow the vertical component of the drag
**And** timing follows the horizontal component
**And** notes are scale-snapped to the selected musical scale
**And** a tooltip "PHRASE" appears during the gesture (FR41)

---

#### Story 2.5: Sustained Notes with Hold-and-Drag Gesture

As a **user**,
I want **to hold and drag to create sustained notes with ADSR fade**,
So that **I can add long pads and sustained tones**.

**Acceptance Criteria:**

**Given** the grid is displayed
**When** I hold (≥400ms) and drag horizontally
**Then** the first note is placed with velocity=2 (accent) (FR6)
**And** continuation notes are placed with velocity=3 (sustain markers) (FR15)
**And** sustain notes render ADSR fade using formula: `positionInSustain < 0.4 ? 0.85 : max(0.25, 1 - positionInSustain * 0.9)`
**And** sustain notes don't retrigger during playback (continuous tone)
**And** a tooltip "SUSTAIN" appears during the gesture (FR41)

---

#### Story 2.6: Erase Steps with Double-Tap Gesture

As a **user**,
I want **to double-tap a pixel to erase the note at that step**,
So that **I can quickly remove unwanted notes**.

**Acceptance Criteria:**

**Given** notes exist on the grid
**When** I tap the same pixel twice within 300ms
**Then** all notes at that step (column) are erased (FR7)
**And** the erase applies to the specific track I tapped
**And** a tooltip "ERASE" appears after the double-tap
**And** haptic feedback confirms the erase (iOS only)

---

#### Story 2.7: Clear All Tracks with Scrub Gesture

As a **user**,
I want **to rapidly move left-right to clear all tracks at once**,
So that **I can start fresh without multiple delete actions**.

**Acceptance Criteria:**

**Given** notes exist on the grid
**When** I perform a scrub gesture (5+ direction changes within 500ms)
**Then** all notes are cleared from all 4 tracks (FR8)
**And** a tooltip "~SCRUB CLEAR~" appears (FR41)
**And** a satisfying animation shows the clear (cascading fade, 300ms)
**And** the action is added to the undo history
**And** haptic feedback confirms the clear (iOS only)

---

#### Story 2.8: Pattern Length Configuration (8-32 Steps)

As a **user**,
I want **to adjust the pattern length from 8 to 32 steps**,
So that **I can create patterns of different durations**.

**Acceptance Criteria:**

**Given** the grid is displayed
**When** I use the pattern length controls (row 0, cols 30-32)
**Then** pattern length can be set to 8, 16, 24, or 32 steps (FR9)
**And** the playhead loops at the selected pattern length
**And** step markers (row 1) update to show active steps
**And** a tooltip displays "16 STEPS" when changed (FR40)
**And** notes beyond the new length are preserved (not deleted) for undo

---

### Epic 3: Musical Intelligence & Scale Snapping

#### Story 3.1: Scale Selection (Major, Minor, Pentatonic)

As a **user**,
I want **to select a musical scale from major, minor, or pentatonic**,
So that **all notes I place sound harmonically correct**.

**Acceptance Criteria:**

**Given** the grid is displayed
**When** I use the scale selector (row 0, cols 7-9)
**Then** I can choose major, minor, or pentatonic scale (FR20, FR47)
**And** a tooltip displays "C MAJOR", "D MINOR", or "E PENTA" when changed (FR40)
**And** all future note placements snap to the selected scale
**And** existing notes are not changed (scale applies prospectively)
**And** the scale selection persists across sessions (FR62)

---

#### Story 3.2: Root Note Selection (12 Chromatic Notes)

As a **user**,
I want **to select a root note from all 12 chromatic notes (C through B)**,
So that **I can compose in any key**.

**Acceptance Criteria:**

**Given** the grid is displayed
**When** I use the root note picker (row 0, cols 11-22)
**Then** I can select any of 12 chromatic notes: C, C#, D, D#, E, F, F#, G, G#, A, A#, B (FR21, FR48)
**And** a tooltip displays "ROOT: F#" when changed (FR40)
**And** the selected scale transposes to the new root note
**And** all future note placements use the new root note
**And** the root note selection persists across sessions (FR62)

---

#### Story 3.3: Automatic Chord Voicing for Vertical Gestures

As a **user**,
I want **chords to voice automatically based on the selected scale**,
So that **I always get harmonically correct chords without music theory knowledge**.

**Acceptance Criteria:**

**Given** a scale and root note are selected
**When** I create a vertical drag gesture on the chords track
**Then** chord notes are voiced using scale intervals (FR22):
- Major scale: [0, 4, 7] semitone intervals
- Minor scale: [0, 3, 7] semitone intervals
- Maj7 chords: [0, 4, 7, 11]
- Min7 chords: [0, 3, 7, 10]
**And** all chord notes belong to the selected scale
**And** chord voicing follows the prototype algorithm (lines 468-471, 26-31)

---

#### Story 3.4: Bass Pattern Generation (Root and Fifth)

As a **user**,
I want **bass patterns to automatically use root and fifth intervals**,
So that **I get musically correct bass lines that support the harmony**.

**Acceptance Criteria:**

**Given** a scale and root note are selected
**When** I create gestures on the bass track (rows 14-17)
**Then** vertical gestures create root + fifth bass patterns (FR23)
**And** bass notes use sawtooth synthesis with 400Hz lowpass filter (FR12)
**And** bass patterns follow the selected scale
**And** the fifth interval is scale-appropriate (perfect fifth or diminished)

---

#### Story 3.5: Musical Validity Enforcement (Scale Snapping)

As a **user**,
I want **all input to automatically snap to the selected scale**,
So that **everything I create sounds musically valid** (FR24).

**Acceptance Criteria:**

**Given** a scale and root note are selected
**When** I place any note on any track using any gesture
**Then** the note pitch snaps to the nearest scale tone
**And** the snap algorithm searches ±5 semitones for closest match
**And** the snap algorithm matches the prototype (lines 458-466)
**And** no dissonant or out-of-scale notes can be created
**And** the snapping is immediate and imperceptible to the user

---

### Epic 4: Multi-Track Composition

#### Story 4.1: Four Independent Track Editing

As a **user**,
I want **to create patterns across 4 independent tracks (melody, chords, bass, rhythm)**,
So that **I can build layered musical compositions**.

**Acceptance Criteria:**

**Given** the grid is displayed with row allocation:
- Melody: rows 2-7
- Chords: rows 8-13
- Bass: rows 14-17
- Rhythm: rows 18-21
**When** I place notes on any track
**Then** each track maintains independent note data (FR10)
**And** tracks use distinct timbres (sine, triangle, sawtooth, drums) (FR12)
**And** tracks are visually color-coded (FR58):
- Melody=#f7dc6f (yellow)
- Chords=#4ecdc4 (teal)
- Bass=#45b7d1 (blue)
- Rhythm=#ff6b6b (red)

---

#### Story 4.2: Multi-Touch Gestures on Different Tracks

As a **user**,
I want **to use multiple fingers to edit different tracks simultaneously**,
So that **I can work efficiently across the full composition**.

**Acceptance Criteria:**

**Given** the grid supports multi-touch
**When** I touch multiple tracks at the same time
**Then** gestures are interpreted independently per track (FR11)
**And** each finger creates notes on its respective track
**And** multi-touch gestures do not interfere with each other
**And** up to 4 simultaneous touches are supported (one per track)

---

#### Story 4.3: Track Mute Control

As a **user**,
I want **to mute individual tracks to hear the rest of the arrangement**,
So that **I can isolate and focus on specific parts**.

**Acceptance Criteria:**

**Given** tracks have notes and playback is active
**When** I tap the mute control for a track (row 0, left edge)
**Then** the selected track stops producing audio (FR50)
**And** muted tracks display notes at 66% opacity (dimmed)
**And** mute state is indicated visually in row 0
**And** mute state persists until toggled off
**And** multiple tracks can be muted simultaneously

---

#### Story 4.4: Track Solo Control

As a **user**,
I want **to solo a single track to hear it in isolation**,
So that **I can focus on editing one part without distraction**.

**Acceptance Criteria:**

**Given** tracks have notes and playback is active
**When** I tap the solo control for a track (row 0, left edge)
**Then** only the soloed track produces audio (FR51)
**And** non-soloed tracks display notes at 10% opacity
**And** solo state is indicated visually in row 0
**And** pressing solo on another track switches the solo
**And** disabling solo restores all tracks to normal playback

---

#### Story 4.5: Rhythm Track with 12 Synthesized Drum Sounds

As a **user**,
I want **a dedicated rhythm track with distinct drum sounds for each row**,
So that **I can create drum patterns without external samples**.

**Acceptance Criteria:**

**Given** the rhythm track is rows 18-21 (4 rows = 12 drums across 3 pitches)
**When** I place notes on the rhythm track
**Then** each grid position triggers a specific drum sound (FR13, FR57):
- Kick, Kick2, Low Tom (row 18)
- Snare, Snare2, Rimshot (row 19)
- Clap, Closed Hat, Open Hat (row 20)
- Crash, Ride, Cowbell (row 21)
**And** drum synthesis matches the prototype algorithms (lines 1176-1403)
**And** drums use noise generation + filtering (no samples)
**And** drum sounds are recognizable and musically usable

---

#### Story 4.6: Track-Specific Content Creation (Melody, Chords, Bass)

As a **user**,
I want **each melodic track to have appropriate gestures and synthesis**,
So that **I can create content that suits each track's role**.

**Acceptance Criteria:**

**Given** the grid with 3 melodic tracks
**When** I create gestures on each track
**Then** melody track (FR54):
- Uses sine wave synthesis
- 6-note vertical range (rows 2-7)
- Supports arpeggios, runs, phrases
**And** chords track (FR55):
- Uses triangle wave synthesis
- 6-note vertical range (rows 8-13)
- Auto-voices chords, supports maj7 arpeggios
**And** bass track (FR56):
- Uses sawtooth synthesis with 400Hz lowpass
- 4-note vertical range (rows 14-17)
- Creates root+fifth patterns, walking bass

---

#### Story 4.7: Per-Track Volume Indicators

As a **user**,
I want **to see visual volume indicators for each track**,
So that **I can monitor the mix balance**.

**Acceptance Criteria:**

**Given** playback is active
**When** notes trigger on any track
**Then** a volume indicator visualizes the track's activity (FR59)
**And** indicators respond in real-time to note triggers
**And** indicators show relative volume levels
**And** indicators are displayed in the pattern overview rows (22-23)

---

### Epic 5: Visual Feedback & Discovery System

#### Story 5.1: Animated Playhead During Playback

As a **user**,
I want **to see a moving playhead showing the current playback position**,
So that **I can visually follow along with the music**.

**Acceptance Criteria:**

**Given** playback is active
**When** the pattern plays
**Then** a visual playhead highlights the current step/column (FR39)
**And** the playhead moves in perfect sync with audio timing
**And** the playhead renders as a vertical highlight across all tracks
**And** the playhead resets to step 0 when the loop restarts
**And** playhead rendering maintains 60 FPS (FR45)

---

#### Story 5.2: Dynamic Status Tooltips (BPM, Scale, Length)

As a **user**,
I want **status information to appear as pixel-font tooltips when I change settings**,
So that **I get feedback without cluttering the grid with permanent UI**.

**Acceptance Criteria:**

**Given** the grid is displayed
**When** I adjust BPM, scale, or pattern length
**Then** a centered tooltip appears using 3×5 pixel font (FR40):
- BPM: "120 BPM"
- Scale: "C MAJOR", "D MINOR", "E PENTA"
- Length: "16 STEPS", "32 STEPS"
**And** tooltips display for 1200ms then fade
**And** tooltips use the PIXEL_FONT character set (prototype lines 50-101)
**And** tooltips are centered on the grid for visibility

---

#### Story 5.3: Gesture-Specific Tooltips

As a **user**,
I want **to see tooltips indicating which gesture I'm performing**,
So that **I learn the gesture vocabulary through discovery**.

**Acceptance Criteria:**

**Given** I'm performing gestures on the grid
**When** each gesture is recognized
**Then** an appropriate tooltip appears (FR41):
- TAP, ACCENT!, ARPEGGIO, RUN, CHORD, WALK
- ROLL, PHRASE, FILL, MULTI, ROOT+5
- ERASE, CLEARED!, ~SCRUB CLEAR~
- <<UNDO, REDO>>, SUSTAIN
**And** tooltips appear during the gesture action
**And** tooltips use 3×5 pixel font rendering
**And** tooltips help users discover advanced gestures organically

---

#### Story 5.4: Tempo-Synchronized Pulse Animations

As a **user**,
I want **to see pulse animations on note triggers synchronized to the tempo**,
So that **I get visual confirmation of musical events**.

**Acceptance Criteria:**

**Given** playback is active
**When** a note triggers
**Then** a pulse animation plays at that grid position (FR42)
**And** the pulse duration is 100ms (prototype line 1506)
**And** pulses are synchronized to the exact moment of audio playback
**And** pulse brightness corresponds to note velocity
**And** pulses maintain 60 FPS rendering

---

#### Story 5.5: Ghost Notes for Gesture Previews

As a **user**,
I want **to see ghost note previews while performing gestures**,
So that **I can see what will be created before committing**.

**Acceptance Criteria:**

**Given** I'm dragging to create a gesture
**When** my finger moves across the grid
**Then** ghost notes appear showing the preview (FR43)
**And** ghost notes render at 22% opacity
**And** ghost notes update in real-time as the gesture changes
**And** ghost notes disappear if the gesture is cancelled
**And** ghost notes become solid when the gesture completes
**And** I can toggle ghost note visibility via settings (FR52)

---

#### Story 5.6: Step Markers and Pattern Overview

As a **user**,
I want **to see step markers showing beat divisions and pattern overview**,
So that **I understand the rhythmic structure at a glance**.

**Acceptance Criteria:**

**Given** the grid is displayed
**When** viewing the interface
**Then** row 1 displays step markers with 4-beat divisions (FR44)
**And** rows 22-23 display pattern overview showing:
- Track activity indicators
- Note color previews for each step
- Overall pattern density visualization
**And** overview updates in real-time as notes are edited
**And** overview helps navigate the full pattern quickly

---

### Epic 6: Song Structure Intelligence (Basic MVP)

#### Story 6.1: Pattern Density Analysis for Section Recognition

As a **user**,
I want **the system to analyze pattern density and recognize section types**,
So that **my loops are automatically categorized as verse, chorus, etc**.

**Acceptance Criteria:**

**Given** I create a pattern with notes across tracks
**When** the pattern is analyzed
**Then** the system calculates note density per track (FR94):
- Chorus: >60% grid filled, multiple tracks active, repeated patterns
- Verse: <40% filled, melodic focus, rhythmic variation
- Intro/Outro: Sparse patterns (<30%), single track focus, lower energy
- Bridge: Different harmonic content, track combination changes
**And** section type is determined using rule-based heuristics
**And** analysis happens in real-time without disrupting workflow
**And** section labeling is displayed in bottom overview rows

---

#### Story 6.2: Section Visualization in Bottom Overview Rows

As a **user**,
I want **to see song sections represented in the bottom rows with color coding**,
So that **I understand the song structure at a glance** (FR95, FR100).

**Acceptance Criteria:**

**Given** patterns are created and analyzed
**When** viewing the grid
**Then** rows 22-23 display section blocks with color coding:
- Intro: blue
- Verse: green
- Chorus: yellow
- Bridge: purple
- Drop: red
- Outro: gray
**And** pixel-font labels display: "INTRO", "VERSE", "CHORU", "BRIDG", "DROP", "OUTRO"
**And** sections are visually distinct and easy to identify
**And** tapping a section block jumps playback to that section (FR97)

---

#### Story 6.3: Intelligent Pattern Variation (Copy-with-Variation)

As a **user**,
I want **the system to suggest variations when I copy a pattern**,
So that **I can quickly create verse/bridge sections from my chorus** (FR96).

**Acceptance Criteria:**

**Given** I have created a chorus pattern
**When** I trigger a copy-with-variation gesture
**Then** the system generates intelligent variations:
- Chorus → Verse: Reduce velocity 30%, thin out bass/drums, lower energy
- Chorus → Bridge: Shift melody notes by scale degrees, change rhythm pattern
- Verse → Outro: Fade out tracks progressively, simplify to melody only
**And** variations maintain musical coherence with the source
**And** I can preview variations before accepting
**And** variations are musically appropriate for the target section type

---

#### Story 6.4: Gestural Section Navigation

As a **user**,
I want **to navigate between song sections using gestures on the bottom rows**,
So that **I can move through my complete song efficiently** (FR97).

**Acceptance Criteria:**

**Given** multiple sections exist in the song
**When** I interact with the bottom overview rows (22-23)
**Then** tapping a section block jumps playback to that section
**And** holding a section block allows renaming/relabeling (FR99)
**And** dragging section blocks rearranges the song order (FR99)
**And** all navigation happens without leaving the grid interface
**And** haptic feedback confirms navigation actions (iOS)

---

#### Story 6.5: Basic Song Flow Suggestions

As a **user**,
I want **the system to suggest a complete song structure after I create 2+ patterns**,
So that **I'm guided toward a finished composition** (FR98).

**Acceptance Criteria:**

**Given** I have created 2 or more distinct patterns
**When** the system analyzes my work
**Then** a tooltip suggestion appears: "TRY: INTRO → VERSE → CHORUS"
**And** I can tap to accept the suggestion (auto-arranges sections)
**And** I can dismiss the suggestion (manual arrangement)
**And** suggestions are contextual based on what sections exist
**And** suggested flow follows standard song structures
**And** accepting a suggestion is reversible via undo

---

### Epic 7: Pattern Library & Export

#### Story 7.1: Save Pattern to Local Storage

As a **user**,
I want **to save my current pattern with a name**,
So that **I can preserve my creations and return to them later**.

**Acceptance Criteria:**

**Given** I have created a pattern
**When** I trigger the save action
**Then** the pattern is saved to local device storage (FR25, FR61)
**And** pattern data includes: tracks, BPM, scale, root, pattern length
**And** metadata is saved: name, creation date, last modified date (FR32)
**And** the save completes in <100ms
**And** the pattern file is <50KB (NFR14)
**And** iOS: stored in app Documents directory via FileManager
**And** Web: stored in IndexedDB

---

#### Story 7.2: Auto-Save Pattern Changes

As a **user**,
I want **my pattern to save automatically as I edit**,
So that **I never lose work due to crashes or accidental closes**.

**Acceptance Criteria:**

**Given** I'm editing a pattern
**When** I make any change (place note, adjust BPM, etc.)
**Then** the pattern auto-saves after a 500ms debounce delay (FR28)
**And** auto-save happens in the background without interrupting workflow
**And** the last auto-save timestamp is tracked
**And** auto-save works offline (FR60, NFR5)

---

#### Story 7.3: Browse Pattern Library

As a **user**,
I want **to view a library of all my saved patterns**,
So that **I can find and load previous work**.

**Acceptance Criteria:**

**Given** multiple patterns are saved
**When** I open the pattern library screen
**Then** all patterns display as grid thumbnails (FR27)
**And** I can sort patterns by: recently modified, creation date, BPM, name
**And** I can search/filter patterns by scale, BPM range, track usage
**And** thumbnail previews show the pattern's grid state visually
**And** the library scrolls smoothly at 60 FPS with 20+ patterns

---

#### Story 7.4: Load Previously Saved Pattern

As a **user**,
I want **to tap a pattern in the library to load it**,
So that **I can continue editing previous work**.

**Acceptance Criteria:**

**Given** the pattern library is displayed
**When** I tap a pattern thumbnail
**Then** the pattern loads into the grid (FR26)
**And** all track data is restored exactly as saved
**And** BPM, scale, root, and pattern length are restored
**And** the current unsaved pattern prompts to save before loading
**And** the load completes in <500ms

---

#### Story 7.5: Export Pattern as JSON File

As a **user**,
I want **to export my pattern as a JSON file**,
So that **I can share it with others or use it on different platforms**.

**Acceptance Criteria:**

**Given** a pattern is loaded
**When** I trigger the export action
**Then** a JSON file is generated containing all pattern data (FR29)
**And** the JSON format matches the cross-platform specification (CR1)
**And** iOS: export via Share Sheet or save to Files app (FR30)
**And** Web: download as .json file via browser
**And** the exported file is human-readable and structured
**And** metadata is included (name, date, BPM, scale)

---

#### Story 7.6: Import Cross-Platform Patterns

As a **user**,
I want **to import JSON pattern files from other platforms**,
So that **I can use patterns created on web in the iOS app and vice versa**.

**Acceptance Criteria:**

**Given** I have a .json pattern file
**When** I trigger the import action
**Then** iOS: file picker using native document picker
**And** Web: file input or drag-and-drop support
**And** the pattern is validated before import (FR31)
**And** imported patterns load correctly with all data preserved
**And** corrupted files show clear error messages
**And** import is compatible with patterns from both web and iOS versions

---

#### Story 7.7: Pattern Management Actions (Rename, Duplicate, Delete)

As a **user**,
I want **to rename, duplicate, or delete patterns in the library**,
So that **I can organize my collection effectively**.

**Acceptance Criteria:**

**Given** the pattern library is displayed
**When** I long-press a pattern thumbnail
**Then** options appear: Rename, Duplicate, Delete, Share
**And** Rename: inline text editing with keyboard
**And** Duplicate: creates copy with " (Copy)" suffix
**And** Delete: confirms before removing (prevents accidents)
**And** Share: uses platform Share Sheet (iOS) or Web Share API
**And** all actions update the library view immediately

---

### Epic 8: History & Reversibility

#### Story 8.1: 50-Level Undo Stack

As a **user**,
I want **to undo my last 50 actions**,
So that **I can experiment freely and reverse mistakes**.

**Acceptance Criteria:**

**Given** I'm editing a pattern
**When** I make changes (place notes, adjust BPM, change scale, etc.)
**Then** each action is added to the undo history stack (FR33)
**And** the stack maintains up to 50 actions in memory (FR63)
**And** pressing undo (row 0, col 4) reverses the last action
**And** undo works for all action types: note placement, deletion, gestures, parameter changes
**And** undo operations complete in <5ms

---

#### Story 8.2: Redo Previously Undone Actions

As a **user**,
I want **to redo actions I've undone**,
So that **I can restore changes if I undo too far**.

**Acceptance Criteria:**

**Given** I have undone one or more actions
**When** I press redo (row 0, col 5)
**Then** the most recently undone action is restored (FR34)
**And** redo stack is cleared when a new action is performed
**And** redo works for all action types that support undo
**And** redo operations complete in <5ms

---

#### Story 8.3: Double-Swipe Left Gesture for Undo

As a **user**,
I want **to double-swipe left anywhere on the grid to undo**,
So that **I can undo without reaching for the button**.

**Acceptance Criteria:**

**Given** I'm editing a pattern with undo history
**When** I perform two leftward swipes (≥6 steps each) within 500ms
**Then** the last action is undone (FR35)
**And** a tooltip "<<UNDO" appears confirming the action (FR41)
**And** haptic feedback confirms the undo (iOS)
**And** the gesture works anywhere on the grid
**And** the gesture doesn't interfere with horizontal drag gestures

---

#### Story 8.4: Double-Swipe Right Gesture for Redo

As a **user**,
I want **to double-swipe right to redo previously undone actions**,
So that **I have quick gestural access to redo**.

**Acceptance Criteria:**

**Given** I have undone one or more actions
**When** I perform two rightward swipes (≥6 steps each) within 500ms
**Then** the most recently undone action is restored (FR36)
**And** a tooltip "REDO>>" appears confirming the action (FR41)
**And** haptic feedback confirms the redo (iOS)
**And** the gesture works anywhere on the grid
**And** the gesture doesn't interfere with horizontal drag gestures

---

### Epic 9: Customization & Configuration

#### Story 9.1: BPM Control (60-200 BPM)

As a **user**,
I want **to adjust the tempo from 60 to 200 BPM**,
So that **I can create patterns at different speeds**.

**Acceptance Criteria:**

**Given** the grid is displayed
**When** I use BPM controls (row 0, cols 26-28)
**Then** tempo adjusts in 5 BPM increments (FR46)
**And** range is 60-200 BPM
**And** a tooltip displays "120 BPM" when changed (FR40)
**And** playback tempo updates immediately during playback
**And** BPM persists across sessions (FR62)
**And** keyboard shortcuts: Arrow Up/Down adjust BPM (web/desktop, FR53)

---

#### Story 9.2: Keyboard Shortcuts for Common Actions

As a **user**,
I want **keyboard shortcuts for play/stop, undo/redo, clear, and BPM**,
So that **I can work efficiently on desktop/web** (FR53).

**Acceptance Criteria:**

**Given** the web app is running on desktop
**When** I press keyboard shortcuts
**Then** the following actions trigger:
- Space: Play/Stop toggle
- Cmd/Ctrl+Z: Undo
- Cmd/Ctrl+Shift+Z: Redo
- Delete/Backspace: Clear all tracks
- Arrow Up: Increase BPM by 5
- Arrow Down: Decrease BPM by 5
**And** shortcuts work without interfering with text input
**And** shortcuts are documented in the help/settings screen

---

#### Story 9.3: Ghost Note Visibility Toggle

As a **user**,
I want **to toggle ghost note visibility on/off**,
So that **I can choose whether to see other tracks' notes while editing**.

**Acceptance Criteria:**

**Given** the grid is displayed with notes on multiple tracks
**When** I toggle the ghost notes setting (row 0)
**Then** ghost notes (other tracks at 22% opacity) show or hide (FR52)
**And** the toggle state is indicated visually in row 0
**And** the preference persists across sessions (FR62)
**And** ghost notes help with visual alignment across tracks when enabled

---

#### Story 9.4: Preferences Persistence Across Sessions

As a **user**,
I want **my settings (BPM, scale, root, ghost notes) to persist between sessions**,
So that **the app remembers my preferences** (FR62).

**Acceptance Criteria:**

**Given** I've configured settings (BPM, scale, root, pattern length, ghost notes)
**When** I close and reopen the app
**Then** all settings are restored to my last configuration
**And** iOS: stored via UserDefaults
**And** Web: stored in localStorage
**And** persistence is automatic (no manual save required)
**And** default values are used on first launch

---

### Epic 10: iOS Native Polish & Integration

#### Story 10.1: Haptic Feedback on Note Placement

As a **user**,
I want **to feel haptic feedback when placing notes**,
So that **I get tactile confirmation of my gestures** (iOS).

**Acceptance Criteria:**

**Given** the iOS app is running on a device with haptic support
**When** I place a note using any gesture
**Then** haptic feedback triggers using UIImpactFeedbackGenerator (FR64)
**And** feedback occurs within 10ms of gesture recognition (NFR41)
**And** haptic intensity is appropriate to the gesture
**And** haptics work for: tap, accent, arpeggio, chord, sustain, erase

---

#### Story 10.2: Distinct Haptic Responses per Gesture Type

As a **user**,
I want **different haptic patterns for different gestures**,
So that **I can feel the difference between tap, accent, chord, etc** (iOS).

**Acceptance Criteria:**

**Given** the iOS app supports haptics
**When** I perform different gesture types
**Then** each gesture has a distinct haptic response (FR65):
- Tap: light impact
- Accent: medium impact
- Arpeggio: light rapid sequence
- Chord: medium impact
- Sustain: light prolonged
- Erase: warning impact
- Clear: heavy impact
**And** haptic patterns are learnable through use

---

#### Story 10.3: Beat-Synchronized Haptic Pulses During Playback

As a **user**,
I want **to feel haptic pulses on each beat during playback**,
So that **I can physically feel the rhythm** (iOS).

**Acceptance Criteria:**

**Given** playback is active on iOS
**When** the pattern plays
**Then** haptic pulses trigger on each beat (FR66)
**And** pulses are synchronized within 10ms of the audio beat
**And** pulse strength corresponds to note velocity
**And** users can enable/disable beat pulses in settings
**And** pulses are battery-efficient (<5% drain per 30min, NFR3)

---

#### Story 10.4: Background Audio Playback

As a **user**,
I want **playback to continue when the app is backgrounded**,
So that **I can use other apps while listening to my pattern** (iOS).

**Acceptance Criteria:**

**Given** playback is active
**When** I switch to another app or lock the screen
**Then** audio continues playing in the background (FR18)
**And** UIBackgroundModes includes "audio" in Info.plist (NFR18)
**And** audio session is configured for background playback (NFR19)
**And** playback controls appear in Control Center
**And** background playback respects iOS audio session interruptions

---

#### Story 10.5: Audio Session Interruption Handling

As a **user**,
I want **the app to handle phone calls and notifications gracefully**,
So that **playback resumes automatically after interruptions** (iOS).

**Acceptance Criteria:**

**Given** playback is active
**When** an interruption occurs (phone call, alarm, FaceTime, etc.)
**Then** audio pauses immediately (FR19)
**And** playback resumes automatically when the interruption ends
**And** the app responds to AVAudioSessionInterruptionNotification
**And** playback position is preserved during interruption
**And** the behavior follows iOS HIG for audio interruptions

---

#### Story 10.6: VoiceOver Accessibility Labels

As a **user with visual impairment**,
I want **VoiceOver to describe all interactive controls**,
So that **I can use the app with screen reading** (iOS).

**Acceptance Criteria:**

**Given** VoiceOver is enabled on iOS
**When** I navigate the interface
**Then** all interactive controls have descriptive labels (NFR8):
- Play/Stop button: "Play" or "Stop playback"
- BPM controls: "Increase tempo to 125 BPM"
- Scale selector: "Select C Major scale"
- Grid pixels: "Melody track, step 3, C note"
**And** VoiceOver announces pattern playback state (NFR9)
**And** VoiceOver describes grid interactions (NFR10)

---

#### Story 10.7: Dynamic Type Support in Settings

As a **user with visual impairment**,
I want **settings text to scale with my iOS text size preference**,
So that **I can read settings comfortably** (iOS).

**Acceptance Criteria:**

**Given** the settings screen is displayed
**When** the user has configured Dynamic Type in iOS Settings
**Then** all text scales according to the user's preference (NFR11)
**And** the layout adapts to larger text sizes
**And** text remains readable at all supported sizes
**And** the interface follows iOS HIG for Dynamic Type

---

#### Story 10.8: WCAG 2.1 AA Color Contrast Compliance

As a **user with visual impairment**,
I want **all colors to meet accessibility contrast standards**,
So that **I can distinguish notes and controls clearly**.

**Acceptance Criteria:**

**Given** the grid is displayed with notes and controls
**When** measuring color contrast ratios
**Then** all combinations meet WCAG 2.1 AA standards (NFR12):
- Normal text: 4.5:1 contrast minimum
- Large text (≥18pt): 3:1 contrast minimum
- Interactive controls: 3:1 contrast minimum
**And** note colors against black background meet requirements
**And** control colors against background meet requirements
**And** contrast compliance is maintained in all themes

---

#### Story 10.9: Privacy Manifest Declaration

As a **developer preparing for App Store submission**,
I want **a Privacy Manifest file declaring zero data collection**,
So that **the app meets iOS 18+ SDK requirements** (NFR6-7).

**Acceptance Criteria:**

**Given** the iOS app is built with Xcode 16+ and iOS 18+ SDK (NFR14-15)
**When** submitting to App Store
**Then** PrivacyInfo.xcprivacy file exists in Resources (NFR6)
**And** manifest declares zero data collection (NFR34, NFR35)
**And** manifest declares UserDefaults API usage with reason CA92.1 (NFR7)
**And** Privacy Nutrition Label shows "Data Not Collected" (NFR35)
**And** the app is COPPA compliant (safe for children under 13) (NFR36)

---

#### Story 10.10: App Store Marketing Assets

As a **developer preparing for App Store release**,
I want **all required marketing assets (icons, screenshots, videos)**,
So that **the app can be submitted successfully**.

**Acceptance Criteria:**

**Given** the app is ready for submission
**When** preparing App Store listing
**Then** all required assets are provided:
- App icons in all required sizes (1024×1024, etc.) (NFR21)
- Launch screen (NFR22)
- Screenshots for required device sizes: 6.7", 6.5", 5.5" iPhones (NFR23)
- App Preview video (30 seconds demonstrating gesture system) (NFR24)
- Privacy Policy URL (NFR25)
**And** Accessibility Nutrition Labels declare supported features (NFR13)
**And** metadata includes description, keywords, age rating (4+)

---

#### Story 10.11: TestFlight Beta Program

As a **developer**,
I want **to run internal and external TestFlight beta tests**,
So that **the app is validated by musicians before public release**.

**Acceptance Criteria:**

**Given** the app is feature-complete and builds successfully
**When** running the beta program
**Then** internal TestFlight beta runs for 1-2 weeks with 5-10 testers (NFR26)
**And** external TestFlight beta runs for 4-8 weeks with 20-50 musicians (NFR27)
**And** zero critical bugs occur in the final 2 weeks of beta (NFR28)
**And** beta feedback is collected and addressed
**And** crash-free rate exceeds 99.5% sessions (NFR5)
**And** the app is ready for App Store submission after beta completion

---

### Epic 11: Offline-First Architecture

#### Story 11.1: Complete Offline Functionality

As a **user**,
I want **the app to work completely offline with no network requirement**,
So that **I can create music anywhere, anytime** (FR60, NFR5).

**Acceptance Criteria:**

**Given** the app is installed and has been launched once
**When** I disable all network connectivity (airplane mode)
**Then** all core functionality works:
- Pattern creation and editing
- Audio playback and synthesis
- Saving and loading patterns
- All gestures and controls
**And** iOS: fully offline, no network calls (NFR33)
**And** Web: PWA with service worker enables offline use (NFR6)
**And** no functionality is degraded in offline mode

---

#### Story 11.2: Local Pattern Storage (Zero Cloud Dependency)

As a **user**,
I want **all my patterns stored locally on my device**,
So that **I maintain full control and privacy of my creations**.

**Acceptance Criteria:**

**Given** I save patterns
**When** patterns are persisted
**Then** iOS: patterns stored in app Documents directory via FileManager (FR61)
**And** Web: patterns stored in IndexedDB with localStorage fallback
**And** no cloud sync or remote storage in MVP (NFR33)
**And** patterns are never transmitted over network
**And** storage is reliable with zero data loss (NFR12, FR62)
**And** patterns persist indefinitely until user deletes them

---

#### Story 11.3: Zero Data Collection and Tracking

As a **user**,
I want **the app to collect zero analytics or tracking data**,
So that **my creative activity remains completely private**.

**Acceptance Criteria:**

**Given** the app is in use
**When** I create patterns, use features, or navigate screens
**Then** no analytics are collected (NFR34)
**And** no usage tracking occurs
**And** no telemetry is sent to external servers
**And** Privacy Nutrition Label declares "Data Not Collected" (NFR35)
**And** the app is COPPA compliant (safe for children under 13) (NFR36)
**And** iOS: Privacy Manifest confirms zero data collection (NFR6)

---

#### Story 11.4: In-Memory Undo History Management

As a **user**,
I want **undo history maintained in memory during my session**,
So that **I can undo actions without storage overhead** (FR63).

**Acceptance Criteria:**

**Given** I'm editing a pattern
**When** I perform actions
**Then** the last 50 actions are stored in memory only (FR63)
**And** undo history is NOT persisted to storage
**And** undo history is cleared when the app closes
**And** undo history uses <10MB memory
**And** memory is managed efficiently (NFR11: <100MB total)

---

### Epic 12: MIDI & External Audio Connectivity (Phase 3)

#### Story 12.1: Per-Track MIDI Output Configuration

As a **user**,
I want **to route each of the 4 tracks to independent MIDI channels**,
So that **I can trigger different external synths per track** (FR67-68).

**Acceptance Criteria:**

**Given** MIDI output is enabled
**When** I configure per-track MIDI channels (1-16)
**Then** melody, chords, bass, and rhythm can each output to different channels
**And** MIDI channel selection is configurable via pixel-UI interface (no external settings)
**And** each track sends MIDI note on/off messages on its assigned channel
**And** MIDI note velocities correspond to PixelBoop velocity levels (1, 2, 3)
**And** configuration is saved with pattern metadata

---

#### Story 12.2: Bluetooth MIDI Output

As a **user**,
I want **to send MIDI wirelessly via Bluetooth to synths and apps**,
So that **I can trigger external sounds without cables** (FR69).

**Acceptance Criteria:**

**Given** a Bluetooth MIDI device is paired
**When** I enable Bluetooth MIDI output
**Then** MIDI messages are transmitted wirelessly
**And** connections to iOS synth apps work (Moog, Korg Gadget, etc.)
**And** connections to Bluetooth-capable hardware synths work
**And** latency is acceptable for live performance (<20ms)
**And** connection stability is maintained during playback

---

#### Story 12.3: USB MIDI Output (Lightning/USB-C)

As a **user**,
I want **to send MIDI via wired USB connection**,
So that **I can use reliable studio connections to interfaces and DAWs** (FR70).

**Acceptance Criteria:**

**Given** a USB MIDI interface is connected
**When** I enable USB MIDI output
**Then** MIDI messages are transmitted via Lightning/USB-C
**And** connections to audio interfaces work
**And** connections to hardware synths work
**And** connections to DAWs work (Ableton, Logic, etc.)
**And** wired connection provides lowest latency (<5ms)

---

#### Story 12.4: USB Audio Output to External Interfaces

As a **user**,
I want **to route audio through professional USB audio interfaces**,
So that **I can monitor through studio equipment** (FR71).

**Acceptance Criteria:**

**Given** a USB audio interface is connected
**When** I enable USB audio output
**Then** PixelBoop's synthesized audio routes to the interface
**And** audio appears on the interface's outputs
**And** multi-channel routing is supported (4 tracks → 4 outputs)
**And** audio quality is maintained (no additional latency or degradation)

---

#### Story 12.5: MIDI Input from External Controllers

As a **user**,
I want **to place notes via MIDI keyboard or controller**,
So that **I can use hardware for alternative input methods** (FR72).

**Acceptance Criteria:**

**Given** a MIDI controller is connected (USB or Bluetooth)
**When** I play notes on the controller
**Then** notes are placed on the selected track at the playhead position
**And** per-track MIDI input channels are configurable (1-16)
**And** MIDI velocity maps to PixelBoop velocity (normal/accent)
**And** gesture-based input remains primary (MIDI is supplementary)
**And** MIDI input works for accessibility use cases

---

#### Story 12.6: Bluetooth MIDI Input for Live Performance

As a **user**,
I want **to receive wireless MIDI from controllers during performance**,
So that **I have flexible live performance input** (FR73).

**Acceptance Criteria:**

**Given** a Bluetooth MIDI controller is paired
**When** I trigger notes on the controller during performance
**Then** notes are placed or triggered in real-time
**And** wireless input is low-latency enough for performance (<20ms)
**And** connection stability is maintained during live use
**And** multiple Bluetooth MIDI devices can be used simultaneously

---

#### Story 12.7: MIDI Clock Send/Receive for Tempo Sync

As a **user**,
I want **to send or receive MIDI clock to sync with external gear**,
So that **PixelBoop stays in tempo with my other equipment** (FR74).

**Acceptance Criteria:**

**Given** MIDI clock is configured
**When** set as master (source)
**Then** PixelBoop sends MIDI clock at the current BPM
**And** external devices sync to PixelBoop's tempo
**When** set as slave (follower)
**Then** PixelBoop receives MIDI clock from external source
**And** PixelBoop's playback syncs to the external tempo
**And** tempo changes are followed in real-time

---

#### Story 12.8: MIDI Transport Control (Start/Stop/Continue)

As a **user**,
I want **MIDI start/stop/continue messages to control playback**,
So that **PixelBoop integrates with DAW and sequencer workflows** (FR75).

**Acceptance Criteria:**

**Given** MIDI transport control is enabled
**When** external gear sends MIDI Start
**Then** PixelBoop playback starts from position 0
**When** external gear sends MIDI Stop
**Then** PixelBoop playback stops and resets to position 0
**When** external gear sends MIDI Continue
**Then** PixelBoop playback resumes from current position
**And** PixelBoop can also send transport messages when configured as master

---

#### Story 12.9: Ableton Link Network-Based Tempo Sync

As a **user**,
I want **to sync tempo and phase with Ableton Live and other Link-enabled apps**,
So that **I can jam wirelessly with multiple devices** (FR76).

**Acceptance Criteria:**

**Given** Ableton Link is enabled
**When** connecting to a Link session
**Then** PixelBoop syncs tempo with all Link-enabled devices
**And** phase sync keeps all devices aligned to the same beat
**And** tempo changes propagate across all linked devices
**And** Link works over local network (WiFi or Ethernet)
**And** multiple PixelBoop instances can Link together

---

#### Story 12.10: Clock Source Selection (Internal/MIDI/Link)

As a **user**,
I want **to choose whether PixelBoop uses its own tempo or syncs to external**,
So that **I have flexible sync options for different workflows** (FR77).

**Acceptance Criteria:**

**Given** the clock source selector is accessible via pixel-UI
**When** I select a clock source
**Then** three options are available:
- Internal: PixelBoop's own BPM controls (master)
- External MIDI: Follow MIDI clock from connected device
- Ableton Link: Sync via Link network protocol
**And** selection is indicated visually in the interface
**And** switching sources happens seamlessly during playback
**And** the selected source persists with pattern save

---

### Epic 13: Live Performance & Hardware Integration (Phase 3)

#### Story 13.1: MIDI File Export for DAW Integration

As a **user**,
I want **to export my pattern as a standard MIDI file**,
So that **I can import it into any DAW for further production** (FR78).

**Acceptance Criteria:**

**Given** a pattern is loaded
**When** I trigger MIDI file export
**Then** a standard MIDI file (.mid) is generated
**And** all 4 tracks export as separate MIDI tracks
**And** timing, notes, and velocities are preserved accurately
**And** the MIDI file imports successfully into Ableton, Logic, FL Studio, etc.
**And** tempo and time signature are embedded in the file

---

#### Story 13.2: Project Save/Load with Full Song State

As a **user**,
I want **to save complete projects with multiple sections and arrangements**,
So that **I can preserve full song compositions** (FR79).

**Acceptance Criteria:**

**Given** a song with multiple sections (intro, verse, chorus, etc.)
**When** I save the project
**Then** all sections and their arrangements are saved
**And** song structure (section order) is preserved
**And** all per-section settings are saved
**And** loading the project restores the complete song state
**And** project files include full metadata and version information

---

#### Story 13.3: Audio Bounce to WAV/MP3

As a **user**,
I want **to render my pattern to an audio file**,
So that **I can share my music easily** (FR80).

**Acceptance Criteria:**

**Given** a pattern or song is loaded
**When** I trigger audio bounce
**Then** the internal synthesis is rendered to audio file
**And** export formats: WAV (lossless) and MP3 (compressed)
**And** rendered audio matches real-time playback exactly
**And** bounce includes all tracks with correct mix levels
**And** file is saved to device storage or shared via platform share

---

#### Story 13.4: Hardware Controller Support (Erae Touch 2, Launchpad, Push)

As a **user**,
I want **to control PixelBoop using grid-based hardware controllers**,
So that **I have tactile, performance-oriented control** (FR81).

**Acceptance Criteria:**

**Given** a supported controller is connected (Erae Touch 2, Launchpad, Push)
**When** I enable hardware integration
**Then** the controller's grid maps to PixelBoop's 44×24 grid
**And** pressing controller pads places/triggers notes
**And** controller LEDs reflect PixelBoop's visual state
**And** bidirectional control: PixelBoop → controller and controller → PixelBoop
**And** controller mapping is configurable via pixel-UI

---

#### Story 13.5: MPE Support for Expressive Control

As a **user**,
I want **to use MPE controllers for pressure, slide, and lift expression**,
So that **I can perform with nuanced control** (FR82).

**Acceptance Criteria:**

**Given** an MPE-capable controller is connected (e.g., Erae Touch 2)
**When** I perform expressive gestures
**Then** pressure controls note velocity/volume
**And** slide (left/right) controls pitch bend or timbre
**And** lift velocity controls note release characteristics
**And** MPE gestures map naturally to PixelBoop's gestural vocabulary
**And** per-note polyphonic expression is supported

---

#### Story 13.6: Scene Launching and Pattern Switching

As a **user**,
I want **to trigger different sections/patterns as scenes during performance**,
So that **I can perform complete songs live** (FR84).

**Acceptance Criteria:**

**Given** multiple patterns/sections are prepared
**When** I trigger a scene launch
**Then** playback switches to the selected pattern/section
**And** switching happens on the next bar boundary (musical timing)
**And** scenes can be triggered via hardware controller or gestures
**And** scene switching is seamless with no audio dropouts
**And** the current scene is indicated visually

---

#### Story 13.7: Performance Mode with Accidental-Clear Protection

As a **user**,
I want **a performance mode that prevents accidental pattern clearing**,
So that **I don't lose my work during live performance** (FR85).

**Acceptance Criteria:**

**Given** performance mode is enabled
**When** I perform gestures during a show
**Then** accidental clear gestures (scrub, double-tap) are disabled
**And** essential playback controls remain accessible
**And** scene launching and pattern switching still work
**And** performance mode is toggled via dedicated control
**And** visual indication shows performance mode is active

---

#### Story 13.8: WLED WiFi LED Strip Control

As a **user**,
I want **to stream the pixel grid state to WLED LED strips in real-time**,
So that **I can create a physical LED backdrop mirroring my music** (FR86).

**Acceptance Criteria:**

**Given** WLED-compatible LED hardware is connected via WiFi
**When** playback is active
**Then** the 44×24 grid state streams to the LED strip
**And** LED colors match note colors exactly
**And** playhead and animations are reflected on physical LEDs
**And** latency is low enough for visual sync (<50ms)
**And** WLED configuration is done via pixel-UI

---

#### Story 13.9: sACN/Art-Net Network LED Panel Control

As a **user**,
I want **to control network-based LED panels with sACN or Art-Net protocols**,
So that **I can drive professional stage lighting** (FR87).

**Acceptance Criteria:**

**Given** sACN (E1.31) or Art-Net compatible LED panels are on the network
**When** playback is active
**Then** grid state is transmitted via sACN or Art-Net protocols
**And** panels display the 44×24 grid visually
**And** protocols support professional DMX512 fixtures
**And** multiple panels can be controlled simultaneously
**And** protocol configuration is accessible via pixel-UI

---

#### Story 13.10: DMX Lighting Control for Stage Fixtures

As a **user**,
I want **to trigger DMX stage lighting based on track activity and BPM**,
So that **I can create synchronized stage production** (FR88).

**Acceptance Criteria:**

**Given** DMX fixtures are connected via USB-DMX adapter
**When** notes trigger or tracks change
**Then** DMX commands control stage fixtures (spotlights, strobes, color washes)
**And** lighting responds to:
- Track activity (which tracks are playing)
- BPM and tempo (pulse on beat)
- Note events (flash on triggers)
- Playback position (follow sections)
**And** DMX mapping is configurable via pixel-UI

---

#### Story 13.11: Instrument LED Guides (Physical Instrument Integration)

As a **user**,
I want **LED strips on physical instruments to show which notes to play**,
So that **live musicians can follow along with PixelBoop sequences** (FR89).

**Acceptance Criteria:**

**Given** LED strips are attached to physical instruments (guitar, piano, drums)
**When** a pattern plays
**Then** LEDs illuminate showing notes to play in sync
**And** LEDs work on:
- Guitar fretboards (show which frets to play)
- Piano keys (show which keys to press)
- Drum pads (show which drums to hit)
**And** LED timing is synchronized to the playback beat
**And** brightness indicates note velocity

---

#### Story 13.12: Protocol Support Configuration (WLED/sACN/Art-Net/DMX)

As a **user**,
I want **to configure which lighting protocols to use**,
So that **I can integrate with my specific hardware setup** (FR90).

**Acceptance Criteria:**

**Given** the lighting configuration screen (pixel-UI)
**When** I configure output protocols
**Then** I can enable/disable:
- WLED (WiFi)
- sACN/E1.31 (network)
- Art-Net (network)
- DMX512 (wired via USB-DMX adapter)
**And** multiple protocols can be active simultaneously
**And** each protocol's settings (IP addresses, universes, channels) are configurable
**And** configuration is saved per-project

---

#### Story 13.13: Expanded Synthesis (Multiple Oscillators, Filters, Effects)

As a **user**,
I want **advanced synthesis capabilities with multiple oscillators and effects**,
So that **I can design custom sounds per track** (FR91).

**Acceptance Criteria:**

**Given** the synthesis editor is accessible
**When** I edit track synthesis
**Then** I can configure:
- Multiple oscillators per track (FM, AM, wavetable)
- Filters (lowpass, highpass, bandpass, notch)
- Effects (reverb, delay, chorus, distortion)
**And** synthesis parameters are saved with the pattern
**And** advanced synthesis doesn't break backward compatibility with basic patterns

---

#### Story 13.14: Audio Input for Sampling Custom Sounds

As a **user**,
I want **to sample audio input and use it in my patterns**,
So that **I can incorporate custom sounds beyond internal synthesis** (FR92).

**Acceptance Criteria:**

**Given** audio input is available (microphone, line-in)
**When** I trigger sample recording
**Then** audio is captured and stored as a playable sample
**And** samples can be assigned to grid positions
**And** samples can be pitch-shifted and time-stretched
**And** samples are stored with the pattern
**And** sample library management is provided

---

#### Story 13.15: Per-Track Sound Design Customization

As a **user**,
I want **to customize synthesis parameters independently per track**,
So that **each track has its own sonic character** (FR93).

**Acceptance Criteria:**

**Given** the sound design interface is accessible
**When** I customize a track's synthesis
**Then** I can adjust:
- Oscillator type and parameters
- Filter type, cutoff, and resonance
- ADSR envelope (attack, decay, sustain, release)
- Effects send levels
- Panning and stereo width
**And** customizations are saved with the pattern
**And** presets can be saved and shared
**And** sound design doesn't affect pattern compatibility
