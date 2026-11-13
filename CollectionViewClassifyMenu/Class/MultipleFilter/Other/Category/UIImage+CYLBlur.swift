//
//  UIImage+CYLBlur.swift
//  CollectionViewClassifyMenu
//
//  Translated from Objective-C to Swift (2026, docs/Swift-Migration.md).
//

import Accelerate
import UIKit

public extension UIImage {

    /**
     * A box-blurred copy (`iterations` passes of a box of `radius` points, close to a Gaussian blur), optionally tinted
     * with a quarter of `tintColor`. Returns the image itself when it is empty or has no bitmap.
     */
    func cylBlurred(radius: CGFloat, iterations: Int, tintColor: UIColor? = nil) -> UIImage {
        guard floor(size.width) * floor(size.height) > 0, let cgImage,
              let data = cgImage.dataProvider?.data, let source = CFDataGetBytePtr(data) else {
            return self
        }
        var boxSize = UInt32(max(1, radius * scale))
        if boxSize % 2 == 0 {
            boxSize += 1
        }
        let width = cgImage.width
        let height = cgImage.height
        let rowBytes = cgImage.bytesPerRow
        let byteCount = rowBytes * height
        let first = UnsafeMutableRawPointer.allocate(byteCount: byteCount, alignment: 16)
        let second = UnsafeMutableRawPointer.allocate(byteCount: byteCount, alignment: 16)
        defer {
            first.deallocate()
            second.deallocate()
        }
        first.copyMemory(from: source, byteCount: min(byteCount, CFDataGetLength(data)))
        var input = vImage_Buffer(data: first, height: vImagePixelCount(height), width: vImagePixelCount(width),
                                  rowBytes: rowBytes)
        var output = vImage_Buffer(data: second, height: vImagePixelCount(height), width: vImagePixelCount(width),
                                   rowBytes: rowBytes)
        let flags = vImage_Flags(kvImageEdgeExtend)
        let tempSize = vImageBoxConvolve_ARGB8888(&input, &output, nil, 0, 0, boxSize, boxSize, nil,
                                                  flags | vImage_Flags(kvImageGetTempBufferSize))
        let temp = UnsafeMutableRawPointer.allocate(byteCount: max(1, tempSize), alignment: 16)
        defer {
            temp.deallocate()
        }
        for _ in 0..<max(0, iterations) {
            vImageBoxConvolve_ARGB8888(&input, &output, temp, 0, 0, boxSize, boxSize, nil, flags)
            swap(&input, &output)
        }
        guard let colorSpace = cgImage.colorSpace,
              let context = CGContext(data: input.data, width: width, height: height, bitsPerComponent: 8,
                                      bytesPerRow: rowBytes, space: colorSpace, bitmapInfo: cgImage.bitmapInfo.rawValue)
        else {
            return self
        }
        if let tintColor, tintColor.cgColor.alpha > 0 {
            context.setFillColor(tintColor.withAlphaComponent(0.25).cgColor)
            context.setBlendMode(.plusLighter)
            context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        }
        guard let blurred = context.makeImage() else {
            return self
        }
        return UIImage(cgImage: blurred, scale: scale, orientation: imageOrientation)
    }
}
