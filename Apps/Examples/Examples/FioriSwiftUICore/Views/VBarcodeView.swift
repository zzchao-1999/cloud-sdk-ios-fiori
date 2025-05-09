import SwiftUI
import VisionKit

struct VBarcodeView: View {
    @State private var scannedString: String = "Scan a QR code or barcode"
    @State private var recognizedItems: [RecognizedItem] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                DataScannerView(
                    recognizedItems: $recognizedItems,
                    scannedString: $scannedString, // Added binding to update from coordinator
                    recognizedDataType: .barcode(),
                    recognizesMultipleItems: false
                )
                .edgesIgnoringSafeArea(.all)
                
                CornerMarkersView(width: geometry.size.width * 0.7,
                                                height: geometry.size.height * 0.3)
                    .foregroundColor(.white)
                    .overlay(
                        Text("Place barcode here")
                            .foregroundColor(.white)
                            .font(.caption)
                    )
                
                Text(scannedString)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding()
            }
        }
    }
}

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
                // Top-left corner (correct)
                path.move(to: CGPoint(x: minX + cornerLength, y: minY))
                path.addLine(to: CGPoint(x: minX + cornerRadius, y: minY))
                path.addArc(center: CGPoint(x: minX + cornerRadius, y: minY + cornerRadius),
                           radius: cornerRadius,
                           startAngle: .degrees(-90),
                           endAngle: .degrees(-180),
                           clockwise: true)
                path.addLine(to: CGPoint(x: minX, y: minY + cornerLength))
                
                // Top-right corner (correct)
                path.move(to: CGPoint(x: maxX - cornerLength, y: minY))
                path.addLine(to: CGPoint(x: maxX - cornerRadius, y: minY))
                path.addArc(center: CGPoint(x: maxX - cornerRadius, y: minY + cornerRadius),
                           radius: cornerRadius,
                           startAngle: .degrees(-90),
                           endAngle: .degrees(0),
                           clockwise: false)
                path.addLine(to: CGPoint(x: maxX, y: minY + cornerLength))
                
                // Bottom-left corner (fixed)
                path.move(to: CGPoint(x: minX, y: maxY - cornerLength))
                path.addLine(to: CGPoint(x: minX, y: maxY - cornerRadius))
                path.addArc(center: CGPoint(x: minX + cornerRadius, y: maxY - cornerRadius),
                           radius: cornerRadius,
                           startAngle: .degrees(90),
                           endAngle: .degrees(180),
                           clockwise: false)
                path.addLine(to: CGPoint(x: minX + cornerLength, y: maxY))
                
                // Bottom-right corner (fixed)
                path.move(to: CGPoint(x: maxX, y: maxY - cornerLength))
                path.addLine(to: CGPoint(x: maxX, y: maxY - cornerRadius))
                path.addArc(center: CGPoint(x: maxX - cornerRadius, y: maxY - cornerRadius),
                           radius: cornerRadius,
                           startAngle: .degrees(0),
                           endAngle: .degrees(90),
                           clockwise: true)
                path.addLine(to: CGPoint(x: maxX - cornerLength, y: maxY))
            }
            .stroke(lineWidth: lineWidth)
        }
    }
}

struct DataScannerView: UIViewControllerRepresentable {
    @Binding var recognizedItems: [RecognizedItem]
    @Binding var scannedString: String // Added to update directly
    let recognizedDataType: DataScannerViewController.RecognizedDataType
    let recognizesMultipleItems: Bool
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let vc = DataScannerViewController(
            recognizedDataTypes: [recognizedDataType],
            qualityLevel: .balanced,
            recognizesMultipleItems: recognizesMultipleItems,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        return vc
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        uiViewController.delegate = context.coordinator
        try? uiViewController.startScanning()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(recognizedItems: $recognizedItems, scannedString: $scannedString)
    }
    
    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        uiViewController.stopScanning()
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        @Binding var recognizedItems: [RecognizedItem]
        @Binding var scannedString: String
        
        init(recognizedItems: Binding<[RecognizedItem]>, scannedString: Binding<String>) {
            self._recognizedItems = recognizedItems
            self._scannedString = scannedString
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            print("didTapOn \(item)")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            recognizedItems.append(contentsOf: addedItems)
            if let item = addedItems.first,
               case let .barcode(barcode) = item,
               let payload = barcode.payloadStringValue {
                scannedString = payload
            }
            print("didAddItems \(addedItems)")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            self.recognizedItems = recognizedItems.filter { item in
                !removedItems.contains(where: { $0.id == item.id })
            }
            if recognizedItems.isEmpty {
                scannedString = "Scan a QR code or barcode"
            }
            print("didRemovedItems \(removedItems)")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
            print("became unavailable with error \(error.localizedDescription)")
        }
    }
}

//import SwiftUI
//import AVFoundation
//import Vision
//import Foundation
//
//struct VBarcodeView: View {
//    @State private var scannedString: String = "Scan a QR code or barcode"
//    @State private var barcodeFrame: CGRect = .zero
//    @State private var previewSize: CGSize = .zero
//    @State private var barcodeImage: UIImage? = nil
//    
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack(alignment: .bottom) {
//                ScannerView(scannedString: $scannedString, barcodeFrame: $barcodeFrame, barcodeImage: $barcodeImage, previewSize: $previewSize)
//                    .edgesIgnoringSafeArea(.all)
//                    .onAppear {
//                        previewSize = geometry.size
//                    }
//                if let image = barcodeImage, barcodeFrame != .zero {
//                    Image(uiImage: image)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: barcodeFrame.width * previewSize.width,
//                              height: barcodeFrame.height * previewSize.height)
//                        .position(x: barcodeFrame.midX * previewSize.width,
//                                y: (1.0 - barcodeFrame.midY) * previewSize.height)
//                        .opacity(0.7)
//                        .animation(.easeInOut(duration: 0.2), value: barcodeFrame)
//                }
//                
//                Text(scannedString)
//                    .font(.system(size: 16, weight: .medium))
//                    .foregroundColor(.white)
//                    .padding()
//                    .background(Color.black.opacity(0.7))
//                    .clipShape(RoundedRectangle(cornerRadius: 10))
//                    .padding()
//            }
//        }
//    }
//    
//    private func convertBarcodeFrame(_ frame: CGRect, to size: CGSize) -> CGRect {
//        // Vision coordinates are normalized (0-1) and need to be flipped vertically
//        let flippedY = 1.0 - frame.origin.y - frame.height
//        return CGRect(
//            x: frame.origin.x * size.width,
//            y: flippedY * size.height,
//            width: frame.width * size.width,
//            height: frame.height * size.height
//        )
//    }
//}
//
//struct ScannerView: UIViewControllerRepresentable {
//    @Binding var scannedString: String
//    @Binding var barcodeFrame: CGRect
//    @Binding var barcodeImage: UIImage?
//    @Binding var previewSize: CGSize
//    
//    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
//        var parent: ScannerView
//        private var lastDetectionTime: Date = .distantPast
//        private let detectionQueue = DispatchQueue(label: "barcode.detection")
//        
//        init(_ parent: ScannerView) {
//            self.parent = parent
//        }
//        
//        func captureOutput(_ output: AVCaptureOutput,
//                         didOutput sampleBuffer: CMSampleBuffer,
//                         from connection: AVCaptureConnection) {
//            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
//            
//            if let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation {
//                connection.videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue) ?? .portrait
//            }
//            
//            detectionQueue.async { [weak self] in
//                self?.detectBarcode(in: pixelBuffer, sampleBuffer: sampleBuffer)
//            }
//        }
//        
//        private func detectBarcode(in pixelBuffer: CVPixelBuffer, sampleBuffer: CMSampleBuffer) {
//            let request = VNDetectBarcodesRequest { [weak self] request, error in
//                guard let self = self else { return }
//                
//                guard error == nil,
//                      let results = request.results as? [VNBarcodeObservation],
//                      let barcode = results.first,
//                      let payload = barcode.payloadStringValue else {
//                    DispatchQueue.main.async {
//                        self.parent.barcodeFrame = .zero
//                        self.parent.barcodeImage = nil
//                    }
//                    return
//                }
//                
//                let now = Date()
//                guard now.timeIntervalSince(self.lastDetectionTime) > 0.3 else { return }
//                self.lastDetectionTime = now
//                
//                // Convert pixel buffer to UIImage and crop
//                let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
//                let context = CIContext()
//                guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
//                let fullImage = UIImage(cgImage: cgImage)
//                
//                // Calculate crop rect in image coordinates
//                let imageSize = ciImage.extent.size
//                let cropRect = CGRect(
//                    x: barcode.boundingBox.origin.x * imageSize.width,
//                    y: (1.0 - barcode.boundingBox.origin.y - barcode.boundingBox.height) * imageSize.height,
//                    width: barcode.boundingBox.width * imageSize.width,
//                    height: barcode.boundingBox.height * imageSize.height
//                )
//                
//                if let croppedCGImage = fullImage.cgImage?.cropping(to: cropRect) {
//                    let croppedImage = UIImage(cgImage: croppedCGImage)
//                    
//                    DispatchQueue.main.async {
//                        self.parent.scannedString = payload
//                        self.parent.barcodeFrame = barcode.boundingBox
//                        self.parent.barcodeImage = croppedImage
//                        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
//                        
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                            if self.parent.barcodeFrame == barcode.boundingBox {
//                                self.parent.barcodeFrame = .zero
//                                self.parent.barcodeImage = nil
//                            }
//                        }
//                    }
//                }
//            }
//            
//            request.symbologies = [.qr, .code128, .ean13, .ean8, .upce]
//            
//            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
//                                              orientation: getCGImageOrientation(),
//                                              options: [:])
//            do {
//                try handler.perform([request])
//            } catch {
//                print("Barcode detection failed: \(error)")
//            }
//        }
//        
//        private func getCGImageOrientation() -> CGImagePropertyOrientation {
//            guard let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation else {
//                return .up
//            }
//            switch orientation {
//            case .portrait: return .up
//            case .portraitUpsideDown: return .down
//            case .landscapeLeft: return .left
//            case .landscapeRight: return .right
//            default: return .up
//            }
//        }
//    }
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    func makeUIViewController(context: Context) -> UIViewController {
//        let viewController = UIViewController()
//        
//        let captureSession = AVCaptureSession()
//        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
//              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
//              captureSession.canAddInput(videoInput) else {
//            return viewController
//        }
//        
//        captureSession.addInput(videoInput)
//        
//        let videoOutput = AVCaptureVideoDataOutput()
//        videoOutput.setSampleBufferDelegate(context.coordinator,
//                                          queue: DispatchQueue(label: "video.queue"))
//        if captureSession.canAddOutput(videoOutput) {
//            captureSession.addOutput(videoOutput)
//        }
//        
//        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        previewLayer.frame = viewController.view.bounds
//        previewLayer.videoGravity = .resizeAspectFill
//        viewController.view.layer.addSublayer(previewLayer)
//        
//        DispatchQueue.global(qos: .userInitiated).async {
//            captureSession.startRunning()
//        }
//        
//        return viewController
//    }
//    
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
//        if let previewLayer = uiViewController.view.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
//            previewLayer.frame = uiViewController.view.bounds
//        }
//    }
//}
//
