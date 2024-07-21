import CbShared
import SwiftUI

struct ChatScreen: View {
    @ObservedObject var viewModel: ChatScreenViewModel

    public init(device: CBDevice) {
        viewModel = ChatScreenViewModel(target: device)
    }

    var body: some View {
        VStack {
            Text("Chat with \(viewModel.targetDevice.deviceName)")
                .font(.title)

            ScrollView {
                LazyVStack {
                    ForEach(viewModel.messages, id: \.id) { message in
                        ChatScreenBubble(message: message, isFirst: false, isLast: false)
                    }
                }
            }

            HStack {
                TextField("Input", text: $viewModel.messageInput)

                Button {
                    viewModel.didPressSend()
                } label: {
                    Text("Send")
                }
            }
            .padding()
        }
    }
}
