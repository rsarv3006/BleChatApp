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
        if message.sender.id != "SELF" {
            VStack(alignment: .leading) {
                HStack { Spacer() }

                VStack(alignment: .leading) {
                    Text(message.timestamp.formatted())
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(message.contents)
                        .font(.body)
                        .padding(EdgeInsets(top: isFirst ? 0 : 8, leading: 16, bottom: isLast ? 0 : 8, trailing: 16))
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                Spacer()
            }
            .padding()
        } else {
            VStack(alignment: .trailing) {
                HStack {
                    Spacer()
                }
                VStack(alignment: .trailing) {
                    Text(message.timestamp.formatted())
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text(message.contents)
                        .font(.body)
                        .padding(EdgeInsets(top: isFirst ? 0 : 8, leading: 16, bottom: isLast ? 0 : 8, trailing: 16))
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
    }
}
