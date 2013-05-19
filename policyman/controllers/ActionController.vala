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
	public class ActionController : IController, Object {
		private PolicyMan.Common.Action action = null;
		
		public AuthorizationsController authorizations_controller { get; private set; default = new AuthorizationsController(); }
		public AuthoritiesTreeStore authorities_tree_store { get; private set; default = new AuthoritiesTreeStore(); }
		public string vendor { get; set; default = ""; }
		public string vendor_url { get; set; default = ""; }
		public string icon_name { get; set; default = ""; }
		public string description { get; set; default = ""; }
		public string message { get; set; default = ""; }
		public bool action_selected { get; set; default = false; }
		
		public ActionController() {
			init_bindings();
		}
		
		private void init_bindings() {
			authorizations_controller.authorizations_changed.connect((sender) => { if ( action != null ) action.action_changed = true; });
		}
		
		public void set_action(PolicyMan.Common.Action ?action) {
			this.action = action;
			if (action == null) {
				action_selected = false;
				return;
			}
			
			vendor = action != null ? action.vendor : "";
			vendor_url = action != null ? action.vendor_url : "";
			icon_name = action != null ? action.icon_name : "";
			description = action != null ? action.description : "";
			message = action != null ? action.message : "";
			
			authorizations_controller.set_authorizations(action != null ? action.authorizations : new Authorizations());
			authorities_tree_store.set_authorities(action.authorities);
			action_selected = true;
		}
		
		public void set_selectable_actions(Gee.List<PolicyMan.Common.Action> ?actions) {
			authorities_tree_store.set_selectable_actions(actions);
		}
	}
}
