import CbShared
import SwiftUI

public class ChatScreenViewModel: ObservableObject {
    @Published var targetDevice: CBDevice
    @Published var chatService: CBChatService
    @Published var messages: [CBMessage] = []
    @Published var messageInput: String = ""

    private let currentDeviceSender: CBSender

    public init(target: CBDevice) {
        targetDevice = target
        chatService = CBChatService(target: target)
        currentDeviceSender = CBSender(id: "SELF", name: "Me")

        chatService.onMessageReceived = { [weak self] messageString in
            guard let self else { return }

            let peripheral = self.targetDevice.peripheral

            let senderId = peripheral.identifier.uuidString
            let senderName = peripheral.name ?? senderId
            let sender = CBSender(id: senderId, name: senderName)

            let message = CBMessage(
                timestamp: Date(),
                sender: sender,
                contents: messageString
            )

            self.messages.append(message)
        }
    }

    public func didPressSend() {
        if messageInput.isEmpty {
            return
        }

        chatService.send(messageInput)

        let message = CBMessage(
            timestamp: Date(),
            sender: currentDeviceSender,
            contents: messageInput
        )

        messageInput = ""

        messages.append(message)
    }
}
