using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using LumenFocus.Maui.Services;
using LumenFocus.Maui.Data.Models;
using TaskModel = LumenFocus.Maui.Data.Models.Task;
using SystemTask = System.Threading.Tasks.Task;

namespace LumenFocus.Maui.ViewModels;

public partial class AddTaskViewModel : ObservableObject
{
    private readonly IDataService _dataService;
    
    [ObservableProperty]
    private string _taskTitle = string.Empty;
    
    [ObservableProperty]
    private string _taskDescription = string.Empty;
    
    [ObservableProperty]
    private string _selectedColor = "blue";
    
    [ObservableProperty]
    private string _selectedIcon = "circle";
    
    [ObservableProperty]
    private string _tagsText = string.Empty;
    
    [ObservableProperty]
    private bool _isLoading = false;
    
    [ObservableProperty]
    private string _errorMessage = string.Empty;
    
    [ObservableProperty]
    private bool _hasError = false;
    
    public List<string> AvailableColors { get; } = new()
    {
        "blue", "green", "red", "yellow", "purple", "orange", "pink", "gray"
    };
    
    public List<string> AvailableIcons { get; } = new()
    {
        "circle", "star", "heart", "square", "triangle", "diamond", "hexagon", "octagon"
    };
    
    public AddTaskViewModel() : this(new DataService(new Data.LumenFocusDbContext()))
    {
    }
    
    public AddTaskViewModel(IDataService dataService)
    {
        _dataService = dataService;
    }
    
    [RelayCommand]
    private async SystemTask AddTaskAsync()
    {
        if (string.IsNullOrWhiteSpace(TaskTitle))
        {
            ShowError("Task title is required");
            return;
        }
        
        try
        {
            IsLoading = true;
            HasError = false;
            
            var tags = TagsText.Split(',', StringSplitOptions.RemoveEmptyEntries)
                .Select(t => t.Trim())
                .Where(t => !string.IsNullOrWhiteSpace(t))
                .ToList();
            
            var task = new TaskModel
            {
                Title = TaskTitle.Trim(),
                Description = TaskDescription.Trim(),
                Color = SelectedColor,
                Icon = SelectedIcon,
                Tags = tags,
                CreatedAt = DateTime.UtcNow
            };
            
            await _dataService.CreateTaskAsync(task);
            
            // Clear form
            TaskTitle = string.Empty;
            TaskDescription = string.Empty;
            TagsText = string.Empty;
            
            // Navigate back
            await Shell.Current.GoToAsync("..");
        }
        catch (Exception ex)
        {
            ShowError($"Failed to create task: {ex.Message}");
        }
        finally
        {
            IsLoading = false;
        }
    }
    
    [RelayCommand]
    private async SystemTask CancelAsync()
    {
        await Shell.Current.GoToAsync("..");
    }
    
    private void ShowError(string message)
    {
        ErrorMessage = message;
        HasError = true;
    }
    
    [RelayCommand]
    private void ClearError()
    {
        HasError = false;
        ErrorMessage = string.Empty;
    }
}
