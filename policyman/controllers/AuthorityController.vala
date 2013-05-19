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

using PolicyMan.Common;

namespace PolicyMan.Controllers {
	public class AuthorityController : Object, IController {
		private Authority authority = null;
		
		public signal void authority_changed(Authority authority);
		public SelectableActionsTreeStore actions_tree_store { get; private set; default = new SelectableActionsTreeStore(); }
		public AuthorizationsController authorizations_controller { get; private set; default = new AuthorizationsController(); }
		public AccountsTreeStore accounts_tree_store { get; private set; default = new AccountsTreeStore(); }
		public string title { get; set; default = ""; }
		public string file_path { get; set; default = ""; }
		
		public AuthorityController() {
			init_bindings();
		}
		
		private void init_bindings() {
			actions_tree_store.selectable_action_selected.connect(add_action);
			actions_tree_store.selectable_action_deselected.connect(remove_action);
		}
		
		public void set_authority(Authority ?authority) {
			this.authority = authority;
			if (authority == null) {
				return;
			}
			
			title = authority.title;
			file_path = authority.file_path;
			
			authorizations_controller.set_authorizations(authority.authorizations);
			actions_tree_store.set_selected_actions(authority.actions);
			accounts_tree_store.set_accounts(authority.accounts);
		}
		
		public void save_changes() {
			authority.title = title;
			
			// Save accounts
			authority.accounts.clear();
			foreach(var account in accounts_tree_store.selected_accounts) {
				authority.accounts.add(account);
			}
			
			// Save selected actions
			
			authority_changed(authority);
		}
		
		public void set_selectable_actions(Gee.List<PolicyMan.Common.Action> ?actions) {
			actions_tree_store.set_actions(actions);
		}
		
		public void add_action(PolicyMan.Common.Action action) {
			if (authority == null) {
				return;
			}
			
			authority.actions.add(action);
		}
		
		public void remove_action(PolicyMan.Common.Action action) {
			if (authority == null) {
				return;
			}
			
			authority.actions.remove(action);
		}
	}
}
