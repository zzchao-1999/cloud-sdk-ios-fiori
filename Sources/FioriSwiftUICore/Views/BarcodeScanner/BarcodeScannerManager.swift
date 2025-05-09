import SwiftUI
import Combine
import VisionKit
#if canImport(ConnectSDK)
import ConnectSDK
#endif
#if canImport(RapidScanCompanion)
import RapidScanCompanion
#endif

@MainActor
public final class BarcodeScannerManager: ObservableObject {
    public static let shared = BarcodeScannerManager()

    @Published public private(set) var activeScannerType: ScannerType?
    @Published public private(set) var status: ScannerStatus = .poweredOff
    @Published public private(set) var isScanning: Bool = false
    @Published public private(set) var pairingImage: Image?

    public var onBarcodeScanned: ((String) -> Void)?
    public var onStatusChanged: ((ScannerStatus) -> Void)?
    
    private var activeScanner: (any BarcodeScanner)?
    private var visionKitScanner = VisionKitScanner()
    #if canImport(ConnectSDK)
    private let proGloveScanner = ProGloveScanner()
    #endif
    #if canImport(RapidScanCompanion)
    private let ipcMobileScanner = IPCMobileScanner()
    #endif
    private let recognizedDataTypes: Set<DataScannerViewController.RecognizedDataType>
    private let recognizesMultipleItems: Bool

    public init(
        recognizedDataTypes: Set<DataScannerViewController.RecognizedDataType>? = nil,
        recognizesMultipleItems: Bool? = nil
    ) {
        self.recognizedDataTypes = recognizedDataTypes ?? Set([.barcode()])
        self.recognizesMultipleItems = recognizesMultipleItems ?? false
        self.visionKitScanner = VisionKitScanner(
            recognizedDataTypes: self.recognizedDataTypes,
            recognizesMultipleItems: self.recognizesMultipleItems
        )
        updateStateForNoScanner(reason: .poweredOff)
        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                self?.resetAllScanners()
            }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func resetAllScanners() {
        #if canImport(ConnectSDK)
        proGloveScanner.stopMonitoring()
        proGloveScanner.delegate = nil
        print("ScannerManager: Reset ProGloveScanner")
        #endif
        #if canImport(RapidScanCompanion)
        ipcMobileScanner.stopMonitoring()
        ipcMobileScanner.delegate = nil
        print("ScannerManager: Reset IPCMobileScanner")
        #endif
        visionKitScanner.stopMonitoring()
        visionKitScanner.delegate = nil
        print("ScannerManager: Reset VisionKitScanner")
        activeScanner = nil
        activeScannerType = nil
        updateStateForNoScanner(reason: .poweredOff)
    }
    
    public func setActiveScanner(_ type: ScannerType?) {
        print("ScannerManager: Setting active scanner to \(type?.description ?? "None")")
        if type != activeScannerType {
            activeScanner?.stopMonitoring()
            activeScanner?.delegate = nil
        }

        if let type = type {
            guard let scanner = getScannerInstance(for: type) else {
                activeScanner = nil
                activeScannerType = nil
                updateStateForNoScanner(reason: .error("Scanner \(type.description) not available"))
                print("ScannerManager: Failed to get scanner instance for \(type.description)")
                return
            }
            if scanner.type != type {
                activeScanner = nil
                activeScannerType = nil
                updateStateForNoScanner(reason: .error("Scanner type mismatch for \(type.description)"))
                print("ScannerManager: Type mismatch - Expected \(type.description), got \(scanner.type.description)")
                return
            }
            activeScanner = scanner
            activeScannerType = type
            scanner.delegate = self
            scanner.startMonitoring()
            updateState(from: scanner)
            print("ScannerManager: Successfully activated scanner: \(type.description)")
        } else {
            activeScanner = nil
            activeScannerType = nil
            updateStateForNoScanner(reason: .poweredOff)
            print("ScannerManager: Cleared active scanner")
        }
    }

    public func startMonitoring() {
        guard let scanner = activeScanner else {
            updateStateForNoScanner(reason: .error("No active scanner selected"))
            return
        }
        scanner.startMonitoring()
    }

    public func stopMonitoring() {
        activeScanner?.stopMonitoring()
        if activeScanner == nil {
            updateStateForNoScanner(reason: .poweredOff)
        } else {
            updateState(from: activeScanner!)
        }
    }

    public func triggerScan() {
        guard let scanner = activeScanner else {
            updateStateForNoScanner(reason: .error("No active scanner selected."))
            return
        }
        scanner.triggerScan()
    }
    
    public func getPairingQRCode() -> Image? {
        guard let scanner = activeScanner else {
            updateStateForNoScanner(reason: .error("No active scanner for pairing"))
            return nil
        }
        return scanner.getPairingQRCode()
    }

    public func cancelPairing() {
        pairingImage = nil
        if let scanner = activeScanner {
            updateState(from: scanner)
        } else {
            updateStateForNoScanner(reason: .poweredOff)
        }
    }

    public func resetActiveScanner() {
        activeScanner?.stopMonitoring()
        activeScanner?.delegate = nil
        activeScanner = nil
        activeScannerType = nil
        updateStateForNoScanner(reason: .poweredOff)
    }

    public func updateScannerDisplay(message: String) {
        activeScanner?.updateDisplay(message: message)
    }

    public func scannerDidReceiveBarcode(_ barcode: String, sender: BarcodeScanner) {
        guard sender === activeScanner else { return }
        onBarcodeScanned?(barcode)
    }

    public func getScannerView() -> Any? {
        guard let scanner = activeScanner, scanner.type == .visionKit else { return nil }
        return (scanner as? VisionKitScanner)?.getScannerViewController()
    }
    
    public func availableScannerTypes() -> [ScannerType] {
        ScannerType.allCases.filter { getScannerInstance(for: $0)?.isAvailable() ?? false}
    }
    
    public func getScannerInstance(for type: ScannerType) -> (any BarcodeScanner)? {
        switch type {
        case .visionKit:
            return visionKitScanner
        case .proGlove:
            #if canImport(ConnectSDK)
            return proGloveScanner
            #else
            print("ScannerManager: ProGlove SDK not available.")
            return nil
            #endif
        case .ipcMobile:
            #if canImport(RapidScanCompanion)
            return ipcMobileScanner
            #else
            print("RapidScanCompanion SDK not available")
            return nil
            #endif
        }
    }

    private func updateState(from scanner: any BarcodeScanner) {
        status = scanner.currentStatus
        isScanning = scanner.currentStatus == .scanning
        pairingImage = nil
        onStatusChanged?(status)
    }

    public func updateStateForNoScanner(reason: ScannerStatus) {
        status = reason
        activeScannerType = nil
        isScanning = false
        pairingImage = nil
        onStatusChanged?(reason)
    }
}

extension BarcodeScannerManager: BarcodeScannerDelegate {
    public func barcodeScannerDidUpdateStatus(_ status: ScannerStatus, for scanner: any BarcodeScanner) {
        guard scanner === activeScanner else { return }
        updateState(from: scanner)
    }
    
    public func barcodeScannerDidReceiveBarcode(_ barcode: String, from scanner: any BarcodeScanner) {
        guard scanner === activeScanner else { return }
        onBarcodeScanned?(barcode)
    }
}
