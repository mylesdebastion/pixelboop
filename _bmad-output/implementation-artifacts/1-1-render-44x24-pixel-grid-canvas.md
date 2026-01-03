# Story 1.1: Render 44×24 Pixel Grid Canvas

Status: ready-for-dev

---

## Story

As a **user**,
I want **to see a 44-column by 24-row pixel grid when I open the app**,
So that **I have a visual canvas for music creation**.

---

## Acceptance Criteria

**Given** the app is launched for the first time
**When** the interface loads
**Then** a 44×24 pixel grid is displayed filling the viewport
**And** pixels have 1px gaps between them
**And** the grid uses dark background (#0a0a0a)
**And** the grid scales responsively based on device size (6-20px pixels)
**And** rendering maintains 60 FPS (FR45)

---

## Requirements References

**Functional Requirements:**
- FR37: System can display a 44×24 pixel grid interface
- FR45: System can render all visual elements at 60 FPS on target devices

**Non-Functional Requirements:**
- NFR1: Visual rendering at 60 FPS on target devices (iPhone 12+ sustained, iPhone SE 2nd gen functional)
- NFR57-60: SDK Requirements (Xcode 16+, iOS 18+ SDK, deployment target iOS 15+, Swift 5.9+)

**Cross-Platform Requirement:**
- Pattern JSON format must match web version exactly (grid coordinates must be consistent)
- Visual consistency: same pixel dimensions, gaps, and layout across platforms

---

## Tasks / Subtasks

- [ ] Task 1: Create basic SwiftUI app shell (AC: Grid appears on launch)
  - [ ] Set up Xcode project with SwiftUI template
  - [ ] Configure deployment target iOS 15.0, build with iOS 18+ SDK
  - [ ] Create main ContentView with app structure

- [ ] Task 2: Implement UIKit pixel grid view (AC: 44×24 grid with 1px gaps)
  - [ ] Create PixelGridUIView subclass of UIView
  - [ ] Implement 44-column × 24-row grid layout in drawRect
  - [ ] Add 1px gaps between pixels using CoreGraphics
  - [ ] Apply dark background color #0a0a0a

- [ ] Task 3: Bridge UIKit grid to SwiftUI (AC: Grid displays in SwiftUI)
  - [ ] Create PixelGridView conforming to UIViewRepresentable
  - [ ] Implement makeUIView and updateUIView methods
  - [ ] Integrate into ContentView

- [ ] Task 4: Implement responsive pixel sizing (AC: 6-20px responsive scaling)
  - [ ] Calculate pixel size based on screen dimensions
  - [ ] Ensure grid fills viewport on all device sizes
  - [ ] Test on iPhone SE (smallest), iPhone 15 Pro Max (largest)

- [ ] Task 5: Performance validation (AC: 60 FPS rendering)
  - [ ] Profile rendering performance with Instruments
  - [ ] Optimize drawRect if needed (offscreen buffer, dirty rects)
  - [ ] Verify 60 FPS on iPhone SE 2nd gen (minimum target)

---

## Dev Notes

### Architecture Context

**Technology Stack:**
- **Language:** Swift 5.9+ (strict concurrency checking enabled)
- **UI Framework:** SwiftUI App lifecycle with UIKit integration via UIViewRepresentable
- **Architecture Pattern:** MVVM (Model-View-ViewModel)
- **Graphics:** CoreGraphics for custom pixel grid rendering
- **Target Platforms:** iOS 15.0+ (iPhone SE 2nd gen minimum)
- **Build Requirements:** Xcode 16+, iOS 18+ SDK

**Why Hybrid SwiftUI + UIKit:**
- SwiftUI provides modern app lifecycle and state management
- UIKit (UIView + CoreGraphics) enables precise pixel-level rendering and touch handling
- This story focuses on UIKit grid rendering; future stories will add gesture recognition

### Technical Requirements

**Grid Specifications (from prototype):**
```swift
let COLS = 44
let ROWS = 24
let BACKGROUND_COLOR = UIColor(hex: "#0a0a0a") // Dark background
let GAP_SIZE: CGFloat = 1.0 // 1px gaps between pixels
```

**Pixel Sizing Strategy:**
- Calculate available viewport space (excluding safe areas)
- Determine pixel size that fits grid with gaps: `pixelSize = min(maxWidth, maxHeight)`
- Constraint: 6px minimum (readability), 20px maximum (avoid excessive size)
- Formula: `pixelSize = floor((viewWidth - (COLS - 1)) / COLS)` accounting for gaps

**Row Allocation (for reference - not implemented in this story):**
- Row 0: Control buttons (not rendered as pixels yet)
- Row 1: Step markers (not rendered yet)
- Rows 2-7: Melody track (6 rows)
- Rows 8-13: Chords track (6 rows)
- Rows 14-17: Bass track (4 rows)
- Rows 18-21: Rhythm track (4 rows)
- Rows 22-23: Pattern overview (2 rows)

**CoreGraphics Rendering Pattern:**
```swift
override func draw(_ rect: CGRect) {
    guard let context = UIGraphicsGetCurrentContext() else { return }

    // Fill background
    context.setFillColor(backgroundColor.cgColor)
    context.fill(rect)

    // Draw pixels with gaps
    for row in 0..<ROWS {
        for col in 0..<COLS {
            let x = CGFloat(col) * (pixelSize + gapSize)
            let y = CGFloat(row) * (pixelSize + gapSize)
            let pixelRect = CGRect(x: x, y: y, width: pixelSize, height: pixelSize)

            // For now, draw empty pixels (no notes yet)
            context.setFillColor(UIColor.clear.cgColor)
            context.fill(pixelRect)
        }
    }
}
```

### Performance Requirements

**60 FPS Target:**
- Each frame budget: 16.67ms (1000ms / 60fps)
- Grid rendering must complete well under budget
- Initial render: acceptable up to 50ms (one-time)
- Subsequent renders: <5ms per frame

**Optimization Techniques:**
- Use `setNeedsDisplay()` selectively (only when grid changes)
- Consider offscreen buffering for static grid structure
- Dirty rectangle updates for partial redraws (future optimization)
- Profile with Instruments Time Profiler and Core Animation

### File Structure Requirements

**Project Organization (MVVM):**
```
PixelBoop/
├── App/
│   ├── PixelBoopApp.swift          // @main entry point
│   └── ContentView.swift            // Root SwiftUI view
├── Views/
│   ├── SequencerView.swift          // Main sequencer screen
│   ├── PixelGridView.swift          // SwiftUI wrapper (UIViewRepresentable)
│   └── PixelGridUIView.swift        // UIKit grid rendering (this story)
├── ViewModels/
│   └── SequencerViewModel.swift     // State management (future story)
├── Models/
│   └── (empty for now)              // Pattern, Track models (future)
├── Services/
│   └── (empty for now)              // Audio, Haptics (future)
└── Resources/
    └── Assets.xcassets              // App icons, colors
```

**This Story's Focus:**
Create `PixelGridUIView.swift` and `PixelGridView.swift` to render the 44×24 grid with proper spacing and background color.

### Testing Requirements

**Manual Testing Checklist:**
- [ ] Grid appears on app launch
- [ ] 44 columns × 24 rows visible
- [ ] 1px gaps clearly visible between pixels
- [ ] Background is dark (#0a0a0a)
- [ ] Grid scales to fill viewport on iPhone SE
- [ ] Grid scales to fill viewport on iPhone 15 Pro Max
- [ ] No rendering glitches or artifacts
- [ ] Smooth performance (no lag when app opens)

**Performance Testing:**
- [ ] Run Instruments Time Profiler during launch
- [ ] Verify drawRect completes in <5ms
- [ ] Check FPS stays at 60 using Xcode Debug → View Debugging → Rendering
- [ ] Test on iPhone SE 2nd gen (slowest target device)

**Unit Testing (Optional but Recommended):**
- Test pixel size calculation logic
- Verify grid dimension constants (44×24)
- Validate color values

### Prototype Reference

**Web Prototype Implementation:**
See `docs/prototype_sequencer.jsx` lines 1-150:
- Constants: `COLS = 44`, `ROWS = 24`
- Pixel font defined (3×5) - used for tooltips in future stories
- Track colors defined - used for colorization in future stories
- Gap rendering pattern proven functional in React Canvas

**Key Prototype Learnings:**
- 44×24 grid dimensions provide good balance of detail and performance
- 1px gaps are essential for pixel distinction at small sizes
- Dark background (#0a0a0a) provides high contrast for colored notes
- Responsive sizing works well across devices (6-20px range)

### Cross-Platform Compatibility Notes

**Grid Coordinate System:**
- Column 0 = leftmost, Column 43 = rightmost
- Row 0 = top, Row 23 = bottom
- This coordinate system MUST match web version exactly
- Future pattern JSON will use (col, row) coordinates

**Visual Consistency:**
- Use exact same background color: #0a0a0a
- Use exact same gap size: 1px
- Pixel colors (future stories) must match web version's NOTE_COLORS

### Known Constraints & Gotchas

**SwiftUI Canvas Limitations:**
- SwiftUI Canvas may not achieve 60 FPS for this use case
- UIKit UIView with CoreGraphics is proven for high-performance custom rendering
- Use UIViewRepresentable to bridge UIKit → SwiftUI

**Safe Area Considerations:**
- Grid should render within safe area bounds (avoid notch/home indicator)
- Calculate available viewport excluding safe area insets

**Device Size Variations:**
- iPhone SE: 375×667 points (smallest)
- iPhone 15 Pro Max: 430×932 points (largest)
- iPad not supported in Phase 1 (defer to Phase 2/3)

---

## Project Context Reference

See `docs/project-context.md` for:
- Complete coding standards and conventions
- Architecture patterns and best practices
- Testing requirements and strategies
- iOS-specific compliance requirements

---

## Dev Agent Record

### Agent Model Used

(To be filled by dev agent)

### Implementation Notes

(To be filled by dev agent during implementation)

### Completion Checklist

- [ ] All acceptance criteria met
- [ ] Code follows Swift style guidelines
- [ ] Performance validated (60 FPS)
- [ ] Tested on multiple device sizes
- [ ] No warnings or errors in Xcode
- [ ] Ready for code review

### File List

(To be filled by dev agent - list all files created/modified)
