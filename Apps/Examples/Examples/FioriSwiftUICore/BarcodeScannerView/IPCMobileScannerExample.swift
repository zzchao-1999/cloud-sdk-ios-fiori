import SwiftUI
import FioriSwiftUICore

struct IPCMobileScannerExample: View {
    @State private var barcode1: String = ""
    @State private var barcode2: String = ""
    @State private var barcode3: String = ""
    @State private var description1: String = ""
    @State private var description2: String = ""
    @State private var customBarcode: String = ""
    @State private var searchResult: String = ""
    @State private var nextFieldIndex = 0
    @ObservedObject private var scannerManager = BarcodeScannerManager.shared
    @State private var qrCodeImage: Image?

    var body: some View {
        VStack(alignment: .center) {
            Text("IPCMobile Scanner Example")
                .font(.title2)
                .foregroundColor(.blue)
                .padding(.top, 16)
        }
        ScrollView {
            VStack {
                // Barcode Fields
                HStack(spacing: 20) {
                    Text("Barcode 1")
                    TextField("Scan with RapidScan", text: $barcode1)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(true)
                }
                HStack(spacing: 20) {
                    Text("Barcode 2")
                    TextField("Scan with RapidScan", text: $barcode2)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(true)
                }
                HStack(spacing: 20) {
                    Text("Barcode 3")
                    TextField("Scan with RapidScan", text: $barcode3)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(true)
                }

                // Description Fields
                HStack(spacing: 20) {
                    Text("Description 1")
                    TextField("Enter description", text: $description1)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                HStack(spacing: 20) {
                    Text("Description 2")
                    TextField("Enter description", text: $description2)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                // Custom Scan Section
                VStack {
                    HStack(spacing: 20) {
                        TextField("Custom Barcode", text: $customBarcode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disabled(true) // Read-only, updated by scanner
                        Button("Scan") {
                            scannerManager.onBarcodeScanned = { barcode in
                                customBarcode = barcode
                                searchResult = "Searched with: \(barcode)"
                                scannerManager.updateScannerDisplay(message: "Scan completed: \(barcode)")
                                scannerManager.onBarcodeScanned = nil
                            }
                        }
//                        .disabled(!scannerManager.isScannerReady)
                    }
                    Text(searchResult)
                        .foregroundStyle(Color.yellow)
                }
            }
            .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
            .onAppear {
                setupScanner()
            }
        }
    }

    private func setupScanner() {
        scannerManager.setActiveScanner(.ipcMobile)
        scannerManager.startMonitoring()
        scannerManager.onBarcodeScanned = { barcode in
            switch nextFieldIndex {
            case 0:
                barcode1 = barcode
                nextFieldIndex = 1
            case 1:
                barcode2 = barcode
                nextFieldIndex = 2
            case 2:
                barcode3 = barcode
                nextFieldIndex = 0
            default:
                break
            }
        }
    }
}
