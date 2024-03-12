//
//  CloudKitService.swift
//  keepers-tech-demo
//
//  Created by hung on 1/24/24.
//

import Dependencies
import DependenciesMacros
import CloudKit

extension DependencyValues {
    public var cloudkitService: CloudKitService {
        get { self[CloudKitService.self] }
        set { self[CloudKitService.self] = newValue }
    }
}

@DependencyClient
public struct CloudKitService {
    public var createRecord: @Sendable () async throws -> Void
    public var findRecord: @Sendable (_ of: Key) async throws -> CKRecord?
    public var deleteRecord: @Sendable (_ of: Key) async throws -> Void
    public var readField: @Sendable (Key) async throws -> Any?
    public var writeField: @Sendable (Key, _ value: Any?) async throws -> Void

    public struct Key {
        public let scope: CKDatabase.Scope
        public let isOwner: Bool = false
        public let recordType: CKRecord.RecordType
        public let key: CKRecord.FieldKey
    }
}

extension CloudKitService: DependencyKey {
    public static let testValue: Self = .init()
    public static let previewValue: Self = .init()
    public static var liveValue: Self {
        .init()
    }

    private static func record(of key: Key) async throws -> CKRecord? {
        var predicate: NSPredicate = .init(value: true)
        if key.isOwner {
            let id = try await CKContainer.default().userRecordID()
            let reference = CKRecord.Reference(recordID: id, action: .none)
            predicate = NSPredicate(format: "creatorUserRecordID == %@", reference)
        }
        let query = CKQuery(recordType: key.recordType, predicate: predicate)
        let database = CKContainer.default().database(with: key.scope)

        let (matchResults, _) = try await database.records(matching: query, resultsLimit: 1)
        switch matchResults.first?.1 {
        case .success(let existingRecord): return existingRecord
        case .failure(let error): throw error
        case .none: return .none
        }
    }

    private static func read(_ key: Key) async throws -> Any? {
        let record = try await record(of: key)
        return record?.value(forKey: key.key)
    }

    private static func write(_ key: Key, value: Any?) async throws {
        let record = try await record(of: key) ?? CKRecord(recordType: key.recordType)
        record.setValue(value, forKey: key.key)

        let database = CKContainer.default().database(with: key.scope)
        try await database.save(record)
    }

    private static func createRecord(_ key: Key) async throws {
        let record = CKRecord(recordType: key.recordType)
    }

    private static func deleteRecord(of key: Key) async throws {
        if let record = try await record(of: key) {
            let database = CKContainer.default().database(with: key.scope)
            try await database.deleteRecord(withID: record.recordID)
        }
    }

    public enum Error: Swift.Error {
        case typeMismatch
    }
}
