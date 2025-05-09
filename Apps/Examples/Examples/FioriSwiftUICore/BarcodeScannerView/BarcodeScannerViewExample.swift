import SwiftUI
import VisionKit
import FioriSwiftUICore

struct BarcodeScannerViewExample: View {
    @State private var barcode: String = ""
    
    var body: some View {
        VStack(alignment: .center) {
            Text("BarcodeScannerView Example")
                .font(.title2)
                .foregroundColor(.blue)
                .padding(.top, 16)
        }
        VStack {
            BarcodeScannerView(
                barcodeValue: $barcode,
                preferredScanner: .proGlove,
                fallbackAllowed: true
            )
            Text("Scanned: \(barcode)")
            Spacer()
        }
    }
}
