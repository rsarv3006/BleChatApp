import Foundation

public struct CBMessage: Codable, Identifiable {
    public static func == (lhs: CBMessage, rhs: CBMessage) -> Bool {
        lhs.timestamp == rhs.timestamp
    }

    public let contents: String
    public let sender: CBSender
    public let timestamp: Date
    public let id: Date

    public init(timestamp: Date, sender: CBSender, contents: String) {
        id = timestamp
        self.timestamp = timestamp
        self.sender = sender
        self.contents = contents
    }
}

public struct CBSender: Codable, Identifiable {
    public let id: String
    public let name: String

    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
