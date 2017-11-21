import UIKit

extension CGContext {
    func draw(points: [Point]) {
        var points = points

        if let firstPoint = try? points.remove(safeAtIndex: 0) {

            beginPath()

            move(to: CGPoint(x: firstPoint.location.x, y: firstPoint.location.y))

            points
                .forEach { addLine(to: CGPoint(x: $0.location.x, y: $0.location.y)) }

            strokePath()
        }
    }

    static func context(withSize size: CGSize, scale: CGFloat, palette: Palette) -> CGContext {
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

        context.setStrokeColor(palette.color.cgColor)
        context.setLineWidth(palette.width)

        return context
    }
}
