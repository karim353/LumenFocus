import Foundation
import CloudKit
import CoreData
import Combine

@MainActor
class CloudKitService: ObservableObject {
    static let shared = CloudKitService()
    
    private let container = CKContainer.default()
    private let database: CKDatabase
    private var cancellables = Set<AnyCancellable>()
    
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
    
    // MARK: - iCloud Status
    
    private func checkiCloudStatus() {
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                self?.isSignedInToiCloud = status == .available
                if status == .available {
                    self?.startObservingChanges()
                }
            }
        }
    }
    
    // MARK: - CloudKit Operations
    
    func syncToCloud() async {
        guard isSignedInToiCloud else {
            syncStatus = .failed(CloudKitError.notSignedIn)
            return
        }
        
        syncStatus = .syncing
        
        do {
            try await syncTasks()
            try await syncSessions()
            try await syncGardenPlants()
            
            lastSyncDate = Date()
            syncStatus = .completed
            
            // Reset status after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.syncStatus = .idle
            }
        } catch {
            syncStatus = .failed(error)
        }
    }
    
    func syncFromCloud() async {
        guard isSignedInToiCloud else {
            syncStatus = .failed(CloudKitError.notSignedIn)
            return
        }
        
        syncStatus = .syncing
        
        do {
            try await fetchTasksFromCloud()
            try await fetchSessionsFromCloud()
            try await fetchGardenPlantsFromCloud()
            
            lastSyncDate = Date()
            syncStatus = .completed
            
            // Reset status after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.syncStatus = .idle
            }
        } catch {
            syncStatus = .failed(error)
        }
    }
    
    // MARK: - Tasks Sync
    
    private func syncTasks() async throws {
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        guard let tasks = try? context.fetch(fetchRequest) else { return }
        
        for task in tasks {
            let record = try createTaskRecord(from: task)
            try await saveRecord(record, to: database)
        }
    }
    
    private func fetchTasksFromCloud() async throws {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Task", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        let result = try await database.records(matching: query)
        let records = result.matchResults.compactMap { try? $0.1.get() }
        
        for record in records {
            try await createTaskFromRecord(record)
        }
    }
    
    private func createTaskRecord(from task: Task) throws -> CKRecord {
        let record = CKRecord(recordType: "Task")
        record["id"] = task.id?.uuidString
        record["title"] = task.title
        record["color"] = task.color
        record["icon"] = task.icon
        record["tags"] = task.tags
        record["createdAt"] = task.createdAt
        record["modifiedAt"] = Date()
        return record
    }
    
    private func createTaskFromRecord(_ record: CKRecord) async throws {
        let context = CoreDataManager.shared.context
        
        // Check if task already exists
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", record["id"] as? String ?? "")
        
        if let existingTask = try? context.fetch(fetchRequest).first {
            // Update existing task
            existingTask.title = record["title"] as? String
            existingTask.color = record["color"] as? String
            existingTask.icon = record["icon"] as? String
            existingTask.tags = record["tags"] as? [String]
        } else {
            // Create new task
            let task = Task(context: context)
            task.id = UUID(uuidString: record["id"] as? String ?? "")
            task.title = record["title"] as? String
            task.color = record["color"] as? String
            task.icon = record["icon"] as? String
            task.tags = record["tags"] as? [String]
            task.createdAt = record["createdAt"] as? Date ?? Date()
        }
        
        try context.save()
    }
    
    // MARK: - Sessions Sync
    
    private func syncSessions() async throws {
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<Session> = Session.fetchRequest()
        
        guard let sessions = try? context.fetch(fetchRequest) else { return }
        
        for session in sessions {
            let record = try createSessionRecord(from: session)
            try await saveRecord(record, to: database)
        }
    }
    
    private func fetchSessionsFromCloud() async throws {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Session", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "startedAt", ascending: false)]
        
        let result = try await database.records(matching: query)
        let records = result.matchResults.compactMap { try? $0.1.get() }
        
        for record in records {
            try await createSessionFromRecord(record)
        }
    }
    
    private func createSessionRecord(from session: Session) throws -> CKRecord {
        let record = CKRecord(recordType: "Session")
        record["id"] = session.id?.uuidString
        record["startedAt"] = session.startedAt
        record["completedAt"] = session.completedAt
        record["duration"] = session.duration
        record["currentPhase"] = session.currentPhase
        record["presetName"] = session.presetName
        record["rounds"] = session.rounds
        record["isCompleted"] = session.isCompleted
        record["taskId"] = session.task?.id?.uuidString
        record["modifiedAt"] = Date()
        return record
    }
    
    private func createSessionFromRecord(_ record: CKRecord) async throws {
        let context = CoreDataManager.shared.context
        
        // Check if session already exists
        let fetchRequest: NSFetchRequest<Session> = Session.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", record["id"] as? String ?? "")
        
        if let existingSession = try? context.fetch(fetchRequest).first {
            // Update existing session
            existingSession.startedAt = record["startedAt"] as? Date
            existingSession.completedAt = record["completedAt"] as? Date
            existingSession.duration = record["duration"] as? Double ?? 0
            existingSession.currentPhase = record["currentPhase"] as? String
            existingSession.presetName = record["presetName"] as? String
            existingSession.rounds = record["rounds"] as? Int16 ?? 1
            existingSession.isCompleted = record["isCompleted"] as? Bool ?? false
        } else {
            // Create new session
            let session = Session(context: context)
            session.id = UUID(uuidString: record["id"] as? String ?? "")
            session.startedAt = record["startedAt"] as? Date
            session.completedAt = record["completedAt"] as? Date
            session.duration = record["duration"] as? Double ?? 0
            session.currentPhase = record["currentPhase"] as? String
            session.presetName = record["presetName"] as? String
            session.rounds = record["rounds"] as? Int16 ?? 1
            session.isCompleted = record["isCompleted"] as? Bool ?? false
            
            // Link to task if exists
            if let taskId = record["taskId"] as? String,
               let taskUUID = UUID(uuidString: taskId) {
                let taskFetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
                taskFetchRequest.predicate = NSPredicate(format: "id == %@", taskUUID as CVarArg)
                if let task = try? context.fetch(taskFetchRequest).first {
                    session.task = task
                }
            }
        }
        
        try context.save()
    }
    
    // MARK: - Garden Plants Sync
    
    private func syncGardenPlants() async throws {
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<GardenPlant> = GardenPlant.fetchRequest()
        
        guard let plants = try? context.fetch(fetchRequest) else { return }
        
        for plant in plants {
            let record = try createGardenPlantRecord(from: plant)
            try await saveRecord(record, to: database)
        }
    }
    
    private func fetchGardenPlantsFromCloud() async throws {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "GardenPlant", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        let result = try await database.records(matching: query)
        let records = result.matchResults.compactMap { try? $0.1.get() }
        
        for record in records {
            try await createGardenPlantFromRecord(record)
        }
    }
    
    private func createGardenPlantRecord(from plant: GardenPlant) throws -> CKRecord {
        let record = CKRecord(recordType: "GardenPlant")
        record["id"] = plant.id?.uuidString
        record["plantType"] = plant.plantType
        record["growthLevel"] = plant.growthLevel
        record["waterLevel"] = plant.waterLevel
        record["createdAt"] = plant.createdAt
        record["lastWatered"] = plant.lastWatered
        record["modifiedAt"] = Date()
        return record
    }
    
    private func createGardenPlantFromRecord(_ record: CKRecord) async throws {
        let context = CoreDataManager.shared.context
        
        // Check if plant already exists
        let fetchRequest: NSFetchRequest<GardenPlant> = GardenPlant.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", record["id"] as? String ?? "")
        
        if let existingPlant = try? context.fetch(fetchRequest).first {
            // Update existing plant
            existingPlant.plantType = record["plantType"] as? String
            existingPlant.growthLevel = record["growthLevel"] as? Int16 ?? 0
            existingPlant.waterLevel = record["waterLevel"] as? Int16 ?? 100
            existingPlant.lastWatered = record["lastWatered"] as? Date
        } else {
            // Create new plant
            let plant = GardenPlant(context: context)
            plant.id = UUID(uuidString: record["id"] as? String ?? "")
            plant.plantType = record["plantType"] as? String
            plant.growthLevel = record["growthLevel"] as? Int16 ?? 0
            plant.waterLevel = record["waterLevel"] as? Int16 ?? 100
            plant.createdAt = record["createdAt"] as? Date ?? Date()
            plant.lastWatered = record["lastWatered"] as? Date
        }
        
        try context.save()
    }
    
    // MARK: - Helper Methods
    
    private func saveRecord(_ record: CKRecord, to database: CKDatabase) async throws {
        try await database.save(record)
    }
    
    private func startObservingChanges() {
        // Subscribe to CloudKit changes
        let subscription = CKQuerySubscription(
            recordType: "Task",
            predicate: NSPredicate(value: true),
            subscriptionID: "task-changes",
            options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
        )
        
        let notification = CKSubscription.NotificationInfo()
        notification.shouldSendContentAvailable = true
        subscription.notificationInfo = notification
        
        Task {
            do {
                try await database.save(subscription)
            } catch {
                print("Failed to save subscription: \(error)")
            }
        }
    }
    
    // MARK: - Manual Sync Methods
    
    func manualSync() async {
        await syncToCloud()
        await syncFromCloud()
    }
    
    func checkForUpdates() async {
        // Check if there are any new records in CloudKit
        // This could be triggered by push notifications
        await syncFromCloud()
    }
}

// MARK: - Errors

enum CloudKitError: LocalizedError {
    case notSignedIn
    case networkError
    case permissionDenied
    case quotaExceeded
    
    var errorDescription: String? {
        switch self {
        case .notSignedIn:
            return "Необходимо войти в iCloud для синхронизации"
        case .networkError:
            return "Ошибка сети. Проверьте подключение к интернету"
        case .permissionDenied:
            return "Доступ к iCloud запрещен"
        case .quotaExceeded:
            return "Превышен лимит iCloud хранилища"
        }
    }
}
