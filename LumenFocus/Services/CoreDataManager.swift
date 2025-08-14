import CoreData
import Foundation

class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    
    let container: NSPersistentContainer
    let context: NSManagedObjectContext
    
    private init() {
        container = NSPersistentContainer(name: "LumenFocus")
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        
        context = container.viewContext
        context.automaticallyMergesChangesFromParent = true
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
    
    // MARK: - Task Management
    
    func createTask(title: String, description: String = "", color: String = "blue", icon: String = "circle") -> Task {
        let task = Task(context: context)
        task.id = UUID()
        task.title = title
        task.color = color
        task.icon = icon
        task.createdAt = Date()
        task.tags = []
        
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
        context.delete(task)
        save()
    }
    
    // MARK: - Session Management
    
    func createSession(startedAt: Date, duration: TimeInterval, type: String, task: Task? = nil) -> Session {
        let session = Session(context: context)
        session.id = UUID()
        session.startedAt = startedAt
        session.duration = duration
        session.currentPhase = type
        session.task = task
        session.isCompleted = true
        session.rounds = 1
        
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
    
    func deleteSession(_ session: Session) {
        context.delete(session)
        save()
    }
    
    // MARK: - Preset Management
    
    func createPreset(name: String, focusTime: TimeInterval, breakTime: TimeInterval, longBreakTime: TimeInterval) -> Preset {
        let preset = Preset(context: context)
        preset.id = UUID()
        preset.name = name
        preset.workDuration = focusTime
        preset.shortBreakDuration = breakTime
        preset.longBreakDuration = longBreakTime
        preset.rounds = 4
        preset.createdAt = Date()
        
        save()
        return preset
    }
    
    func fetchPresets() -> [Preset] {
        let request: NSFetchRequest<Preset> = Preset.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Preset.createdAt, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching presets: \(error)")
            return []
        }
    }
    
    func deletePreset(_ preset: Preset) {
        context.delete(preset)
        save()
    }
}
