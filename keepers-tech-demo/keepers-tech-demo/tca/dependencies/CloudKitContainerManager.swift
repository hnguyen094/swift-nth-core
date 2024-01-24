//
//  CloudKitContainerManager.swift
//  keepers-tech-demo
//
//  Created by hung on 1/24/24.
//

import Dependencies
import CloudKit

extension DependencyValues {
    var cloudkitManager: CloudKitContainerManager {
        get { self[CloudKitContainerManager.self] }
        set { self[CloudKitContainerManager.self] = newValue }
    }
}

struct CloudKitContainerManager {
    @Dependency(\.logger) var logger
    
    private let publicDatabase: CKDatabase
    
    init() {
        publicDatabase = CKContainer.default().publicCloudDatabase
    }
    
    // TODO: add to queue, and have queue process multiple clicks at once to avoid oplock
    // TODO: merge all records, or find a safe way to concurrently edit records. Potential solution: https://stackoverflow.com/questions/29373056/increment-field-value-in-a-ckrecord-variable-without-fetching
    func voteAsync() async -> Int64? {
        do {
            let id = try await CKContainer.default().userRecordID()
            let reference = CKRecord.Reference(recordID: id, action: .none)
            let predicate = NSPredicate(format: "creatorUserRecordID == %@", reference)
            let query = CKQuery(recordType: "Interest", predicate: predicate)

            let (matchResults, _) = try await publicDatabase.records(matching: query, resultsLimit: 1)
            var record: CKRecord? = .none
            if case .success(let existingRecord) = matchResults.first?.1 {
                let currentValue = existingRecord.value(forKey: "count") as? Int64 ?? 0
                if currentValue == Int64.max {
                    logger.warning("CloudKit vote maxed out at Byte limit (\(currentValue))")
                    return currentValue
                }
                existingRecord.setValue(currentValue + 1, forKey: "count")
                record = existingRecord
            } else {
                record = CKRecord(recordType: "Interest")
                record?.setValue(1, forKey: "count")
            }
            let newRecordCount = (try await publicDatabase.save(record!)).value(forKey: "count") as? Int64
            logger.debug("Successfully saved vote. Current count: \(String(describing: newRecordCount))")
            return newRecordCount
        } catch {
            logger.error("CloudKit failed to vote. \(error)")
            return .none
        }
    }
}

extension CloudKitContainerManager: DependencyKey {
    static let liveValue: CloudKitContainerManager = .init()
}
