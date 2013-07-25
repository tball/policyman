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
		
		public TopToolbarView top_toolbar_view;
		public AuthorityView authority_view;
		public AuthoritiesTreeView authorities_tree_view;
		
		public signal void delete_authority_clicked(TreeIter ?tree_iter);
		public signal void add_authority_clicked();
		
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
			var vertical_tree_view_box = new Box(Orientation.VERTICAL, 4);
			//action_tree_view = new ActionTreeView();
			//action_view = new ActionView();
			top_toolbar_view = new TopToolbarView();
			authority_view = new AuthorityView();
			authorities_tree_view = new AuthoritiesTreeView();
			
			var authority_toolbar = new Toolbar();
			var add_authority_rule_button = new ToolButton(null, null);
			var delete_authority_button = new ToolButton(null, null);
			add_authority_rule_button.clicked.connect((object) => { add_authority_clicked(); });
			add_authority_rule_button.icon_name = "list-add-symbolic";
			delete_authority_button.clicked.connect((object) => { var tree_iter = authorities_tree_view.get_selected_tree_iter(); delete_authority_clicked(tree_iter); });
			delete_authority_button.icon_name = "list-remove-symbolic";
			authority_toolbar.insert(add_authority_rule_button, 0);
			authority_toolbar.insert(delete_authority_button, 1);
			
			//horizontal_box.pack_start(action_tree_view);
			//horizontal_box.pack_start(action_view);
			vertical_tree_view_box.pack_start(authorities_tree_view);
			vertical_tree_view_box.pack_start(authority_toolbar, false);
			horizontal_box.pack_start(vertical_tree_view_box);
			horizontal_box.pack_start(authority_view);
			vertical_box.pack_start(top_toolbar_view, false);
			vertical_box.pack_start(horizontal_box);
			this.add(vertical_box);
		}
		
		public void connect_model(IController controller) {
			var main_window_controller = controller as MainWindowController;
			
			// Connect childs views
			authorities_tree_view.connect_model(main_window_controller.authorities_tree_store);
			authority_view.connect_model(main_window_controller.authority_controller);
			top_toolbar_view.connect_model(main_window_controller);
			
			// Connect model
			this.delete_authority_clicked.connect(main_window_controller.delete_authority_clicked);
			this.add_authority_clicked.connect(main_window_controller.add_authority_clicked);
			main_window_controller.bind_property("authority-selected", authority_view, "sensitive", BindingFlags.DEFAULT | BindingFlags.SYNC_CREATE);
		}
	}
}
