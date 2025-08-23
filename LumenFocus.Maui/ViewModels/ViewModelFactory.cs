using LumenFocus.Maui.Services;
using LumenFocus.Maui.Data;

namespace LumenFocus.Maui.ViewModels;

public static class ViewModelFactory
{
    public static TimerViewModel CreateTimerViewModel()
    {
        var dbContext = new LumenFocusDbContext();
        var dataService = new DataService(dbContext);
        var notificationService = new NotificationService();
        var audioService = new AudioService();
        var focusModeService = new FocusModeService();
        
        return new TimerViewModel(dataService, notificationService, audioService, focusModeService);
    }
    
    public static TasksViewModel CreateTasksViewModel()
    {
        var dbContext = new LumenFocusDbContext();
        var dataService = new DataService(dbContext);
        return new TasksViewModel(dataService);
    }
    
    public static GardenViewModel CreateGardenViewModel()
    {
        var dbContext = new LumenFocusDbContext();
        var dataService = new DataService(dbContext);
        return new GardenViewModel(dataService);
    }
    
    public static StatisticsViewModel CreateStatisticsViewModel()
    {
        var dbContext = new LumenFocusDbContext();
        var dataService = new DataService(dbContext);
        return new StatisticsViewModel(dataService);
    }
    
    public static SettingsViewModel CreateSettingsViewModel()
    {
        var dbContext = new LumenFocusDbContext();
        var dataService = new DataService(dbContext);
        var notificationService = new NotificationService();
        var focusModeService = new FocusModeService();
        
        return new SettingsViewModel(dataService, notificationService, focusModeService);
    }
    
    public static AddTaskViewModel CreateAddTaskViewModel()
    {
        var dbContext = new LumenFocusDbContext();
        var dataService = new DataService(dbContext);
        return new AddTaskViewModel(dataService);
    }
}
