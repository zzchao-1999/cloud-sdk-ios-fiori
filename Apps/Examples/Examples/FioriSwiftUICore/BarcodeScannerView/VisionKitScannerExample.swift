import SwiftUI
import FioriSwiftUICore

struct VisionKitScannerExample: View {
    @State private var customBarcode: String = ""
    @State private var searchResult: String = ""
    @State private var isPresentingCamera = false
//    @StateObject private var scannerManager = BarcodeScannerManager.shared
    @StateObject private var scannerManager = BarcodeScannerManager(
        recognizedDataTypes: Set([.barcode()]),
        recognizesMultipleItems: false
    )
    
    var body: some View {
        VStack(alignment: .center) {
            Text("VisionKit Scanner Example")
                .font(.title2)
                .foregroundColor(.blue)
                .padding(.top, 16)
        }
        VStack {
            VStack {
                HStack(spacing: 20) {
                    ZStack(alignment: .trailing) {
                        TextField("Camera Scanning", text: $customBarcode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disabled(true)
                        Button(action: {
                            scannerManager.onBarcodeScanned = { barcode in
                                customBarcode = barcode
                                scannerManager.onBarcodeScanned = nil
                                isPresentingCamera = false
                            }
                            scannerManager.triggerScan()
                            isPresentingCamera = true
                        }) {
                            Image(systemName: "barcode.viewfinder")
                                .font(.title2)
                                .foregroundColor(scannerManager.status == .ready ? .blue : .gray)
                                .padding(.trailing, 8)
                        }
                        .disabled(scannerManager.status != .ready)
                    }
                }
            }
            Spacer()
        }
        .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
        .onAppear {
            setupScanner()
        }
        .fullScreenCover(isPresented: $isPresentingCamera) {
            if let scannerView = scannerManager.getScannerView() as? UIViewController {
                VisionKitScannerView(scannerView: scannerView)
                    .ignoresSafeArea(.all)
            }
        }
    }

    private func setupScanner() {
        scannerManager.setActiveScanner(.visionKit)
        scannerManager.startMonitoring()
    }
}

// Wrapper for presenting DataScannerViewController in SwiftUI
struct VisionKitScannerView: UIViewControllerRepresentable {
    let scannerView: UIViewController
    
    func makeUIViewController(context: Context) -> UIViewController {
        scannerView
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
