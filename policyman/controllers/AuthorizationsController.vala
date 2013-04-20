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
	public class AuthorizationsController : Object, IController {
		private Authorizations authorizations = null;
		public AuthorizationTreeStore allow_any_authorization_tree_store { private set; get; default = new AuthorizationTreeStore(); }
		public AuthorizationTreeStore allow_active_authorization_tree_store { private set; get; default = new AuthorizationTreeStore(); }
		public AuthorizationTreeStore allow_inactive_authorization_tree_store { private set; get; default = new AuthorizationTreeStore(); }
		
		public AuthorizationsController() {
			init_bindings();
		}
		
		private void init_bindings() {
			allow_any_authorization_tree_store.authorization_selected.connect(allow_any_authorization_selected);
			allow_active_authorization_tree_store.authorization_selected.connect(allow_active_authorization_selected);
			allow_inactive_authorization_tree_store.authorization_selected.connect(allow_inactive_authorization_selected);
		}
		
		public void set_authorizations(Authorizations authorizations) {
			this.authorizations = authorizations;
			
			allow_any_authorization_tree_store.select_authorization(authorizations.allow_any);
			allow_active_authorization_tree_store.select_authorization(authorizations.allow_active);
			allow_inactive_authorization_tree_store.select_authorization(authorizations.allow_inactive);
		}
		
		public void allow_any_authorization_selected(Authorization authorization) {
			if (authorizations != null) {
				authorizations.allow_any = authorization;
			}
		}
		
		public void allow_active_authorization_selected(Authorization authorization) {
			if (authorizations != null) {
				authorizations.allow_active = authorization;
			}
		}
		
		public void allow_inactive_authorization_selected(Authorization authorization) {
			if (authorizations != null) {
				authorizations.allow_inactive = authorization;
			}
		}
	}
}
