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
	public class TopToolbarView : Toolbar, IBaseView {
		private Entry search_entry;
		private ToolButton save_tool_button;
		
		public signal void search_string_changed(string search_string);
		public signal void save_changes_button_clicked();
		
		public TopToolbarView() {
			GLib.Object (hexpand : true,
						 vexpand : false
						 );
			init();
		}
		
		protected void init() {
			get_style_context().add_class(STYLE_CLASS_PRIMARY_TOOLBAR);
			
			search_entry = new Entry() { margin = 4 };
			save_tool_button = new ToolButton(null, null) { expand = false, margin = 4 };
			
			search_entry.changed.connect((sender) => { search_string_changed(search_entry.text); });
			save_tool_button.clicked.connect((sender) => { save_changes_button_clicked(); });
			search_entry.secondary_icon_name = "edit-find-symbolic";
			//save_tool_button.height_request = 35;
			//save_tool_button.width_request = 35;
			save_tool_button.icon_name = "document-save-symbolic";
			save_tool_button.tooltip_text = "Save changes";
			
			//v_tool_bar_item_box.pack_start(save_button);
			//v_tool_bar_item_box.pack_start(search_entry);
			
			var separator_tool_item = new SeparatorToolItem() { draw = false, expand = true };
			var search_entry_tool_item = new ToolItem();
			//var tool_item = new ToolItem();
			//tool_item.add(v_tool_bar_item_box);
			search_entry_tool_item.add(search_entry);
			this.insert(save_tool_button, 0);
			this.insert(separator_tool_item, 1);
			this.insert(search_entry_tool_item, 2);
			//this.insert(tool_item, 0);
		}
		
		public void connect_model(IController controller) {
			var main_window_controller = controller as MainWindowController;
			
			// Bind to the model properties
			search_string_changed.connect(main_window_controller.authorities_tree_store.on_search_string_changed);
			save_changes_button_clicked.connect(main_window_controller.on_save_changes);
		}
	}
}
