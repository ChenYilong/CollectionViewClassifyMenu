// Usage: swift scripts/stitch-screenshots.swift --out <file.png> [--columns 2] [--crop x,y,w,h]
//            --header <line> [--header <line> ...] --footer <line> [--footer <line> ...]
//            "<caption>::<image>" ["<caption>::<image>" ...]
//
// Stitches screenshots by the rules of AGENTS.md ("Screenshots: stitching layout", "Screenshots: header and footer"):
// a portrait image, two columns by default and as many rows as needed, filled left to right, top to bottom; a header
// band above the grid, a footer band below it and a caption band above every panel. No text is drawn on a screenshot:
// every band has its own space. The panels keep their original pixels (no scaling); `--crop` (pixels, top-left origin)
// cuts the same rectangle out of every image, so crop to whole elements. Output: PNG.
import AppKit

var out = "", columns = 2, crop: CGRect? = nil
var header: [String] = [], footer: [String] = [], panels: [(String, String)] = []
var args = Array(CommandLine.arguments.dropFirst())
while !args.isEmpty {
    let a = args.removeFirst()
    switch a {
    case "--out": out = args.removeFirst()
    case "--columns": columns = max(1, Int(args.removeFirst()) ?? 2)
    case "--header": header.append(args.removeFirst())
    case "--footer": footer.append(args.removeFirst())
    case "--crop":
        let v = args.removeFirst().split(separator: ",").compactMap { Double($0) }
        precondition(v.count == 4, "--crop x,y,w,h")
        crop = CGRect(x: v[0], y: v[1], width: v[2], height: v[3])
    default:
        let parts = a.components(separatedBy: "::")
        precondition(parts.count == 2, "panel: \"<caption>::<image>\"")
        panels.append((parts[0], parts[1]))
    }
}
precondition(!out.isEmpty && !panels.isEmpty, "--out and at least one panel are required")
precondition(!header.isEmpty && !footer.isEmpty, "a header and a footer are required")

let images: [NSBitmapImageRep] = panels.map {
    guard let rep = NSBitmapImageRep(data: try! Data(contentsOf: URL(fileURLWithPath: $0.1))) else {
        fatalError("cannot read \($0.1)")
    }
    return rep
}
let cell = crop?.size ?? CGSize(width: images.map(\.pixelsWide).max()!, height: images.map(\.pixelsHigh).max()!)
let cols = min(columns, panels.count), rows = (panels.count + cols - 1) / cols
let margin: CGFloat = 24, gap: CGFloat = 24, width = margin * 2 + cell.width * CGFloat(cols) + gap * CGFloat(cols - 1)

let red = NSColor(srgbRed: 1, green: 0.231, blue: 0.188, alpha: 1)  // #FF3B30, iOS system red
// Text scales with the image, so it stays readable next to full-resolution panels (1206 px wide for an iPhone 17 Pro).
let headerFont = NSFont.boldSystemFont(ofSize: max(28, (width / 55).rounded()))
let captionFont = NSFont.boldSystemFont(ofSize: max(24, (cell.width / 32).rounded()))
let footerFont = NSFont.systemFont(ofSize: max(22, (width / 70).rounded()))
func height(_ text: String, _ font: NSFont, _ w: CGFloat) -> CGFloat {
    ceil((text as NSString).boundingRect(with: NSSize(width: w, height: 10_000), options: [.usesLineFragmentOrigin],
                                         attributes: [.font: font]).height)
}
let headerText = header.joined(separator: "\n"), footerText = footer.joined(separator: "\n")
let headerH = height(headerText, headerFont, width - margin * 2) + margin * 2
let footerH = height(footerText, footerFont, width - margin * 2) + margin * 2
let captionH = panels.map { height($0.0, captionFont, cell.width) }.max()! + 12
let rowH = captionH + cell.height
let total = headerH + CGFloat(rows) * rowH + CGFloat(rows - 1) * gap + footerH

let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(width), pixelsHigh: Int(total), bitsPerSample: 8,
                           samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
                           bytesPerRow: 0, bitsPerPixel: 0)!
rep.size = NSSize(width: width, height: total)  // 1 point = 1 pixel: the panels keep their original pixels
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
NSColor.white.setFill(); NSRect(x: 0, y: 0, width: width, height: total).fill()
// Header band (top), with a rule under it; footer band (bottom), with a rule above it.
(headerText as NSString).draw(in: NSRect(x: margin, y: total - headerH + margin, width: width - margin * 2,
                                         height: headerH - margin * 2), withAttributes: [.font: headerFont, .foregroundColor: red])
(footerText as NSString).draw(in: NSRect(x: margin, y: margin, width: width - margin * 2, height: footerH - margin * 2),
                              withAttributes: [.font: footerFont, .foregroundColor: NSColor.darkGray])
NSColor.lightGray.setFill()
NSRect(x: 0, y: total - headerH, width: width, height: 2).fill()
NSRect(x: 0, y: footerH - 2, width: width, height: 2).fill()
for (i, (caption, _)) in panels.enumerated() {
    let col = i % cols, row = i / cols
    let x = margin + CGFloat(col) * (cell.width + gap)
    let top = total - headerH - CGFloat(row) * (rowH + gap)
    (caption as NSString).draw(in: NSRect(x: x, y: top - captionH, width: cell.width, height: captionH - 6),
                               withAttributes: [.font: captionFont, .foregroundColor: red])
    let img = images[i], ph = CGFloat(img.pixelsHigh)
    let src = crop ?? CGRect(x: 0, y: 0, width: CGFloat(img.pixelsWide), height: ph)
    img.draw(in: NSRect(x: x, y: top - captionH - src.height, width: src.width, height: src.height),
             from: NSRect(x: src.minX, y: ph - src.minY - src.height, width: src.width, height: src.height),
             operation: .copy, fraction: 1, respectFlipped: false, hints: [.interpolation: NSImageInterpolation.none.rawValue])
}
NSGraphicsContext.restoreGraphicsState()
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
print("\(out): \(Int(width)) x \(Int(total)) px, \(cols) columns x \(rows) rows")
