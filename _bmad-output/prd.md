---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
inputDocuments:
  - docs/prd.md (reference - existing PRD draft)
  - prototype_sequencer.jsx (reference - React prototype code)
documentCounts:
  briefs: 1
  research: 0
  brainstorming: 0
  projectDocs: 0
workflowType: 'prd'
lastStep: 11
workflowComplete: true
completionDate: '2025-12-18'
project_name: 'pixelboop'
user_name: 'Myles'
date: '2025-12-18'
---

# Product Requirements Document - pixelboop

**Author:** Myles
**Date:** 2025-12-18

## Executive Summary

**PixelBoop** is a multi-platform gesture-based music sequencer that makes music creation feel like play. Built on a 44×24 pixel grid interface, it transforms touch gestures into musical phrases through intelligent interpretation - horizontal drags create arpeggios, vertical gestures build chords, diagonal movements craft melodies. The system features real-time audio synthesis with a 4-track engine (melody, chords, bass, rhythm), pattern-based sequencing, and built-in musical intelligence (scale snapping, automatic chord voicing) that ensures users can't make "wrong" notes.

The product targets a spectrum from complete beginners intimidated by traditional DAWs to professional producers seeking rapid mobile sketching tools. Non-musicians find it approachable and fun ("like doodling with sound"), while experienced creators appreciate its gestural efficiency and constraint-driven creativity. The 44×24 grid limitation becomes a feature, forcing melodic thinking over track accumulation.

**Implementation Strategy:**
- **Phase 1 (MVP):** Web app at `pixelboop.audiolux.app`, integrated with jam.audiolux.app tech stack for rapid user testing and feedback validation
- **Phase 2:** iOS native app with <10ms audio latency, $0.99 App Store release to validate market demand
- **Phase 3 (Kickstarter potential):** MIDI output per track (trigger external synths), USB/Bluetooth MIDI I/O, USB audio output, hardware controller integration (Erae Touch 2, Launchpad), song/pattern export, and live performance capabilities
- **Marketing Hub:** `www.pixelboop.com` landing page directing to both iOS App Store and Audiolux web version

**Audiolux Framework Integration:**
PixelBoop embodies the Audiolux framework's core principle: teaching music through visual and gestural interaction rather than traditional notation. Users learn music theory accidentally through spatial experimentation - discovering that vertical gestures create chord stacks, understanding note relationships through color-coded pitches, and internalizing rhythm through the grid's temporal structure. It's musical education disguised as playful discovery.

### What Makes This Special

**"An instrument that feels like a game, disguised as a toy, that teaches music accidentally."**

PixelBoop succeeds across multiple user dimensions:

1. **Discovery-Driven Gamification:** Features aren't tutorial-gated but discovered through experimentation. Hidden combo presses reveal secret functions, delivering dopamine hits when users uncover them. Shake-to-clear, double-swipe-undo, hold-drag-sustain - each discovery feels like finding a secret move in a classic game.

2. **"Boopy" Brand Personality:** Cute pixel aesthetic that appears simple yet hides sophisticated depth. The low-resolution constraint is embraced as charm, creating a "pixel DAW" aesthetic that invites rather than intimidates. Visual identity balances approachability (newcomer-friendly) with capability (pro-level synthesis).

3. **Immediate Engagement Without Barriers:** Unlike GarageBand's overwhelming menus or traditional piano rolls, users create music within seconds of first touch. The prototype validation confirms: even non-musicians get "drawn in" and find it "seriously fun to tinker with." No music theory required, but music theory absorbed through play.

4. **Gestural Efficiency for Creators:** Professional producers appreciate rapid sketching capability - a 16-bar loop idea captured in 30 seconds on the train. Gestures replace menu diving: drag for arpeggio, stack for chord, diagonal for phrase. Export patterns to reconstruct in Ableton later. It's a musical sketchbook optimized for mobile contexts.

5. **Sensory Engagement Across Modalities:** Tactile (touch gestures), visual (color-coded notes, pixel animations), and audio (real-time synthesis) create a multi-sensory feedback loop. Pattern thinkers appreciate the visual grid structure; fidget creators find meditative satisfaction in gestural play; nostalgic gamers recognize Game Boy-era constraint-as-feature design.

6. **Performance Instrument Potential:** Advanced use cases extend to hardware controllers like Erae Touch 2, enabling live performance with MPE pressure sensitivity. The gesture vocabulary maps naturally to grid controllers, positioning PixelBoop as a performance instrument, not just composition software.

7. **Educational Foundation:** Built on Audiolux principles for visual/gestural music learning. Users internalize scale theory, chord voicing, and rhythmic structure through spatial experimentation rather than didactic instruction. Music education through joyful discovery.

**Market Positioning:** PixelBoop occupies the white space between "toy apps" (too simple, no depth) and "professional DAWs" (overwhelming, desktop-focused). It's **serious creative capability packaged in playful discovery** - constraint-driven music making that rewards exploration.

**Validation Strategy:** $0.99 iOS MVP to test market resonance. If sales reach validation threshold, launch Kickstarter for deep development: per-track MIDI output to external synths, USB/Bluetooth MIDI connectivity, USB audio output, hardware controller support, song export, and expanded synthesis. The current .jsx prototype already demonstrates the core magic - now it's about validating demand before deep investment.

## Project Classification

**Technical Type:** Multi-Platform Web + Mobile App
- **Primary (Phase 1):** Progressive Web App integrated with jam.audiolux.app tech stack
- **Secondary (Phase 2):** iOS Native App with AVFoundation audio engine
- **Future (Phase 3):** Hardware controller integration, live performance capabilities

**Domain:** Creative Tools / Music Production (with Educational elements)

**Complexity:** Medium-High
- **Technical Complexity:** Real-time audio synthesis, gesture recognition algorithms, cross-platform behavioral consistency, musical intelligence (scale snapping, chord voicing)
- **Creative Complexity:** Balancing accessibility (no barriers) with sophistication (pro-level depth)
- **Validation Complexity:** Low (MVP web app for rapid feedback)

**Project Context:** Greenfield - new product launch

**Development Approach:**
- Web-first for rapid validation leveraging existing Audiolux infrastructure
- iOS as validation of native market demand ($0.99 price point)
- Kickstarter-funded deep development contingent on market validation
- Integration with broader Audiolux ecosystem (jam.audiolux.app framework, cross-product pattern sharing)

**Key Technical Considerations:**
- Phase 1: Web Audio API with AudioWorklet for <20ms latency
- Phase 2: iOS AVFoundation with C/C++ audio thread for <10ms latency
- Shared gesture interpretation logic across platforms for behavioral consistency
- Pattern data format compatibility for cross-platform sharing

## Success Criteria

### User Success

**Core Success Signal:** Users return after the first session. PixelBoop succeeds when someone closes it, then reopens it later because they have a musical idea or just want to play.

**Beginner Success:**
- Creates first pattern within 2 minutes that "sounds good"
- Discovers their first hidden gesture through experimentation (dopamine reward)
- Shows creation to someone with pride, not embarrassment
- **Measurable:** Pattern library has 3+ saved patterns = found repeatable value

**Pro/Creator Success:**
- Captures musical idea in <60 seconds during "non-music time" (commute, waiting room)
- Exports pattern and successfully reconstructs it in their DAW
- Uses as sketching tool rather than full production environment
- **Measurable:** Weekly active use with 5+ pattern exports

**Discovery-Driven Success:**
- Finds at least 3 hidden features through experimentation (not tutorials)
- Gets "whoa!" reaction when showing someone a gesture combo
- Continues exploring after mastering basics
- **Measurable:** Session length >10 minutes after 3rd use = deeper engagement

**Educational Success (Audiolux Framework Goal):**
- Non-musician understands "vertical = chord, horizontal = arpeggio" through spatial play
- Internalizes scale relationships without sheet music
- Can explain what they learned to someone else
- **Measurable:** User-generated content showing musical understanding (social posts, pattern sharing)

### Business Success

**Phase 1 (Web MVP at pixelboop.audiolux.app):**
- **Validation Metric:** 100+ users complete first pattern AND return within 7 days = 40% retention
- **Engagement Signal:** Average 3+ patterns created per user
- **Viral Indicator:** 20% share their patterns (social/export) = worth showing others
- **Integration Success:** Seamless experience within jam.audiolux.app ecosystem

**Phase 2 (iOS $0.99 App Store):**
- **Revenue Validation:** 500 sales in first month = market wants this enough to pay
- **Worth-It Test:** 4+ star rating with reviews mentioning "fun," "intuitive," "addictive"
- **Kickstarter Threshold:** 2,000 sales OR strong community engagement = proceed to Phase 3
- **No-Refund Rate:** <5% refund requests = people feel they got their dollar's worth

**Phase 3 (Kickstarter Deep Development):**
- **Funding Goal:** $20k-50k to justify professional audio engineering investment
- **Backer Validation:** 500+ backers = community believes in deeper version
- **Stretch Goals:** Per-track MIDI output, Bluetooth MIDI, USB audio output, hardware controller integration (Erae Touch 2, Launchpad), expanded synthesis engine

**Ecosystem Integration:**
- PixelBoop patterns shareable across Audiolux suite
- Users discover Audiolux framework through PixelBoop gateway
- Cross-traffic between pixelboop.audiolux.app and jam.audiolux.app

### Technical Success

**Phase 1 (Web MVP):**
- Audio Latency: <20ms tap-to-sound (AudioWorklet implementation)
- Performance: 60 FPS grid rendering on mobile browsers
- Offline PWA: Works fully offline after first load
- Browser Support: iOS Safari, Chrome Android, desktop browsers
- Integration: Seamless auth/data sharing with jam.audiolux.app infrastructure
- Load Time: <2 seconds on 4G connection

**Phase 2 (iOS Native):**
- Audio Latency: <10ms tap-to-sound (AVFoundation with C/C++ audio thread)
- Performance: 60 FPS on iPhone 12+, works on iPhone SE 2nd gen
- App Store Approval: First-submission approval (no rejections)
- Crash-Free Rate: >99.5% crash-free sessions
- Size: <50MB app download
- Battery: <5% drain per 30 minutes active use

**Cross-Platform Consistency:**
- Gesture Parity: Identical behavior - same gesture produces same musical output
- Visual Consistency: Pixel-perfect rendering (same colors, animations, timing)
- Pattern Compatibility: Export from web, import to iOS works flawlessly
- Shared Logic: Core gesture interpretation and music theory code shared between platforms

**No-Fail Criteria (Must Work):**
- Zero Data Loss: Patterns never corrupted or lost
- No Audio Glitches: Clean audio rendering without pops/clicks
- Gesture Recognition: 95%+ gesture accuracy (doesn't misinterpret intended gesture)

### Measurable Outcomes

**3-Month Success (Post Web MVP Launch):**
- 200+ active users on pixelboop.audiolux.app
- 40% 7-day retention (users return within a week)
- Average 4+ patterns created per user
- 15%+ share/export rate
- Qualitative feedback confirms "fun to use" and "draws me in"

**6-Month Success (Post iOS Launch):**
- 1,000+ iOS sales at $0.99
- 4+ star App Store rating
- Decision point: Proceed to Kickstarter? (Yes if 2k+ sales or strong engagement)
- Zero critical bugs/crashes after first month

**12-Month Success (Kickstarter or Pivot):**
- If Kickstarter: $30k+ funded for Phase 3 development
- If pivot: Validated learnings inform Audiolux framework evolution
- PixelBoop establishes "pixel DAW" as viable category
- Community built around discovery-driven music tools

## Product Scope

### MVP - Minimum Viable Product (Phase 1: Web)

**Feature Parity with prototype_sequencer.jsx + Immersive Grid Interface:**

**Core Grid & Interface:**
- 44×24 pixel grid with 4 tracks (melody, chords, bass, rhythm)
- Immersive fullscreen grid-only interface (no external UI)
- All status information via pixel font tooltips

**Complete Gesture Vocabulary:**
- Tap: Place single note/drum hit (<300ms)
- Hold + Tap: Accented note (≥400ms hold, 2× velocity)
- Horizontal Drag: Arpeggios, runs, walking bass, drum rolls
- Vertical Drag: Chords/stacked notes
- Diagonal Drag: Melodic phrases with pitch variation
- **Hold + Drag (SUSTAINED NOTES):** ADSR envelope with velocity 2→3 fade - ESSENTIAL
- Double Tap: Erase step
- Double Swipe Left: Undo
- Double Swipe Right: Redo
- **Scrub:** Rapid left-right touch or mouse drag motion to clear all tracks (5+ direction changes)

**Audio Synthesis:**
- Real-time synthesis with track-specific timbres (sine, triangle, sawtooth)
- 12 synthesized drum sounds (kick, snare, clap, hats, crash, ride, cowbell, etc.)
- Note velocity system (1=normal, 2=accent, 3=sustain with ADSR fade)
- Complete ADSR envelope rendering for sustained notes

**Musical Intelligence:**
- Scale snapping (major, minor, pentatonic)
- Root note selection (12 chromatic notes)
- Automatic chord voicing
- Bass fifth/root patterns

**Pattern Sequencer:**
- Pattern length: 8-32 steps
- Tempo: 60-200 BPM
- Loop playback with visual playhead

**Track Controls:**
- Mute/solo per track
- Visual volume indicators

**History & Data:**
- 50-level undo/redo
- Pattern save/load with local storage
- Pattern export (JSON format)
- Auto-save on changes

**Visual Feedback:**
- Playhead, pulse animations, ghost notes
- Pixel-font tooltips for all actions and status
- Dynamic status tooltips: "120 BPM", "C MAJOR", "16 STEPS" (centered, 1200ms)
- Gesture tooltips: TAP, ACCENT!, ARPEGGIO, RUN, CHORD, WALK, ROLL, PHRASE, FILL, MULTI, ROOT+5, ERASE, CLEARED!, ~SCRUB CLEAR~, <<UNDO, REDO>>, SUSTAIN
- Color-coded tracks and chromatic notes
- Step markers, pattern overview rows

**Control Interface (Row 0):**
- Play/Stop, Undo/Redo, Scale selection, Root note picker
- Ghost notes toggle, BPM controls, Pattern length controls
- Scrub gesture visual indicator, Clear all button

**Keyboard Shortcuts:**
- Space: Play/Stop
- Cmd/Ctrl+Z: Undo/Redo
- Delete: Clear all
- Arrows: BPM adjustment

**UI Enhancement vs Prototype:**
- Remove external info bar → dynamic tooltips ("120 BPM", "C MAJOR", "16 STEPS")
- Remove external legend → discovery-driven learning
- Fullscreen mobile optimization
- PWA offline capability
- Integration with jam.audiolux.app tech stack

### Growth Features (Phase 2: iOS + Post-Launch)

**iOS Native App:**
- <10ms audio latency with AVFoundation/C++ audio thread
- Haptic feedback on note placement
- iOS Share Sheet integration
- $0.99 App Store release

**Enhanced Features:**
- Pattern library with visual thumbnails
- Pattern duplication/variation tools
- BPM tap tempo
- Copy/paste sections
- Additional scale types (harmonic minor, modes)
- Expanded pattern length options
- Pattern categories/tagging
- Community pattern sharing (if engagement warrants)
- Audio export (WAV/MP3 rendering)

### Vision (Phase 3: Kickstarter-Funded)

**Deep Development:**

**MIDI & External Audio Connectivity (Core Phase 3 Goals):**
- **MIDI Output per Track:** Each of the 4 tracks (melody, chords, bass, rhythm) can independently output MIDI to external hardware synths, software instruments, or DAWs. Users can trigger their favorite external sounds while using PixelBoop's gesture interface for composition.
- **Bluetooth MIDI Output:** Wireless MIDI transmission to Bluetooth-capable synths, iOS devices running synth apps (e.g., Moog apps, Korg Gadget), and compatible hardware. Essential for cable-free live performance setups.
- **USB MIDI Output:** Wired MIDI via Lightning/USB-C for reliable studio connections to audio interfaces, hardware synths, and DAWs.
- **USB Audio Output:** Direct audio routing to external audio interfaces for professional monitoring and recording. Enables integration with studio setups without relying on device speakers.
- **MIDI Input (Lower Priority):** Accept MIDI notes from external controllers, keyboards, or trigger pads to place notes on tracks. Enables alternative input methods beyond touch gestures - useful for users with hardware controllers or accessibility needs. Note: Gesture-based input remains primary; MIDI input is supplementary.
- **Bluetooth MIDI Input:** Receive MIDI from wireless controllers for live performance flexibility.

**UX Challenge:** All MIDI/audio configuration must be achievable through the pixel-only interface. This requires creative solutions - potentially using the song overview row (22-23) or dedicated configuration patterns accessible via gesture combinations. No external settings screens.

**Pattern & Song Export:**
- **MIDI File Export:** Export patterns/songs as standard MIDI files for import into any DAW
- **Project Save/Load:** Full song state persistence including all tracks, sections, and arrangements
- **Audio Bounce:** Render patterns to WAV/MP3 for sharing (internal synth sounds)
- **Pattern Sharing:** JSON format for PixelBoop-to-PixelBoop pattern exchange

**Hardware Controller Integration:**
- Erae Touch 2, Launchpad, Push - bidirectional control
- MPE support for expressive control (pressure, slide)
- Controller mapping configuration (pixel-UI based)

**Live Performance Features:**
- Scene launching and pattern switching
- Ableton Link sync integration
- Clock source selection (internal/external MIDI clock)
- Performance mode with accidental-clear protection

**Lighting & Visual Output (Nice-to-Have):**
- **WLED / sACN / Art-Net Output:** Stream pixel grid state to LED strips and panels in real-time. A physical LED matrix could mirror the 44×24 grid exactly, creating a stage backdrop that shows the music being created.
- **DMX Lighting Control:** Trigger stage lighting fixtures based on track activity, BPM, note events, or playback position. Full stage lighting driven entirely by PixelBoop.
- **Instrument LED Guides:** Output note data to LED strips attached to physical instruments (guitar fretboards, piano keys, drum pads) showing IRL musicians which notes to play in sync with the sequence.
- **BPM/Track Visualizers:** Dedicated LED outputs for tempo pulse, track activity meters, or section indicators for stage monitoring.
- **Protocol Support:** WLED (WiFi), sACN/E1.31 (network), Art-Net (network), DMX512 (wired via USB-DMX adapters).

**Expanded Synthesis:**
- Multiple oscillators, filters, effects (reverb, delay)
- Audio input: sample your own sounds
- Per-track sound design

**Platform Expansion:**
- Desktop versions (macOS, Windows) with audio routing
- Potential Android native (if market warrants)

**Educational Vision (Audiolux Framework Evolution):**
- Guided "discovery journeys" teaching music concepts
- Achievement system for learning milestones
- Educator dashboard for classroom use
- Student progress tracking
- Curriculum integration with music theory concepts
- Multi-user collaborative patterns

## User Journeys

### Journey 1: Sarah Santos - From Intimidation to Creation

Sarah is a 28-year-old graphic designer who's always been curious about making music but feels completely lost whenever she opens GarageBand. All those tracks, plugins, and piano roll grids make her feel stupid - like she's missing some fundamental knowledge everyone else has. One evening, scrolling through the App Store after a frustrating attempt at music creation, she finds PixelBoop for $0.99. The pixel grid aesthetic reminds her of the design tools she loves, so she takes a chance.

Opening the app, Sarah sees the 44×24 grid with cute colorful pixels. No menus. No tutorials. Just... a grid. Curious, she taps a few pixels and hears pleasant tones. She drags her finger horizontally across the melody track and gasps - it created an arpeggio that actually sounds musical. "Wait, I didn't mess that up?" She tries a vertical drag and gets a chord. Within two minutes, she has a simple 8-step loop playing that sounds... good. Really good.

The breakthrough comes when her designer friend visits and sees her playing with PixelBoop. "You made this?! I didn't know you were into music production." Sarah realizes she's been experimenting for 40 minutes and has three saved patterns - melodic loops she's actually proud of. She exports one to show her boyfriend later. For the first time, music creation doesn't feel like something she's too dumb to understand. It feels like doodling, but with sound. She opens PixelBoop the next day during lunch break just to "play around," and it becomes her creative meditation tool.

**Requirements Revealed:**
- Zero-barrier entry with no tutorials required
- Immediate musical gratification (sounds good within 2 minutes)
- Pattern save/library for preserving creations
- Export functionality for sharing outside the app
- Visual/spatial interface that doesn't require music theory knowledge

### Journey 2: Marcus Chen - Capturing Lightning in a Bottle

Marcus is a professional music producer with a full Ableton setup at home, but his best ideas always come during his 45-minute train commute. By the time he gets to his studio, the melody in his head has evaporated. He's tried Figure, GarageBand, even voice memo humming - nothing captures the *musical* idea fast enough. When he sees PixelBoop mentioned in a producer forum as a "sketching tool," he's skeptical but downloads it anyway.

First commute test: Marcus has a bass line idea. He opens PixelBoop, sets C minor scale, taps out the root notes on the bass track. Hold-drag for the sustained note - perfect. Quick arpeggio gesture on chords. The whole sketch takes 35 seconds. He exports the JSON pattern and texts it to himself. That evening in Ableton, he imports the pattern data, and there it is - his exact idea, perfectly preserved with timing and note relationships intact.

The real win comes two weeks later when Marcus pitches a client demo that started as a PixelBoop sketch on the subway. The client loves it, asks how he works so fast. Marcus grins - he's now using PixelBoop for *all* his initial ideas because the constraints force him to think melodically instead of getting lost in production details. He has 23 patterns saved and calls them his "idea bank." PixelBoop isn't his DAW - it's his musical sketchbook that fits in his pocket.

**Requirements Revealed:**
- Rapid pattern creation (<60 seconds for experienced users)
- Musical intelligence (scale snapping ensures ideas sound right)
- Pattern export in structured format (JSON for reconstruction)
- Sustained notes gesture (hold-drag for bass lines, pads)
- Integration potential with professional tools (pattern data compatibility)

### Journey 3: Jamie Lee - The Fidget Composer

Jamie has ADHD and can't sit still. They've tried meditation apps, fidget spinners, stress balls - anything to occupy their restless hands during boring meetings. Music apps never worked because they required too much *thinking*. But their partner sends them a link to PixelBoop with the message "this might be your thing."

Jamie opens it during a Zoom meeting (camera off). Starts tapping pixels. Dragging. Watching colors. Hearing sounds respond immediately. Their hands are busy, but it's not mindless - there's a creative loop happening. Tap-drag-listen-tap. They discover the scrub gesture by accident (rapid left-right while frustrated) and laugh when everything clears with a satisfying swoosh. "That's so satisfying."

The breakthrough is realizing they've been "playing" for 20 minutes and feel... calm. Focused, even. Not because they were *trying* to meditate, but because the tactile-visual-audio loop occupied all three of their sensory channels at once. Their pattern has a repetitive, trance-like quality - they weren't trying to make music, they were just playing, and music happened as a side effect. They save it. Open PixelBoop during every meeting from then on. Their partner notices they're less anxious. Jamie has seven patterns saved and calls them their "stim sessions."

**Requirements Revealed:**
- Multi-sensory feedback loop (tactile + visual + audio)
- Immediate response to all gestures (no lag = maintains flow state)
- Discovery-driven interface (no instructions to read/remember)
- Satisfying gestural interactions (scrub-to-clear, double-tap-erase)
- No "wrong" inputs (musical intelligence ensures everything sounds acceptable)

### Journey 4: Dev Patel - The Grid Thinker

Dev is a software engineer who thinks in patterns and data structures. They've always wanted to learn music but sheet music looks like gibberish. When they see PixelBoop's 44×24 grid in a design forum, something clicks - "That's basically a 2D array with temporal and pitch axes."

First session: Dev maps out the interface mentally. Rows = pitch, columns = time. The color coding is a chromatic scale (they verify by tapping C through B). Horizontal gestures create sequences. Vertical gestures create stacks. The scale snapping is like input validation - it won't let you make "invalid" notes. This is a *data structure* for music, and Dev finally gets it.

The breakthrough comes when Dev realizes they're learning music theory through spatial reasoning instead of memorization. "Vertical drag makes chords" becomes "stacking elements in the pitch dimension creates harmonic structures." After two weeks, they can explain to a musician friend what a I-IV-V progression is *in musical terms* because they internalized it by seeing it as a pattern in the grid. They've made 12 patterns and started reading about music theory because PixelBoop gave them the mental model they needed. Music isn't mysterious anymore - it's just another system to understand and manipulate.

**Requirements Revealed:**
- Spatial/visual representation of musical relationships
- Color-coded chromatic system for pattern recognition
- Grid-based interface showing time and pitch relationships
- Logical gesture vocabulary (consistent rules for interactions)
- Pattern overview visualization (rows 22-23 showing structure)

### Journey 5: Alex Rivera - From Studio Tool to Performance Instrument

Alex is an electronic musician who's been eyeing the Erae Touch 2 controller but can't find the right software to pair it with. Most iOS music apps are "studio tools" - great for composition, terrible for live performance. When they read about PixelBoop's gesture system, they wonder if it could map to a hardware grid controller.

First experiment: Alex tests PixelBoop's gesture vocabulary on their phone. The hold-drag sustain gesture, the pressure sensitivity in accents, the scrub-to-clear - these are all expressive, performance-oriented controls. They imagine mapping this to the Erae's pressure-sensitive grid: velocity tied to pressure, drag gestures becoming smooth controller sweeps, scrub as a performance reset.

The vision crystallizes: PixelBoop isn't just a composition tool - with the right hardware integration, it could be a *live instrument*. Alex starts building setlists using PixelBoop patterns as "scenes." They perform at an open mic using just their phone and bluetooth speaker, switching between patterns, live-scrubbing sections, using sustained note gestures for builds. The crowd doesn't see a phone - they see someone *playing* an instrument. Alex posts the performance video online with "What is this??" comments. They're ready to back a Kickstarter if it means MPE controller support and live performance mode.

**Requirements Revealed:**
- Expressive gesture vocabulary (velocity, sustain, pressure)
- Pattern switching/scene management
- Performance-oriented controls (scrub, quick-erase, undo)
- Hardware controller integration potential (Phase 3)
- Live mode considerations (no accidental clears, visual feedback)

### Journey 6: River Nakamura - The Nostalgic Speedrunner

River is 32 and grew up making Game Boy chiptunes on LSDj. They miss that constraint-based creativity - the "I only have 4 channels, how do I make this sound huge?" challenge. Modern DAWs are too unlimited. When they see PixelBoop's pixel aesthetic and 44×24 grid, nostalgia hits hard. They download it immediately.

First session feels like coming home. The 4-track constraint, the low-res pixel grid, the limited pattern length options - it's like PICO-8 for music. River starts "speedrunning" - how fast can I make a banger? They discover the hidden sustained notes gesture by accident (hold-drag) and shout "SECRET MOVE!" They spend an hour hunting for more hidden gestures. Found scrub-clear. Found double-tap-erase. This is exactly the discovery-driven design River loves - no tutorial, just experimentation and mastery.

The breakthrough: River makes a 16-step loop in 47 seconds that sounds like a complete track. They post it on Twitter with "made this in <60 sec on PixelBoop" and get 200 likes. Comments ask "what's PixelBoop?" River becomes an evangelist, making tutorial videos showing hidden gestures, speedrun challenges ("make a banger in 2 minutes"), pattern breakdowns. They've saved 40+ patterns and treat each as a "level" they've beaten. For River, PixelBoop isn't just a music app - it's a game where the reward is making sick beats.

**Requirements Revealed:**
- Constraint-based creative environment (4 tracks, grid limits)
- Hidden gesture discovery system (no tooltips showing all features)
- Retro/pixel aesthetic consistency
- Speedrun-friendly workflow (fast pattern creation)
- Social sharing potential (export, pattern showcase)

### Journey Requirements Summary

These six journeys reveal the following capability areas needed for PixelBoop:

**Core Musical Interaction:**
- Zero-tutorial gestural interface with immediate musical feedback
- Complete gesture vocabulary: tap, hold, drag (horizontal/vertical/diagonal/sustained), double-tap, double-swipe, scrub
- Musical intelligence: scale snapping, automatic chord voicing, velocity system
- Real-time audio synthesis with track-specific timbres

**Pattern Management:**
- Save/load pattern library with local storage
- Pattern export (JSON format for interoperability)
- Auto-save to prevent data loss
- Pattern browsing/organization

**User Experience:**
- Multi-sensory feedback (visual, audio, tactile/haptic on iOS)
- Immediate response (<16ms input latency)
- Discovery-driven learning (hidden gestures, no forced tutorials)
- Visual pattern representation (grid showing time and pitch relationships)

**Creative Tools:**
- 4-track constraint with distinct sonic identities
- Pattern length flexibility (8-32 steps)
- Tempo control (60-200 BPM)
- Track mute/solo for experimentation
- 50-level undo/redo for safe exploration

**Social/Sharing:**
- Pattern export for sharing/reconstruction
- Professional tool integration (DAW import potential)
- Social media friendly (quick creation for posting)

**Future Performance Capabilities (Phase 3):**
- Hardware controller integration (Erae Touch 2, MPE)
- Live performance mode with scene management
- Expressive control mapping

## Innovation & Novel Patterns

### Detected Innovation Areas

**Gesture-to-Music Intelligence System:**
PixelBoop translates spatial gestures into musically coherent output through real-time interpretation algorithms. Unlike traditional music apps that require understanding notation or piano keyboards, PixelBoop's gesture vocabulary maps intuitive movements (drag horizontal = arpeggio, vertical = chord) to musical structures. The innovation is in the *interpretation layer* - the system ensures gestures always produce musically valid results through scale snapping and automatic chord voicing, removing the "wrong note" barrier.

**Discovery-Driven UX Paradigm:**
Most creative tools front-load tutorials and tooltips. PixelBoop deliberately hides features to be discovered through experimentation. Hold-drag for sustained notes, scrub-to-clear, double-swipe-undo - each discovery delivers a dopamine reward that reinforces exploration. This "anti-tutorial" approach transforms learning from obligation to game mechanic, making mastery feel like achievement rather than instruction.

**Constraint-as-Feature "Pixel DAW" Category:**
Where modern DAWs compete on unlimited tracks and features, PixelBoop embraces radical constraints (44×24 grid, 4 tracks, 8-32 steps) as creative catalysts. The innovation parallels PICO-8 in game development - artificial limitations that force creative problem-solving. This positions PixelBoop in a new category: constraint-driven music tools optimized for rapid ideation over exhaustive production.

**Spatial Music Theory Education (Audiolux Framework):**
PixelBoop teaches music theory through spatial reasoning rather than didactic instruction. Users internalize concepts (vertical stacking = harmony, horizontal sequencing = melody, color = pitch) through tactile experimentation. The innovation is educational methodology: music learning disguised as play, making theory comprehension a side effect of creative exploration.

### Validation Approach

**Prototype Validation (Already Complete):**
The working .jsx prototype has validated core feasibility - gesture recognition works, audio synthesis performs adequately, users report immediate engagement. Key quote from testing: "seriously fun to tinker with" and "draws you in." The gesture-to-music system is proven functional.

**MVP Validation Strategy:**
Phase 1 web app at pixelboop.audiolux.app tests market resonance through engagement metrics (40% 7-day retention target, 3+ patterns per user). If users return after first session and create multiple patterns, the discovery-driven engagement loop is validated.

**iOS Validation Checkpoint:**
$0.99 price point tests willingness-to-pay. Target: 500 sales in first month proves users value it enough to spend money (low barrier but signals commitment). 4+ star ratings confirm experiential satisfaction beyond novelty.

**Kickstarter Decision Point:**
2,000+ iOS sales OR strong community engagement triggers Phase 3 fundraising. This validates that the innovation resonates beyond early adopters and justifies deeper development investment (per-track MIDI output to external synths, USB/Bluetooth MIDI, USB audio output, hardware controller integration, song export).

### Risk Mitigation

**Innovation Risk: "Too Different" Rejection:**
PixelBoop might be so unlike existing music apps that users don't recognize its value. Mitigation: Leverage existing Audiolux ecosystem for initial users familiar with visual/gestural music concepts. Position as "musical sketchbook" not "DAW replacement" to set appropriate expectations.

**Innovation Risk: Discovery UX Frustration:**
Hidden gestures could frustrate users who want explicit tutorials. Mitigation: Balance discovery with gentle affordances (visual cues like pulse animations, contextual tooltips for basic gestures). Monitor analytics for drop-off points indicating confusion vs. disengagement.

**Technical Risk: Gesture Recognition Accuracy:**
Novel gesture vocabulary (sustained notes, scrub-clear, diagonal phrases) might produce too many false positives. Mitigation: Prototype already demonstrates 95%+ accuracy. Tuning thresholds (timing windows, direction vectors, velocity curves) during beta testing before full launch.

**Market Risk: "Toy" Perception:**
Cute pixel aesthetic might signal "not serious" to professional creators. Mitigation: Emphasize "constraint-driven creativity" and "rapid sketching" in messaging. Show professional use cases (Marcus Chen journey - producer using for commute ideas). Position as complement to DAWs, not replacement.

**Fallback Strategy:**
If broader market validation fails but Audiolux community engagement succeeds, pivot to "Audiolux Suite" integration - PixelBoop as one tool in educational/creative ecosystem rather than standalone product. Pattern sharing between Audiolux apps could sustain development without mass-market success.

## Mobile App Specific Requirements

### Project-Type Overview

PixelBoop is a **mobile-first gesture-based music creation tool** with a phased platform strategy. The core experience is optimized for touch interaction on mobile devices, with web serving as rapid validation (Phase 1) before native iOS development (Phase 2). The technical architecture prioritizes low-latency audio performance, offline-first operation, and minimal permissions to maintain focus on creative flow without barriers.

### Platform Requirements

**Phase 1: Progressive Web App**
- **Target Platforms:** iOS Safari 14+, Chrome Android 90+, Desktop browsers (Chrome, Firefox, Safari)
- **Technology Stack:**
  - Web Audio API with AudioWorklet for audio synthesis
  - Canvas/WebGL for 60 FPS grid rendering
  - Touch Events API + Pointer Events for gesture recognition
  - Service Worker for offline PWA functionality
  - IndexedDB for local pattern storage
- **Performance Targets:**
  - Audio latency: <20ms tap-to-sound
  - Visual rendering: 60 FPS on mobile browsers
  - Load time: <2 seconds on 4G connection
  - Works fully offline after initial load

**Phase 2: iOS Native App**
- **Target Platforms:** iOS 15+ (iPhone SE 2nd gen minimum, optimized for iPhone 12+)
- **Technology Stack:**
  - Swift/SwiftUI for UI layer
  - AVFoundation with C/C++ audio thread for synthesis
  - CoreGraphics for grid rendering
  - UserDefaults/CoreData for pattern storage
- **Performance Targets:**
  - Audio latency: <10ms tap-to-sound (professional audio standard)
  - Visual rendering: 60 FPS sustained
  - Battery consumption: <5% drain per 30 minutes active use
  - App size: <50MB download
- **Cross-Platform Consistency:**
  - Shared gesture interpretation logic (port core algorithms)
  - Identical musical behavior (same gestures produce same output)
  - Pattern format compatibility (export from web, import to iOS seamlessly)

**Phase 3: Future Platforms (Post-Kickstarter)**
- Android native (if market validation warrants)
- Desktop versions (macOS, Windows) for studio integration
- Hardware controller support (Erae Touch 2, Launchpad, Push)

### Device Permissions & Features

**iOS Native Permissions Required:**
- **Audio Session:** Required for real-time synthesis and playback
  - User impact: "PixelBoop needs audio access to create sounds"
  - Requested on first launch
- **Haptic Engine:** Optional but recommended for tactile feedback
  - No permission prompt required (UIFeedbackGenerator)
  - Enhanced experience on devices with Taptic Engine

**Haptic Feedback Strategy:**
- Light impact on note placement (tap/drag)
- Medium impact on accent notes (hold+tap)
- Selection feedback on control interactions (play/stop, scale selection)
- Notification feedback on undo/redo, clear all
- Beat synchronization: subtle pulse on downbeat during playback

**Device Features Utilized:**
- **Touch/Multi-touch:** Core gesture vocabulary (tap, hold, drag, swipe)
- **Accelerometer/Gyroscope:** Optional enhancement for scrub gesture detection
- **Background Audio:** Continue playback when app backgrounded or screen locked
- **Audio Session Management:** Proper handling of interruptions (calls, notifications)

**Permissions NOT Required (Privacy-Focused):**
- No camera access
- No location services
- No contacts access
- No photo library access
- No network access required after initial download
- No analytics/tracking in MVP

### Offline Mode & Data Storage

**Offline-First Architecture:**
- **100% offline functionality** - all features work without internet connectivity
- Local-only data storage for MVP (no cloud sync)
- Pattern creation, editing, playback, save/load all function offline

**Web (PWA) Storage:**
- **IndexedDB** for pattern library (unlimited storage with quota management)
- **LocalStorage** for app preferences (scale, tempo, last used settings)
- **Service Worker cache** for app resources (code, assets)
- **Export capability:** Download patterns as JSON files to device storage

**iOS Native Storage:**
- **UserDefaults** for app preferences and settings
- **CoreData** for pattern library with iCloud sync readiness (disabled in MVP)
- **File System** for pattern export to iOS Files app
- **Automatic backup** via iOS device backup (patterns preserved)

**Data Persistence Strategy:**
- Auto-save on every pattern change (debounced 500ms)
- 50-level undo/redo history maintained in memory
- Pattern library with metadata (name, created date, last modified, BPM, scale)
- No data loss tolerance: patterns never corrupted or lost

**Future Cloud Sync (Phase 3):**
- Optional iCloud sync for pattern library
- Cross-device pattern access (start on iPhone, continue on iPad)
- Conflict resolution for simultaneous edits
- Privacy: End-to-end encrypted pattern data

### Push Notification Strategy

**MVP (Phase 1 & 2): No Push Notifications**
- PixelBoop is a creation tool, not a social/engagement platform
- No notifications needed for core creative workflow
- Keeps permission footprint minimal
- Reduces user interruption and distraction

**Phase 3: Potential Notification Use Cases (If Community Features Added):**
- **Pattern Challenges:** "New weekly pattern challenge: Create a beat in 8 steps"
- **Community Sharing:** "Your pattern got 10 likes" (if social features added)
- **Feature Updates:** Major new features or capabilities (user opt-in)
- **Never:** Engagement spam, daily reminders, re-engagement notifications

**Design Principle:** Notifications should add value, never nag. Users open PixelBoop because they want to create, not because we pestered them.

### App Store Compliance & Distribution

**iOS App Store Requirements:**

**Age Rating: 4+**
- No objectionable content
- No violence, profanity, or mature themes
- No social features requiring moderation (MVP)
- No user-generated content sharing (MVP)

**Privacy & Data:**
- **App Privacy Nutrition Label:**
  - Data Not Collected: No analytics, no tracking, no personal information
  - Data Used to Track You: None
  - Data Linked to You: None
- **Privacy Policy:** Simple statement confirming local-only storage, no data collection
- **COPPA Compliant:** Safe for all ages including children under 13

**Monetization & Pricing:**
- **One-time purchase:** $0.99 USD
- **No in-app purchases** (IAP) in MVP
- **No subscriptions**
- **No ads**
- Future Phase 3: Optional IAP for expansion packs (additional scales, drum kits)

**Audio & Content:**
- **All sounds synthesized:** No licensed samples, no copyright concerns
- **No external audio sources:** Self-contained synthesis engine
- **No streaming:** All audio generated locally in real-time

**Technical Compliance:**
- **App Review Guidelines 4.2.1:** Not a "me-too" app - unique gesture-based music interface
- **IPv6 Compatibility:** Required for App Store approval (network calls if future features need it)
- **Background Modes:** Audio playback mode for continue-while-backgrounded
- **Crash-Free Rate Target:** >99.5% to avoid app store penalties

**App Store Optimization (ASO):**
- **Category:** Music > Make Music
- **Keywords:** "music sequencer, gesture music, pixel sequencer, music maker, beat maker, loop creator"
- **Screenshots:** Demonstrate gesture vocabulary and pattern creation flow
- **App Preview Video:** 30-second demo showing tap-to-creation workflow

### Implementation Considerations

**Cross-Platform Code Sharing:**
- **Shared Logic:** Gesture interpretation algorithms, musical intelligence (scale snapping, chord voicing), pattern data structures
- **Platform-Specific:** Audio synthesis (Web Audio vs AVFoundation), UI rendering, storage mechanisms
- **Strategy:** Core music logic in portable format (TypeScript → Swift translation, or shared C++ library)

**Audio Architecture:**
- **Web:** Web Audio API ScriptProcessorNode/AudioWorklet for synthesis
- **iOS:** AVAudioEngine with custom audio units, C/C++ audio callback for <10ms latency
- **Synthesis Engine:** Additive/subtractive synthesis (sine, triangle, sawtooth waveforms)
- **Voice Management:** Polyphonic synthesis with voice stealing for resource management

**Gesture Recognition:**
- **Touch state machine:** Track touch start → move → end lifecycle
- **Timing thresholds:** <300ms = tap, ≥400ms = hold, direction vectors for drag detection
- **Velocity calculation:** Distance/time for gesture speed (impacts musical velocity)
- **Multi-touch handling:** Simultaneous gestures on different tracks

**Performance Optimization:**
- **60 FPS rendering:** Canvas/UIKit optimization, dirty rectangle updates
- **Audio thread priority:** Real-time thread scheduling for glitch-free audio
- **Memory management:** Pattern data compression, efficient undo/redo storage
- **Battery optimization:** Reduce rendering during idle, audio engine suspension when stopped

## Functional Requirements

### Pattern Creation & Editing

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

### Audio Synthesis & Playback

- FR12: System can synthesize notes in real-time with track-specific timbres (sine, triangle, sawtooth)
- FR13: System can synthesize 12 distinct drum sounds for rhythm track
- FR14: System can apply velocity levels to notes (normal, accent, sustain)
- FR15: System can render ADSR envelope fades for sustained notes
- FR16: System can play patterns in a continuous loop
- FR17: Users can start and stop pattern playback
- FR18: System can maintain audio playback when application is backgrounded (iOS)
- FR19: System can handle audio session interruptions (calls, notifications)

### Musical Intelligence

- FR20: System can constrain note placement to selected musical scale (major, minor, pentatonic)
- FR21: Users can select from 12 chromatic root notes
- FR22: System can automatically voice chords based on vertical gestures
- FR23: System can generate bass patterns using root and fifth intervals
- FR24: System can ensure all user input produces musically valid results

### Pattern Management

- FR25: Users can save patterns to local storage
- FR26: Users can load previously saved patterns
- FR27: Users can browse their pattern library
- FR28: System can automatically save pattern changes
- FR29: Users can export patterns as JSON files
- FR30: Users can export patterns to device file system (iOS Files app)
- FR31: System can import patterns created on other platforms (cross-platform compatibility)
- FR32: System can preserve pattern metadata (name, creation date, BPM, scale)

### History & Reversibility

- FR33: Users can undo their last 50 actions
- FR34: Users can redo previously undone actions
- FR35: Users can undo by double-swiping left
- FR36: Users can redo by double-swiping right

### Visual Feedback & Interface

- FR37: System can display a 44×24 pixel grid interface
- FR38: System can render color-coded notes based on chromatic pitch
- FR39: System can display a visual playhead during pattern playback
- FR40: System can show dynamic status tooltips (BPM, scale, pattern length) using pixel font
- FR41: System can display gesture-specific tooltips (TAP, ACCENT, ARPEGGIO, CHORD, SUSTAIN, etc.)
- FR42: System can show pulse animations synchronized to tempo
- FR43: System can display ghost notes for gesture previews
- FR44: System can provide step markers and pattern overview visualization
- FR45: System can render all visual elements at 60 FPS on target devices

### Control & Configuration

- FR46: Users can adjust tempo from 60 to 200 BPM
- FR47: Users can select musical scale type (major, minor, pentatonic)
- FR48: Users can select root note from chromatic scale
- FR49: Users can adjust pattern length (8, 16, 24, 32 steps)
- FR50: Users can mute individual tracks
- FR51: Users can solo individual tracks
- FR52: Users can toggle ghost note visibility
- FR53: Users can use keyboard shortcuts for common actions (Space=play/stop, Cmd+Z=undo, Delete=clear, Arrows=BPM)

### Track Management

- FR54: Users can create independent musical content on melody track
- FR55: Users can create independent musical content on chords track
- FR56: Users can create independent musical content on bass track
- FR57: Users can create independent musical content on rhythm/drums track
- FR58: System can visually distinguish tracks through color coding
- FR59: Users can view volume indicators per track

### Offline & Storage

- FR60: System can function completely offline without network connectivity
- FR61: System can store patterns in local device storage
- FR62: System can preserve user preferences across sessions
- FR63: System can maintain 50-level undo history in memory during active session

### Haptic Feedback (iOS Native)

- FR64: System can provide tactile feedback on note placement (iOS)
- FR65: System can provide distinct haptic responses for different gesture types (iOS)
- FR66: System can synchronize haptic pulses to beat during playback (iOS)

## App Store Compliance Requirements (iOS)

### Privacy Manifest (MANDATORY - Enforced since May 2024)

**Requirement:** All iOS apps must include a `PrivacyInfo.xcprivacy` file declaring data collection practices and Required Reason API usage.

**PixelBoop Compliance:**

- NFR45: App must include `PrivacyInfo.xcprivacy` file in Xcode project
- NFR46: Privacy manifest must declare zero data collection (NSPrivacyCollectedDataTypes: empty array)
- NFR47: Privacy manifest must declare Required Reason API usage:
  - **UserDefaults API** (NSPrivacyAccessedAPICategoryUserDefaults): Declare approved reason "CA92.1" (Accessing user defaults to read and write information that is only accessible to the app)
  - **FileTimestamp API** (NSPrivacyAccessedAPICategoryFileTimestamp): If checking pattern file modification dates, declare approved reason
  - **DiskSpace API** (NSPrivacyAccessedAPICategoryDiskSpace): If checking available storage before saving patterns, declare approved reason
- NFR48: Xcode-generated Privacy Report must accurately reflect "Data Not Collected" status for App Store Privacy Nutrition Label

**Rationale:** PixelBoop stores all data locally using UserDefaults (preferences) and FileManager (pattern JSON files). No data leaves the device. Privacy manifest ensures App Store approval and transparency to users.

### Accessibility Compliance (MANDATORY - New for 2025)

**Requirement:** Apps must support basic accessibility features including VoiceOver, Dynamic Type, and sufficient color contrast. Accessibility Nutrition Labels (new 2025) will initially be voluntary but trending mandatory.

**PixelBoop Compliance:**

- NFR49: All interactive UI elements must have VoiceOver accessibility labels (buttons in control row, pattern library, settings)
- NFR50: VoiceOver must announce pattern playback state ("Playing", "Stopped", "Pattern: [name]")
- NFR51: VoiceOver must describe grid interactions ("Tap to place note", "Drag to create arpeggio")
- NFR52: Settings screen must support Dynamic Type (text scales with system font size preferences)
- NFR53: Color contrast must meet minimum WCAG 2.1 AA standards (4.5:1 for normal text, 3:1 for large text)
- NFR54: Accessibility Nutrition Labels must accurately declare supported features:
  - ✅ VoiceOver Support (basic labels for controls)
  - ✅ Sufficient Contrast (verified for UI text)
  - ⚠️ Limited Motor Accessibility (gesture-based interface requires touch capability)
  - ❌ Not Fully Accessible (pixel grid music creation inherently requires visual/touch interaction)

**Accessibility Limitations Disclosure:**
- NFR55: App Store description must clearly state "Requires touch gestures for music creation" to set user expectations
- NFR56: VoiceOver support focuses on navigation and pattern management, not real-time grid composition

**Rationale:** PixelBoop's gesture-based pixel grid is inherently visual/tactile. Full accessibility (e.g., blind users creating music via screen reader) is not feasible for MVP, but basic VoiceOver navigation and control labeling is mandatory for App Store approval.

### SDK & Build Requirements (2025 Standards)

**Requirement:** Apps submitted after April 2025 must be built with Xcode 16+ using iOS 18+ SDK.

**PixelBoop Compliance:**

- NFR57: Development environment must use Xcode 16 or later
- NFR58: App must be built with iOS 18 SDK (or later)
- NFR59: Deployment target set to iOS 15+ (maintain backward compatibility while using modern SDK)
- NFR60: Swift 5.9+ language version

**Rationale:** Apple enforces modern SDK usage to ensure apps benefit from latest security, performance, and API improvements.

### Technical Compliance

**IPv6 Compatibility:**
- NFR61: App must support IPv6-only networks (automatically satisfied - PixelBoop has no network calls in MVP)

**Background Modes:**
- NFR62: `UIBackgroundModes` must declare "audio" capability for background pattern playback
- NFR63: Audio session must be configured for background playback (`.playback` category)

**App Transport Security (ATS):**
- NFR64: If future versions add networking, all connections must use HTTPS (TLS 1.2+)
- NFR65: No plaintext HTTP allowed without explicit ATS exception (avoid exceptions)

**Crash-Free Rate:**
- NFR66: App must maintain >99.5% crash-free sessions (monitored via Xcode Organizer, MetricKit)
- NFR67: Zero critical bugs in final 2 weeks of TestFlight beta before App Store submission

### App Store Submission Assets & Metadata

**Required Assets:**
- NFR68: App icon in all required sizes (1024×1024 App Store icon + all iOS icon sizes)
- NFR69: Launch screen (storyboard or image set)
- NFR70: Screenshots for required device sizes (6.7", 6.5", 5.5" iPhones minimum)
- NFR71: App Preview video (30 seconds, optional but recommended, demonstrates gesture system)

**Metadata Requirements:**
- NFR72: App Store description must clearly explain gesture-based music creation
- NFR73: Keywords must include: music sequencer, gesture music, pixel sequencer, beat maker, loop creator
- NFR74: Age rating: 4+ (no objectionable content)
- NFR75: Category: Music > Make Music
- NFR76: Privacy Policy URL (simple statement: "All data stored locally. No data collection.")

### TestFlight Beta Requirements

**Beta Testing Strategy:**
- NFR77: Internal TestFlight beta (1-2 weeks, 5-10 testers) to validate basic functionality
- NFR78: External TestFlight beta (4-8 weeks, 20-50 musicians) to validate user experience and stability
- NFR79: Zero critical bugs in final 2 weeks of external beta before App Store submission
- NFR80: Crash-free rate >99.5% across all beta sessions

**Rationale:** Extended beta testing with target users (musicians) ensures gesture system works intuitively and audio quality meets professional standards before public launch.

### App Review Guidelines Compliance

**Critical Guidelines for PixelBoop:**

- NFR81: App must be complete and functional (no placeholders, no "coming soon" features)
- NFR82: App must comply with Guideline 4.2.1 (Minimum Functionality) - not a "me-too" app
  - **PixelBoop Defense:** Unique gesture-based music interface with pixel grid aesthetic differentiates from traditional sequencers
- NFR83: App must not require sign-in, account creation, or external authentication for core functionality
- NFR84: $0.99 one-time purchase must use Apple In-App Purchase system (App Store handles transaction, PixelBoop delivered as paid download)
- NFR85: No misleading claims in App Store description (accurately represent gesture system capabilities)

### Optional/Future Compliance Requirements

**EU Digital Services Act (if distributing in EU):**
- NFR86: Trader status must be provided and verified for EU App Store distribution
- NFR87: Without trader status, app will be removed from EU App Store

**Game Center (Not Applicable):**
- PixelBoop does not use Game Center features - no compliance needed

**Push Notifications (Not Applicable):**
- MVP does not use push notifications - no APNs certificate update needed

**AI Transparency (Not Applicable):**
- PixelBoop uses algorithmic music theory (scale snapping, chord voicing), not AI/ML
- No AI transparency disclosure required

### Compliance Verification Checklist

Before App Store submission, verify:

- ✅ `PrivacyInfo.xcprivacy` included with UserDefaults declared
- ✅ VoiceOver labels on all controls and buttons
- ✅ Color contrast validated (WCAG 2.1 AA minimum)
- ✅ Built with Xcode 16+ and iOS 18+ SDK
- ✅ Background audio mode declared and tested
- ✅ Crash-free rate >99.5% in final 2 weeks of beta
- ✅ All required App Store assets (icon, screenshots, description)
- ✅ Privacy Policy URL provided
- ✅ TestFlight beta completed (4-8 weeks, 20-50 testers)
- ✅ No critical bugs or accessibility blockers
