//
//  Keychain.swift
//  flaky-mvp
//
//  Created by hung on 2/19/24.
//

import Dependencies
import DependenciesMacros

import AuthenticationServices

extension DependencyValues {
    public var keychain: KeychainClient {
        get { self[KeychainClient.self] }
        set { self[KeychainClient.self] = newValue }
    }
}

@DependencyClient
public struct KeychainClient {
    public var initialize: (Query) -> Void
    public var readItem: () throws -> String
    public var saveItem: (_ password: String) throws -> Void
    public var deleteItem: () throws -> Void

    public struct Query {
        public let service: String
        public let account: String
        public let accessGroup: String?

        public init(service: String, account: String, accessGroup: String?) {
            self.service = service
            self.account = account
            self.accessGroup = accessGroup
        }
    }

    public enum KeychainError: Error {
        case noPassword
        case unexpectedPasswordData
        case unexpectedItemData
        case unhandledError
        case calledBeforeInitialize
    }
}

extension KeychainClient: DependencyKey {
    public static var testValue: Self = .init()
    public static var previewValue: Self = .init()
    public static var liveValue: Self {
        var maybeQuery: Query? = .none

        func readItem() throws -> String {
            guard let q = maybeQuery else {
                throw KeychainError.calledBeforeInitialize
            }
            let service = q.service,
                account = q.account,
                accessGroup = q.accessGroup
            /*
             Build a query to find the item that matches the service, account and
             access group.
             */
            var query = keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            query[kSecMatchLimit as String] = kSecMatchLimitOne
            query[kSecReturnAttributes as String] = kCFBooleanTrue
            query[kSecReturnData as String] = kCFBooleanTrue

            // Try to fetch the existing keychain item that matches the query.
            var queryResult: AnyObject?
            let status = withUnsafeMutablePointer(to: &queryResult) {
                SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
            }

            // Check the return status and throw an error if appropriate.
            guard status != errSecItemNotFound else { throw KeychainError.noPassword }
            guard status == noErr else { throw KeychainError.unhandledError }

            // Parse the password string from the query result.
            guard let existingItem = queryResult as? [String: AnyObject],
                let passwordData = existingItem[kSecValueData as String] as? Data,
                let password = String(data: passwordData, encoding: String.Encoding.utf8)
                else {
                    throw KeychainError.unexpectedPasswordData
            }

            return password
        }

        func saveItem(_ password: String) throws {
            guard let q = maybeQuery else {
                throw KeychainError.calledBeforeInitialize
            }
            let service = q.service,
                account = q.account,
                accessGroup = q.accessGroup

            // Encode the password into an Data object.
            let encodedPassword = password.data(using: String.Encoding.utf8)!

            do {
                // Check for an existing item in the keychain.
                try _ = readItem()

                // Update the existing item with the new password.
                var attributesToUpdate = [String: AnyObject]()
                attributesToUpdate[kSecValueData as String] = encodedPassword as AnyObject?

                let query = keychainQuery(withService: service, account: account, accessGroup: accessGroup)
                let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)

                // Throw an error if an unexpected status was returned.
                guard status == noErr else { throw KeychainError.unhandledError }
            } catch KeychainError.noPassword {
                /*
                 No password was found in the keychain. Create a dictionary to save
                 as a new keychain item.
                 */
                var newItem = keychainQuery(withService: service, account: account, accessGroup: accessGroup)
                newItem[kSecValueData as String] = encodedPassword as AnyObject?

                // Add a the new item to the keychain.
                let status = SecItemAdd(newItem as CFDictionary, nil)

                // Throw an error if an unexpected status was returned.
                guard status == noErr else { throw KeychainError.unhandledError }
            }
        }

        func deleteItem() throws {
            guard let q = maybeQuery else {
                throw KeychainError.calledBeforeInitialize
            }
            let service = q.service,
                account = q.account,
                accessGroup = q.accessGroup

            // Delete the existing item from the keychain.
            let query = keychainQuery(withService: service, account: account, accessGroup: accessGroup)
            let status = SecItemDelete(query as CFDictionary)

            // Throw an error if an unexpected status was returned.
            guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError }
        }

        return .init(
            initialize: { maybeQuery = $0 },
            readItem: readItem,
            saveItem: saveItem(_:),
            deleteItem: deleteItem)
    }

    private static func keychainQuery(withService service: String, account: String? = nil, accessGroup: String? = nil) -> [String: AnyObject] {
        var query = [String: AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service as AnyObject?

        if let account = account {
            query[kSecAttrAccount as String] = account as AnyObject?
        }

        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }

        return query
    }
}
