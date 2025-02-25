import SwiftUI
#if canImport(ConnectSDK)
import ConnectSDK
#endif

public struct BarcodeScannerView: View {
    @State private var textFieldText: String = ""
    @State private var isScanning: Bool = false

    public init() {}
    
    public var body: some View {
        VStack {
            HStack {
                TextField("Enter text or scan result", text: $textFieldText)
                   .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    // Simulate scanning action
                    self.isScanning = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.textFieldText = "Scanned result"
                        self.isScanning = false
                    }
                }) {
                    Image(systemName: "barcode.viewfinder")
                        .font(.largeTitle)
                        .disabled(self.isScanning)
                }
            }
#if canImport(ConnectSDK)
            Text("ConnectSDK Version: \(ConnectSDKVersionStringObject)")
                .foregroundStyle(Color.yellow)
#endif
        }
    }
}

struct ContentView: View {
    var body: some View {
        BarcodeScannerView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
