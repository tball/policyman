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
		public Gee.List<PolicyMan.Common.Action> actions = null;
		public Gee.List<Authority> authorities = null;
		
		public Authority create_authority() {
			var new_authority = new Authority()
			{
				title = "New Authority"
			};
			authorities.add(new_authority);
			return new_authority;
		}
		
		public void add_action_to_authority(Authority authority, PolicyMan.Common.Action action) {
			if (!authority.actions.contains(action)) {
				authority.actions.add(action);
			}
		}
		
		public bool remove_action_from_authority(Authority authority, PolicyMan.Common.Action action) {
			if (!authority.actions.contains(action)) {
				return false;
			}
			authority.actions.remove(action);
			return true;
		}
		
		
		public bool remove_authority(Authority authority) {
			if (authorities == null) {
				return false;
			}
			
			authorities.remove(authority);
			return true;
		}
		
		public bool load(out Gee.List<PolicyMan.Common.Action> actions, out Gee.List<PolicyMan.Common.Authority> authorities) {
			if (!init_policyman_helper()) {
				actions = null;
				authorities = null;
				return false;
			}

			Variant container_variant = null;
			try {
				container_variant = policy_man_helper.get_actions();
			} catch (IOError e) {
				actions = null;
				authorities = null;
				return false;
			}
			
			if (container_variant == null) {
				actions = null;
				authorities = null;
				return false;
			}
			
			// Create our container
			var container = new Container(null, null);
			container.from_variant(container_variant);
			
			actions = container.get_actions();
			if (actions == null) {
				authorities = null;
				return false;
			}
			
			// Attach accounts to the authorities
			authorities = container.get_authorities();
			attach_accounts_to_authorities(authorities);
			
			this.actions = actions;
			this.authorities = authorities;
			
			return true;
		}
		
		public bool save() {
			if (!init_policyman_helper()) {
				return false;
			}
			
			generate_accounts_strings(authorities);
			var container = new Container(actions, authorities);
			try {
				stdout.printf("Saving actions\n");
				policy_man_helper.set_actions(container.to_variant());
			} catch (IOError e) {
				stdout.printf("Saving actions failed: " + e.message + "\n");
				return false;
			}
			
			return true;
		}
		
		private void generate_accounts_strings(Gee.List<Authority> authorities) {
			foreach (var authority in authorities) {
				authority.accounts_string = "";
				foreach (var account in authority.accounts) {
					authority.accounts_string += (account.account_type == AccountType.LINUX_USER ? "unix-user" : "unix-group") + ":" + account.user_name + ";";
				}
			}
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
					policy_man_helper = Bus.get_proxy_sync (BusType.SYSTEM, "org.freedesktop.policyman.helper",
														"/org/freedesktop/policyman/helper");

				} catch (IOError e) {
					stdout.printf("PolicyManHelper init failed\n");
					return false;
				}
			}
			return true;
		}
	}
}
