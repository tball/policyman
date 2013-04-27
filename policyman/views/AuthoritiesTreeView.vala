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
		private ToolButton add_authority_rule_button;
		private ToolButton delete_authority_button;
		private AuthorityView authority_view;
		
		public signal void authority_edit_clicked(TreeIter ?tree_iter);
		public signal void authority_delete_clicked(TreeIter ?tree_iter);
		public signal void authority_add_clicked();
		
		public AuthoritiesTreeView() {
			GLib.Object (orientation: Gtk.Orientation.VERTICAL);
			init();
		}
		
		protected void init() {
			tree_view = new TreeView() { expand = true, headers_visible = false };
			var authority_toolbar = new Toolbar();
			var scrolled_window = new ScrolledWindow(null, null) { expand = true, shadow_type = ShadowType.IN };
			add_authority_rule_button = new ToolButton(null, null);
			delete_authority_button = new ToolButton(null, null);
			
			// Init treeview
			var title_text_cell_renderer = new CellRendererText();
			var tree_view_column = new TreeViewColumn();
			
			tree_view_column.pack_start(title_text_cell_renderer, false);
			tree_view_column.set_attributes(title_text_cell_renderer, "markup", 0, null);
			tree_view.append_column(tree_view_column);

			add_authority_rule_button.clicked.connect(add_authority_button_clicked);
			add_authority_rule_button.icon_name = "list-add-symbolic";
			delete_authority_button.clicked.connect(delete_authority_button_clicked);
			delete_authority_button.icon_name = "list-remove-symbolic";
			
			// Create view bindings
			tree_view.row_activated.connect(tree_iter_double_clicked);

			authority_toolbar.insert(add_authority_rule_button, 0);
			authority_toolbar.insert(delete_authority_button, 1);
			
			scrolled_window.add(tree_view);
			this.pack_start(scrolled_window);
			this.pack_start(authority_toolbar, false);
			
			// Init authority window
			authority_view = new AuthorityView();
		}
		
		private void tree_iter_double_clicked(TreeView tree_view, TreePath path, TreeViewColumn column) {
			TreeModel tree_model;
			TreeIter tree_iter;
			tree_view.get_selection().get_selected(out tree_model, out tree_iter);
			authority_edit_clicked(tree_iter);
			authority_view.transient_for = this.get_ancestor(typeof(Window)) as Window;
			authority_view.modal = true;
			authority_view.show_all();
		}
		
		private void add_authority_button_clicked() {
			authority_view.transient_for = this.get_ancestor(typeof(Window)) as Window;
			authority_view.modal = true;
			authority_view.show_all();
			authority_add_clicked();
		}
		
		private void delete_authority_button_clicked() {
			TreeModel tree_model;
			TreeIter tree_iter;
			tree_view.get_selection().get_selected(out tree_model, out tree_iter);
			authority_delete_clicked(tree_iter);
		}
		
		public void connect_model(IController controller) {
			var authorities_tree_store = controller as AuthoritiesTreeStore;
			if (authorities_tree_store == null) {
				return;
			}
			
			// Bind view to model
			tree_view.set_model(authorities_tree_store);
			
			//added_or_edited_authority_controller.authority_changed.connect(authority_changed);
			authority_edit_clicked.connect(authorities_tree_store.edit_authority);
			authority_add_clicked.connect(authorities_tree_store.add_authority);
			authority_delete_clicked.connect(authorities_tree_store.delete_authority);
			authority_view.connect_model(authorities_tree_store.added_or_edited_authority_controller);
			
			
			/*var explicit_overview_model = controller as AuthoritiesTreeStore;
			explicit_overview_model.bind_property("explicit-action-list-tree-store", explicit_action_tree_view, "model");
			explicit_overview_model.bind_property("can-add-or-edit-explicit-action", this, "sensitive");
			explicit_action_tree_view.model = explicit_overview_model.explicit_action_list_tree_store;
			
			// Connect view events to model
			explicit_action_tree_view.get_selection().changed.connect(explicit_overview_model.explicit_action_selection_changed);
			action_added_or_edited_rule_button_clicked.connect(explicit_overview_model.add_or_edit_explicit_action);*/
		}
	}
}
