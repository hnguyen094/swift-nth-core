//
//  CloudKitDatabase.swift
//  flaky-mvp
//
//  Created by hung on 3/12/24.
//

import Dependencies
import DependenciesMacros
import CloudKit

extension DependencyValues {
    public var cloudkitDatabase: CloudKitDatabase {
        get { self[CloudKitDatabase.self] }
        set { self[CloudKitDatabase.self] = newValue }
    }
}

@DependencyClient
public struct CloudKitDatabase: Sendable {
    public var accountStatus: @Sendable () async throws -> CKAccountStatus
    public var accountStatusUpdates: @Sendable () async throws -> any AsyncSequence<CKAccountStatus, Swift.Error>
    public var userRecord: @Sendable () async throws -> CKRecord
    public var modifyRecords: @Sendable (
        _ scope: CKDatabase.Scope,
        _ saving: [CKRecord],
        _ deleting: [CKRecord.ID],
        _ atomically: Bool) async throws -> Void
    public var getRecords: @Sendable (
        _ scope: CKDatabase.Scope,
        _ query: CKQuery,
        _ zones: [CKRecordZone]) async throws -> [CKRecord]
}

extension CloudKitDatabase: DependencyKey {
    public static var liveValue: Self {
        let client = Client()
        return .init(
            accountStatus: client.accountStatus,
            accountStatusUpdates: {
                NotificationCenter.default.notifications(named: .CKAccountChanged)
                    .compactMap { _ in try await client.accountStatus() }
            },
            userRecord: client.userRecord,
            modifyRecords: client.modifyRecords(scope:saving:deleting:atomically:),
            getRecords: client.getRecords(scope:query:in:)
        )
    }
}

extension CloudKitDatabase {
    actor Client {
        let container = CKContainer.default()

        private var userRecord: CKRecord? = .none

        func accountStatus() async throws -> CKAccountStatus {
            try await container.accountStatus()
        }

        func userRecord() async throws -> CKRecord {
            guard let record = userRecord else {
                let database = container.database(with: .public)
                let userRecordID = try await container.userRecordID()
                userRecord = try await database.record(for: userRecordID)
                return userRecord!
            }
            return record
        }

        func modifyRecords(
            scope: CKDatabase.Scope,
            saving: [CKRecord],
            deleting: [CKRecord.ID],
            atomically: Bool)
        async throws {
            let database = container.database(with: scope)
            let results = try await database.modifyRecords(
                saving: saving,
                deleting: deleting,
                atomically: atomically)
            for result in results.saveResults {
                switch result.value {
                case .success: continue
                case .failure(let error): throw error
                }
            }
            for result in results.deleteResults {
                switch result.value {
                case .success: continue
                case .failure(let error): throw error
                }
            }       
        }

        func getRecords(
            scope: CKDatabase.Scope,
            query: CKQuery,
            in zones: [CKRecordZone])
        async throws -> [CKRecord] {
            let database = container.database(with: scope)
            var allRecords: [CKRecord] = []
            try await withThrowingTaskGroup(of: [CKRecord].self) { group in
                for zone in zones {
                    group.addTask {
                        try await getFromZone(zone)
                    }
                }

                for try await records in group {
                    allRecords.append(contentsOf: records)
                }
            }
            return allRecords

            @Sendable func getFromZone(_ zone: CKRecordZone) async throws -> [CKRecord] {
                var records: [CKRecord] = []
                var (matchResults, maybeCursor) = try await database.records(matching: query, inZoneWith: zone.zoneID)
                records.append(contentsOf: try await handleResults(matchResults))
                while case .some(let cursor) = maybeCursor {
                    (matchResults, maybeCursor) = try await database.records(continuingMatchFrom: cursor)
                    records.append(contentsOf: try await handleResults(matchResults))
                }
                return records
            }

            @Sendable func handleResults(_ results: [(CKRecord.ID, Result<CKRecord, Swift.Error>)]) 
            async throws -> [CKRecord] {
                return try results.compactMap { (id, result) in
                    switch result {
                    case .success(let record): return record
                    case .failure(let error): throw error
                    }
                }
            }
        }
    }
}
