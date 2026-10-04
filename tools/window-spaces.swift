// Lists an app's windows and the Space (desktop) each one is on.
//
// Useful for finding windows that are on a different Space than you
// expect, e.g. a hidden window that makes macOS jump to another desktop
// when the app is activated.
//
// Usage: tools/window-spaces [app-name]   (default: iTerm2)
//
// Uses private CoreGraphics (CGS) functions, the same ones window
// managers use, so this may break in a future macOS release.

import CoreGraphics
import Foundation

@_silgen_name("CGSMainConnectionID") func CGSMainConnectionID() -> Int32
@_silgen_name("CGSGetActiveSpace") func CGSGetActiveSpace(_ cid: Int32) -> Int
@_silgen_name("CGSCopySpacesForWindows")
func CGSCopySpacesForWindows(_ cid: Int32, _ mask: Int32, _ windowIDs: CFArray) -> CFArray

let appName = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "iTerm2"
let allSpacesMask: Int32 = 7
let cid = CGSMainConnectionID()

print("active space:", CGSGetActiveSpace(cid))

let windows = CGWindowListCopyWindowInfo([.optionAll], kCGNullWindowID) as! [[String: Any]]
for window in windows
where window[kCGWindowOwnerName as String] as? String == appName
  && window[kCGWindowLayer as String] as? Int == 0
{
  let id = window[kCGWindowNumber as String] as! Int
  let bounds = window[kCGWindowBounds as String] as! [String: Any]
  let spaces = CGSCopySpacesForWindows(cid, allSpacesMask, [id] as CFArray) as! [Int]
  let onscreen = window[kCGWindowIsOnscreen as String] as? Bool ?? false
  print(
    id, "\(bounds["Width"]!)x\(bounds["Height"]!)", "at", bounds["X"]!, bounds["Y"]!,
    "spaces:", spaces, "onscreen:", onscreen,
    "title:", window[kCGWindowName as String] as? String ?? "")
}
