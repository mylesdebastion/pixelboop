//
//  TooltipSystem.swift
//  pixelboop
//
//  Pixel font tooltip system matching prototype lines 49-133, 321-367
//

import Foundation
import UIKit

// MARK: - Pixel Font (from prototype lines 49-101)

struct PixelFont {

    /// 3x5 pixel font definitions
    /// Each character is a 5-row x 3-column array where 1 = lit pixel
    static let characters: [Character: [[Int]]] = [
        "A": [[0,1,0],[1,0,1],[1,1,1],[1,0,1],[1,0,1]],
        "B": [[1,1,0],[1,0,1],[1,1,0],[1,0,1],[1,1,0]],
        "C": [[0,1,1],[1,0,0],[1,0,0],[1,0,0],[0,1,1]],
        "D": [[1,1,0],[1,0,1],[1,0,1],[1,0,1],[1,1,0]],
        "E": [[1,1,1],[1,0,0],[1,1,0],[1,0,0],[1,1,1]],
        "F": [[1,1,1],[1,0,0],[1,1,0],[1,0,0],[1,0,0]],
        "G": [[0,1,1],[1,0,0],[1,0,1],[1,0,1],[0,1,1]],
        "H": [[1,0,1],[1,0,1],[1,1,1],[1,0,1],[1,0,1]],
        "I": [[1,1,1],[0,1,0],[0,1,0],[0,1,0],[1,1,1]],
        "J": [[0,0,1],[0,0,1],[0,0,1],[1,0,1],[0,1,0]],
        "K": [[1,0,1],[1,0,1],[1,1,0],[1,0,1],[1,0,1]],
        "L": [[1,0,0],[1,0,0],[1,0,0],[1,0,0],[1,1,1]],
        "M": [[1,0,1],[1,1,1],[1,0,1],[1,0,1],[1,0,1]],
        "N": [[1,0,1],[1,1,1],[1,1,1],[1,0,1],[1,0,1]],
        "O": [[0,1,0],[1,0,1],[1,0,1],[1,0,1],[0,1,0]],
        "P": [[1,1,0],[1,0,1],[1,1,0],[1,0,0],[1,0,0]],
        "Q": [[0,1,0],[1,0,1],[1,0,1],[1,1,1],[0,1,1]],
        "R": [[1,1,0],[1,0,1],[1,1,0],[1,0,1],[1,0,1]],
        "S": [[0,1,1],[1,0,0],[0,1,0],[0,0,1],[1,1,0]],
        "T": [[1,1,1],[0,1,0],[0,1,0],[0,1,0],[0,1,0]],
        "U": [[1,0,1],[1,0,1],[1,0,1],[1,0,1],[0,1,0]],
        "V": [[1,0,1],[1,0,1],[1,0,1],[0,1,0],[0,1,0]],
        "W": [[1,0,1],[1,0,1],[1,0,1],[1,1,1],[1,0,1]],
        "X": [[1,0,1],[1,0,1],[0,1,0],[1,0,1],[1,0,1]],
        "Y": [[1,0,1],[1,0,1],[0,1,0],[0,1,0],[0,1,0]],
        "Z": [[1,1,1],[0,0,1],[0,1,0],[1,0,0],[1,1,1]],
        "0": [[0,1,0],[1,0,1],[1,0,1],[1,0,1],[0,1,0]],
        "1": [[0,1,0],[1,1,0],[0,1,0],[0,1,0],[1,1,1]],
        "2": [[1,1,0],[0,0,1],[0,1,0],[1,0,0],[1,1,1]],
        "3": [[1,1,0],[0,0,1],[0,1,0],[0,0,1],[1,1,0]],
        "4": [[1,0,1],[1,0,1],[1,1,1],[0,0,1],[0,0,1]],
        "5": [[1,1,1],[1,0,0],[1,1,0],[0,0,1],[1,1,0]],
        "6": [[0,1,1],[1,0,0],[1,1,0],[1,0,1],[0,1,0]],
        "7": [[1,1,1],[0,0,1],[0,1,0],[0,1,0],[0,1,0]],
        "8": [[0,1,0],[1,0,1],[0,1,0],[1,0,1],[0,1,0]],
        "9": [[0,1,0],[1,0,1],[0,1,1],[0,0,1],[1,1,0]],
        " ": [[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,0,0]],
        ".": [[0,0,0],[0,0,0],[0,0,0],[0,0,0],[0,1,0]],
        ":": [[0,0,0],[0,1,0],[0,0,0],[0,1,0],[0,0,0]],
        "-": [[0,0,0],[0,0,0],[1,1,1],[0,0,0],[0,0,0]],
        "+": [[0,0,0],[0,1,0],[1,1,1],[0,1,0],[0,0,0]],
        "/": [[0,0,1],[0,0,1],[0,1,0],[1,0,0],[1,0,0]],
        "!": [[0,1,0],[0,1,0],[0,1,0],[0,0,0],[0,1,0]],
        "?": [[1,1,0],[0,0,1],[0,1,0],[0,0,0],[0,1,0]],
        ">": [[1,0,0],[0,1,0],[0,0,1],[0,1,0],[1,0,0]],
        "<": [[0,0,1],[0,1,0],[1,0,0],[0,1,0],[0,0,1]],
        "=": [[0,0,0],[1,1,1],[0,0,0],[1,1,1],[0,0,0]],
        "%": [[1,0,1],[0,0,1],[0,1,0],[1,0,0],[1,0,1]],
        "#": [[1,0,1],[1,1,1],[1,0,1],[1,1,1],[1,0,1]],
        "~": [[0,0,0],[0,1,0],[1,0,1],[0,0,0],[0,0,0]],
    ]
}

// MARK: - Tooltip Definitions (from prototype lines 103-133)

enum TooltipKey: String {
    case togglePlay = "togglePlay"
    case undo = "undo"
    case redo = "redo"
    case scaleMajor = "scaleMajor"
    case scaleMinor = "scaleMinor"
    case scalePenta = "scalePenta"
    case toggleGhosts = "toggleGhosts"
    case bpmUp = "bpmUp"
    case bpmDown = "bpmDown"
    case lenUp = "lenUp"
    case lenDown = "lenDown"
    case clearAll = "clearAll"

    // Track control tooltips
    case muteMelody = "muteMelody"
    case muteChords = "muteChords"
    case muteBass = "muteBass"
    case muteRhythm = "muteRhythm"
    case unmute = "unmute"
    case soloMelody = "soloMelody"
    case soloChords = "soloChords"
    case soloBass = "soloBass"
    case soloRhythm = "soloRhythm"

    // Gesture tooltips
    case gestureTap = "gesture_tap"
    case gestureAccent = "gesture_accent"
    case gestureArpeggio = "gesture_arpeggio"
    case gestureRun = "gesture_run"
    case gestureStack = "gesture_stack"
    case gestureWalking = "gesture_walking"
    case gestureRoll = "gesture_roll"
    case gesturePhrase = "gesture_phrase"
    case gestureFill = "gesture_fill"
    case gestureMulti = "gesture_multi"
    case gestureFifth = "gesture_fifth"
    case gestureErase = "gesture_erase"
    case gestureClear = "gesture_clear"
    case gestureShake = "gesture_shake"
    case gestureSwipeUndo = "gesture_swipeUndo"
    case gestureSwipeRedo = "gesture_swipeRedo"
    case gestureSustain = "gesture_sustain"

    var displayText: String {
        switch self {
        case .togglePlay: return "PLAY/STOP"
        case .undo: return "UNDO"
        case .redo: return "REDO"
        case .scaleMajor: return "MAJOR"
        case .scaleMinor: return "MINOR"
        case .scalePenta: return "PENTA"
        case .toggleGhosts: return "GHOSTS"
        case .bpmUp: return "BPM +"
        case .bpmDown: return "BPM -"
        case .lenUp: return "LEN +"
        case .lenDown: return "LEN -"
        case .clearAll: return "CLEAR!"
        case .muteMelody: return "MUTE MELODY"
        case .muteChords: return "MUTE CHORDS"
        case .muteBass: return "MUTE BASS"
        case .muteRhythm: return "MUTE RHYTHM"
        case .unmute: return "UNMUTE"
        case .soloMelody: return "SOLO MELODY"
        case .soloChords: return "SOLO CHORDS"
        case .soloBass: return "SOLO BASS"
        case .soloRhythm: return "SOLO RHYTHM"
        case .gestureTap: return "TAP"
        case .gestureAccent: return "ACCENT!"
        case .gestureArpeggio: return "ARPEGGIO"
        case .gestureRun: return "RUN"
        case .gestureStack: return "CHORD"
        case .gestureWalking: return "WALK"
        case .gestureRoll: return "ROLL"
        case .gesturePhrase: return "PHRASE"
        case .gestureFill: return "FILL"
        case .gestureMulti: return "MULTI"
        case .gestureFifth: return "ROOT+5"
        case .gestureErase: return "ERASE"
        case .gestureClear: return "CLEARED!"
        case .gestureShake: return "~SHAKE CLEAR~"
        case .gestureSwipeUndo: return "<<UNDO"
        case .gestureSwipeRedo: return "REDO>>"
        case .gestureSustain: return "SUSTAIN"
        }
    }

    var displayRow: Int {
        return 2  // All tooltips display in row 2
    }
}

// MARK: - Tooltip Pixel

struct TooltipPixel {
    let row: Int
    let col: Int
    let intensity: CGFloat  // 0.0 - 1.0
}

// MARK: - Tooltip System

class TooltipSystem {

    private static let gridCols = 44
    private static let gridRows = 24

    /// Generate pixel positions for tooltip text (from prototype lines 321-352)
    /// - Parameters:
    ///   - text: Text to display
    ///   - startRow: Row to start rendering (default 2)
    ///   - startCol: Column to start (nil = center)
    /// - Returns: Array of pixels to light up
    static func generatePixels(
        for text: String,
        startRow: Int = 2,
        startCol: Int? = nil
    ) -> [TooltipPixel] {
        var pixels: [TooltipPixel] = []
        let upperText = text.uppercased()

        // Calculate total width
        var totalWidth = 0
        for char in upperText {
            if PixelFont.characters[char] != nil {
                totalWidth += 4  // 3 pixels + 1 space
            }
        }
        totalWidth = max(0, totalWidth - 1)  // Remove trailing space

        // Calculate starting column (center if not specified)
        let col = startCol ?? (gridCols - totalWidth) / 2

        // Generate pixels for each character
        var currentCol = col
        for char in upperText {
            guard let charPixels = PixelFont.characters[char] else { continue }

            for r in 0..<5 {
                for c in 0..<3 {
                    if charPixels[r][c] == 1 {
                        let pixelRow = startRow + r
                        let pixelCol = currentCol + c

                        // Bounds check
                        if pixelRow >= 0 && pixelRow < gridRows &&
                           pixelCol >= 0 && pixelCol < gridCols {
                            pixels.append(TooltipPixel(row: pixelRow, col: pixelCol, intensity: 0.85))
                        }
                    }
                }
            }
            currentCol += 4  // Move to next character position
        }

        return pixels
    }

    /// Convert gesture type to tooltip key
    static func tooltipKey(for gestureType: GestureType) -> TooltipKey? {
        switch gestureType {
        case .tap: return .gestureTap
        case .accent: return .gestureAccent
        case .arpeggio: return .gestureArpeggio
        case .run: return .gestureRun
        case .stack: return .gestureStack
        case .walking: return .gestureWalking
        case .roll: return .gestureRoll
        case .phrase: return .gesturePhrase
        case .fill: return .gestureFill
        case .multi: return .gestureMulti
        case .fifth: return .gestureFifth
        case .erase: return .gestureErase
        case .clear: return .gestureClear
        case .swipeUndo: return .gestureSwipeUndo
        case .swipeRedo: return .gestureSwipeRedo
        case .sustain: return .gestureSustain
        }
    }
}

// MARK: - Color Blending Helper (from prototype lines 137-155)

extension UIColor {
    /// Blend color with white for tooltip effect
    func blendedWithWhite(amount: CGFloat = 0.7) -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)

        r = r + (1.0 - r) * amount
        g = g + (1.0 - g) * amount
        b = b + (1.0 - b) * amount

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
