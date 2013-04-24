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
		
		public ActionsTreeStore actions_tree_store { get; private set; default = new ActionsTreeStore(); }
		public AuthorizationsController authorizations_controller { get; private set; default = new AuthorizationsController(); }
		public string title { get; set; default = ""; }
		public string file_path { get; set; default = ""; }
		
		public AuthorityController() {
			init_bindings();
		}
		
		private void init_bindings() {
			
		}
		
		public void set_authority(Authority ?authority) {
			this.authority = authority;
			if (authority == null) {
				return;
			}
			
			title = authority.title;
			file_path = authority.file_path;
			
			authorizations_controller.set_authorizations(authority.authorizations);
			actions_tree_store.set_actions(authority.actions);
		}
		
		public void save_changes() {
			authority.title = title;
		}
	}
}
