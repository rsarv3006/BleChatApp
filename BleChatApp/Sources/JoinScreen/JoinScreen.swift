import SwiftUI
import CbShared

public struct JoinScreen: View {
    @ObservedObject var viewModel: JoinScreenViewModel

    public init() {
        self.viewModel = JoinScreenViewModel()
    }

    public var body: some View {
        ScrollView {
            Text("Connect")
                .font(.title)
                .padding()

            HStack {
                Spacer()

                VStack {
                    TextField("Dislay Name", text: $viewModel.displayName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Button {
                        print("set button pressed")
                    } label: {
                        Text("Set Name")
                    }
                }

                Spacer()
            }

            Text("Available Connections")
                .padding()

            LazyVStack {
                ForEach(viewModel.foundDevices, id: \.id) { device in
                    Text(device.deviceName)
                }
            }
            
        }
    }
}
