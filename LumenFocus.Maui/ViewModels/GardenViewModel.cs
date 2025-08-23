using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using LumenFocus.Maui.Services;
using LumenFocus.Maui.Data.Models;
using System.Collections.ObjectModel;
using SystemTask = System.Threading.Tasks.Task;

namespace LumenFocus.Maui.ViewModels;

public partial class GardenViewModel : ObservableObject
{
    private readonly IDataService _dataService;
    
    [ObservableProperty]
    private ObservableCollection<GardenPlant> _plants = new();
    
    [ObservableProperty]
    private bool _isLoading = false;
    
    [ObservableProperty]
    private string _newPlantName = string.Empty;
    
    [ObservableProperty]
    private string _selectedPlantType = "Flower";
    
    [ObservableProperty]
    private string _selectedPlantColor = "green";
    
    public List<string> AvailablePlantTypes { get; } = new()
    {
        "Flower", "Tree", "Herb", "Succulent", "Vegetable", "Fruit"
    };
    
    public List<string> AvailablePlantColors { get; } = new()
    {
        "green", "red", "blue", "yellow", "purple", "orange", "pink", "white"
    };
    
    public GardenViewModel() : this(new DataService(new Data.LumenFocusDbContext()))
    {
    }
    
    public GardenViewModel(IDataService dataService)
    {
        _dataService = dataService;
        _ = LoadPlantsAsync();
    }
    
    private async SystemTask LoadPlantsAsync()
    {
        try
        {
            IsLoading = true;
            var plants = await _dataService.GetGardenPlantsAsync();
            
            Plants.Clear();
            foreach (var plant in plants)
            {
                Plants.Add(plant);
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error loading plants: {ex.Message}");
        }
        finally
        {
            IsLoading = false;
        }
    }
    
    [RelayCommand]
    private async SystemTask AddPlantAsync()
    {
        if (string.IsNullOrWhiteSpace(NewPlantName))
            return;
        
        try
        {
            var plant = new GardenPlant
            {
                Name = NewPlantName.Trim(),
                PlantType = SelectedPlantType,
                Type = SelectedPlantType,
                Color = SelectedPlantColor,
                GrowthLevel = 0,
                WaterLevel = 100,
                WaterCount = 0,
                WaterNeeded = 3,
                CreatedAt = DateTime.UtcNow
            };
            
            await _dataService.CreateGardenPlantAsync(plant);
            
            // Clear form
            NewPlantName = string.Empty;
            
            // Reload plants
            await LoadPlantsAsync();
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error adding plant: {ex.Message}");
        }
    }
    
    [RelayCommand]
    private async SystemTask WaterPlantAsync(GardenPlant plant)
    {
        try
        {
            plant.WaterLevel = Math.Min(100, plant.WaterLevel + 25);
            plant.WaterCount = Math.Min(plant.WaterCount + 1, plant.WaterNeeded);
            plant.LastWatered = DateTime.UtcNow;
            
            await _dataService.UpdateGardenPlantAsync(plant);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error watering plant: {ex.Message}");
        }
    }
    
    [RelayCommand]
    private async SystemTask RemovePlantAsync(GardenPlant plant)
    {
        try
        {
            await _dataService.DeleteGardenPlantAsync(plant.Id);
            Plants.Remove(plant);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine($"Error removing plant: {ex.Message}");
        }
    }
    
    [RelayCommand]
    private async SystemTask RefreshAsync()
    {
        await LoadPlantsAsync();
    }
}
