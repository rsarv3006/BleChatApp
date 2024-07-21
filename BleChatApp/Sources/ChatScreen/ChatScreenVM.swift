import CbShared
import SwiftUI

public class ChatScreenViewModel: ObservableObject {
    @Published var targetDevice: CBDevice
    @Published var chatService: CBChatService

    public init(target: CBDevice) {
        self.targetDevice = target
        self.chatService = CBChatService(target: target)
    }
}
