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
		
		private Gee.List<Authority> authorities = null;
		public AuthorityController added_or_edited_authority_controller { get; private set; default = new AuthorityController(); }
		
		public AuthoritiesTreeStore() {
			set_column_types(new Type[] {typeof(string), typeof(Authority)});
			
			init_bindings();
		}
		
		private void init_bindings() {
			added_or_edited_authority_controller.authority_changed.connect(added_or_edited_authority_changed);
		}
		
		public void added_or_edited_authority_changed(Authority authority) {
			// Check if the authority already exists in our list
			var authority_already_exists = true;
			if (authorities.index_of(authority) < 0) {
				authority_already_exists = false;
			}
			
			// Search for the authority and update the TreeStore data accordingly
			if (authority_already_exists) {
				TreeIter tree_iter;
				if (!get_iter_first(out tree_iter)) {
					return;
				}
				
				do {
					Value val;
					get_value(tree_iter, ColumnTypes.OBJECT, out val);
					if (val.get_object() as Authority == authority ) {
						var tree_path = get_path( tree_iter );
						if (tree_path != null) {
							authority_already_exists = true;
							set_tree_iter_data(tree_iter, authority);
						}
					}
				} while (iter_next(ref tree_iter));
			}
			// The authority does not exist, so we must create a new one
			else {
				authorities.add(authority);
				TreeIter root;
				append(out root, null);
				set_tree_iter_data(root, authority);
			}
		}
		
		public void add_authority() {
			var new_authority = new Authority();
			added_or_edited_authority_controller.set_authority(new_authority);
		}
		
		public void delete_authority(TreeIter ?tree_iter) {
			if (tree_iter == null) {
				return;
			}
			
			Value authority_value;
			get_value(tree_iter, ColumnTypes.OBJECT, out authority_value);
			var deleted_authority = authority_value.get_object() as PolicyMan.Common.Authority;
			if (deleted_authority == null) {
				return;
			}
			
			// Delete the authority
			authorities.remove(deleted_authority);
			//remove(ref tree_iter);
			gtk_tree_store_remove(this, (TreeIter *)tree_iter);
		}
		
		public void edit_authority(TreeIter ?tree_iter) {
			Value authority_value;
			get_value(tree_iter, ColumnTypes.OBJECT, out authority_value);
			var edited_authority = authority_value.get_object() as PolicyMan.Common.Authority;
			
			// Lets edit the authority
			added_or_edited_authority_controller.set_authority(edited_authority);
		}
		
		public void set_authorities(Gee.List<Authority> ?authorities) {
			this.authorities = authorities;
			clear();
			
			if (authorities == null) {
				return;
			}

			// Parse policies			
			foreach (var authority in authorities) {
				foreach(var account in authority.accounts) {
					stdout.printf((account.account_type == AccountType.LINUX_USER ? " user = " : " group = ") + account.user_name + "\n");
				}
				
				TreeIter root;
				append(out root, null);
				set_tree_iter_data(root, authority);
			}
		}
		
		public void set_selectable_actions(Gee.List<PolicyMan.Common.Action> ?actions) {
			added_or_edited_authority_controller.set_selectable_actions(actions);
		}
		
		private void set_tree_iter_data(TreeIter tree_iter, Authority authority) {
			set(tree_iter, ColumnTypes.TITLE, "<b>" + authority.title + "</b>, " + "(Allow any: " + authority.authorizations.allow_any.to_string() + ", Allow active: " + authority.authorizations.allow_active.to_string() + ", Allow inactive: " + authority.authorizations.allow_inactive.to_string() + ")", ColumnTypes.OBJECT, authority, -1);
		}
	}
}
