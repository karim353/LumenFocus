using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using LumenFocus.Maui.Services;
using LumenFocus.Maui.Data.Models;
using System.Collections.ObjectModel;
using TaskModel = LumenFocus.Maui.Data.Models.Task;
using SystemTask = System.Threading.Tasks.Task;

namespace LumenFocus.Maui.ViewModels;

public partial class TasksViewModel : ObservableObject
{
    private readonly IDataService _dataService;
    
    [ObservableProperty]
    private ObservableCollection<TaskModel> _tasks = new();
    
    [ObservableProperty]
    private bool _isLoading = false;
    
    [ObservableProperty]
    private string _searchText = string.Empty;
    
    [ObservableProperty]
    private TaskModel? _selectedTask;
    
    public TasksViewModel() : this(new DataService(new Data.LumenFocusDbContext()))
    {
    }
    
    public TasksViewModel(IDataService dataService)
    {
        _dataService = dataService;
        _ = LoadTasksAsync();
    }
    
    private async SystemTask LoadTasksAsync()
    {
        try
        {
            IsLoading = true;
            var tasks = await _dataService.GetTasksAsync();
            
            Tasks.Clear();
            foreach (var task in tasks)
            {
                Tasks.Add(task);
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error loading tasks: {ex.Message}");
        }
        finally
        {
            IsLoading = false;
        }
    }
    
    [RelayCommand]
    private async SystemTask AddTaskAsync()
    {
        await Shell.Current.GoToAsync("AddTask");
    }
    
    [RelayCommand]
    private async SystemTask EditTaskAsync(TaskModel task)
    {
        // Navigate to edit task page
        var parameters = new Dictionary<string, object>
        {
            { "Task", task }
        };
        await Shell.Current.GoToAsync("EditTask", parameters);
    }
    
    [RelayCommand]
    private async SystemTask DeleteTaskAsync(TaskModel task)
    {
        try
        {
            var result = await _dataService.DeleteTaskAsync(task.Id);
            if (result)
            {
                Tasks.Remove(task);
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error deleting task: {ex.Message}");
        }
    }
    
    [RelayCommand]
    private async SystemTask RefreshAsync()
    {
        await LoadTasksAsync();
    }
    
    partial void OnSearchTextChanged(string value)
    {
        // Implement search functionality if needed
        _ = LoadTasksAsync();
    }
}
