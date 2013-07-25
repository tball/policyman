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
	public class AuthoritiesTreeView : Box, IBaseView {
		private TreeView tree_view;
		public signal void tree_iter_edited(TreeIter ?tree_iter);
		
		public AuthoritiesTreeView() {
			GLib.Object (orientation: Gtk.Orientation.VERTICAL);
			init();
		}
		
		protected void init() {
			tree_view = new TreeView() { expand = true, headers_visible = false };
			var scrolled_window = new ScrolledWindow(null, null) { expand = true, shadow_type = ShadowType.IN };
			
			// Init treeview
			var title_text_cell_renderer = new CellRendererText();
			var tree_view_column = new TreeViewColumn();
			
			tree_view_column.pack_start(title_text_cell_renderer, false);
			tree_view_column.set_attributes(title_text_cell_renderer, "markup", 0, null);
			tree_view.append_column(tree_view_column);
			
			// Create view bindings
			tree_view.row_activated.connect(tree_iter_double_clicked);

			scrolled_window.add(tree_view);
			this.pack_start(scrolled_window);
		}
		
		private void tree_iter_double_clicked(TreeView tree_view, TreePath path, TreeViewColumn column) {
			TreeModel tree_model;
			TreeIter tree_iter;
			tree_view.get_selection().get_selected(out tree_model, out tree_iter);
			tree_iter_edited(tree_iter);
		}
		
		public TreeIter get_selected_tree_iter() {
			TreeModel tree_model;
			TreeIter tree_iter;
			tree_view.get_selection().get_selected(out tree_model, out tree_iter);
			return tree_iter;
		}
				
		public void connect_model(IController controller) {
			var authorities_tree_store = controller as AuthoritiesTreeStore;
			if (authorities_tree_store == null) {
				return;
			}
			
			// Bind view to model
			tree_view.set_model(authorities_tree_store);
			
			// Bind model to events from view
			tree_view.get_selection().changed.connect((sender) => {
				TreeModel tree_model;
				TreeIter tree_iter; 
				if (tree_view.get_selection().get_selected(out tree_model, out tree_iter)) {
					authorities_tree_store.select_authority_tree_iter(tree_iter);
				}
			});
		}
	}
}
