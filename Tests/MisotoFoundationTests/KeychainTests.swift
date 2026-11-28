import Foundation
#if canImport(LocalAuthentication)
import LocalAuthentication
#endif
@testable import MisotoFoundation
import MisotoTesting
import Security
import Testing

struct GenericPasswordTests {
    private static func keys(_ dictionary: [String: Any]) -> Set<String> { Set(dictionary.keys) }

    @Test func aPlainQueryNamesOnlyClassServiceAndAccount() {
        let query = GenericPassword(service: "s", account: "a").query
        #expect(Self.keys(query) == [kSecClass as String, kSecAttrService as String, kSecAttrAccount as String])
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
        let keychain = RecordingKeychain()
        let status = GenericPassword(service: "s", account: "a")
            .upsert(Data("v".utf8), accessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly, updatesAccessibility: true, in: keychain)
        #expect(status == errSecSuccess)
        #expect(Self.keys(keychain.updated[0].attributes) == [kSecValueData as String, kSecAttrAccessible as String])
        let insert = keychain.added[0]
        #expect(Self.keys(insert) == [
            kSecClass as String, kSecAttrService as String, kSecAttrAccount as String,
            kSecValueData as String, kSecAttrAccessible as String,
        ])
    }

    @Test func upsertCanKeepAnExistingRowsClass() {
        let keychain = RecordingKeychain()
        keychain.updateStatus = errSecSuccess
        GenericPassword(service: "s", account: "a", synchronizable: true)
            .upsert(Data("v".utf8), accessible: kSecAttrAccessibleAfterFirstUnlock, updatesAccessibility: false, in: keychain)
        #expect(Self.keys(keychain.updated[0].attributes) == [kSecValueData as String])
        #expect(keychain.added.isEmpty)
    }

    @Test func upsertPassesExtraAttributesOnlyToANewRow() {
        let keychain = RecordingKeychain()
        GenericPassword(service: "s", account: "a").upsert(
            Data(), accessible: kSecAttrAccessibleAfterFirstUnlock, updatesAccessibility: true,
            extraOnAdd: [kSecAttrLabel as String: "L"], in: keychain
        )
        #expect(keychain.updated[0].attributes[kSecAttrLabel as String] == nil)
        #expect(keychain.added[0][kSecAttrLabel as String] as? String == "L")
    }

    @Test func replaceDeletesThenAddsWithExplicitAccess() {
        let keychain = RecordingKeychain()
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

    @Test func replaceRollbackPreservesExistingAccessibilityClassAndDisablesAuthUI() {
        let keychain = RecordingKeychain(inMemoryAccounts: true)
        keychain.seed(
            account: "a",
            value: "old-secret",
            accessible: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        )
        keychain.addStatuses = [errSecParam, errSecSuccess]

        let status = GenericPassword(service: "s", account: "a").replace(
            Data("new-secret".utf8),
            access: .accessible(kSecAttrAccessibleWhenUnlockedThisDeviceOnly),
            in: keychain
        )

        #expect(status == errSecParam)
        #expect(keychain.copied.count == 1)
        #if canImport(LocalAuthentication)
        let context = keychain.copied[0][kSecUseAuthenticationContext as String] as? LAContext
        #expect(context?.interactionNotAllowed == true)
        #endif
        #expect(keychain.added.count == 2)
        #expect(keychain.added[1][kSecValueData as String] as? Data == Data("old-secret".utf8))
        #expect(keychain.added[1][kSecAttrAccessible as String] as? String == kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String)
        #expect(keychain.value(of: "a") == "old-secret")
    }

    @Test func replaceNeverDowngradesProtectionWhenExistingProtectionIsUnknown() {
        let keychain = RecordingKeychain()
        keychain.stored = Data("old-secret".utf8)
        keychain.addStatuses = [errSecParam, errSecSuccess]

        let status = GenericPassword(service: "s", account: "a").replace(
            Data("new-secret".utf8),
            access: .accessible(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly),
            in: keychain
        )

        #expect(status == errSecParam)
        #expect(keychain.copied.isEmpty, "Should not even read secret when rollback protection class is unknown")
        #expect(keychain.added.count == 1, "Must not restore without a verified protection class")
    }

    @Test func replaceRollbackUsesExplicitRollbackAccessEvenForBiometryProtectedItems() {
        let keychain = RecordingKeychain()
        keychain.stored = Data("old-secret".utf8)
        keychain.addStatuses = [errSecParam, errSecSuccess]

        let status = GenericPassword(service: "s", account: "a").replace(
            Data("new-secret".utf8),
            access: .accessible(kSecAttrAccessibleWhenUnlockedThisDeviceOnly),
            rollbackAccess: .accessible(kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly),
            in: keychain
        )

        #expect(status == errSecParam)
        #expect(keychain.added.count == 2)
        #expect(keychain.added[1][kSecAttrAccessible as String] as? String == kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly as String)
    }

    @Test func readAsksForOneRowsData() {
        let keychain = RecordingKeychain()
        keychain.stored = Data("hello".utf8)
        let item = GenericPassword(service: "s", account: "a")
        #expect(item.readString(in: keychain) == "hello")
        #expect(keychain.copied[0][kSecReturnData as String] as? Bool == true)
        #expect(keychain.copied[0][kSecMatchLimit as String] as! CFString == kSecMatchLimitOne)
    }

    @Test func aMissingRowReadsNil() {
        #expect(GenericPassword(service: "s", account: "a").readString(in: RecordingKeychain()) == nil)
    }

    @Test func servicesFiltersByPrefix() {
        let keychain = RecordingKeychain()
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
