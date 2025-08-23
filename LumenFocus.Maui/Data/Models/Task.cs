using System.ComponentModel.DataAnnotations;

namespace LumenFocus.Maui.Data.Models;

public class Task
{
    public int Id { get; set; }
    
    [Required]
    [MaxLength(200)]
    public string Title { get; set; } = string.Empty;
    
    [MaxLength(1000)]
    public string? Description { get; set; }
    
    [MaxLength(50)]
    public string Color { get; set; } = "blue";
    
    [MaxLength(50)]
    public string Icon { get; set; } = "circle";
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    public List<string> Tags { get; set; } = new();
    
    // Navigation properties
    public virtual ICollection<Session> Sessions { get; set; } = new List<Session>();
}
