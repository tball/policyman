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

namespace PolicyMan.Controllers {
	public class ActionController : IController, Object {
		private PolicyMan.Common.Action action = null;
		private ActionManagerController action_manager_controller { get; private set; }
		
		public AuthorityController added_or_edited_authority_controller { get; private set; }
		public AuthorizationsController authorizations_controller { get; private set; default = new AuthorizationsController(); }
		public AuthoritiesTreeStore authorities_tree_store { get; private set; }
		public string vendor { get; set; default = ""; }
		public string vendor_url { get; set; default = ""; }
		public string icon_name { get; set; default = ""; }
		public string description { get; set; default = ""; }
		public string message { get; set; default = ""; }
		public bool action_selected { get; set; default = false; }
		
		public ActionController(ActionManagerController action_manager_controller) {
			this.action_manager_controller = action_manager_controller;
			this.authorities_tree_store = new AuthoritiesTreeStore(action_manager_controller);
			this.added_or_edited_authority_controller = new AuthorityController(action_manager_controller); 
			init_bindings();
		}
		
		private void init_bindings() {
			action_manager_controller.action_changed.connect(on_action_changed);
			//added_or_edited_authority_controller
		}
		
		public void on_action_changed(PolicyMan.Common.Action action) {
			// Only update the shown action, if its the one changed
			if (this.action == action) {
				update_action();
			}
		}
		
		public void update_action() {
			vendor = action != null ? action.vendor : "";
			vendor_url = action != null ? action.vendor_url : "";
			icon_name = action != null ? action.icon_name : "";
			description = action != null ? action.description : "";
			message = action != null ? action.message : "";
		}
		
		public void set_action(PolicyMan.Common.Action ?action) {
			this.action = action;
			if (action == null) {
				action_selected = false;
				return;
			}
			
			update_action();
			
			authorizations_controller.set_authorizations(action != null ? action.authorizations : new Authorizations());
			action_selected = true;
		}
		
		public void set_selectable_actions(Gee.List<PolicyMan.Common.Action> ?actions) {
			added_or_edited_authority_controller.set_selectable_actions(actions);
		}
		
		
		public void delete_authority(TreeIter ?tree_iter) {
			if (tree_iter == null) {
				return;
			}
			
			Value authority_value;
			authorities_tree_store.get_value(tree_iter, AuthoritiesTreeStore.ColumnTypes.OBJECT, out authority_value);
			var deleted_authority = authority_value.get_object() as PolicyMan.Common.Authority;
			if (deleted_authority == null) {
				return;
			}

			//remove(ref tree_iter);
			//gtk_tree_store_remove(this, (TreeIter *)tree_iter);
		}
	}
}
