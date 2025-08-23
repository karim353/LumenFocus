using LumenFocus.Maui.ViewModels;

namespace LumenFocus.Maui.Views;

public partial class FocusView : ContentPage
{
	public FocusView()
	{
		InitializeComponent();
		BindingContext = ViewModelFactory.CreateTimerViewModel();
	}
}
