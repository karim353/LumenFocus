using System.ComponentModel.DataAnnotations;

namespace LumenFocus.Maui.Data.Models;

public class Preset
{
    public int Id { get; set; }
    
    [Required]
    [MaxLength(100)]
    public string Name { get; set; } = string.Empty;
    
    public double WorkDuration { get; set; } = 1500; // 25 minutes in seconds
    
    public double ShortBreakDuration { get; set; } = 300; // 5 minutes in seconds
    
    public double LongBreakDuration { get; set; } = 900; // 15 minutes in seconds
    
    public int Rounds { get; set; } = 4;
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
