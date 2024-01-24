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
    private var selfID: CKRecord.ID? = .none
    
    init() {
        publicDatabase = CKContainer.default().publicCloudDatabase
    }
    
    func vote() {
        CKContainer.default().fetchUserRecordID { id, error in
            guard let id = id else { return }
            let reference = CKRecord.Reference(recordID: id, action: .none)
            let predicate = NSPredicate(format: "creatorUserRecordID == %@", reference)
            let query = CKQuery(recordType: "Interest", predicate: predicate)
            
            // Result<(matchResults: [(CKRecord.ID, Result<CKRecord, Error>)], queryCursor: CKQueryOperation.Cursor?), Error>
            publicDatabase.fetch(withQuery: query, resultsLimit: 1) { result in
                switch result {
                case .success(let matchResults):
                    let record =  if let firstMatch = matchResults.matchResults.first, case .success(let valid) = firstMatch.1 {
                        valid
                    } else {
                        CKRecord(recordType: "Interest")
                    }
                    let currentValue = record.value(forKey: "count") as? UInt8 ?? 0
                    if currentValue == UInt8.max {
                        logger.debug("CloudKit vote maxed out at Byte limit (\(currentValue))")
                        return }
                    record.setValue(currentValue + 1, forKey: "count")
                    
                    let saveOperation = CKModifyRecordsOperation(recordsToSave: [record])
                    saveOperation.modifyRecordsResultBlock = { result in
                        logger.debug("CloudKit save operation result: \(String(describing: result))")
                    }
                    publicDatabase.add(saveOperation)
                case .failure(let error):
                    logger.error("CloudKit failed to fetch from public database. \(error)")
                }
            }
        }
    }
}

extension CloudKitContainerManager: DependencyKey {
    static let liveValue: CloudKitContainerManager = .init()
}
