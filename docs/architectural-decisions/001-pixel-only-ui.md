# ADR 001: Pixel-Only UI Design System

**Status:** Accepted
**Date:** 2026-01-02
**Updated:** 2026-01-03 (Story 1.2 violation documented)
**Decision Makers:** Product Design (UX Spec), Architecture Team
**Impact:** All visual UI implementation (Epic 1-10)

---

## Context

PixelBoop is a gesture-based music sequencer with 44×24 pixel grid interface. The product vision requires "complete visual-audio equivalence" where the pixel grid IS the music made visible.

**Business Requirements:**
- Distinctive retro aesthetic (PICO-8 inspiration)
- Zero abstraction between visual and sonic output
- Cross-platform pattern compatibility (web + iOS)
- Discovery-driven UX (no tutorials, no UI chrome)

**Technical Constraints:**
- 44×24 grid with 1px gaps between pixels
- Vertical fill optimization (pixel size = availableHeight / 24)
- 60 FPS rendering requirement
- <10ms audio-to-visual sync latency

---

## Decision

**PixelBoop uses 100% custom pixel-based rendering with ZERO native UI components outside the unified pixel grid.**

### Core Principle
> "The grid IS the interface. Every pixel serves musical purpose. Zero chrome."

### Implementation Requirements

**✅ REQUIRED:**
1. ALL visual elements rendered within unified `PixelGridUIView` using CoreGraphics
2. Icons rendered as pixel art patterns (3×3 to 5×5 pixel grids)
3. Text rendered using 3×5 pixel font (custom glyph renderer)
4. Menu controls integrated as leftmost columns of same pixel grid
5. All pixels use identical size/gaps - seamless visual integration
6. SwiftUI used ONLY for:
   - `UIViewRepresentable` wrapper for state management
   - `@Published` properties for observable state
   - NOT for any visual rendering

**❌ PROHIBITED:**
1. SwiftUI `Text`, `Image`, `Button`, or any native UI components for app content
2. SF Symbols (`Image(systemName:)`) for icons
3. Separate SwiftUI views overlaying pixel grid
4. Any visual element rendered outside PixelGridUIView
5. High-resolution graphics or anti-aliased rendering
6. Platform-specific UI chrome (iOS status bar visible during use)

### Architectural Pattern

```
PixelGridUIView (UIKit + CoreGraphics)
├── Menu Columns (leftmost N columns)
│   ├── Pixel art icons (play = triangle, stop = square)
│   └── 3×5 pixel font labels (BPM, scale names)
├── 1px black divider (single pixel column)
└── Sequencer Grid (44×24 main canvas)
    ├── Note pixels (color-coded by pitch)
    ├── Playhead (brightened pixel column)
    └── Ghost notes (dimmed pixel previews)

SwiftUI Wrapper (UIViewRepresentable)
└── State management only (NO visual rendering)
```

---

## Consequences

### Positive

✅ **Visual-Audio Equivalence:** Grid pixels = musical notes (1:1 mapping, zero abstraction)
✅ **Cross-Platform Consistency:** Identical rendering on web (Canvas API) and iOS (CoreGraphics)
✅ **Distinctive Identity:** Retro aesthetic differentiates from generic music apps
✅ **Performance:** CoreGraphics rendering achieves 60 FPS on iPhone SE
✅ **Pattern Compatibility:** JSON patterns export/import between platforms perfectly

### Negative

❌ **Development Complexity:** Custom pixel font renderer, icon renderer required
❌ **Accessibility Challenges:** VoiceOver requires manual pixel region mapping
❌ **Text Limitations:** 3×5 pixel font restricts character set and readability
❌ **Icon Simplicity:** 3×3 pixel icons require abstract representations
❌ **Maintenance:** Custom rendering code vs. free native UI updates

### Mitigation Strategies

**Accessibility:**
- VoiceOver labels map pixel regions to semantic names
- Larger tap targets via grid coordinate snapping
- High contrast pixel colors (WCAG 2.1 AA compliance)

**Text Readability:**
- Limit text to essential labels (BPM values, scale names)
- Use Unicode symbols where possible (♯, ♭, ▶, ■)
- Tooltips appear briefly, then fade (minimize text exposure)

**Icon Recognition:**
- Follow universal patterns (▶ = play, ■ = stop, + = add, - = subtract)
- Test icon comprehension in user research
- Iterate based on TestFlight beta feedback

**Development Efficiency:**
- Port proven pixel font from web prototype (`prototype_sequencer.jsx`)
- Reuse icon patterns across stories (shared renderer)
- Document pixel art patterns in implementation guide

---

## Violation Examples

### ❌ WRONG (Story 1.2 Initial Implementation)

```swift
// HIGH-RESOLUTION SWIFTUI OVERLAY
struct MenuColumnView: View {
    var body: some View {
        VStack {
            Image(systemName: "play.fill")  // ❌ SF Symbol
            Text("Play")                     // ❌ Native Text
        }
    }
}
```

**Why Wrong:**
- Creates separate SwiftUI view overlaying grid
- Uses SF Symbols (high-res vector graphics)
- Uses native Text rendering (not pixel-based)
- Violates "zero chrome outside grid" principle

### ✅ CORRECT (Story 1.2 Target Implementation)

```swift
// PIXEL-BASED INTEGRATED RENDERING
class PixelGridUIView: UIView {
    override func draw(_ rect: CGRect) {
        // ... existing grid rendering ...

        // Menu column as leftmost pixel columns
        renderMenuColumn(isExpanded: menuExpanded)
    }

    func renderMenuColumn(isExpanded: Bool) {
        let menuWidth = isExpanded ? 5 : 1  // pixel column count

        for col in 0..<menuWidth {
            for row in 0..<ROWS {
                // Render menu icons as pixel art
                if col == 0 && row == 2 {
                    renderPlayIcon(at: (col, row))  // 3×3 triangle
                }
                // Render labels using 3×5 pixel font
                if isExpanded && row == 2 {
                    renderPixelText("Play", at: (col + 1, row))
                }
            }
        }
    }
}
```

**Why Correct:**
- Menu integrated into PixelGridUIView (no separate views)
- Icons rendered as pixel art patterns
- Text rendered using custom 3×5 pixel font
- Seamless integration with main grid (same pixel size/gaps)

---

## References

**Documentation:**
- UX Design Specification: Design System Foundation (lines 759-920)
- UX Design Specification: Pixel-Based UI Patterns (lines 805-845)
- Architecture Document: Unified Pixel Grid (Story 1-1 implementation notes)
- Project Context: UI Rendering Architecture (Critical Implementation Rules)

**Implementation:**
- Story 1-1: Unified grid architecture with menu integration
- Story 1-2: Collapsible menu (initially violated, requires reimplementation)
- `docs/prototype_sequencer.jsx`: Web implementation reference

**Prior Art:**
- PICO-8: 16-color palette, 128×128 pixel constraint-as-feature
- Bitsy: 8×8 pixel room design with custom font rendering
- MicroStudio: Pixel-based game engine with integrated code editor

---

## Enforcement

**Code Review Checklist:**
1. Are all UI elements rendered within PixelGridUIView? (Y/N)
2. Does implementation use SF Symbols or native SwiftUI text? (Y/N - should be No)
3. Is there a separate SwiftUI view overlaying the grid? (Y/N - should be No)
4. Do all pixels use same size/gaps as main grid? (Y/N)

**Automated Detection:**
- Grep for: `Image(systemName:`, `Text(`, `Button(`, `HStack {` in Views/ (should only appear in UIViewRepresentable wrappers)
- Build warning: Any UIKit view outside PixelGridUIView
- Unit test: Validate pixel font glyph rendering matches prototype

**Review Authority:**
- Visual component stories require UX design review
- Architectural violations auto-block PR merge
- TestFlight beta feedback validates icon/font comprehension

---

## History

- **2026-01-02:** Decision accepted based on UX design specification
- **2026-01-03:** Story 1.2 violation documented, ADR created as enforcement mechanism
- **2026-01-03:** Added to project-context.md as "UI Rendering Architecture" section

---

**Next Review:** After Epic 1 completion (Story 1-7 done)
**Success Criteria:** Zero architectural violations in Epic 1 Stories 1-3 through 1-7
