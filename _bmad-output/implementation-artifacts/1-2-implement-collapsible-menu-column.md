# Story 1.2: Implement Collapsible Menu Column UI

Status: ready-for-dev

---

## Story

As a **user**,
I want **to access controls through a collapsible menu column that doesn't obscure my creative canvas**,
So that **I have grid-only immersion when focused on creation, but full controls available when needed**.

---

## Acceptance Criteria

**Given** the grid is displayed with menu column placeholder (Story 1.1)
**When** I tap the menu column area
**Then** the menu expands from collapsed state (~60px icon-only) to expanded state (~250px full controls) (FR104)
**And** the menu displays icon-only buttons in collapsed state (FR105)
**And** the menu displays full labeled controls in expanded state (FR106)
**And** tapping the expanded menu collapses it back to icon-only state
**And** the menu transition animation is smooth (<300ms)
**And** the menu state persists across app restarts (remembers last state)
**And** the menu works without edge-swipe gestures (hardware controller compatible, FR107)

---

## Requirements References

**Functional Requirements:**
- FR103: System displays collapsible menu column adjacent to grid on devices with horizontal space
- FR104: Users can expand/collapse menu column by tapping collapsed menu area
- FR105: Menu column displays icon-only controls in collapsed state
- FR106: Menu column displays full labeled controls in expanded state
- FR107: Menu system works identically on hardware controllers (no edge-swipe gestures)

**Non-Functional Requirements:**
- NFR1: Visual rendering at 60 FPS on target devices
- NFR49: All interactive UI elements must have VoiceOver accessibility labels

---

## Tasks / Subtasks

- [ ] Task 1: Create MenuViewModel for state management
  - [ ] Create MenuViewModel.swift in ViewModels folder
  - [ ] Add @Published isExpanded: Bool property
  - [ ] Implement toggleMenuState() method
  - [ ] Add UserDefaults persistence for menu state
  - [ ] Write unit tests for MenuViewModel

- [ ] Task 2: Create MenuColumnView SwiftUI component
  - [ ] Create MenuColumnView.swift in Views folder
  - [ ] Implement collapsed state layout (icon-only, ~60px width)
  - [ ] Implement expanded state layout (full controls, ~250px width)
  - [ ] Add smooth expand/collapse animation (<300ms ease-in-out)
  - [ ] Add 1px separator line between grid and menu

- [ ] Task 3: Create ControlButtonView reusable component
  - [ ] Create ControlButtonView.swift in Views folder
  - [ ] Support icon-only mode (collapsed menu)
  - [ ] Support icon+label mode (expanded menu)
  - [ ] Add VoiceOver accessibility labels
  - [ ] Add haptic feedback on tap (UIImpactFeedbackGenerator)

- [ ] Task 4: Implement tap gesture for menu toggle
  - [ ] Add tap gesture recognizer to MenuColumnView
  - [ ] Call MenuViewModel.toggleMenuState() on tap
  - [ ] Ensure gesture works in both collapsed and expanded states
  - [ ] Verify no conflicts with grid gestures

- [ ] Task 5: Integrate MenuColumnView into SequencerView layout
  - [ ] Update SequencerView.swift to include HStack: [PixelGridView, MenuColumnView]
  - [ ] Pass MenuViewModel as @ObservedObject to MenuColumnView
  - [ ] Verify layout adapts correctly to different device sizes
  - [ ] Test on iPhone SE, iPhone 15 Pro Max

- [ ] Task 6: Add placeholder control buttons
  - [ ] Add Play/Stop button to menu (functional implementation in later stories)
  - [ ] Add BPM control placeholder
  - [ ] Add Scale selection placeholder
  - [ ] Add Undo/Redo placeholders
  - [ ] All buttons display correctly in both states

- [ ] Task 7: Testing and validation
  - [ ] Write unit tests for MenuViewModel state management
  - [ ] Write UI tests for menu expand/collapse interaction
  - [ ] Verify VoiceOver announces menu state ("Menu collapsed", "Menu expanded")
  - [ ] Test menu state persistence across app restarts
  - [ ] Verify 60 FPS performance maintained

---

## Dev Notes

### Architecture Context

**MVVM Pattern:**
- **Model**: None (menu state is UI state, not domain data)
- **ViewModel**: MenuViewModel (menu state management, expand/collapse logic, persistence)
- **View**: MenuColumnView (SwiftUI layout, animation, tap gesture)

**Component Hierarchy:**
```
SequencerView (main container)
├── PixelGridView (44×24 grid)
└── MenuColumnView (collapsible menu)
    ├── MenuViewModel (@ObservedObject)
    └── ControlButtonView (reusable buttons)
        ├── Icon (SF Symbol)
        └── Label (optional, visible when expanded)
```

### Technical Requirements

**MenuViewModel State:**
```swift
class MenuViewModel: ObservableObject {
    @Published var isExpanded: Bool = false

    func toggleMenuState() {
        isExpanded.toggle()
        UserDefaults.standard.set(isExpanded, forKey: "menuExpanded")
    }

    init() {
        isExpanded = UserDefaults.standard.bool(forKey: "menuExpanded")
    }
}
```

**Menu Column Widths:**
```swift
let COLLAPSED_WIDTH: CGFloat = 60  // Icon-only
let EXPANDED_WIDTH: CGFloat = 250  // Full controls with labels
let SEPARATOR_WIDTH: CGFloat = 1   // Black separator line
```

**Animation Parameters:**
```swift
.animation(.easeInOut(duration: 0.3), value: menuViewModel.isExpanded)
```

**Layout Strategy:**
```swift
HStack(spacing: 0) {
    PixelGridView(...)

    Rectangle()
        .fill(Color.black)
        .frame(width: SEPARATOR_WIDTH)

    MenuColumnView(viewModel: menuViewModel)
        .frame(width: menuViewModel.isExpanded ? EXPANDED_WIDTH : COLLAPSED_WIDTH)
}
```

### Menu Column Button Layout

**Collapsed State (Icon-Only, 60px wide):**
```
┌──────────┐
│    ▶︎    │ Play/Stop
│    ↻     │ Undo
│    ↺     │ Redo
│   120    │ BPM
│   C♯     │ Scale
│    ⚙     │ Settings
└──────────┘
```

**Expanded State (Full Controls, 250px wide):**
```
┌───────────────────────────┐
│  ▶︎  Play                  │
│  ↻  Undo                  │
│  ↺  Redo                  │
│  BPM: [120] [−] [+]       │
│  Scale: [C♯] [Major ▾]    │
│  ⚙  Settings              │
└───────────────────────────┘
```

### Accessibility Requirements

**VoiceOver Labels:**
- Collapsed menu button: "Menu, collapsed. Tap to expand controls."
- Expanded menu area: "Menu, expanded. Tap to collapse."
- Individual buttons: "Play", "Stop", "Undo", "Redo", etc.

**VoiceOver Announcements:**
- On expand: Announce "Menu expanded"
- On collapse: Announce "Menu collapsed"

### Hardware Controller Compatibility

**Design Constraint (FR107):**
- Menu toggle must work via direct tap (not edge-swipe gesture)
- This ensures compatibility with hardware grid controllers (Erae Touch 2, Launchpad) in Phase 3
- Edge-swipe gestures don't translate to physical controller buttons

### Performance Requirements

**60 FPS Target:**
- Menu animation must not drop frames
- Use SwiftUI's `.animation()` modifier (hardware-accelerated)
- Avoid complex view hierarchies in menu (keep it simple)

**Optimization:**
- Menu buttons rendered once, not on every frame
- State changes trigger minimal re-renders

### Cross-Platform Consistency

**Pattern Compatibility:**
- Menu column is iOS-specific enhancement (web version may differ)
- Grid rendering remains 44×24 (pattern compatibility intact)
- Controls in menu will eventually match web version's control row functionality

### Testing Strategy

**Unit Tests:**
- MenuViewModel state toggles correctly
- UserDefaults persistence works (save/load menu state)
- MenuViewModel initializes with saved state

**UI Tests:**
- Tap collapsed menu → expands to 250px
- Tap expanded menu → collapses to 60px
- Menu state persists after app restart
- VoiceOver announces menu state changes

**Device Testing:**
- iPhone SE: Verify collapsed menu doesn't feel cramped
- iPhone 15 Pro Max: Verify expanded menu uses space well
- iPad: Verify menu layout adapts appropriately

### Known Constraints

**Horizontal Space Limitations:**
- On very narrow devices (iPhone SE portrait), expanded menu (250px) may feel wide
- Future enhancement: Adaptive expanded width based on available space
- For MVP: Fixed 60px collapsed, 250px expanded

**Control Functionality:**
- This story creates UI structure only
- Actual control functionality (play/stop, BPM, etc.) implemented in Story 1.3 and later stories

### Integration Points

**Dependencies:**
- Story 1.1 must be complete (menu column placeholder exists)
- MenuViewModel must be created before MenuColumnView

**Blocks:**
- Story 1.3 (Migrate Controls to Menu) depends on this story's MenuColumnView structure

---

## Project Context Reference

See `docs/project-context.md` for:
- Complete coding standards and conventions
- SwiftUI best practices
- Accessibility requirements
- Testing strategies

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
- [ ] Performance validated (60 FPS)
- [ ] Tested on multiple device sizes
- [ ] Unit tests passing
- [ ] UI tests passing
- [ ] No warnings or errors in Xcode
- [ ] Ready for code review

### File List

**To be created:**
- `pixelboop/ViewModels/MenuViewModel.swift`
- `pixelboop/Views/MenuColumnView.swift`
- `pixelboop/Views/ControlButtonView.swift`
- `pixelboopTests/MenuViewModelTests.swift`
- `pixelboopUITests/MenuColumnUITests.swift`

**To be modified:**
- `pixelboop/Views/SequencerView.swift` (integrate MenuColumnView)

### Change Log

- 2026-01-03: Story created as part of Sprint Change Proposal (Adaptive Menu Column System)
