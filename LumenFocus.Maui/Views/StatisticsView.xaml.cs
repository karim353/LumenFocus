using LumenFocus.Maui.ViewModels;

namespace LumenFocus.Maui.Views;

public partial class StatisticsView : ContentPage
{
	public StatisticsView()
	{
		InitializeComponent();
		BindingContext = ViewModelFactory.CreateStatisticsViewModel();
	}
}
