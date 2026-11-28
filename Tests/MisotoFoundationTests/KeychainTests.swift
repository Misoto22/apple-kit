import Foundation
@testable import MisotoFoundation
import MisotoTesting
import Security
import Testing

/// Records every dictionary, as kioku-ios's RecordingKeychain does.
final class LocalRecordingKeychain: KeychainItems {
    var added: [[String: Any]] = []
    var updated: [(query: [String: Any], attributes: [String: Any])] = []
    var deleted: [[String: Any]] = []
    var copied: [[String: Any]] = []
    var updateStatus: OSStatus = errSecItemNotFound
    var addStatuses: [OSStatus] = []
    var stored: Data?
    var rows: [[String: Any]] = []

    func add(_ attributes: [String: Any]) -> OSStatus {
        added.append(attributes)
        if !addStatuses.isEmpty { return addStatuses.removeFirst() }
        return errSecSuccess
    }

    func copy(_ query: [String: Any]) -> (data: Data?, status: OSStatus) {
        copied.append(query)
        return stored.map { ($0, errSecSuccess) } ?? (nil, errSecItemNotFound)
    }

    func update(_ query: [String: Any], _ attributes: [String: Any]) -> OSStatus {
        updated.append((query, attributes))
        return updateStatus
    }

    func delete(_ query: [String: Any]) -> OSStatus {
        deleted.append(query)
        return errSecSuccess
    }

    func copyAttributes(_ query: [String: Any]) -> (items: [[String: Any]], status: OSStatus) {
        (rows, errSecSuccess)
    }
}

private func keys(_ dictionary: [String: Any]) -> Set<String> { Set(dictionary.keys) }

struct GenericPasswordTests {
    @Test func aPlainQueryNamesOnlyClassServiceAndAccount() {
        let query = GenericPassword(service: "s", account: "a").query
        #expect(keys(query) == [kSecClass as String, kSecAttrService as String, kSecAttrAccount as String])
    }

    @Test func aServiceOnlyRowHasNoAccount() {
        #expect(GenericPassword(service: "s").query[kSecAttrAccount as String] == nil)
    }

    @Test func setOptionsAppearInTheQuery() {
        let query = GenericPassword(
            service: "s", account: "a", accessGroup: "G.group", synchronizable: true, usesDataProtectionKeychain: true
        ).query
        #expect(query[kSecAttrAccessGroup as String] as? String == "G.group")
        #expect((query[kSecAttrSynchronizable as String] as! CFBoolean) == kCFBooleanTrue)
        #expect(query[kSecUseDataProtectionKeychain as String] as? Bool == true)
    }

    @Test func upsertAddsWithTheClassWhenThereIsNoRow() {
        let keychain = LocalRecordingKeychain()
        let status = GenericPassword(service: "s", account: "a")
            .upsert(Data("v".utf8), accessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly, updatesAccessibility: true, in: keychain)
        #expect(status == errSecSuccess)
        #expect(keys(keychain.updated[0].attributes) == [kSecValueData as String, kSecAttrAccessible as String])
        let insert = keychain.added[0]
        #expect(keys(insert) == [
            kSecClass as String, kSecAttrService as String, kSecAttrAccount as String,
            kSecValueData as String, kSecAttrAccessible as String,
        ])
    }

    @Test func upsertCanKeepAnExistingRowsClass() {
        let keychain = LocalRecordingKeychain()
        keychain.updateStatus = errSecSuccess
        GenericPassword(service: "s", account: "a", synchronizable: true)
            .upsert(Data("v".utf8), accessible: kSecAttrAccessibleAfterFirstUnlock, updatesAccessibility: false, in: keychain)
        #expect(keys(keychain.updated[0].attributes) == [kSecValueData as String])
        #expect(keychain.added.isEmpty)
    }

    @Test func upsertPassesExtraAttributesOnlyToANewRow() {
        let keychain = LocalRecordingKeychain()
        GenericPassword(service: "s", account: "a").upsert(
            Data(), accessible: kSecAttrAccessibleAfterFirstUnlock, updatesAccessibility: true,
            extraOnAdd: [kSecAttrLabel as String: "L"], in: keychain
        )
        #expect(keychain.updated[0].attributes[kSecAttrLabel as String] == nil)
        #expect(keychain.added[0][kSecAttrLabel as String] as? String == "L")
    }

    @Test func replaceDeletesThenAddsWithExplicitAccess() {
        let keychain = LocalRecordingKeychain()
        let status = GenericPassword(service: "s").replace(
            Data("v".utf8),
            access: .accessible(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly),
            in: keychain
        )
        #expect(status == errSecSuccess)
        #expect(keychain.deleted.count == 1)
        #expect(keychain.added.count == 1)
        #expect(keychain.added[0][kSecAttrAccessible as String] as! CFString == kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
    }

    @Test func replaceRestoresPreviousDataWhenAddFails() {
        let keychain = LocalRecordingKeychain()
        keychain.stored = Data("old-secret".utf8)
        keychain.addStatuses = [errSecParam, errSecSuccess]
        let status = GenericPassword(service: "s").replace(
            Data("new-secret".utf8),
            access: .accessible(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly),
            in: keychain
        )
        #expect(status == errSecParam)
        #expect(keychain.added.count == 2)
        #expect(keychain.added[1][kSecValueData as String] as? Data == Data("old-secret".utf8))
    }

    @Test func readAsksForOneRowsData() {
        let keychain = LocalRecordingKeychain()
        keychain.stored = Data("hello".utf8)
        let item = GenericPassword(service: "s", account: "a")
        #expect(item.readString(in: keychain) == "hello")
        #expect(keychain.copied[0][kSecReturnData as String] as? Bool == true)
        #expect(keychain.copied[0][kSecMatchLimit as String] as! CFString == kSecMatchLimitOne)
    }

    @Test func aMissingRowReadsNil() {
        #expect(GenericPassword(service: "s", account: "a").readString(in: LocalRecordingKeychain()) == nil)
    }

    @Test func servicesFiltersByPrefix() {
        let keychain = LocalRecordingKeychain()
        keychain.rows = [
            [kSecAttrService as String: "app.leaving.1"], [kSecAttrService as String: "app.session"],
            [kSecAttrService as String: "app.leaving.2"], [:],
        ]
        #expect(GenericPassword.services(withPrefix: "app.leaving.", in: keychain) == ["app.leaving.1", "app.leaving.2"])
    }

    @Test func notFoundCountsAsNothingLeft() {
        #expect(KeychainStatus.isSuccessOrNotFound(errSecItemNotFound))
        #expect(!KeychainStatus.isSuccessOrNotFound(errSecInteractionNotAllowed))
    }

    @Test func recordingKeychainSupportsPerAccountStorageAndForcedStatuses() {
        let keychain = RecordingKeychain(inMemoryAccounts: true)
        keychain.seed(account: "alpha", value: "v1")
        #expect(keychain.value(of: "alpha") == "v1")

        let item = GenericPassword(service: "s", account: "alpha")
        #expect(item.readString(in: keychain) == "v1")
        #expect(item.upsert(Data("v2".utf8), accessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly, updatesAccessibility: true, in: keychain) == errSecSuccess)
        #expect(keychain.value(of: "alpha") == "v2")
        #expect(keychain.accessibility(of: "alpha") == kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String)

        keychain.forcedUpdateStatus = errSecInteractionNotAllowed
        #expect(keychain.update([kSecAttrAccount as String: "alpha"], [:]) == errSecInteractionNotAllowed)
        keychain.forcedUpdateStatus = nil

        let beta = GenericPassword(service: "s", account: "beta")
        #expect(beta.upsert(Data("b1".utf8), accessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly, updatesAccessibility: true, in: keychain) == errSecSuccess)
        #expect(keychain.value(of: "beta") == "b1")
        #expect(keychain.delete([kSecAttrAccount as String: "beta"]) == errSecSuccess)
        #expect(keychain.value(of: "beta") == nil)
    }
}
