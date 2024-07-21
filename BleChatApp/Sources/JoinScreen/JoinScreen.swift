import CbShared
import SwiftUI

public struct JoinScreen: View {
    @ObservedObject var viewModel: JoinScreenViewModel

    public init() {
        viewModel = JoinScreenViewModel()
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
                        viewModel.onDisplayNameChanged()
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
                    NavigationLink(device.deviceName, destination: ChatScreen(device: device))
                }
            }
        }
    }
}
