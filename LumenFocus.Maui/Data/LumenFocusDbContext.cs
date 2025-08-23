using Microsoft.EntityFrameworkCore;
using LumenFocus.Maui.Data.Models;

namespace LumenFocus.Maui.Data;

public class LumenFocusDbContext : DbContext
{
    public LumenFocusDbContext()
    {
    }

    public LumenFocusDbContext(DbContextOptions<LumenFocusDbContext> options) : base(options)
    {
    }

    public DbSet<Data.Models.Task> Tasks { get; set; }
    public DbSet<Session> Sessions { get; set; }
    public DbSet<Preset> Presets { get; set; }
    public DbSet<GardenPlant> GardenPlants { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        if (!optionsBuilder.IsConfigured)
        {
            var dbPath = Path.Combine(FileSystem.AppDataDirectory, "LumenFocus.db");
            optionsBuilder.UseSqlite($"Data Source={dbPath}");
        }
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Configure Task entity
        modelBuilder.Entity<Data.Models.Task>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Tags)
                .HasConversion(
                    v => string.Join(',', v),
                    v => v.Split(',', StringSplitOptions.RemoveEmptyEntries).ToList());
        });

        // Configure Session entity
        modelBuilder.Entity<Session>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasOne(e => e.Task)
                .WithMany(t => t.Sessions)
                .HasForeignKey(e => e.TaskId)
                .OnDelete(DeleteBehavior.SetNull);
        });

        // Configure Preset entity
        modelBuilder.Entity<Preset>(entity =>
        {
            entity.HasKey(e => e.Id);
        });

        // Configure GardenPlant entity
        modelBuilder.Entity<GardenPlant>(entity =>
        {
            entity.HasKey(e => e.Id);
        });

        // Seed default presets
        modelBuilder.Entity<Preset>().HasData(
            new Preset
            {
                Id = 1,
                Name = "Pomodoro",
                WorkDuration = 1500,
                ShortBreakDuration = 300,
                LongBreakDuration = 900,
                Rounds = 4,
                CreatedAt = DateTime.UtcNow
            },
            new Preset
            {
                Id = 2,
                Name = "Quick Focus",
                WorkDuration = 900,
                ShortBreakDuration = 180,
                LongBreakDuration = 600,
                Rounds = 6,
                CreatedAt = DateTime.UtcNow
            }
        );
    }
}
