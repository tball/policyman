using PolicyMan.Controllers;

namespace PolicyMan.Views {
	public interface IBaseView : GLib.Object {
		public abstract void connect_model(IController controller);
	} 
}
