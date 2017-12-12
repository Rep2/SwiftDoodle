import UIKit

extension CGContext {
    func draw(points: [Point], palette: PaletteViewModel) {
        var points = points

        if let firstPoint = try? points.remove(safeAtIndex: 0) {
            setBlendMode(palette.tool == .eraser ? .clear : .normal)

            setStrokeColor(palette.color.cgColor)
            setLineWidth(CGFloat(palette.width))

            beginPath()

            move(to: CGPoint(x: firstPoint.location.x, y: firstPoint.location.y))

            points.forEach { addLine(to: CGPoint(x: $0.location.x, y: $0.location.y)) }

            strokePath()
        }
    }

    static func context(withSize size: CGSize, scale: CGFloat) -> CGContext {
        let context = CGContext(
            data: nil,
            width: Int(size.width * scale),
            height: Int(size.height * scale),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )!

        context.setLineCap(.round)

        let transform = CGAffineTransform(scaleX: scale, y: scale)
        context.concatenate(transform)

        return context
    }
}
