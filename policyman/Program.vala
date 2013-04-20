/**
 * PolicyMan is a gtk based polkit authorization manager.
 * Copyright (C) 2012  Thomas Balling Sørensen
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 **/

using Gtk;
using PolicyMan.Controllers;
using PolicyMan.Views;

namespace PolicyMan {
	class Program : Object {
		private IBaseView main_window_view = null;
		private IController action_manager_controller = null;

		public Program( ) {
			/* Object( application_id: "PolicyMan",
			        flags: ApplicationFlags.FLAGS_NONE );*/

		}

		public void setup_ui(string[] args) {
			Gtk.init (ref args);
			main_window_view = new MainWindowView();
			action_manager_controller = new ActionManagerController();
			main_window_view.connect_model(action_manager_controller);
			
			var main_window_view_window = main_window_view as Window;
			main_window_view_window.destroy.connect(Gtk.main_quit);
			main_window_view_window.show_all();
		}

		public void run() {
			Gtk.main();
		}
	}
}
