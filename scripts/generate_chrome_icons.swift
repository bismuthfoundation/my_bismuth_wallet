import AppKit
import Foundation

let args = CommandLine.arguments
guard args.count >= 3 else {
  fputs("Usage: generate_chrome_icons.swift <source-png> <output-dir>\n", stderr)
  exit(1)
}

let sourceURL = URL(fileURLWithPath: args[1])
let outputDirURL = URL(fileURLWithPath: args[2], isDirectory: true)

guard let sourceImage = NSImage(contentsOf: sourceURL) else {
  fputs("Could not load source image: \(sourceURL.path)\n", stderr)
  exit(1)
}

let fileManager = FileManager.default
try fileManager.createDirectory(at: outputDirURL, withIntermediateDirectories: true)

let targets: [(String, CGFloat)] = [
  ("favicon.png", 32),
  ("icons/Icon-192.png", 192),
  ("icons/Icon-512.png", 512),
  ("icons/Icon-maskable-192.png", 192),
  ("icons/Icon-maskable-512.png", 512),
]

func renderIcon(size: CGFloat) -> Data? {
  let canvas = NSSize(width: size, height: size)
  let image = NSImage(size: canvas)
  image.lockFocus()

  NSColor.clear.setFill()
  NSRect(origin: .zero, size: canvas).fill()

  let cardInset = size * 0.08
  let cardRect = NSRect(
    x: cardInset,
    y: cardInset,
    width: size - (cardInset * 2),
    height: size - (cardInset * 2)
  )
  let cornerRadius = size * 0.18
  let cardPath = NSBezierPath(
    roundedRect: cardRect,
    xRadius: cornerRadius,
    yRadius: cornerRadius
  )
  NSColor.white.setFill()
  cardPath.fill()

  let logoInset = size * 0.18
  let logoRect = NSRect(
    x: logoInset,
    y: logoInset,
    width: size - (logoInset * 2),
    height: size - (logoInset * 2)
  )
  sourceImage.draw(
    in: logoRect,
    from: .zero,
    operation: .sourceOver,
    fraction: 1.0
  )

  image.unlockFocus()

  guard
    let tiffData = image.tiffRepresentation,
    let rep = NSBitmapImageRep(data: tiffData)
  else {
    return nil
  }

  return rep.representation(using: .png, properties: [:])
}

for (relativePath, size) in targets {
  let targetURL = outputDirURL.appendingPathComponent(relativePath)
  try fileManager.createDirectory(
    at: targetURL.deletingLastPathComponent(),
    withIntermediateDirectories: true
  )
  guard let pngData = renderIcon(size: size) else {
    fputs("Failed to render \(relativePath)\n", stderr)
    exit(1)
  }
  try pngData.write(to: targetURL)
}
