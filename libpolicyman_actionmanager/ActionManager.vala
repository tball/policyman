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
			stdout.printf("Loading actions\n");
			
			Variant[] action_variants = null;
			try {
				action_variants = policy_man_helper.get_actions();
			} catch (IOError e) {
				stdout.printf("Get actions failed\n");
				actions = null;
				return false;
			}
			stdout.printf("Got actions\n");
			
			if (action_variants == null) {
				actions = null;
				return false;
			}
			
			actions = ISerializable.to_object_list<PolicyMan.Common.Action>(action_variants);
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
		
		private bool init_policyman_helper() {
			if (policy_man_helper == null) {
				stdout.printf("Initializing PolicyManHelper\n");
				// Init authorization helper
				try {
					policy_man_helper = Bus.get_proxy_sync (BusType.SYSTEM, "org.gnome.policyman.helper",
														"/org/gnome/policyman/helper");

				} catch (IOError e) {
					stdout.printf("PolicyManHelper init failed\n");
					return false;
				}
				stdout.printf("Initialized PolicyManHelper\n");
			}
			return true;
		}
	}
}
