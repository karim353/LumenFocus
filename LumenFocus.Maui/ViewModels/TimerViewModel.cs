using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using LumenFocus.Maui.Services;
using LumenFocus.Maui.Data.Models;
using System.Collections.ObjectModel;
using TaskModel = LumenFocus.Maui.Data.Models.Task;
using SystemTask = System.Threading.Tasks.Task;

namespace LumenFocus.Maui.ViewModels;

public partial class TimerViewModel : ObservableObject
{
    private readonly IDataService _dataService;
    private readonly INotificationService _notificationService;
    private readonly IAudioService _audioService;
    private readonly IFocusModeService _focusModeService;
    
    [ObservableProperty]
    private TimeSpan _remainingTime = TimeSpan.FromMinutes(25);
    
    [ObservableProperty]
    private TimeSpan _totalTime = TimeSpan.FromMinutes(25);
    
    [ObservableProperty]
    private bool _isRunning = false;
    
    [ObservableProperty]
    private bool _isPaused = false;
    
    [ObservableProperty]
    private string _currentTaskTitle = "Focus Session";
    
    [ObservableProperty]
    private ObservableCollection<TaskModel> _availableTasks = new();
    
    [ObservableProperty]
    private TaskModel? _selectedTask;
    
    private IDispatcherTimer? _timer;
    private Session? _currentSession;
    
    public TimerViewModel(IDataService dataService, INotificationService notificationService, 
                        IAudioService audioService, IFocusModeService focusModeService)
    {
        _dataService = dataService;
        _notificationService = notificationService;
        _audioService = audioService;
        _focusModeService = focusModeService;
        
        InitializeTimer();
        LoadTasksAsync();
    }
    
    private void InitializeTimer()
    {
        try
        {
            _timer = Application.Current?.Dispatcher.CreateTimer();
            if (_timer != null)
            {
                _timer.Interval = TimeSpan.FromSeconds(1);
                _timer.Tick += Timer_Tick;
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error initializing timer: {ex.Message}");
        }
    }
    
    private async void LoadTasksAsync()
    {
        try
        {
            var tasks = await _dataService.GetTasksAsync();
            AvailableTasks.Clear();
            foreach (var task in tasks)
            {
                AvailableTasks.Add(task);
            }
        }
        catch (Exception ex)
        {
            // Log error
            System.Diagnostics.Debug.WriteLine($"Error loading tasks: {ex.Message}");
        }
    }
    
    private void Timer_Tick(object? sender, EventArgs e)
    {
        if (RemainingTime.TotalSeconds > 0)
        {
            RemainingTime = RemainingTime.Subtract(TimeSpan.FromSeconds(1));
        }
        else
        {
            StopTimer();
            SessionCompleted();
        }
    }
    
    [RelayCommand]
    private void StartTimer()
    {
        if (IsRunning) return;
        
        IsRunning = true;
        IsPaused = false;
        _timer?.Start();
        
        StartSession();
    }
    
    [RelayCommand]
    private void PauseTimer()
    {
        if (!IsRunning) return;
        
        IsPaused = true;
        _timer?.Stop();
    }
    
    [RelayCommand]
    private void ResumeTimer()
    {
        if (!IsRunning || !IsPaused) return;
        
        IsPaused = false;
        _timer?.Start();
    }
    
    [RelayCommand]
    private void StopTimer()
    {
        IsRunning = false;
        IsPaused = false;
        _timer?.Stop();
        RemainingTime = TotalTime;
        
        EndSession();
    }
    
    [RelayCommand]
    private void ResetTimer()
    {
        StopTimer();
        RemainingTime = TotalTime;
    }
    
    private async void StartSession()
    {
        try
        {
            _currentSession = new Session
            {
                TaskId = SelectedTask?.Id,
                StartedAt = DateTime.UtcNow,
                Duration = TotalTime,
                Status = "Active"
            };
            
            await _dataService.CreateSessionAsync(_currentSession);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error starting session: {ex.Message}");
        }
    }
    
    private async void EndSession()
    {
        try
        {
            if (_currentSession != null)
            {
                _currentSession.EndedAt = DateTime.UtcNow;
                _currentSession.Status = "Completed";
                await _dataService.UpdateSessionAsync(_currentSession);
                _currentSession = null;
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error ending session: {ex.Message}");
        }
    }
    
    private async void SessionCompleted()
    {
        try
        {
            await _notificationService.ShowNotificationAsync("Session Complete!", "Great job! Your focus session is finished.");
            await _audioService.PlaySoundAsync("session_complete");
            
            if (_currentSession != null)
            {
                _currentSession.EndedAt = DateTime.UtcNow;
                _currentSession.Status = "Completed";
                await _dataService.UpdateSessionAsync(_currentSession);
                _currentSession = null;
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error completing session: {ex.Message}");
        }
    }
    
    partial void OnSelectedTaskChanged(TaskModel? value)
    {
        if (value != null)
        {
            CurrentTaskTitle = value.Title;
        }
    }
    
    partial void OnTotalTimeChanged(TimeSpan value)
    {
        if (!IsRunning)
        {
            RemainingTime = value;
        }
    }
}
