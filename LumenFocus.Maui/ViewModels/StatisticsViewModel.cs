using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using LumenFocus.Maui.Services;
using LumenFocus.Maui.Data.Models;
using System.Collections.ObjectModel;
using TaskModel = LumenFocus.Maui.Data.Models.Task;
using SystemTask = System.Threading.Tasks.Task;

namespace LumenFocus.Maui.ViewModels;

public partial class StatisticsViewModel : ObservableObject
{
    private readonly IDataService _dataService;
    
    [ObservableProperty]
    private int _totalSessions = 0;
    
    [ObservableProperty]
    private int _completedSessions = 0;
    
    [ObservableProperty]
    private TimeSpan _totalFocusTime = TimeSpan.Zero;
    
    [ObservableProperty]
    private TimeSpan _averageSessionTime = TimeSpan.Zero;
    
    [ObservableProperty]
    private int _currentStreak = 0;
    
    [ObservableProperty]
    private int _longestStreak = 0;
    
    [ObservableProperty]
    private ObservableCollection<TaskModel> _topTasks = new();
    
    [ObservableProperty]
    private bool _isLoading = false;
    
    [ObservableProperty]
    private string _selectedPeriod = "Week";
    
    public StatisticsViewModel() : this(new DataService(new Data.LumenFocusDbContext()))
    {
    }
    
    public StatisticsViewModel(IDataService dataService)
    {
        _dataService = dataService;
        _ = LoadStatisticsAsync();
    }
    
    private async SystemTask LoadStatisticsAsync()
    {
        try
        {
            IsLoading = true;
            
            var sessions = await _dataService.GetSessionsAsync();
            var tasks = await _dataService.GetTasksAsync();
            
            // Calculate basic statistics
            TotalSessions = sessions.Count;
            CompletedSessions = sessions.Count(s => s.Status == "Completed");
            
            var completedSessions = sessions.Where(s => s.Status == "Completed").ToList();
            if (completedSessions.Any())
            {
                TotalFocusTime = TimeSpan.FromSeconds(completedSessions.Sum(s => s.Duration.TotalSeconds));
                AverageSessionTime = TimeSpan.FromSeconds(TotalFocusTime.TotalSeconds / completedSessions.Count);
            }
            
            // Calculate streaks
            CalculateStreaks(completedSessions);
            
            // Get top tasks
            var taskStats = tasks.Select(t => new
            {
                Task = t,
                SessionCount = sessions.Count(s => s.TaskId == t.Id)
            }).OrderByDescending(x => x.SessionCount).Take(5);
            
            TopTasks.Clear();
            foreach (var stat in taskStats)
            {
                TopTasks.Add(stat.Task);
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error loading statistics: {ex.Message}");
        }
        finally
        {
            IsLoading = false;
        }
    }
    
    private void CalculateStreaks(List<Session> completedSessions)
    {
        if (!completedSessions.Any()) return;
        
        var sortedSessions = completedSessions
            .OrderByDescending(s => s.StartedAt)
            .ToList();
        
        var currentDate = DateTime.Today;
        var streak = 0;
        var longestStreak = 0;
        var tempStreak = 0;
        
        foreach (var session in sortedSessions)
        {
            var sessionDate = session.StartedAt.Date;
            var daysDiff = (currentDate - sessionDate).Days;
            
            if (daysDiff == tempStreak)
            {
                tempStreak++;
                if (tempStreak > longestStreak)
                {
                    longestStreak = tempStreak;
                }
            }
            else
            {
                tempStreak = 1;
            }
            
            if (daysDiff == 0)
            {
                streak = tempStreak;
            }
        }
        
        CurrentStreak = streak;
        LongestStreak = longestStreak;
    }
    
    partial void OnSelectedPeriodChanged(string value)
    {
        _ = LoadStatisticsAsync();
    }
    
    [RelayCommand]
    private async SystemTask RefreshStatisticsAsync()
    {
        await LoadStatisticsAsync();
    }
}
