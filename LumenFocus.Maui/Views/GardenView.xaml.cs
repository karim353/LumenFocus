using LumenFocus.Maui.ViewModels;

namespace LumenFocus.Maui.Views;

public partial class GardenView : ContentPage
{
	public GardenView()
	{
		InitializeComponent();
		BindingContext = ViewModelFactory.CreateGardenViewModel();
	}
}
