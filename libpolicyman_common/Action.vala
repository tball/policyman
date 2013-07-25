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
	public class Action : ISerializable, Object {
		public string vendor { get; set; default = ""; }
		public string vendor_url { get; set; default = ""; }
		public string id { get; set; default = ""; }
		public string icon_name { get; set; default = ""; }
		public string description { get; set; default = ""; }
		public string message { get; set; default = ""; }
		public bool action_changed { get; set; default = false; }
		public Authorizations authorizations { get; set; default = new Authorizations(); }

		public void copy_to(Action dest_action) {
			dest_action.vendor = vendor;
			dest_action.vendor_url = vendor_url;
			dest_action.id = id;
			dest_action.icon_name = icon_name;
			dest_action.description = description;
			dest_action.message = message;
		}

		public void copy_from(Action src_action) {
			vendor = src_action.vendor;
			vendor_url = src_action.vendor_url;
			id = src_action.id;
			icon_name = src_action.icon_name;
			description = src_action.description;
			message = src_action.message;
		}

		public string to_string() {
			return "Action {\n id: %s\n vendor: %s\n vendor_url: %s\n icon_name: %s\n description: %s\n message: %s\n}\n".printf(id, vendor, vendor_url, icon_name, description, message);
		}
		
		public Variant to_variant() {
			var variant_arr = new Variant[] {
				new Variant.string(vendor),
				new Variant.string(vendor_url),
				new Variant.string(id),
				new Variant.string(icon_name),
				new Variant.string(description),
				new Variant.string(message),
				new Variant.boolean(action_changed)
			};
			
			return new Variant.tuple(variant_arr);
		}
		
		public void from_variant(Variant variant) {
			if (!variant.get_type().is_tuple()) {
				return;
			}
			
			vendor = variant.get_child_value(0).get_string();
			vendor_url = variant.get_child_value(1).get_string();
			id = variant.get_child_value(2).get_string();
			icon_name = variant.get_child_value(3).get_string();
			description = variant.get_child_value(4).get_string();
			message = variant.get_child_value(5).get_string();
			action_changed = variant.get_child_value(6).get_boolean();
		}
	}
}
