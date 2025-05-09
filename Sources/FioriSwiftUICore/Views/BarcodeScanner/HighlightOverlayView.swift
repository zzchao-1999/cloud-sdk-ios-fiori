import SwiftUI
import VisionKit

struct HighlightOverlayView: View {
    let normalizedBounds: RecognizedItem.Bounds?

    var body: some View {
        GeometryReader { geometry in
            if let bounds = normalizedBounds {
                let viewSize = geometry.size
                let rect = CGRect(
                    x: bounds.topLeft.x * viewSize.width,
                    y: (1.0 - bounds.topLeft.y) * viewSize.height,
                    width: (bounds.topRight.x - bounds.topLeft.x) * viewSize.width,
                    height: (bounds.topLeft.y - bounds.bottomLeft.y) * viewSize.height
                )
                Rectangle()
                    .stroke(Color.green, lineWidth: 2)
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)
            }
        }
    }
}
