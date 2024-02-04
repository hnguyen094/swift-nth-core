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
    public var vote: (_ recordType: CKRecord.RecordType, _ key: String) async throws -> Int64
}

extension CloudKitService: DependencyKey {
    public static let testValue: Self = .init()
    public static let previewValue: Self = .init()
    public static var liveValue: Self {
        let publicDatabase = CKContainer.default().publicCloudDatabase
        return .init(
            // TODO: add to queue, and have queue process multiple clicks at once to avoid oplock
            // TODO: merge all records, or find a safe way to concurrently edit records. Potential solution: https://stackoverflow.com/questions/29373056/increment-field-value-in-a-ckrecord-variable-without-fetching
            vote: { recordType, key in
                let id = try await CKContainer.default().userRecordID()
                let reference = CKRecord.Reference(recordID: id, action: .none)
                let predicate = NSPredicate(format: "creatorUserRecordID == %@", reference)
                let query = CKQuery(recordType: recordType, predicate: predicate)

                let (matchResults, _) = try await publicDatabase.records(matching: query, resultsLimit: 1)
                var record: CKRecord? = .none
                if case .success(let existingRecord) = matchResults.first?.1 {
                    let currentValue = existingRecord.value(forKey: key) as? Int64 ?? 0
                    if currentValue == Int64.max {
                        throw Error.voteMaxedOut
                    }
                    existingRecord.setValue(currentValue + 1, forKey: key)
                    record = existingRecord
                } else {
                    record = CKRecord(recordType: recordType)
                    record?.setValue(1, forKey: key)
                }
                let newRecordCount = (try await publicDatabase.save(record!)).value(forKey: key) as? Int64 ?? 0
                return newRecordCount
            }
        )
    }
    
    public enum Error: Swift.Error {
        case voteMaxedOut
    }
}
