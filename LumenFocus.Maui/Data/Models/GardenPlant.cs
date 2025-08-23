using System.ComponentModel.DataAnnotations;

namespace LumenFocus.Maui.Data.Models;

public class GardenPlant
{
    public int Id { get; set; }
    
    [Required]
    [MaxLength(100)]
    public string Name { get; set; } = string.Empty;
    
    [Required]
    [MaxLength(100)]
    public string PlantType { get; set; } = string.Empty;
    
    [MaxLength(100)]
    public string Type { get; set; } = string.Empty;
    
    [MaxLength(50)]
    public string Color { get; set; } = "green";
    
    public int GrowthLevel { get; set; } = 0;
    
    public int WaterLevel { get; set; } = 100;
    
    public int WaterCount { get; set; } = 0;
    
    public int WaterNeeded { get; set; } = 3;
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    public DateTime? LastWatered { get; set; }
}
