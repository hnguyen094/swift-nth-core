//
//  LocalContacts.swift
//  flaky-mvp
//
//  Created by hung on 3/12/24.
//

import Dependencies
import DependenciesMacros

import UIKit

@preconcurrency
import Contacts

extension DependencyValues {
    public var localContacts: LocalContacts {
        get { self[LocalContacts.self] }
        set { self[LocalContacts.self] = newValue }
    }
}

@DependencyClient
public struct LocalContacts: Sendable {
    public var requestAuthorization: @Sendable () async throws -> CNAuthorizationStatus
    public var getContacts: @Sendable (_ forceUpdate: Bool) async throws -> [Contact]

    public struct Contact: Identifiable, Hashable, Sendable {
        public var id: UUID
        public var givenName: String
        public var familyName: String
        public var fullName: String?
        public var phoneNumber: String?
        public var thumbnail: UIImage?
    }
}

extension LocalContacts: DependencyKey {
    public static var previewValue: Self {
        let client = Client()
        return .init(
            requestAuthorization: { .authorized },
            getContacts: { force in
                var contacts = await client.cachedContacts ?? mockContacts()
                if force {
                    contacts = mockContacts()
                    await client.manuallyUpdateContacts(contacts)
                }
                return contacts
            }
        )
    }
    public static var liveValue: Self {
        let client = Client()

        return .init(
            requestAuthorization: client.requestAuthorization,
            getContacts: { try await client.getContacts($0) }
        )
    }

    static func mockContacts() -> [Contact] {
        @Dependency(\.uuid) var uuid
        let randomGivenNames = ["Jack", "Jill", "Taylor"]
        let randomFamilyNames = ["Smith", "Anderson", "Swift"]
        var contacts: [Contact] = .init()

        for given in randomGivenNames {
            for family in randomFamilyNames {
                contacts.append(.init(
                    id: uuid().uuidString,
                    givenName: given,
                    familyName: family,
                    fullName: "\(given) \(family)",
                    phoneNumber: randomNumber(),
                    thumbnail: .none))
            }
        }
        return contacts

        func randomNumber() -> String {
            return (0..<10).reduce("") { partialResult, _ in
                partialResult + "\(Int.random(in: 0...9))"
            }
        }
    }
}

fileprivate extension LocalContacts {
    actor Client {
        let store: CNContactStore = .init()
        var cachedContacts: [Contact]? = .none
        let formatter: CNContactFormatter = .init()

        init() {
            formatter.style = .fullName
        }

        func manuallyUpdateContacts(_ contacts: [Contact]) {
            self.cachedContacts = contacts
        }

        func requestAuthorization() async throws -> CNAuthorizationStatus {
            switch CNContactStore.authorizationStatus(for: .contacts) {
            case .notDetermined:
                if try await store.requestAccess(for: .contacts) {
                    return .authorized
                }
                return .denied
            case .authorized:
                return .authorized
            default:
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    Task { @MainActor in
                        UIApplication.shared.open(url)
                    }
                }
                return .denied
            }
        }

        func getContacts(_ forceUpdate: Bool) throws -> [Contact] {
            if !forceUpdate, case .some(let cached) = cachedContacts {
                return cached
            }
            var keys = [CNContactPhoneNumbersKey, CNContactThumbnailImageDataKey] as [CNKeyDescriptor]
            keys.append(CNContactFormatter.descriptorForRequiredKeys(for: .fullName))
            let request = CNContactFetchRequest(keysToFetch: keys)
            request.unifyResults = true
            request.sortOrder = .userDefault

            var contacts = [Contact]()
            try store.enumerateContacts(with: request) { contact, _ in
                let thumbnail: UIImage? = if case .some(let data) = contact.thumbnailImageData {
                    UIImage(data: data)
                } else { .none }

                contacts.append(.init(
                    id: contact.identifier,
                    givenName: contact.givenName,
                    familyName: contact.familyName,
                    fullName: formatter.string(from: contact),
                    phoneNumber: contact.phoneNumbers.first?.value.stringValue,
                    thumbnail: thumbnail))
            }
            cachedContacts = contacts
            return contacts
        }
    }
}
