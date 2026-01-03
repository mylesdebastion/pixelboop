# BMAD Workflow Improvements: Preventing Architectural Violations

**Date:** 2026-01-03
**Issue:** Story 1.2 violated pixel-only UI constraint despite comprehensive documentation
**Root Cause:** Fresh context dev agents don't load/apply architectural constraints from UX specs

---

## Executive Summary

Story 1.2 was implemented with high-resolution SwiftUI controls instead of pixel-based rendering, violating PixelBoop's core "100% Custom Pixel-Based Design System" constraint. This occurred because:

1. **project-context.md** doesn't include pixel-only UI constraint
2. **create-story workflow** doesn't extract UI rendering constraints from UX spec into story Dev Notes
3. **dev-story workflow** doesn't mandate reading previous story learnings or UX design spec
4. **Fresh context dev agents** rely solely on project-context.md and story file - never see UX design specification

### Impact
- Story 1.2 requires complete reimplementation (~4-6 hours)
- Stories 1-3 to 1-7 at high risk without fixes
- User trust damaged (4-5 hours planning invalidated by implementation)

### Solution Summary
Inject architectural constraints at **4 critical points** in BMAD workflow:
1. **project-context.md** (IMMEDIATE - highest ROI)
2. **create-story workflow** (architecture extraction)
3. **dev-story workflow** (previous story context loading)
4. **Story template** (explicit architectural constraints section)

---

## Analysis: How Dev Agents Get Context

### Current Context Loading Flow

```
dev-story workflow executes
  ↓
Step 1: Find story file (sprint-status.yaml autodiscovery or user-provided)
  ↓
Step 2: Load project context
  → Loads: project-context.md (if exists)
  → Loads: Story file (AC, Tasks, Dev Notes)
  ↓
Step 3-10: Implementation without re-checking architecture
```

**❌ What's Missing:**
- No UX design specification loading
- No previous story implementation notes
- No architectural decision record (ADR) loading
- No cross-story pattern validation

### What Dev Agent Sees vs. What It Needs

| Context Source | Current State | Needed For Story 1.2 |
|---|---|---|
| **project-context.md** | Loaded ✅ | Missing pixel-only UI rule ❌ |
| **Story 1.2 file** | Loaded ✅ | Dev Notes missing constraint ❌ |
| **Story 1.1 notes** | NOT loaded ❌ | Had critical architectural fix warning ✅ |
| **UX design spec** | NOT loaded ❌ | Has pixel-only UI requirement ✅ |
| **Architecture doc** | NOT loaded (create-story uses it) ❌ | Has unified grid architecture ✅ |

---

## Recommended Fixes (Priority Order)

### 🔥 FIX #1: Update project-context.md (IMMEDIATE)

**Why This is #1 Priority:**
- Dev agents **always** load this file in Step 2
- Single source of truth for all stories
- Highest ROI: 5 minutes work, prevents all future UI violations

**Implementation:**

Add new section to `/Users/dbi/Documents/GitHub/pixelboop/_bmad-output/project-context.md`:

```markdown
### UI Rendering Architecture (CRITICAL)

**Pixel-Only UI Constraint (NON-NEGOTIABLE):**
- ❌ NEVER use SwiftUI Text, Image, Button, or any native UI components for app content
- ❌ NEVER use SF Symbols (Image(systemName:)) for icons
- ❌ NEVER overlay SwiftUI views on top of pixel grid
- ✅ ALL visual elements rendered within unified PixelGridUIView using CoreGraphics
- ✅ Icons rendered as pixel art patterns (e.g., play = 3×3 triangle pixels)
- ✅ Text rendered using 3×5 pixel font (NOT native Text views)
- ✅ Menu controls are leftmost columns of same pixel grid (NOT separate views)

**Rationale:**
PixelBoop uses "100% Custom Pixel-Based Design System with zero UI elements outside the 44×24 pixel grid" (UX Design Specification). The grid IS the interface. Every pixel serves musical purpose. Zero chrome.

**Architectural Pattern:**
- Single `PixelGridUIView` (UIKit) renders entire interface
- Menu column = leftmost N pixel columns (e.g., 1 col collapsed, 5 cols expanded)
- 1px black divider between menu columns and sequencer columns
- All pixels use same size/gaps - seamless integration
- SwiftUI wrapper via UIViewRepresentable for state management only

**Violation Detection:**
If you see ANY of these in code, it's wrong:
- `Text("label")` - Should be 3×5 pixel font rendered in CoreGraphics
- `Image(systemName: "play.fill")` - Should be pixel art pattern
- Separate `MenuView`, `ButtonView`, etc. - Should be integrated into PixelGridUIView
- `HStack`, `VStack` containing UI chrome - Should be pixel columns/rows

**References:**
- UX Design Specification: Design System Foundation (lines 759-920)
- Architecture: Unified Pixel Grid (Story 1-1 implementation notes)
- Story 1-1: CRITICAL ARCHITECTURAL FIX documenting this exact constraint
```

**File to Modify:** `_bmad-output/project-context.md`
**Section:** Add after "Framework-Specific Rules", before "Testing Rules"
**Lines to Add:** ~40 lines
**Risk:** None - purely additive

---

### 🔧 FIX #2: Enhance create-story Workflow (IMPORTANT)

**Why This Matters:**
- Prevents issues at story creation time (earlier = better)
- Extracts UI constraints from UX spec into story Dev Notes
- Fresh dev agents see constraint in story file itself

**Current State Analysis:**

File: `_bmad/bmm/workflows/4-implementation/create-story/instructions.xml`

**Step 3** (Architecture analysis) currently:
```xml
<step n="3" goal="Architecture analysis for developer guardrails">
  <action>Systematically analyze architecture content for story-relevant requirements</action>
  <!-- Extracts: technical stack, code structure, API patterns, etc. -->
</step>
```

**Missing:** Explicit UX design specification analysis for visual component stories

**Recommended Enhancement:**

Add new step after Step 3:

```xml
<step n="3.5" goal="UX and visual constraints analysis">
  <critical>🎨 VISUAL COMPONENT ANALYSIS - Extract UI rendering constraints!</critical>

  <check if="story involves visual components (keywords: UI, render, display, menu, button, icon, text)">
    <action>Load UX design specification: {ux_content}</action>

    <action>Extract UI rendering architecture requirements:
      - Design system choice (native vs. custom vs. pixel-based)
      - UI component rendering approach (SwiftUI native vs. custom rendering)
      - Visual element constraints (chrome allowed vs. chrome-free)
      - Layout patterns (overlays vs. integrated vs. unified)
      - Typography approach (native fonts vs. pixel fonts)
      - Icon rendering (SF Symbols vs. custom vs. pixel art)
    </action>

    <check if="UX spec defines custom design system (e.g., pixel-only)">
      <action>Extract complete design system constraints</action>
      <action>Add to story Dev Notes under new "Architectural Constraints" subsection:
        - Rendering approach (e.g., "Pixel-only UI - NO SwiftUI chrome")
        - Prohibited patterns (e.g., "NEVER use Text, Image, Button components")
        - Required patterns (e.g., "ALL UI rendered in PixelGridUIView CoreGraphics")
        - Violation examples (e.g., "If you see Image(systemName:), it's wrong")
        - Reference sections (e.g., "UX Design Spec lines 759-920")
      </action>
    </check>

    <check if="previous story in epic involved UI work">
      <action>Load previous story implementation notes</action>
      <action>Extract UI patterns established (e.g., "Story 1-1 unified grid architecture")</action>
      <action>Add to story Dev Notes: "Previous Story Pattern: [description]"</action>
    </check>
  </check>

  <check if="story does NOT involve visual components">
    <action>Skip UX analysis - not relevant to this story</action>
  </check>
</step>
```

**Story Dev Notes Template Enhancement:**

Add new subsection to story template (after "Dev Notes" header):

```markdown
## Dev Notes

### Architectural Constraints

**[Auto-populated by create-story workflow if visual components detected]**

**UI Rendering:** [Design system approach]
**Prohibited:** [List of anti-patterns]
**Required:** [List of required patterns]
**Violation Detection:** [How to spot mistakes]
**References:** [UX/Architecture doc sections]

### Architecture Context
[Existing content...]
```

**Files to Modify:**
1. `_bmad/bmm/workflows/4-implementation/create-story/instructions.xml` (add Step 3.5)
2. `_bmad/bmm/workflows/4-implementation/create-story/template.md` (add Architectural Constraints subsection)

**Risk:** Medium - changes story generation workflow
**Testing:** Create test story for visual component (e.g., Story 1-3) and verify constraint extraction

---

### 📖 FIX #3: Enhance dev-story Workflow (GOOD TO HAVE)

**Why This Helps:**
- Adds safety net even if create-story missed constraint
- Loads previous story learnings for cross-story pattern validation
- Provides architectural compliance checkpoint before implementation

**File:** `_bmad/bmm/workflows/4-implementation/dev-story/instructions.xml`

**Enhancement 1: Load Previous Story Context (Step 2)**

Add to Step 2 after "Load {project_context}":

```xml
<step n="2" goal="Load project context and story information">
  <critical>Load all available context to inform implementation</critical>

  <action>Load {project_context} for coding standards and project-wide patterns (if exists)</action>

  <!-- NEW: Load previous story context -->
  <check if="story_num > 1">
    <action>Extract epic_num and story_num from story_key (e.g., "1-2-user-auth" → epic=1, story=2)</action>
    <action>Calculate previous_story_num = story_num - 1</action>
    <action>Find previous story file: {story_dir}/{epic_num}-{previous_story_num}-*.md</action>

    <check if="previous story file exists">
      <action>Read previous story implementation notes:</action>
      <action>  - Dev Agent Record → Implementation Notes</action>
      <action>  - Dev Agent Record → Completion Notes</action>
      <action>  - Change Log (most recent entry)</action>
      <action>  - Look for keywords: "CRITICAL", "ARCHITECTURAL", "IMPORTANT", "VIOLATION", "FIX"</action>

      <action>Extract architectural decisions/patterns from previous story</action>
      <action>Note any warnings or learnings relevant to current story</action>

      <output>📚 **Previous Story Context Loaded** (Story {epic_num}-{previous_story_num})

        Key Learnings: [summarize architectural patterns, warnings, fixes]
        Files Created: [list new files from previous story]
        Patterns Established: [architectural decisions]
      </output>
    </check>
  </check>

  <!-- Existing content -->
  <action>Parse sections: Story, Acceptance Criteria, Tasks/Subtasks, Dev Notes...</action>
</step>
```

**Enhancement 2: Architectural Compliance Checkpoint (Step 5)**

Add to Step 5 before implementation begins:

```xml
<step n="5" goal="Implement task following red-green-refactor cycle">
  <critical>FOLLOW THE STORY FILE TASKS/SUBTASKS SEQUENCE EXACTLY AS WRITTEN - NO DEVIATION</critical>

  <!-- NEW: Architectural compliance check before implementation -->
  <action>Review story Dev Notes → Architectural Constraints section (if exists)</action>
  <action>Review project-context.md → Critical Implementation Rules → UI Rendering Architecture (if exists)</action>
  <action>Review previous story context → architectural patterns (if loaded)</action>

  <check if="current task involves UI/visual components">
    <action>Validate planned approach against constraints:
      - Does implementation use prohibited patterns? (e.g., SwiftUI Text/Image for pixel-only UI)
      - Does implementation follow required patterns? (e.g., CoreGraphics rendering for pixel UI)
      - Does implementation match previous story patterns? (e.g., unified grid architecture)
    </action>

    <check if="planned approach violates architectural constraints">
      <output>⚠️ **ARCHITECTURAL VIOLATION DETECTED**

        Planned: [description of what you were about to implement]
        Constraint: [which constraint would be violated]
        Required: [correct approach per constraints]

        Halting implementation to prevent violation.
      </output>
      <action>HALT - Request clarification or adjust approach to comply</action>
    </check>
  </check>

  <!-- Existing implementation continues -->
  <action>Review the current task/subtask from the story file...</action>
</step>
```

**Files to Modify:**
1. `_bmad/bmm/workflows/4-implementation/dev-story/instructions.xml` (Step 2 and Step 5 enhancements)

**Risk:** Low - purely additive safety checks
**Testing:** Run dev-story on Story 1-3 and verify previous story context loads

---

### 📋 FIX #4: Create Architectural Decision Record (OPTIONAL BUT RECOMMENDED)

**Why This Helps:**
- Single source of truth for non-negotiable architectural decisions
- Easier to reference than 2500-line UX spec
- Can be loaded by dev-story workflow for critical decisions

**Implementation:**

Create new file: `docs/architectural-decisions/001-pixel-only-ui.md`

```markdown
# ADR 001: Pixel-Only UI Design System

**Status:** Accepted
**Date:** 2026-01-02
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

---

**Next Review:** After Epic 1 completion (Story 1-7 done)
**Success Criteria:** Zero architectural violations in Epic 1 Stories 1-3 through 1-7
```

**File to Create:** `docs/architectural-decisions/001-pixel-only-ui.md`

**Integration with Workflows:**

Update dev-story Step 2 to load ADRs:

```xml
<action>Check for architectural decision records: docs/architectural-decisions/*.md</action>
<action>Load any ADRs relevant to current story domain (UI, audio, storage, etc.)</action>
<action>Include ADR constraints in implementation planning</action>
```

**Risk:** None - purely documentation
**Benefit:** High - single source of truth, easier to maintain than repeating in each story

---

## UX Design Specification Sharding Analysis

**Current State:**
- File: `_bmad-output/planning-artifacts/ux-design-specification.md`
- Size: 2,526 lines
- Sections: Executive Summary, Core Experience, Emotional Response, UX Patterns, Design System, Defining Experience, etc.

**Context Window Impact:**
- Claude Sonnet 4.5: 200K tokens (~150K words ~500K characters ~100K lines)
- UX spec: ~2.5K lines = ~2.5% of context window
- **Verdict:** NOT prohibitively large, but sharding would help with targeted loading

### Sharding Option A: Section-Based Sharding

Create separate files for major sections:

```
ux-design-specification/
├── index.md (table of contents + cross-references)
├── 01-executive-summary.md (~200 lines)
├── 02-target-users.md (~400 lines)
├── 03-core-experience.md (~300 lines)
├── 04-design-system-foundation.md (~500 lines) ← Contains pixel-only UI
├── 05-design-opportunities.md (~300 lines)
├── 06-emotional-response.md (~300 lines)
└── 07-ux-patterns.md (~500 lines)
```

**Pros:**
- Workflows can load specific sections (e.g., create-story loads section 4 for UI stories)
- Easier to navigate for humans
- Parallel loading possible in create-story workflow

**Cons:**
- Cross-references between sections more complex
- Index maintenance overhead
- Breaking changes to existing references

### Sharding Option B: Critical Constraints Extract

Create lightweight "critical-constraints.md" with ONLY non-negotiables:

```
ux-design-specification.md (full spec - 2526 lines, unchanged)
ux-critical-constraints.md (new - ~300 lines)
  ├── Pixel-Only UI Constraint
  ├── Gesture Vocabulary Requirements
  ├── Visual-Audio Equivalence Rules
  ├── Discovery-Driven UX Principles
  └── Cross-Platform Compatibility Rules
```

**Pros:**
- Minimal disruption (original file unchanged)
- Dev agents load small critical file + full spec on-demand
- Easy to maintain (update both when UX changes)

**Cons:**
- Duplication risk (must update both files)
- Which file is "source of truth"?

### Sharding Option C: Don't Shard, Optimize Loading

Keep single file but improve workflow targeting:

```xml
<!-- create-story workflow enhancement -->
<check if="story involves visual components">
  <action>Load UX spec section: Design System Foundation (lines 759-920)</action>
  <action>Extract pixel-only UI constraints specifically</action>
</check>
```

**Pros:**
- No file structure changes
- Workflows read only relevant sections
- Single source of truth

**Cons:**
- Requires line number maintenance (brittle)
- Harder to parallelize loading

### Recommendation: **Option C (Don't Shard) + Option B (Critical Constraints Extract)**

**Rationale:**
1. Keep `ux-design-specification.md` as single source of truth (humans + deep analysis)
2. Create `ux-critical-constraints.md` as distilled agent reference (dev agents + create-story)
3. project-context.md includes pixel-only UI rule (immediate safety net)

**Implementation:**
1. Create `_bmad-output/planning-artifacts/ux-critical-constraints.md` (~300 lines)
2. Update create-story workflow to load critical constraints for visual stories
3. Update dev-story workflow to reference critical constraints in Step 5 compliance check
4. Maintain both files: UX spec = full documentation, critical constraints = agent reference

**Maintenance:**
- When UX spec changes, update critical constraints if constraint-related
- Quarterly review: prune critical constraints that become obvious
- Add new constraints when violations occur (continuous improvement)

---

## Implementation Plan

### Phase 1: Immediate Fixes (Before Story 1.3)

1. **Update project-context.md** (5 minutes)
   - Add "UI Rendering Architecture" section with pixel-only UI constraint
   - Test: Read project-context.md, verify constraint is clear

2. **Create ADR 001** (15 minutes)
   - Write `docs/architectural-decisions/001-pixel-only-ui.md`
   - Test: Read ADR, verify violation examples are clear

3. **Create UX Critical Constraints** (30 minutes)
   - Extract critical constraints from UX spec (lines 759-920, 500-650, etc.)
   - Write `_bmad-output/planning-artifacts/ux-critical-constraints.md`
   - Test: Read critical constraints, verify pixel-only UI is prominent

**Timeline:** 50 minutes
**Risk:** None - purely additive documentation
**Validation:** Run create-story for Story 1-3, manually verify constraint appears in Dev Notes

### Phase 2: Workflow Enhancements (Before Epic 2)

4. **Enhance create-story workflow** (1 hour)
   - Add Step 3.5: UX and visual constraints analysis
   - Update story template with "Architectural Constraints" subsection
   - Test: Create test story for visual component, verify constraint extraction

5. **Enhance dev-story workflow** (1 hour)
   - Update Step 2: Load previous story context
   - Update Step 5: Architectural compliance checkpoint
   - Test: Run dev-story on test story, verify compliance check triggers

**Timeline:** 2 hours
**Risk:** Low - mostly additive, need testing on non-production stories
**Validation:** Run full cycle (create-story → dev-story) for test story

### Phase 3: Continuous Improvement (Ongoing)

6. **Monitor Epic 1 Stories 1-3 to 1-7** (during implementation)
   - Watch for architectural violations
   - Update critical constraints if new patterns emerge
   - Refine workflow checkpoints based on real-world agent behavior

7. **Epic 1 Retrospective** (after Story 1-7)
   - Validate: Zero architectural violations in remaining stories
   - Document: Patterns established, lessons learned
   - Update: project-context.md, ADRs, workflows based on learnings

**Timeline:** Throughout Epic 1
**Risk:** None - observation and refinement
**Validation:** Epic 1 retrospective shows zero repeat violations

---

## Success Criteria

### Immediate (Stories 1-3 to 1-7)
- ✅ No architectural violations in remaining Epic 1 stories
- ✅ Dev agents reference pixel-only UI constraint in implementation notes
- ✅ Code review catches any violations before completion (if any occur)

### Medium-Term (Epic 2-5)
- ✅ Create-story workflow extracts constraints into story Dev Notes automatically
- ✅ Dev-story workflow loads previous story context by default
- ✅ Zero violations across all visual component stories

### Long-Term (Epic 6-13)
- ✅ Architectural Decision Records cover all non-negotiable constraints
- ✅ Project-context.md is definitive quick reference for agents
- ✅ UX critical constraints maintained in sync with full UX spec
- ✅ Workflow enhancements proven effective across multiple epics

---

## Appendix: Workflow File Locations

### Key Files to Modify

```
_bmad-output/
├── project-context.md ← ADD: UI Rendering Architecture section
├── planning-artifacts/
│   └── ux-critical-constraints.md ← CREATE: Distilled agent reference
│
_bmad/bmm/workflows/4-implementation/
├── create-story/
│   ├── instructions.xml ← ENHANCE: Add Step 3.5 (UX constraints)
│   └── template.md ← ENHANCE: Add Architectural Constraints subsection
└── dev-story/
    └── instructions.xml ← ENHANCE: Steps 2 & 5 (previous context + compliance)

docs/
└── architectural-decisions/
    └── 001-pixel-only-ui.md ← CREATE: Non-negotiable decision record
```

### Testing Files

```
_bmad-output/implementation-artifacts/
├── test-story-ui-component.md ← CREATE: Test story for workflow validation
└── test-story-implementation-notes.md ← Document: Test run results
```

---

## Questions for User

1. **Immediate Action:** Should I proceed with Phase 1 (update project-context.md, create ADR, create UX critical constraints) now?

2. **UX Spec Sharding:** Do you prefer:
   - **Option A:** Don't shard (keep single file)
   - **Option B:** Shard by section (7 separate files)
   - **Option C:** Create critical constraints extract + keep full spec

3. **Workflow Enhancements:** Should I implement Phase 2 (enhance create-story and dev-story workflows) now or defer until after Epic 1 completion?

4. **Story 1.2 Reimplementation:** Should we reimplement Story 1.2 now (using updated project-context.md) or continue with Story 1-3 to 1-7 and circle back?

5. **ADR Process:** Do you want ADRs for other architectural decisions (e.g., lock-free ring buffer, JSON compatibility, offline-first) or just critical UI constraints for now?

---

**Document Status:** Complete - Ready for User Review
**Next Actions:** Awaiting user decisions on questions 1-5
