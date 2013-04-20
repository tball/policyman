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
	public class Authorizations : ISerializable, Object {
		public Authorization allow_any { get; set; default = Authorization.NOT_AUTHORIZED; }
		public Authorization allow_active { get; set; default = Authorization.NOT_AUTHORIZED; }
		public Authorization allow_inactive { get; set; default = Authorization.NOT_AUTHORIZED; }
		
		public Variant to_variant() {
			var variant_arr = new Variant[]
			{
				new Variant.uint16(allow_any),
				new Variant.uint16(allow_active),
				new Variant.uint16(allow_inactive)
			};
			return new Variant.tuple(variant_arr);
		}
		public void from_variant(Variant variant) {
			allow_any = (Authorization)variant.get_child_value(0).get_uint16();
			allow_active = (Authorization)variant.get_child_value(1).get_uint16();
			allow_inactive = (Authorization)variant.get_child_value(2).get_uint16();
		}
	}
}
