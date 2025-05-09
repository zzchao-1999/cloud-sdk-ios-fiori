import SwiftUI
import VisionKit

public struct BarcodeScannerView: View {
    @Binding public var barcodeValue: String
    @StateObject private var scannerManager = BarcodeScannerManager.shared
    @State private var isPresentingCamera = false
    private let preferredScanner: ScannerType
    private let fallbackAllowed: Bool
    
    public init(
        barcodeValue: Binding<String>,
        preferredScanner: ScannerType = .visionKit,
        fallbackAllowed: Bool = false
    ) {
        self._barcodeValue = barcodeValue
        self.preferredScanner = preferredScanner
        self.fallbackAllowed = fallbackAllowed
    }
    
    public var body: some View {
        HStack(spacing: 20) {
            ZStack(alignment: .trailing) {
                TextField("Barcode value", text: $barcodeValue)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(true)
                
                Button(action: {
                    scannerManager.onBarcodeScanned = { barcode in
                        barcodeValue = barcode
                        scannerManager.onBarcodeScanned = nil
                        isPresentingCamera = false
                    }
                    let isPreferredScannerReady = scannerManager.getScannerInstance(for: preferredScanner)?.currentStatus == .ready
                    scannerManager.setActiveScanner(isPreferredScannerReady ? preferredScanner : .visionKit)
                    scannerManager.triggerScan()
                    if scannerManager.getScannerInstance(for: scannerManager.activeScannerType!)?.type == .visionKit {
                        isPresentingCamera = true
                    }
                }) {
                    Image(systemName: "barcode.viewfinder")
                        .font(.title2)
                        .foregroundColor(isButtonEnabled ? .blue : .gray)
                        .padding(.trailing, 8)
                }
                .disabled(!isButtonEnabled)
            }
        }
        .onAppear {
            scannerManager.setActiveScanner(preferredScanner)
            scannerManager.startMonitoring()
        }
        .fullScreenCover(isPresented: $isPresentingCamera) {
            if let scannerView = scannerManager.getScannerView() as? UIViewController {
                VisionKitScannerView(scannerView: scannerView)
                    .ignoresSafeArea(.all)
            }
        }
    }
    
    private var isButtonEnabled: Bool {
        // Enable button for proglove or ipcmobile regardless of readiness
        if preferredScanner == .proGlove || preferredScanner == .ipcMobile {
            return true
        }
        // Enable button for visionKit if ready
        if preferredScanner == .visionKit {
            return scannerManager.getScannerInstance(for: .visionKit)?.currentStatus == .ready
        }
        // Enable button for fallback to visionKit if allowed and visionKit is ready
        return fallbackAllowed && scannerManager.getScannerInstance(for: .visionKit)?.currentStatus == .ready
    }
}

struct VisionKitScannerView: UIViewControllerRepresentable {
    let scannerView: UIViewController
    
    func makeUIViewController(context: Context) -> UIViewController {
        scannerView
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
