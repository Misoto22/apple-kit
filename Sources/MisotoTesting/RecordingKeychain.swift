import Foundation
import MisotoFoundation
import Security

/// Recording Keychain double for tests across Misoto apps (unsigned test hosts lack Keychain entitlements).
///
/// By default (`inMemoryAccounts: false`) it acts as a simple single-slot recorder controlled via `stored`,
/// `updateStatus`, and `addStatuses`. Pass `inMemoryAccounts: true` for a stateful per-account in-memory store
/// tracking `rowAttributes`, duplicate-add errors, and per-operation `forced*Status` overrides.
public final class RecordingKeychain: KeychainItems {
    public let inMemoryAccounts: Bool

    public var added: [[String: Any]] = []
    public var updated: [(query: [String: Any], attributes: [String: Any])] = []
    public var deleted: [[String: Any]] = []
    public var copied: [[String: Any]] = []
    public var updateStatus: OSStatus = errSecItemNotFound
    public var addStatuses: [OSStatus] = []
    public var stored: Data?
    public var rows: [[String: Any]] = []

    public private(set) var accountRows: [String: Data] = [:]
    public private(set) var rowAttributes: [String: [String: Any]] = [:]
    public var forcedCopyStatus: OSStatus?
    public var forcedAddStatus: OSStatus?
    public var forcedUpdateStatus: OSStatus?

    public init(inMemoryAccounts: Bool = false) {
        self.inMemoryAccounts = inMemoryAccounts
    }

    public func seed(account: String, value: String, accessible: CFString? = nil) {
        accountRows[account] = Data(value.utf8)
        var attrs: [String: Any] = [kSecAttrAccount as String: account]
        if let accessible {
            attrs[kSecAttrAccessible as String] = accessible as String
        }
        rowAttributes[account] = attrs
    }

    public func value(of account: String) -> String? {
        accountRows[account].flatMap { String(data: $0, encoding: .utf8) }
    }

    public func accessibility(of account: String) -> String? {
        rowAttributes[account]?[kSecAttrAccessible as String] as? String
    }

    public func add(_ attributes: [String: Any]) -> OSStatus {
        added.append(attributes)
        if let forcedAddStatus { return forcedAddStatus }
        let scriptedStatus = addStatuses.isEmpty ? nil : addStatuses.removeFirst()
        if let scriptedStatus, scriptedStatus != errSecSuccess {
            return scriptedStatus
        }
        if inMemoryAccounts {
            let account = attributes[kSecAttrAccount as String] as? String ?? ""
            guard accountRows[account] == nil else { return errSecDuplicateItem }
            accountRows[account] = attributes[kSecValueData as String] as? Data
            rowAttributes[account] = attributes
        }
        return scriptedStatus ?? errSecSuccess
    }

    public func copy(_ query: [String: Any]) -> (data: Data?, status: OSStatus) {
        copied.append(query)
        if let forcedCopyStatus { return (nil, forcedCopyStatus) }
        if inMemoryAccounts {
            let account = query[kSecAttrAccount as String] as? String ?? ""
            guard let data = accountRows[account] else { return (nil, errSecItemNotFound) }
            return (data, errSecSuccess)
        }
        return stored.map { ($0, errSecSuccess) } ?? (nil, errSecItemNotFound)
    }

    public func update(_ query: [String: Any], _ attributes: [String: Any]) -> OSStatus {
        updated.append((query, attributes))
        if let forcedUpdateStatus { return forcedUpdateStatus }
        if inMemoryAccounts {
            let account = query[kSecAttrAccount as String] as? String ?? ""
            guard accountRows[account] != nil else { return errSecItemNotFound }
            if let data = attributes[kSecValueData as String] as? Data {
                accountRows[account] = data
            }
            rowAttributes[account, default: [:]].merge(attributes) { _, new in new }
            return errSecSuccess
        }
        return updateStatus
    }

    public func delete(_ query: [String: Any]) -> OSStatus {
        deleted.append(query)
        if inMemoryAccounts {
            let account = query[kSecAttrAccount as String] as? String ?? ""
            rowAttributes.removeValue(forKey: account)
            return accountRows.removeValue(forKey: account) == nil ? errSecItemNotFound : errSecSuccess
        }
        return errSecSuccess
    }

    public func copyAttributes(_ query: [String: Any]) -> (items: [[String: Any]], status: OSStatus) {
        if inMemoryAccounts && rows.isEmpty {
            let targetAccount = query[kSecAttrAccount as String] as? String
            let targetService = query[kSecAttrService as String] as? String
            let matched = rowAttributes.compactMap { account, attrs -> [String: Any]? in
                if let targetAccount, account != targetAccount { return nil }
                if let targetService,
                   let storedService = attrs[kSecAttrService as String] as? String,
                   storedService != targetService
                {
                    return nil
                }
                return attrs
            }
            return matched.isEmpty ? ([], errSecItemNotFound) : (matched, errSecSuccess)
        }
        return (rows, errSecSuccess)
    }
}
