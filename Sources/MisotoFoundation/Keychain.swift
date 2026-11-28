import Foundation
#if canImport(LocalAuthentication)
import LocalAuthentication
#endif
import Security

/// The Keychain calls a stored credential needs, as a seam. An unsigned test host has no Keychain entitlement, so a test
/// hands in a fake that records every dictionary and asserts the attributes on it instead of reading the real Keychain.
///
/// Not `Sendable`: a recording fake is a class with state. ``SystemKeychain`` itself is.
public protocol KeychainItems {
    /// `SecItemAdd` with `attributes`.
    func add(_ attributes: [String: Any]) -> OSStatus
    /// `SecItemCopyMatching` with `query`, returning the item's data.
    func copy(_ query: [String: Any]) -> (data: Data?, status: OSStatus)
    /// `SecItemUpdate`: `attributes` onto every row `query` matches.
    func update(_ query: [String: Any], _ attributes: [String: Any]) -> OSStatus
    /// `SecItemDelete` with `query`.
    func delete(_ query: [String: Any]) -> OSStatus
    /// `SecItemCopyMatching` with `kSecMatchLimitAll` and `kSecReturnAttributes`: every matching row's attributes.
    func copyAttributes(_ query: [String: Any]) -> (items: [[String: Any]], status: OSStatus)
}

extension KeychainItems {
    /// A fake that never enumerates reports nothing found.
    public func copyAttributes(_ query: [String: Any]) -> (items: [[String: Any]], status: OSStatus) {
        ([], errSecItemNotFound)
    }
}

/// The device's own Keychain.
public struct SystemKeychain: KeychainItems, Sendable {
    public init() {}

    public func add(_ attributes: [String: Any]) -> OSStatus {
        SecItemAdd(attributes as CFDictionary, nil)
    }

    public func copy(_ query: [String: Any]) -> (data: Data?, status: OSStatus) {
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        return (item as? Data, status)
    }

    public func update(_ query: [String: Any], _ attributes: [String: Any]) -> OSStatus {
        SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
    }

    public func delete(_ query: [String: Any]) -> OSStatus {
        SecItemDelete(query as CFDictionary)
    }

    public func copyAttributes(_ query: [String: Any]) -> (items: [[String: Any]], status: OSStatus) {
        var lookup = query
        lookup[kSecMatchLimit as String] = kSecMatchLimitAll
        lookup[kSecReturnAttributes as String] = true
        var result: CFTypeRef?
        let status = SecItemCopyMatching(lookup as CFDictionary, &result)
        return ((result as? [[String: Any]]) ?? [], status)
    }
}

/// One generic-password row's identity, and the four ways the apps write it.
///
/// It decides nothing an app decides: there is no default accessibility class (the system's own, `WhenUnlocked`, rides an
/// encrypted backup onto another phone), no default access group (a new row then lands in the app's own group), and no
/// synchronizable flag unless the app sets one. An attribute left nil is absent from the query, so a row written before
/// an app adopted this is the same row.
public struct GenericPassword: Sendable, Hashable {
    /// Access policy for a replaced Keychain row: either an explicit `kSecAttrAccessible` class or a `SecAccessControl`.
    public enum Access: @unchecked Sendable {
        case accessible(CFString)
        case accessControl(SecAccessControl)
    }

    public var service: String
    /// Nil for a row identified by its service alone (revala-ios's sessions).
    public var account: String?
    public var accessGroup: String?
    /// Nil leaves `kSecAttrSynchronizable` out of the query.
    public var synchronizable: Bool?
    /// macOS: the data-protection Keychain instead of the file-based login Keychain.
    public var usesDataProtectionKeychain: Bool

    public init(
        service: String,
        account: String? = nil,
        accessGroup: String? = nil,
        synchronizable: Bool? = nil,
        usesDataProtectionKeychain: Bool = false
    ) {
        self.service = service
        self.account = account
        self.accessGroup = accessGroup
        self.synchronizable = synchronizable
        self.usesDataProtectionKeychain = usesDataProtectionKeychain
    }

    /// The row's identity, for `SecItemCopyMatching`, `SecItemUpdate` and `SecItemDelete`.
    public var query: [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
        ]
        if let account { query[kSecAttrAccount as String] = account }
        if let accessGroup { query[kSecAttrAccessGroup as String] = accessGroup }
        if let synchronizable { query[kSecAttrSynchronizable as String] = synchronizable ? kCFBooleanTrue : kCFBooleanFalse }
        if usesDataProtectionKeychain { query[kSecUseDataProtectionKeychain as String] = true }
        return query
    }

    /// The row's value. `extra` adds lookup keys such as `kSecUseAuthenticationContext`.
    public func read(in keychain: some KeychainItems = SystemKeychain(), extra: [String: Any] = [:]) -> (data: Data?, status: OSStatus) {
        var lookup = query.merging(extra) { $1 }
        lookup[kSecReturnData as String] = true
        lookup[kSecMatchLimit as String] = kSecMatchLimitOne
        let (data, status) = keychain.copy(lookup)
        return (status == errSecSuccess ? data : nil, status)
    }

    /// The row's value as UTF-8 text, or nil when there is no row or it is not text.
    public func readString(in keychain: some KeychainItems = SystemKeychain()) -> String? {
        read(in: keychain).data.flatMap { String(data: $0, encoding: .utf8) }
    }

    /// Writes the value in place, keeping the row and anything else on it; adds the row when there is none.
    ///
    /// - Parameters:
    ///   - accessible: a `kSecAttrAccessible…` class for a new row. No default, on purpose.
    ///   - updatesAccessibility: whether an existing row moves to `accessible` too (kioku-ios, jade) or keeps its class
    ///     (kura-ios's master key).
    ///   - extraOnAdd: attributes only a new row gets, such as `kSecAttrAccessControl`.
    @discardableResult
    public func upsert(
        _ data: Data,
        accessible: CFString,
        updatesAccessibility: Bool,
        extraOnAdd: [String: Any] = [:],
        in keychain: some KeychainItems = SystemKeychain()
    ) -> OSStatus {
        var attributes: [String: Any] = [kSecValueData as String: data]
        if updatesAccessibility { attributes[kSecAttrAccessible as String] = accessible }
        let status = keychain.update(query, attributes)
        guard status == errSecItemNotFound else { return status }
        var insert = query.merging(extraOnAdd) { $1 }
        insert[kSecValueData as String] = data
        insert[kSecAttrAccessible as String] = accessible
        return keychain.add(insert)
    }

    /// Deletes the row and adds it again whole: for a row whose access control must be set afresh, which `SecItemUpdate`
    /// cannot change.
    ///
    /// Rollback never degrades the row's protection class: before deleting, this inspects `rollbackAccess` or the
    /// existing item's `kSecAttrAccessible` attribute without prompting user authentication, and only reads/restores the
    /// previous data (non-interactively via `LAContext.interactionNotAllowed = true`) when an explicit protection level
    /// is known.
    @discardableResult
    public func replace(
        _ data: Data,
        access: Access,
        rollbackAccess: Access? = nil,
        in keychain: some KeychainItems = SystemKeychain()
    ) -> OSStatus {
        let verifiedRollbackAccess = rollbackAccess ?? existingAccessible(in: keychain)
        var previousData: Data?
        if verifiedRollbackAccess != nil {
            var authExtra: [String: Any] = [:]
            #if canImport(LocalAuthentication)
            let context = LAContext()
            context.interactionNotAllowed = true
            authExtra[kSecUseAuthenticationContext as String] = context
            #endif
            let previous = read(in: keychain, extra: authExtra)
            if previous.status == errSecSuccess {
                previousData = previous.data
            }
        }

        let deleteStatus = keychain.delete(query)
        guard KeychainStatus.isSuccessOrNotFound(deleteStatus) else { return deleteStatus }

        var insert = query
        insert[kSecValueData as String] = data
        Self.apply(access, to: &insert)

        let addStatus = keychain.add(insert)
        if addStatus != errSecSuccess, let previousData, let verifiedRollbackAccess {
            var restore = query
            restore[kSecValueData as String] = previousData
            Self.apply(verifiedRollbackAccess, to: &restore)
            _ = keychain.add(restore)
        }
        return addStatus
    }

    /// Deletes the row. The status is returned as the Keychain gave it; ``KeychainStatus/isSuccessOrNotFound(_:)`` reads
    /// "nothing left" either way.
    @discardableResult
    public func delete(in keychain: some KeychainItems = SystemKeychain()) -> OSStatus {
        keychain.delete(query)
    }

    /// The services of every generic-password row this process can see whose service starts with `prefix`.
    public static func services(
        withPrefix prefix: String,
        in keychain: some KeychainItems = SystemKeychain()
    ) -> [String] {
        let (items, status) = keychain.copyAttributes([kSecClass as String: kSecClassGenericPassword])
        guard status == errSecSuccess else { return [] }
        return items.compactMap { $0[kSecAttrService as String] as? String }.filter { $0.hasPrefix(prefix) }
    }

    private func existingAccessible(in keychain: some KeychainItems) -> Access? {
        let (items, status) = keychain.copyAttributes(query)
        guard status == errSecSuccess,
              let accessible = items.first?[kSecAttrAccessible as String] as? String,
              !accessible.isEmpty
        else {
            return nil
        }
        return .accessible(accessible as CFString)
    }

    private static func apply(_ access: Access, to attributes: inout [String: Any]) {
        switch access {
        case .accessible(let accessible):
            attributes[kSecAttrAccessible as String] = accessible
        case .accessControl(let accessControl):
            attributes[kSecAttrAccessControl as String] = accessControl
        }
    }
}

public enum KeychainStatus {
    /// A delete that found nothing has nothing left to delete.
    public static func isSuccessOrNotFound(_ status: OSStatus) -> Bool {
        status == errSecSuccess || status == errSecItemNotFound
    }
}
