using Microsoft.EntityFrameworkCore.Migrations;

namespace LumenFocus.Maui.Data.Migrations;

public partial class InitialCreate : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.CreateTable(
            name: "Presets",
            columns: table => new
            {
                Id = table.Column<int>(type: "INTEGER", nullable: false)
                    .Annotation("Sqlite:Autoincrement", true),
                Name = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false),
                WorkDuration = table.Column<double>(type: "REAL", nullable: false),
                ShortBreakDuration = table.Column<double>(type: "REAL", nullable: false),
                LongBreakDuration = table.Column<double>(type: "REAL", nullable: false),
                Rounds = table.Column<int>(type: "INTEGER", nullable: false),
                CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_Presets", x => x.Id);
            });

        migrationBuilder.CreateTable(
            name: "Tasks",
            columns: table => new
            {
                Id = table.Column<int>(type: "INTEGER", nullable: false)
                    .Annotation("Sqlite:Autoincrement", true),
                Title = table.Column<string>(type: "TEXT", maxLength: 200, nullable: false),
                Description = table.Column<string>(type: "TEXT", maxLength: 1000, nullable: true),
                Color = table.Column<string>(type: "TEXT", maxLength: 50, nullable: true),
                Icon = table.Column<string>(type: "TEXT", maxLength: 50, nullable: true),
                CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                Tags = table.Column<string>(type: "TEXT", nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_Tasks", x => x.Id);
            });

        migrationBuilder.CreateTable(
            name: "Sessions",
            columns: table => new
            {
                Id = table.Column<int>(type: "INTEGER", nullable: false)
                    .Annotation("Sqlite:Autoincrement", true),
                StartedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                CompletedAt = table.Column<DateTime>(type: "TEXT", nullable: true),
                Duration = table.Column<double>(type: "REAL", nullable: false),
                CurrentPhase = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false),
                IsCompleted = table.Column<bool>(type: "INTEGER", nullable: false),
                Rounds = table.Column<int>(type: "INTEGER", nullable: false),
                PresetName = table.Column<string>(type: "TEXT", maxLength: 200, nullable: true),
                TaskId = table.Column<int>(type: "INTEGER", nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_Sessions", x => x.Id);
                table.ForeignKey(
                    name: "FK_Sessions_Tasks_TaskId",
                    column: x => x.TaskId,
                    principalTable: "Tasks",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.SetNull);
            });

        migrationBuilder.CreateTable(
            name: "GardenPlants",
            columns: table => new
            {
                Id = table.Column<int>(type: "INTEGER", nullable: false)
                    .Annotation("Sqlite:Autoincrement", true),
                PlantType = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false),
                GrowthLevel = table.Column<int>(type: "INTEGER", nullable: false),
                WaterLevel = table.Column<int>(type: "INTEGER", nullable: false),
                CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                LastWatered = table.Column<DateTime>(type: "TEXT", nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_GardenPlants", x => x.Id);
            });

        // Seed default presets
        migrationBuilder.InsertData(
            table: "Presets",
            columns: new[] { "Id", "Name", "WorkDuration", "ShortBreakDuration", "LongBreakDuration", "Rounds", "CreatedAt" },
            values: new object[,]
            {
                { 1, "Pomodoro", 1500.0, 300.0, 900.0, 4, DateTime.UtcNow },
                { 2, "Quick Focus", 900.0, 180.0, 600.0, 6, DateTime.UtcNow }
            });

        migrationBuilder.CreateIndex(
            name: "IX_Sessions_TaskId",
            table: "Sessions",
            column: "TaskId");
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropTable(name: "Sessions");
        migrationBuilder.DropTable(name: "Tasks");
        migrationBuilder.DropTable(name: "Presets");
        migrationBuilder.DropTable(name: "GardenPlants");
    }
}
