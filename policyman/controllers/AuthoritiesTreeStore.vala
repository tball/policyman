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
using PolicyMan.Common;
using PolicyMan.Views;

// The following is a workaround for a bug in vala 0.18.1.
[CCode (cname = "gtk_tree_store_remove")]
private static extern bool gtk_tree_store_remove(Gtk.TreeStore store, Gtk.TreeIter* iter);

namespace PolicyMan.Controllers {
	public class AuthoritiesTreeStore : TreeStore, IController {
		public enum ColumnTypes {
			TITLE = 0,
			OBJECT
		}
		
		public signal void authority_selected(PolicyMan.Common.Authority authority);
		public TreeModelFilter tree_store_filter { get; private set; }

		private ActionManagerController action_manager_controller { get; private set; }
		private string search_string = "";

		public AuthoritiesTreeStore(ActionManagerController action_manager_controller) {
			this.action_manager_controller = action_manager_controller;

			set_column_types(new Type[] {typeof(string), typeof(Authority)});
			
			tree_store_filter = new TreeModelFilter(this, null);
			tree_store_filter.set_visible_func(visibility_func);
			
			init_bindings();
		}
		
		private bool visibility_func(TreeModel model, TreeIter iter) {
			if (search_string == "") {
				// Search aborted
				return true;	
			}
			
			var lower_case_filter_string = search_string.down();
			
			// Get current title
			Value authority_title_value;
			model.get_value(iter, ColumnTypes.TITLE, out authority_title_value);
			var authority_title = authority_title_value.get_string().down();
			
			return authority_title.contains(lower_case_filter_string);
		}
		
		private void init_bindings() {
			action_manager_controller.authority_changed.connect(on_authority_changed);
		}
		
		public void on_search_string_changed(string search_string) {
			this.search_string = search_string;
			tree_store_filter.refilter();
		}

		public void on_authority_changed(Authority authority) {
			// Search for the authority and update the TreeStore data accordingly
			var tree_iter = get_tree_iter_from_authority(authority);
			if (tree_iter != null) {
				set_tree_iter_data(tree_iter, authority);
			}
		}
		
		private TreeIter ?get_tree_iter_from_authority(Authority authority) {
			// Search for the authority and update the TreeStore data accordingly
			TreeIter tree_iter;
			if (!get_iter_first(out tree_iter)) {
				return null;
			}
			
			do {
				Value val;
				get_value(tree_iter, ColumnTypes.OBJECT, out val);
				if (val.get_object() as Authority == authority ) {
					var tree_path = get_path( tree_iter );
					if (tree_path != null) {
						return tree_iter;
					}
				}
			} while (iter_next(ref tree_iter));
			
			return null;
		}
		
		public void add_authority(Authority authority) {
			TreeIter root;
			append(out root, null);
			set_tree_iter_data(root, authority);
		}
		
		public void remove_authority(Authority authority) {
			// Search for our Authority and remove it from our TreeStore
			var tree_iter = get_tree_iter_from_authority(authority);
			if (tree_iter != null) {
				gtk_tree_store_remove(this, (TreeIter*)tree_iter);
			}
		}
		
		public void select_authority_tree_iter(TreeIter tree_iter) {
			// Get the selected authority
			Value authority_value;
			tree_store_filter.get_value(tree_iter, AuthoritiesTreeStore.ColumnTypes.OBJECT, out authority_value);
			var selected_authority = authority_value.get_object() as PolicyMan.Common.Authority;

			authority_selected(selected_authority);
		}
		
		private void set_tree_iter_data(TreeIter tree_iter, Authority authority) {
			set(tree_iter, ColumnTypes.TITLE, "<b>" + authority.title + "</b>, " + "(Allow any: " + authority.authorizations.allow_any.to_string() + ", Allow active: " + authority.authorizations.allow_active.to_string() + ", Allow inactive: " + authority.authorizations.allow_inactive.to_string() + ")", ColumnTypes.OBJECT, authority, -1);
		}
	}
}
