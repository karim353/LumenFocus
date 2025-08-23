using System.ComponentModel.DataAnnotations;

namespace LumenFocus.Maui.Data.Models;

public class Session
{
    public int Id { get; set; }
    
    public DateTime StartedAt { get; set; }
    
    public DateTime? CompletedAt { get; set; }
    
    public DateTime? EndedAt { get; set; }
    
    public TimeSpan Duration { get; set; }
    
    [MaxLength(100)]
    public string CurrentPhase { get; set; } = string.Empty;
    
    [MaxLength(50)]
    public string Status { get; set; } = "Active";
    
    public bool IsCompleted { get; set; }
    
    public int Rounds { get; set; } = 1;
    
    [MaxLength(200)]
    public string? PresetName { get; set; }
    
    // Foreign key
    public int? TaskId { get; set; }
    
    // Navigation properties
    public virtual Task? Task { get; set; }
}
