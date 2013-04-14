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
	public class Authority : ISerializable, Object {
		public string title { get; set; default = ""; }
		public string file_path { get; set; default = ""; }
		public Authorizations authorizations { get; set; default = new Authorizations(); }
		public Gee.List<Action> actions { get; set; default = new ArrayList<Action>(); }
		public Gee.List<Account> accounts { get; set; default = new ArrayList<Account>(); }
		
		public Variant to_variant() {
			Gee.List<Variant> action_variants = new ArrayList<Variant>();
			foreach(var action in actions) {
				action_variants.add(action.to_variant());
			}
			Gee.List<Variant> account_variants = new ArrayList<Variant>();
			foreach(var account in accounts) {
				account_variants.add(account.to_variant());
			}
			
			var variant_arr = new Variant[] {
				new Variant.string(title),
				new Variant.string(file_path),
				authorizations.to_variant(),
				action_variants.to_array(),
				account_variants.to_array()
			};
			return new Variant.tuple(variant_arr);
		}
		
		public void from_variant(Variant variant) {
			title = variant.get_child_value(0).get_string();
			file_path = variant.get_child_value(1).get_string();
			authorizations = (Authorizations)variant.get_child_value(2).get_uint16();
			
			var action_variant_arr = variant.get_child_value(3);
			foreach(var action_variant in action_variant_arr) {
				var new_action = new Action();
				new_action.from_variant(action_variant);
				actions.add(new_action);
			}
			
			var account_variant_arr = variant.get_child_value(4);
			foreach(var account_variant in account_variant_arr) {
				var new_account = new Account();
				new_account.from_variant(account_variant);
				accounts.add(new_account);
			}
		}
	}
}
