import CbShared
import SwiftUI

public struct ChatScreenBubble: View {
    let message: CBMessage
    let isFirst: Bool
    let isLast: Bool

    public init(message: CBMessage, isFirst: Bool, isLast: Bool) {
        self.message = message
        self.isFirst = isFirst
        self.isLast = isLast
    }

    public var body: some View {
        VStack(alignment: .leading) {
            if message.sender.id != "SELF" {
                Text(message.contents)
                    .font(.body)
                    .padding(EdgeInsets(top: isFirst ? 0 : 8, leading: 16, bottom: isLast ? 0 : 8, trailing: 16))
                    .background(Color.green)
                    .foregroundColor(.white)
            } else {
                Text(message.contents)
                    .font(.body)
                    .padding(EdgeInsets(top: isFirst ? 0 : 8, leading: 16, bottom: isLast ? 0 : 8, trailing: 16))
                    .background(Color.blue)
                    .foregroundColor(.white)
            }
        }
    }
}
