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
	public class MainWindowController : Object, IController {
		public AuthorityController authority_controller { get; private set; }
		public AuthoritiesTreeStore authorities_tree_store { get; private set; }
		public ActionManagerController action_manager_controller { get; private set; }
		public bool authority_selected { get; private set; default = false; }
		
		public MainWindowController(ActionManagerController action_manager_controller) {
			this.action_manager_controller = action_manager_controller;
			authority_controller = new AuthorityController(action_manager_controller);
			authorities_tree_store = new AuthoritiesTreeStore(action_manager_controller);
			
			init_bindings();
		}
		
		private void init_bindings() {
			action_manager_controller.authority_added.connect(authorities_tree_store.add_authority);
			action_manager_controller.authority_removed.connect(authorities_tree_store.remove_authority);
			action_manager_controller.authority_changed.connect(authorities_tree_store.on_authority_changed);
			action_manager_controller.actions_changed.connect(authority_controller.set_selectable_actions);
			authorities_tree_store.authority_selected.connect(authority_controller.set_authority);
			authorities_tree_store.authority_selected.connect(on_authority_selected);
		}
		
		public void delete_authority_clicked(TreeIter ?tree_iter) {
			// Get the deleted authority
			Value authority_value;
			authorities_tree_store.get_value(tree_iter, AuthoritiesTreeStore.ColumnTypes.OBJECT, out authority_value);
			var deleted_authority = authority_value.get_object() as PolicyMan.Common.Authority;
			
			action_manager_controller.delete_authority(deleted_authority);
		}
		
		private void on_authority_selected(Authority authority) {
			authority_selected = authority != null;
		}
		
		public void add_authority_clicked() {
			action_manager_controller.create_authority();
		}
		
		public void reload_authority_tree_store() {
			
		}
		
		public void on_save_changes() {
			action_manager_controller.save_changes();
		}
	}
}
