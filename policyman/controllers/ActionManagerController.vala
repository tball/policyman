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

using Gee;
using PolicyMan.Common;

namespace PolicyMan.Controllers {
	public class ActionManagerController : Object, IController {
		private ActionManager action_manager;
		private Gee.List<PolicyMan.Common.Action> actions;
		private Gee.List<PolicyMan.Common.Authority> authorities;
		public signal void actions_changed(Gee.List<PolicyMan.Common.Action> ?actions);
		public signal void action_changed(PolicyMan.Common.Action action);
		public signal void authority_changed(Authority authority);
		public signal void authority_added(Authority authority);
		public signal void authority_removed(Authority authority);
		public signal void authority_added_to_action(PolicyMan.Common.Action action, Authority authority);
		public signal void authority_removed_from_action(PolicyMan.Common.Action action, Authority authority);
		
		public ActionManagerController() {

		}
		
		public void init() {
			action_manager = new ActionManager();
			if (!action_manager.load(out actions, out authorities)) {
				return;
			}
			
			actions_changed(actions);
			
			foreach (var authority in authorities) {
				authority_added(authority);
			}
		}
		
		public void delete_authority(Authority authority) {
			if (action_manager.remove_authority(authority)) {
				authority_removed(authority);
			}
		}
		
		public Authority create_authority() {
			var new_authority = action_manager.create_authority();
			authority_added(new_authority);
			return new_authority;
		}
		
		public void add_action_to_authority(Authority authority, PolicyMan.Common.Action action) {
			action_manager.add_action_to_authority(authority, action);
		}
		
		public void remove_action_from_authority(Authority authority, PolicyMan.Common.Action action) {
			action_manager.remove_action_from_authority(authority, action);
		}
		
		
		public void force_action_update(PolicyMan.Common.Action action) {
			action_changed(action);
		}
		
		public void force_authority_update(Authority authority) {
			authority_changed(authority);
		}
		
		public void save_changes() {
			if (!action_manager.save()) {
				stdout.printf("Saving actions failed\n");
			}
		}
		
		public void close() {
			Gtk.main_quit();
		}
	}
}
