# UX Critical Constraints for AI Agents

**Source:** Full UX Design Specification (2,526 lines)
**Purpose:** Distilled critical constraints that AI dev agents must follow
**Last Updated:** 2026-01-03

_This is a focused extract of NON-NEGOTIABLE constraints from the full UX spec. When implementing visual/interaction features, always validate against these constraints. For comprehensive context, read the full UX Design Specification._

---

## 1. Pixel-Only UI Design System (NON-NEGOTIABLE)

**Source:** UX Design Specification, Design System Foundation (lines 759-920)

### Core Principle
> "The grid IS the interface. Every pixel serves musical purpose. Zero chrome."

### Absolute Requirements

**✅ REQUIRED:**
- ALL visual elements rendered within 44×24 pixel grid using CoreGraphics
- Icons rendered as pixel art patterns (3×3 to 5×5 pixels)
- Text rendered using 3×5 pixel font (custom glyph renderer)
- Menu controls integrated as leftmost columns of same grid
- All pixels use identical size/gaps (seamless integration)

**❌ PROHIBITED:**
- SwiftUI `Text`, `Image`, `Button` components for app content
- SF Symbols (`Image(systemName:)`) for icons
- Separate SwiftUI views overlaying pixel grid
- Any visual element outside unified PixelGridUIView
- Platform UI chrome visible during use

### Implementation Pattern

```
PixelGridUIView (CoreGraphics only)
├── Menu Columns (leftmost N columns)
├── 1px divider (single pixel column)
└── Sequencer Grid (44×24 main canvas)

SwiftUI (UIViewRepresentable)
└── State management ONLY
```

**Violation Detection:**
If you see `Text(`, `Image(systemName:`, or separate `MenuView`, `ButtonView` components → WRONG. Should be integrated into PixelGridUIView.

---

## 2. Visual-Audio Equivalence (CORE PRINCIPLE)

**Source:** UX Design Specification, Core Experience (lines 206-310)

### Principle
The 44×24 pixel grid is simultaneously:
- A visual canvas (what you see)
- An audio sequencer (what you hear)
- A tactile interface (what you touch)

**No translation layer exists** - pixels ARE notes, gestures ARE musical phrases, patterns ARE songs.

### Implementation Requirements

**Visual Representation:**
- Grid pixels represent musical notes directly (1:1 mapping)
- Color coding by chromatic pitch (hue = pitch)
- Brightness = velocity/volume
- Saturation = sustain/envelope

**Audio Representation:**
- Real-time synthesis triggered by pixel state
- <10ms latency (perceived as instant)
- Audio events drive visual feedback (not touch events)

**Touch Representation:**
- Gestures express musical intent, not pixel precision
- Forgiveness over accuracy (snap to grid, interpret intent)
- Multi-touch for simultaneous track editing

---

## 3. Gesture Language as Composable System

**Source:** UX Design Specification, Key Design Challenges (lines 72-95)

### Principle
New features emerge from **combining existing gesture primitives**, not adding menu complexity.

**Required:**
- Gesture vocabulary is extensible through composition
- No mode switches or menu navigation for core features
- Visual feedback indicates gesture "mode" progression
- Gesture state machine supports multi-step hold sequences

**Example (Future Feature - Arpeggiator):**
```
Vertical drag → hold + drag up/down → sets arp pattern
              → hold + drag left/right → sets arp length
```

**Implementation Pattern:**
- Base gestures: tap, hold, drag (horizontal/vertical/diagonal)
- Composite gestures: hold + drag combinations
- Visual tooltips show gesture progression (TAP → CHORD → ARP UP → LENGTH 8)

---

## 4. Discovery-Driven UX (NO TUTORIALS)

**Source:** UX Design Specification, Discovery Through Progressive Depth (lines 298, 408-413)

### Principle
Users discover features through experimentation, not instruction. Hidden gestures create dopamine rewards.

**Design Pattern:**
- **Basic gestures visible:** TAP, CHORD, ARPEGGIO (contextual tooltips)
- **Advanced gestures hidden:** SUSTAIN, SCRUB, SWIPE-UNDO (discovery rewards)
- **Visual hints, not instructions:** Pulse animations, ghost notes, brighter pixels

**Required:**
- No forced tutorials or onboarding flows
- First gesture produces musically satisfying result (validates intent)
- Progressive depth through experimentation
- Visual affordances hint at possibilities without explicit instruction

**Prohibited:**
- Tutorial mode or help screens overlaying grid
- Instructional text explaining how to use features
- Forced onboarding sequences

---

## 5. Gesture Forgiveness Over Precision

**Source:** UX Design Specification, Gesture Expresses Intent (lines 290-294)

### Principle
Gestures communicate musical ideas, not pixel coordinates. Small mobile pixels + fat fingers = forgiveness required.

**Required:**
- Roughly horizontal drag = arpeggio (even if slightly diagonal)
- Roughly vertical drag = chord (even if not pixel-perfect)
- Hold timing thresholds forgiving (≥400ms, not exact)
- Direction vectors interpreted broadly (not pixel-perfect angles)

**Implementation:**
- Gesture smoothing algorithms
- Snap-to-grid for pixel placement
- Intent recognition over coordinate precision
- Direction thresholds (e.g., >60° = vertical, <30° = horizontal)

---

## 6. Musical Intelligence Ensures Success

**Source:** UX Design Specification, Musical Correctness Without Music Theory (lines 245-250)

### Principle
Users can't sound bad, but they can sound generic until mastery. Musical intelligence enables success, gesture fluency creates uniqueness.

**Required:**
- Scale snapping ensures notes sound harmonically correct
- Chord voicing follows music theory (major [0,4,7], minor [0,3,7], etc.)
- Automatic rhythm patterns for drum track
- Bass patterns follow harmonic roots (root and fifth intervals)

**Prohibited:**
- Allowing out-of-scale notes (unless chromatic mode explicitly enabled)
- Random chord voicings that sound dissonant
- Drum patterns that conflict rhythmically

**Implementation:**
- Scale selection: major, minor, pentatonic (12 root notes)
- Automatic chord voicing based on vertical gesture direction
- Bass pattern generation using scale intervals
- All input produces musically valid results

---

## 7. Instant Gratification, Earned Mastery

**Source:** UX Design Specification, Instant Gratification (lines 299-300)

### Principle
First gestures sound really good (musical intelligence). Continued practice enables personal voice (gesture fluency).

**User Journey:**
1. **Immediate Success** (first 2 minutes): First gesture → sounds good → validates promise
2. **Exploration** (first session): Gesture experimentation → hidden features discovered
3. **Mastery** (return sessions): Gesture fluency → personal expression → unique voice

**Implementation:**
- Musical intelligence ensures first tap/drag sounds coherent
- Discovery rewards (hidden gestures) fuel exploration
- Gesture mastery enables expression beyond generic presets
- No skill ceiling (progressive complexity through composition)

---

## 8. 44×24 Grid Layout Specification

**Source:** UX Design Specification, Pixel Primitives (lines 888-901); Architecture Document; PixelGridUIView.swift

### Grid Structure

```
Row 0:    [Control buttons - not rendered yet]
Row 1:    [Step markers - timeline indicators]
Rows 2-7:  Melody track (6 rows)
Rows 8-13: Chords track (6 rows)
Rows 14-17: Bass track (4 rows)
Rows 18-21: Rhythm track (4 rows)
Rows 22-23: Pattern overview (section markers)

Columns 0-43: Timeline steps (44 steps total)
```

**Grid Dimensions (Landscape-Oriented):**
- Columns: 44 (col 0-43 = timeline steps, render horizontally on x-axis)
- Rows: 24 (row 0-23 = tracks/pitches, render vertically on y-axis)
- Gap size: 1px between all pixels
- Background: #0a0a0a (dark)

**Responsive Sizing & Centering:**
- Pixel size: `floor(min(widthBasedSize, heightBasedSize))` - fits both dimensions
- Minimum margins: 8px on all sides (keeps edge pixels touchable)
- Grid centered: Calculated offsets center grid in available space
- Adapts to devices: iPhone, iPad automatically scale while maintaining aspect ratio

**Layout Algorithm:**
```swift
// Calculate pixel size from both dimensions
pixelSizeFromWidth = (availableWidth - (COLS-1) * GAP) / COLS
pixelSizeFromHeight = (availableHeight - (ROWS-1) * GAP) / ROWS
pixelSize = floor(min(pixelSizeFromWidth, pixelSizeFromHeight))

// Center grid in available space
gridWidth = COLS * pixelSize + (COLS-1) * GAP
gridHeight = ROWS * pixelSize + (ROWS-1) * GAP
gridOffsetX = (bounds.width - gridWidth) / 2
gridOffsetY = (bounds.height - gridHeight) / 2
```

**Touch Coordinate Conversion:**
- Touch points must account for grid centering offset
- Helper method: `gridCellAtPoint(_ point: CGPoint) -> (col: Int, row: Int)?`
- Converts screen coordinates → grid cell coordinates
- Returns nil if touch is outside grid bounds

**Orientation:**
- App locked to landscape-only (no orientation changes)
- Grid always renders 44 wide × 24 tall
- No layout recalculation or animation on device rotation

---

## 9. Cross-Platform Pattern Compatibility

**Source:** UX Design Specification, Platform Strategy (lines 221-235); Architecture Document

### Requirement
Patterns created on web MUST import to iOS perfectly (and vice versa). JSON format is sacred.

**Required:**
- Grid coordinates identical (44×24 across all platforms)
- JSON field names: `camelCase` (NOT `snake_case`)
- Gesture interpretation produces identical musical output
- Pattern export/import tested: web → iOS → web round-trip

**Implementation:**
- Use `Codable` with exact field names matching web
- Test JSON compatibility in unit tests
- Validate cross-platform round-trip in integration tests

---

## 10. Adaptive Menu Column System

**Source:** UX Design Specification, Adaptive Control Layout (lines 629-634)

### Principle
UI chrome adapts to available space without obscuring creative canvas. Grid-only immersion when collapsed, full controls when needed.

**Required Pattern:**
- Menu column is **part of pixel grid** (leftmost columns)
- Collapsed: Narrow width (e.g., 1 pixel column, icon-only)
- Expanded: Wider width (e.g., 5 pixel columns, icons + labels)
- Tap interaction toggles collapsed ↔ expanded
- Hardware controller compatible (no edge-swipe gestures)

**Prohibited:**
- Menu as separate SwiftUI overlay
- Edge-swipe gestures (incompatible with hardware controllers)
- Menu obscuring sequencer grid

**Implementation:**
- Menu width = number of pixel columns (1 col = collapsed, 5 cols = expanded)
- 1px black divider between menu and sequencer sections
- All pixels same size/gaps (seamless integration)

---

## 11. Performance Requirements

**Source:** UX Design Specification, Multi-Sensory Feedback Loop (lines 126-137); NFRs

### Non-Negotiable Targets

**Visual:**
- 60 FPS rendering (16.67ms per frame budget)
- No dropped frames during playback or gesture interaction

**Audio:**
- <10ms tap-to-sound latency (iOS native)
- <20ms for web (acceptable)
- Audio thread NEVER blocks

**Haptic (iOS):**
- Feedback triggers within 10ms of gesture recognition
- Prepared before triggering (`prepare()` call)

**Threading:**
- Main thread: UI updates only
- Audio thread: NEVER allocates, locks, or calls Swift
- Lock-free ring buffer for Main ↔ Audio communication

---

## 12. Accessibility Compliance

**Source:** UX Design Specification, Accessibility Requirements (lines 185-195)

### WCAG 2.1 AA Requirements

**Required:**
- VoiceOver labels on all interactive pixel regions
- Color contrast: 4.5:1 normal, 3:1 large text
- Brightness variations work for colorblind users (don't rely on hue alone)
- Dynamic Type support in settings

**Grid-Specific:**
- VoiceOver maps pixel regions to semantic names
- Larger tap targets via coordinate snapping (forgiveness)
- High contrast pixel colors
- No instant 100%↔0% transitions (accessibility-critical timing)

---

## 13. Constraint-as-Feature Identity

**Source:** UX Design Specification, Constraint-Driven Creators (lines 65-68, 198-204)

### Principle
The 44×24 grid and 4-track limit are celebrated features, not apologized for. Constraints drive creativity.

**Philosophy:**
- Grid limitation forces melodic thinking (can't just add more tracks)
- Constraint creates distinctive aesthetic (PICO-8 inspiration)
- Limitation becomes brand identity
- Community rallies around creative problem-solving within constraints

**Implementation:**
- Never apologize for grid size in UI
- Never add "expand grid" feature
- Embrace constraint in marketing ("pixel DAW")
- Design challenges: "Make a track using only 8 steps"

---

## 14. Offline-First Architecture

**Source:** UX Design Specification, Save/Load Friction (lines 686); Epic 11 Requirements

### Requirement
System functions 100% offline. Zero cloud dependency. Zero data collection.

**Required:**
- Local storage only (FileManager + UserDefaults)
- Auto-save everything (no save prompts)
- Export when ready (user-initiated only)
- Zero network calls during operation

**Prohibited:**
- Cloud sync in MVP
- Analytics or tracking
- Required internet connection
- User account system

---

## Usage Guidelines for AI Agents

**Before Implementing Visual Components:**
1. ✅ Read constraint #1 (Pixel-Only UI) - ALWAYS
2. ✅ Validate approach against violation detection patterns
3. ✅ Reference ADR 001 for detailed examples

**Before Implementing Gestures:**
1. ✅ Read constraints #3, #5 (Composable Language, Forgiveness)
2. ✅ Ensure gesture vocabulary extensibility
3. ✅ Validate timing thresholds and forgiveness

**Before Implementing Audio/Visual Sync:**
1. ✅ Read constraints #2, #11 (Visual-Audio Equivalence, Performance)
2. ✅ Ensure <10ms latency requirements met
3. ✅ Validate threading model (lock-free ring buffer)

**Before Implementing Any Feature:**
1. ✅ Check if constraint applies from list above
2. ✅ Read full UX Design Specification for comprehensive context
3. ✅ Validate against project-context.md critical rules

---

## References

**Full Documentation:**
- UX Design Specification: `_bmad-output/planning-artifacts/ux-design-specification.md` (2,526 lines)
- Architecture Document: `_bmad-output/planning-artifacts/architecture.md`
- Project Context: `_bmad-output/project-context.md`
- ADR 001: `docs/architectural-decisions/001-pixel-only-ui.md`

**Implementation Examples:**
- Story 1-1: Unified grid architecture (correct pattern)
- Story 1-2: Initial implementation (violation), requires reimplementation
- Prototype: `docs/prototype_sequencer.jsx` (web reference)

---

**Document Status:** Active enforcement for Epic 1-10 visual/interaction stories
**Next Update:** After Epic 1 retrospective, based on new patterns/violations discovered
