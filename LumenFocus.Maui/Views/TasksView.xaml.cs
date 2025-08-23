using LumenFocus.Maui.ViewModels;

namespace LumenFocus.Maui.Views;

public partial class TasksView : ContentPage
{
	public TasksView()
	{
		InitializeComponent();
		BindingContext = ViewModelFactory.CreateTasksViewModel();
	}
}
