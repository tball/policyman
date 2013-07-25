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
	 public class SelectableActionTreeView : ActionTreeView {
		 private CellRendererToggle toggle_cell_rendere = new CellRendererToggle();
		 public SelectableActionTreeView() {
			 GLib.Object (width_request : 80,
						  shadow_type : ShadowType.IN);
			 base.init();
			 init();
		 }
		 
		 public override void connect_model(IController controller) {
			var actions_tree_store = controller as SelectableActionsTreeStore;
			if (actions_tree_store == null) {
				return;
			}
			
			toggle_cell_rendere.toggled.connect(actions_tree_store.toggle_selection_on_tree_path_string);
			
			// Connect base model
			base.connect_model(actions_tree_store);
		}
		
		private new void init() {
			var checkbox_column = new TreeViewColumn() {
				sizing = TreeViewColumnSizing.AUTOSIZE,
				expand = false
			};
			checkbox_column.title = "Selected";
			
			toggle_cell_rendere = new CellRendererToggle();
			checkbox_column.pack_start(toggle_cell_rendere, false);
			checkbox_column.set_attributes(toggle_cell_rendere, "inconsistent", SelectableActionsTreeStore.SelectableColumnTypes.INCONSISTENT, "active", SelectableActionsTreeStore.SelectableColumnTypes.SELECTED, null);
			tree_view.append_column(checkbox_column);
		}
	}
}
