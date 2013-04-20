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

namespace PolicyMan.Views {
	public class MainWindowView : Window, IBaseView {
		private Box horizontal_box;
		private Box vertical_box;
		
		public ActionTreeView action_tree_view;
		public ActionView action_view;
		public TopToolbarView top_toolbar_view;
		public MainWindowView() {
			GLib.Object ( icon_name : "changes-prevent-symbolic",
						  title : "PolicyMan Authorization Manager",
						  window_position : WindowPosition.CENTER,
						  width_request : 1024,
						  height_request : 768);
			init();
		}
		
		protected void init() {
			horizontal_box = new Box(Orientation.HORIZONTAL, 4);
			vertical_box = new Box(Orientation.VERTICAL, 4);
			action_tree_view = new ActionTreeView();
			action_view = new ActionView();
			top_toolbar_view = new TopToolbarView();
			
			horizontal_box.pack_start(action_tree_view);
			horizontal_box.pack_start(action_view);
			vertical_box.pack_start(top_toolbar_view, false);
			vertical_box.pack_start(horizontal_box);
			this.add(vertical_box);
		}
		
		public void connect_model(IController controller) {
			ActionManagerController action_manager_controller = (ActionManagerController)controller;
			
			// Connect childs views
			action_tree_view.connect_model(action_manager_controller.actions_tree_store);
			action_view.connect_model(action_manager_controller.selected_action_controller);
			top_toolbar_view.connect_model(action_manager_controller);
			
			// Connect signals
			this.destroy.connect(action_manager_controller.close);
		}
	}
}
