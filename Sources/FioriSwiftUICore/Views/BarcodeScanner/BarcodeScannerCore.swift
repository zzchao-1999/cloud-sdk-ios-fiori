import SwiftUI
import VisionKit

public enum ScannerStatus: Equatable {
    case poweredOff
    case poweredOn
    case initializing
    case ready
    case scanning
    case connected
    case disconnected
    case error(String)

    public var description: String {
        switch self {
        case .poweredOff: return "Powerred Off"
        case .poweredOn: return "Powerred On"
        case .initializing: return "Initializing"
        case .ready: return "Ready"
        case .scanning: return "Scanning"
        case .connected: return "Connected"
        case .disconnected: return "Disconnected"
        case .error(let msg): return "Error: \(msg)"
        }
    }
}

public enum ScannerType: Equatable, CaseIterable {
    case visionKit
    case proGlove
    case ipcMobile
//    case quantum
    
    
    public var description: String {
        switch self {
        case .visionKit:
            return "Camera (VisionKit)"
        case .proGlove:
            return "ProGlove"
        case .ipcMobile:
            return "IPCMobile (RapidScan)"
//        case .quantum
//            return "NexusConnect/Linea Pro"
        }
    }
}

// Delegate protocol for scanners to report back to the manager
@MainActor
public protocol BarcodeScannerDelegate: AnyObject {
    func barcodeScannerDidUpdateStatus(_ status: ScannerStatus, for sender: any BarcodeScanner)
    func barcodeScannerDidReceiveBarcode(_ barcode: String, from sender: any BarcodeScanner)
}

@MainActor
public protocol BarcodeScanner: AnyObject {
    var type: ScannerType { get }
    var currentStatus: ScannerStatus { get }
    var delegate: (any BarcodeScannerDelegate)? { get set }

    func startMonitoring()
    func stopMonitoring()
    func triggerScan()
    func reset()

    func getPairingQRCode() -> Image?

    func updateDisplay(message: String)
    
    func isAvailable() -> Bool
    func getScannerView() -> Any?
}

public extension BarcodeScanner {
    func triggerScan() {}
    func updateDisplay(message: String) {}
    func getPairingQRCode() -> Image? { nil }
    func stopMonitoring() { reset() }
    func isAvailable() -> Bool { false }
    func getScannerView() -> Any? { nil }
}
