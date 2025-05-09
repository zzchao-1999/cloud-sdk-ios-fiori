import SwiftUI

struct CornerMarkersView: View {
    let width: CGFloat
    let height: CGFloat
    let cornerLength: CGFloat = 20
    let cornerRadius: CGFloat = 5
    let lineWidth: CGFloat = 2

    var body: some View {
        GeometryReader { geometry in
            let availableWidth = min(width, geometry.size.width)
            let availableHeight = min(height, geometry.size.height)
            let minX = (geometry.size.width - availableWidth) / 2
            let minY = (geometry.size.height - availableHeight) / 2
            let maxX = minX + availableWidth
            let maxY = minY + availableHeight

            Path { path in
                path.move(to: CGPoint(x: minX + cornerLength, y: minY))
                path.addLine(to: CGPoint(x: minX + cornerRadius, y: minY))
                path.addArc(center: CGPoint(x: minX + cornerRadius, y: minY + cornerRadius),
                            radius: cornerRadius,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(-180),
                            clockwise: true)
                path.addLine(to: CGPoint(x: minX, y: minY + cornerLength))

                path.move(to: CGPoint(x: maxX - cornerLength, y: minY))
                path.addLine(to: CGPoint(x: maxX - cornerRadius, y: minY))
                path.addArc(center: CGPoint(x: maxX - cornerRadius, y: minY + cornerRadius),
                            radius: cornerRadius,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(0),
                            clockwise: false)
                path.addLine(to: CGPoint(x: maxX, y: minY + cornerLength))

                path.move(to: CGPoint(x: minX, y: maxY - cornerLength))
                path.addLine(to: CGPoint(x: minX, y: maxY - cornerRadius))
                path.addArc(center: CGPoint(x: minX + cornerRadius, y: maxY - cornerRadius),
                            radius: cornerRadius,
                            startAngle: .degrees(180),
                            endAngle: .degrees(90),
                            clockwise: true)
                path.addLine(to: CGPoint(x: minX + cornerLength, y: maxY))

                path.move(to: CGPoint(x: maxX, y: maxY - cornerLength))
                path.addLine(to: CGPoint(x: maxX, y: maxY - cornerRadius))
                path.addArc(center: CGPoint(x: maxX - cornerRadius, y: maxY - cornerRadius),
                            radius: cornerRadius,
                            startAngle: .degrees(0),
                            endAngle: .degrees(90),
                            clockwise: false)
                path.addLine(to: CGPoint(x: maxX - cornerLength, y: maxY))
            }
            .stroke(lineWidth: lineWidth)
        }
    }
}
