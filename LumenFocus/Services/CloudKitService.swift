import CloudKit
import Foundation

class CloudKitService: ObservableObject {
    static let shared = CloudKitService()
    
    private let container = CKContainer.default()
    private let database: CKDatabase
    
    @Published var isSignedInToiCloud = false
    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSyncDate: Date?
    
    enum SyncStatus {
        case idle
        case syncing
        case completed
        case failed(Error)
    }
    
    private init() {
        self.database = container.privateCloudDatabase
        checkiCloudStatus()
    }
    
    private func checkiCloudStatus() {
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                self?.isSignedInToiCloud = status == .available
            }
            
            if let error = error {
                print("Error checking iCloud status: \(error)")
            }
        }
    }
    
    func checkForUpdates() async {
        guard isSignedInToiCloud else { return }
        
        await MainActor.run {
            syncStatus = .syncing
        }
        
        do {
            // Check for remote changes
            let changes = try await fetchRemoteChanges()
            
            if !changes.isEmpty {
                // Apply remote changes to local Core Data
                await applyRemoteChanges(changes)
            }
            
            await MainActor.run {
                syncStatus = .completed
                lastSyncDate = Date()
            }
        } catch {
            await MainActor.run {
                syncStatus = .failed(error)
            }
            print("Error checking for updates: \(error)")
        }
    }
    
    func manualSync() async {
        guard isSignedInToiCloud else { return }
        
        await MainActor.run {
            syncStatus = .syncing
        }
        
        do {
            // Sync local changes to CloudKit
            try await syncToCloud()
            
            // Check for remote changes
            let changes = try await fetchRemoteChanges()
            
            if !changes.isEmpty {
                await applyRemoteChanges(changes)
            }
            
            await MainActor.run {
                syncStatus = .completed
                lastSyncDate = Date()
            }
        } catch {
            await MainActor.run {
                syncStatus = .failed(error)
            }
            print("Error during manual sync: \(error)")
        }
    }
    
    func syncToCloud() async throws {
        // This would implement the logic to sync local Core Data changes to CloudKit
        // For now, we'll just simulate a sync operation
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
    }
    
    private func fetchRemoteChanges() async throws -> [CKRecord] {
        // This would implement the logic to fetch changes from CloudKit
        // For now, return empty array
        return []
    }
    
    private func applyRemoteChanges(_ changes: [CKRecord]) async {
        // This would implement the logic to apply remote changes to local Core Data
        // For now, just log the changes
        print("Applying \(changes.count) remote changes")
    }
    
    func createRecord(for entity: String, with data: [String: Any]) async throws -> CKRecord {
        let record = CKRecord(recordType: entity)
        
        for (key, value) in data {
            record[key] = value as? CKRecordValue
        }
        
        try await database.save(record)
        return record
    }
    
    func updateRecord(_ record: CKRecord) async throws {
        try await database.save(record)
    }
    
    func deleteRecord(_ record: CKRecord) async throws {
        try await database.deleteRecord(withID: record.recordID)
    }
    
    func fetchRecords(ofType type: String, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) async throws -> [CKRecord] {
        let query = CKQuery(recordType: type, predicate: predicate ?? NSPredicate(value: true))
        query.sortDescriptors = sortDescriptors
        
        let result = try await database.records(matching: query)
        return result.matchResults.compactMap { try? $0.1.get() }
    }
    
    func subscribeToChanges(for recordType: String) async throws {
        let subscription = CKQuerySubscription(
            recordType: recordType,
            predicate: NSPredicate(value: true),
            subscriptionID: "\(recordType)-changes",
            options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
        )
        
        let notification = CKSubscription.NotificationInfo()
        notification.shouldSendContentAvailable = true
        subscription.notificationInfo = notification
        
        try await database.save(subscription)
    }
}
