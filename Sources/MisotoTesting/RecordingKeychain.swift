import Foundation
import MisotoFoundation
import Security

/// Recording Keychain double for tests across Misoto apps (unsigned test hosts lack Keychain entitlements).
public final class RecordingKeychain: KeychainItems {
    public var added: [[String: Any]] = []
    public var updated: [(query: [String: Any], attributes: [String: Any])] = []
    public var deleted: [[String: Any]] = []
    public var copied: [[String: Any]] = []
    public var updateStatus: OSStatus = errSecItemNotFound
    public var addStatuses: [OSStatus] = []
    public var stored: Data?
    public var rows: [[String: Any]] = []

    public init() {}

    public func add(_ attributes: [String: Any]) -> OSStatus {
        added.append(attributes)
        if !addStatuses.isEmpty { return addStatuses.removeFirst() }
        return errSecSuccess
    }

    public func copy(_ query: [String: Any]) -> (data: Data?, status: OSStatus) {
        copied.append(query)
        return stored.map { ($0, errSecSuccess) } ?? (nil, errSecItemNotFound)
    }

    public func update(_ query: [String: Any], _ attributes: [String: Any]) -> OSStatus {
        updated.append((query, attributes))
        return updateStatus
    }

    public func delete(_ query: [String: Any]) -> OSStatus {
        deleted.append(query)
        return errSecSuccess
    }

    public func copyAttributes(_ query: [String: Any]) -> (items: [[String: Any]], status: OSStatus) {
        (rows, errSecSuccess)
    }
}
