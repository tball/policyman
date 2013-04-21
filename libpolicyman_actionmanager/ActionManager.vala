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

			Variant[] action_variants = null;
			try {
				action_variants = policy_man_helper.get_actions();
			} catch (IOError e) {
				actions = null;
				return false;
			}
			
			if (action_variants == null) {
				actions = null;
				return false;
			}
			
			actions = ISerializable.to_object_list<PolicyMan.Common.Action>(action_variants);
			
			// Attach actions to the authorities
			attach_actions_to_authorities(actions);
			
			// Attach accounts to the authorities
			attach_accounts_to_authorities(actions);
			
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
		
		private void attach_accounts_to_authorities(Gee.List<PolicyMan.Common.Action> actions) {
			// Fetch all the system accounts
			var user_accounts = AccountUtilities.get_users();
			var group_accounts = AccountUtilities.get_groups();
			Gee.List<Authority> attached_authorities = new ArrayList<Authority>();
			
			// Bind accounts to the authorities
			foreach (var action in actions) {
				foreach (var authority in action.authorities) {
					if (attached_authorities.index_of(authority) != -1) {
						continue;
					}

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
					attached_authorities.add(authority);
				}
			}
		}
		
		private void attach_actions_to_authorities(Gee.List<PolicyMan.Common.Action> actions) {
			foreach (var action in actions) {
				foreach (var authority in action.authorities) {
					authority.actions.add(action);
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
