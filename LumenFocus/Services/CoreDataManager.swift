import CoreData
import Foundation

class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "LumenFocus")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    func delete(_ object: NSManagedObject) {
        context.delete(object)
        save()
    }
    
    // MARK: - Task Management
    
    func createTask(title: String, color: String, icon: String, tags: [String]) -> Task {
        let task = Task(context: context)
        task.id = UUID()
        task.title = title
        task.color = color
        task.icon = icon
        task.tags = tags
        task.createdAt = Date()
        save()
        return task
    }
    
    func fetchTasks() -> [Task] {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Task.createdAt, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching tasks: \(error)")
            return []
        }
    }
    
    func deleteTask(_ task: Task) {
        delete(task)
    }
    
    // MARK: - Session Management
    
    func createSession(
        startedAt: Date,
        completedAt: Date?,
        duration: TimeInterval,
        currentPhase: String,
        presetName: String,
        rounds: Int16,
        isCompleted: Bool,
        task: Task?
    ) -> Session {
        let session = Session(context: context)
        session.id = UUID()
        session.startedAt = startedAt
        session.completedAt = completedAt
        session.duration = duration
        session.currentPhase = currentPhase
        session.presetName = presetName
        session.rounds = rounds
        session.isCompleted = isCompleted
        session.task = task
        save()
        return session
    }
    
    func fetchSessions() -> [Session] {
        let request: NSFetchRequest<Session> = Session.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Session.startedAt, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching sessions: \(error)")
            return []
        }
    }
    
    func fetchSessions(for task: Task) -> [Session] {
        let request: NSFetchRequest<Session> = Session.fetchRequest()
        request.predicate = NSPredicate(format: "task == %@", task)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Session.startedAt, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching sessions for task: \(error)")
            return []
        }
    }
    
    func fetchSessions(from startDate: Date, to endDate: Date) -> [Session] {
        let request: NSFetchRequest<Session> = Session.fetchRequest()
        request.predicate = NSPredicate(format: "startedAt >= %@ AND startedAt <= %@", startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Session.startedAt, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching sessions in date range: \(error)")
            return []
        }
    }
    
    // MARK: - Garden Management
    
    func createPlant(plantType: String) -> GardenPlant {
        let plant = GardenPlant(context: context)
        plant.id = UUID()
        plant.plantType = plantType
        plant.growthLevel = 0
        plant.waterLevel = 100
        plant.createdAt = Date()
        plant.lastWatered = Date()
        save()
        return plant
    }
    
    func fetchPlants() -> [GardenPlant] {
        let request: NSFetchRequest<GardenPlant> = GardenPlant.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \GardenPlant.createdAt, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching plants: \(error)")
            return []
        }
    }
    
    func waterPlant(_ plant: GardenPlant) {
        plant.waterLevel = min(100, plant.waterLevel + 25)
        plant.lastWatered = Date()
        
        // Grow plant if well watered
        if plant.waterLevel >= 80 && plant.growthLevel < 5 {
            plant.growthLevel += 1
        }
        
        save()
    }
    
    func growPlant(_ plant: GardenPlant) {
        if plant.waterLevel >= 60 && plant.growthLevel < 5 {
            plant.growthLevel += 1
            plant.waterLevel = max(0, plant.waterLevel - 20)
            save()
        }
    }
}
