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

namespace PolicyMan.Common {
	public class Account : ISerializable, Object {
		public string user_name { get; set; default = ""; }
		public string full_name { get; set; default = ""; }
		public AccountType account_type { get; set; default = AccountType.LINUX_USER; }
		
		public Variant to_variant() {
			var variant_arr = new Variant[] {
				new Variant.string(user_name),
				new Variant.string(full_name),
				new Variant.uint16(account_type)
			};
			
			return new Variant.tuple(variant_arr);
		}
		
		public void from_variant(Variant variant) {
			if (!variant.get_type().is_tuple()) {
				return;
			}
			
			user_name = variant.get_child_value(0).get_string();
			full_name = variant.get_child_value(1).get_string();
			account_type = (AccountType)variant.get_child_value(2).get_uint16();
		}
	}
}
