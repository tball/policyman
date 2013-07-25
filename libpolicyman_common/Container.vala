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
 
namespace PolicyMan.Common {
	public class Container : Object, ISerializable {
		private Gee.List<Action> actions;
		private Gee.List<Authority> authorities;
		private bool actions_attached_to_authorities = false;
		
		public Container(Gee.List<Action> ?actions, Gee.List<Authority> ?authorities) {
			this.actions = actions;
			this.authorities = authorities;
		}
		
		public Gee.List<Action> ?get_actions() {
			if (actions == null) {
				return null;
			}
			attach_actions_to_authorities();
		
			return actions;
		}
		
		public Gee.List<Authority> ?get_authorities() {
			if (authorities == null) {
				return null;
			}
			attach_actions_to_authorities();
			
			return authorities;
		}
		
		private void generate_actions_strings_for_authorities() {
			if (authorities == null) {
				return;
			}

			foreach (var authority in authorities) {
				authority.actions_string = "";
				if (authority.actions == null) {
					continue;
				}
				if (authority.actions.size <= 0) {
					continue;
				}
				for (var index = 0; index < authority.actions.size; index++) {
					var action = authority.actions[index];
					authority.actions_string += action.id + ";";
				}
			}
		}
		
		public void attach_actions_to_authorities() {
			if (authorities == null || actions == null || actions_attached_to_authorities) {
				return;
			}
			
			// Here we are going to attach the authorities to the actions
			foreach(var authority in authorities) {
				foreach(var action in actions) {
					// TODO: Create smarter parsing of the actions_string (including wildcards etc.)
					if (authority.actions_string.contains(action.id)) {
						authority.actions.add(action);
					}
				}
			}
			
			actions_attached_to_authorities = true;
		}
		
		public Variant to_variant() {
			generate_actions_strings_for_authorities();
			var action_variant_array = ISerializable.to_variant_array<Action>(actions);
			var authority_variant_array = ISerializable.to_variant_array<Authority>(authorities);
			
			return new Variant.tuple(new Variant[] { action_variant_array, authority_variant_array });
		}
		
		public void from_variant(Variant variant) {
			var action_variant_array = variant.get_child_value(0) as Variant[];
			var authority_variant_array = variant.get_child_value(1) as Variant[];
			actions = ISerializable.to_object_list<Action>(action_variant_array);
			authorities = ISerializable.to_object_list<Authority>(authority_variant_array);
			attach_actions_to_authorities();
		}
	}
}
