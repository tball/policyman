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

namespace PolicyMan.Controllers {
	public class ActionController : IController, Object {
		public AuthorizationTreeStore allow_any_authorization_tree_store { get; private set; default = new AuthorizationTreeStore(); }
		public AuthorizationTreeStore allow_active_authorization_tree_store { get; private set; default = new AuthorizationTreeStore(); }
		public AuthorizationTreeStore allow_inactive_authorization_tree_store { get; private set; default = new AuthorizationTreeStore(); }
		
		public string vendor { get; set; default = ""; }
		public string vendor_url { get; set; default = ""; }
		public string icon_name { get; set; default = ""; }
		public string description { get; set; default = ""; }
		public string message { get; set; default = ""; }
		
		public ActionController() {
			init_bindings();
		}
		
		private void init_bindings() {
			
		}
		
		public void set_action(PolicyMan.Common.Action action) {
			vendor = action.vendor;
			vendor_url = action.vendor_url;
			icon_name = action.icon_name;
			description = action.description;
			message = action.message;
			
			allow_any_authorization_tree_store.set_authorization(action.authorizations.allow_any);
			allow_active_authorization_tree_store.set_authorization(action.authorizations.allow_active);
			allow_inactive_authorization_tree_store.set_authorization(action.authorizations.allow_inactive);
		}
	}
}
