//
//  LocalContacts.swift
//  flaky-mvp
//
//  Created by hung on 3/12/24.
//

import Dependencies
import DependenciesMacros

import Contacts
import UIKit

extension DependencyValues {
    public var localContacts: LocalContacts {
        get { self[LocalContacts.self] }
        set { self[LocalContacts.self] = newValue }
    }
}

@DependencyClient
@MainActor
public struct LocalContacts {
    public var requestAuthorization: () async throws -> CNAuthorizationStatus
    public var getContacts: (_ forceUpdate: Bool) throws -> [Contact]

    public struct Contact: Identifiable, Hashable {
        public var id: UUID
        public var givenName: String
        public var familyName: String
        public var fullName: String?
        public var phoneNumber: String?
        public var thumbnail: UIImage?
    }
}

extension LocalContacts: DependencyKey {
    public static let testValue: Self = .init()
    public static var previewValue: Self {
        var contacts = mockContacts()
        return .init(
            requestAuthorization: { .authorized },
            getContacts: { force in
                if force {
                    contacts = mockContacts()
                    return contacts
                }
                return contacts
            }
        )
    }
    public static var liveValue: Self {
        let store: CNContactStore = .init()
        var cachedContacts: [Contact]? = .none
        let formatter: CNContactFormatter = .init()
        formatter.style = .fullName

        return .init(
            requestAuthorization: {
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
                        await UIApplication.shared.open(url)
                    }
                    return .denied
                }
            },
            getContacts: { forceUpdate in
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
                        id: contact.id,
                        givenName: contact.givenName,
                        familyName: contact.familyName,
                        fullName: formatter.string(from: contact),
                        phoneNumber: contact.phoneNumbers.first?.value.stringValue,
                        thumbnail: thumbnail))
                }
                cachedContacts = contacts
                return contacts
            }
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
                    id: uuid(),
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
