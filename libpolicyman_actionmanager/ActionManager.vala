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

namespace PolicyMan {
	public class ActionManager {
		private IPolicyManHelper policy_man_helper = null;
		private Gee.List<PolicyMan.Common.Action> actions = null;
		
		public bool load(out Gee.List<PolicyMan.Common.Action> actions) {
			if (!init_policyman_helper()) {
				actions = null;
				return false;
			}

			Variant container_variant = null;
			try {
				container_variant = policy_man_helper.get_actions();
			} catch (IOError e) {
				actions = null;
				return false;
			}
			
			if (container_variant == null) {
				actions = null;
				return false;
			}
			
			// Create our container
			var container = new Container(null, null);
			container.from_variant(container_variant);
			actions = container.get_actions();
			if (actions == null) {
				return false;
			}
			
			// Attach accounts to the authorities
			var authorities = container.get_authorities();
			if (authorities != null) {
				attach_accounts_to_authorities(authorities);
			}
			
			return true;
		}
		
		public bool save() {
			if (actions == null || !init_policyman_helper()) {
				return false;
			}
			
			Variant[] action_variants = ISerializable.to_variant_array<PolicyMan.Common.Action>(actions);
			try {
				policy_man_helper.set_actions(action_variants);
			} catch (IOError e) {
				return false;
			}
			
			return true;
		}
		
		private void attach_accounts_to_authorities(Gee.List<Authority> authorities) {
			// Fetch all the system accounts
			var user_accounts = AccountUtilities.get_users();
			var group_accounts = AccountUtilities.get_groups();
			
			// Bind accounts to the authorities
			foreach (var authority in authorities) {
				var splitted_account_string = authority.accounts_string.split(";");
				
				foreach (var account_string in splitted_account_string) {
					string[] type_and_name = account_string.split(":");
					if (type_and_name == null || type_and_name.length != 2) {
						// Invalid
						continue;
					}
					
					var type_string = type_and_name[0];
					var user_string = type_and_name[1];
					type_string = type_string.chomp().chug();
					user_string = user_string.chomp().chug();
					
					if (type_string == "unix-group") {
						// Search for the correntsponding group
						foreach (var group_account in group_accounts) {
							if (group_account.user_name == user_string) {
								// Match!
								authority.accounts.add(group_account);
							}
						}
					}
					else if (type_string == "unix-user") {
						// Search for the correntsponding user
						foreach (var user_account in user_accounts) {
							if (user_account.user_name == user_string) {
								// Match!
								authority.accounts.add(user_account);
							}
						}
					}
				}
			}
		}
		
		private bool init_policyman_helper() {
			if (policy_man_helper == null) {
				// Init authorization helper
				try {
					policy_man_helper = Bus.get_proxy_sync (BusType.SYSTEM, "org.gnome.policyman.helper",
														"/org/gnome/policyman/helper");

				} catch (IOError e) {
					stdout.printf("PolicyManHelper init failed\n");
					return false;
				}
			}
			return true;
		}
	}
}
