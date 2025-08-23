using Microsoft.EntityFrameworkCore;
using LumenFocus.Maui.Data;
using LumenFocus.Maui.Data.Models;

namespace LumenFocus.Maui.Services;

public class DataService : IDataService
{
    private readonly LumenFocusDbContext _context;

    public DataService(LumenFocusDbContext context)
    {
        _context = context;
    }

    // Task operations
    public async Task<List<Data.Models.Task>> GetTasksAsync()
    {
        return await _context.Tasks
            .OrderByDescending(t => t.CreatedAt)
            .ToListAsync();
    }

    public async Task<Data.Models.Task> CreateTaskAsync(Data.Models.Task task)
    {
        _context.Tasks.Add(task);
        await _context.SaveChangesAsync();
        return task;
    }

    public async Task<bool> UpdateTaskAsync(Data.Models.Task task)
    {
        _context.Tasks.Update(task);
        var result = await _context.SaveChangesAsync();
        return result > 0;
    }

    public async Task<bool> DeleteTaskAsync(int taskId)
    {
        var task = await _context.Tasks.FindAsync(taskId);
        if (task == null) return false;
        
        _context.Tasks.Remove(task);
        var result = await _context.SaveChangesAsync();
        return result > 0;
    }

    // Session operations
    public async Task<List<Session>> GetSessionsAsync()
    {
        return await _context.Sessions
            .Include(s => s.Task)
            .OrderByDescending(s => s.StartedAt)
            .ToListAsync();
    }

    public async Task<Session> CreateSessionAsync(Session session)
    {
        _context.Sessions.Add(session);
        await _context.SaveChangesAsync();
        return session;
    }

    public async Task<bool> UpdateSessionAsync(Session session)
    {
        _context.Sessions.Update(session);
        var result = await _context.SaveChangesAsync();
        return result > 0;
    }

    public async Task<bool> DeleteSessionAsync(int sessionId)
    {
        var session = await _context.Sessions.FindAsync(sessionId);
        if (session == null) return false;
        
        _context.Sessions.Remove(session);
        var result = await _context.SaveChangesAsync();
        return result > 0;
    }

    // Preset operations
    public async Task<List<Preset>> GetPresetsAsync()
    {
        return await _context.Presets
            .OrderByDescending(p => p.CreatedAt)
            .ToListAsync();
    }

    public async Task<Preset> CreatePresetAsync(Preset preset)
    {
        _context.Presets.Add(preset);
        await _context.SaveChangesAsync();
        return preset;
    }

    public async Task<bool> UpdatePresetAsync(Preset preset)
    {
        _context.Presets.Update(preset);
        var result = await _context.SaveChangesAsync();
        return result > 0;
    }

    public async Task<bool> DeletePresetAsync(int presetId)
    {
        var preset = await _context.Presets.FindAsync(presetId);
        if (preset == null) return false;
        
        _context.Presets.Remove(preset);
        var result = await _context.SaveChangesAsync();
        return result > 0;
    }

    // Garden operations
    public async Task<List<GardenPlant>> GetGardenPlantsAsync()
    {
        return await _context.GardenPlants
            .OrderByDescending(p => p.CreatedAt)
            .ToListAsync();
    }

    public async Task<GardenPlant> CreateGardenPlantAsync(GardenPlant plant)
    {
        _context.GardenPlants.Add(plant);
        await _context.SaveChangesAsync();
        return plant;
    }

    public async Task<bool> UpdateGardenPlantAsync(GardenPlant plant)
    {
        _context.GardenPlants.Update(plant);
        var result = await _context.SaveChangesAsync();
        return result > 0;
    }

    public async Task<bool> DeleteGardenPlantAsync(int plantId)
    {
        var plant = await _context.GardenPlants.FindAsync(plantId);
        if (plant == null) return false;
        
        _context.GardenPlants.Remove(plant);
        var result = await _context.SaveChangesAsync();
        return result > 0;
    }
}
