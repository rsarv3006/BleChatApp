import CbShared
import SwiftUI

struct ChatScreen: View {
    @ObservedObject var viewModel: ChatScreenViewModel

    public init(device: CBDevice) {
        viewModel = ChatScreenViewModel(target: device)
    }

    var body: some View {
        ScrollView {
            Text("Chat with \(viewModel.targetDevice.deviceName)")
                .font(.title)
        }
    }
}
