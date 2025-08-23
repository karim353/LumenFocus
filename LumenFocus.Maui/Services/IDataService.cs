using LumenFocus.Maui.Data.Models;

namespace LumenFocus.Maui.Services;

public interface IDataService
{
    // Task operations
    Task<List<Data.Models.Task>> GetTasksAsync();
    Task<Data.Models.Task> CreateTaskAsync(Data.Models.Task task);
    Task<bool> UpdateTaskAsync(Data.Models.Task task);
    Task<bool> DeleteTaskAsync(int taskId);
    
    // Session operations
    Task<List<Session>> GetSessionsAsync();
    Task<Session> CreateSessionAsync(Session session);
    Task<bool> UpdateSessionAsync(Session session);
    Task<bool> DeleteSessionAsync(int sessionId);
    
    // Preset operations
    Task<List<Preset>> GetPresetsAsync();
    Task<Preset> CreatePresetAsync(Preset preset);
    Task<bool> UpdatePresetAsync(Preset preset);
    Task<bool> DeletePresetAsync(int presetId);
    
    // Garden operations
    Task<List<GardenPlant>> GetGardenPlantsAsync();
    Task<GardenPlant> CreateGardenPlantAsync(GardenPlant plant);
    Task<bool> UpdateGardenPlantAsync(GardenPlant plant);
    Task<bool> DeleteGardenPlantAsync(int plantId);
}
