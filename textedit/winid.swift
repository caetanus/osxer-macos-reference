// Prints the CGWindowID of the frontmost on-screen window of the named app (for screencapture -l).
import CoreGraphics
import Foundation
let owner = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "TextEdit"
let opts: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
let list = CGWindowListCopyWindowInfo(opts, kCGNullWindowID) as? [[String: Any]] ?? []
for w in list where (w[kCGWindowOwnerName as String] as? String) == owner
    && (w[kCGWindowLayer as String] as? Int) == 0 {
    if let n = w[kCGWindowNumber as String] as? Int { print(n); exit(0) }
}
exit(1)
