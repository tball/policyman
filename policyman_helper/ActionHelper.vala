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
using Xml;
using Polkit;
using PolicyMan.Common;

namespace PolicyMan {
	[DBus (name = "org.gnome.policyman.helper")]
	public class PolicyManHelper : Object {
		public Variant[] get_actions(BusName bus_name) throws GLib.Error {
			stdout.printf("Fetching actions\n");
			// Check permissions
			string error_str;
			if (!grant_permission(bus_name, "org.gnome.policyman.GetActions", out error_str)) {
				throw new PolicyManHelperError.SOME_ERROR("Cannot get actions due to the following error: " + error_str);
			}
			stdout.printf("Permission granted\n");
			
			// Fetch actions
			var authority = Polkit.Authority.get_sync();
			GLib.List<Polkit.ActionDescription> action_descriptors;
			try {
				action_descriptors = authority.enumerate_actions_sync(null);
			}
			catch(GLib.Error err) {
				throw new PolicyManHelperError.SOME_ERROR("Could not enumerate actions.");
			}
			stdout.printf("Fetched %d actions\n", (int)action_descriptors.length());
			
			// Convert action to our own format
			Gee.List<Variant> action_variants = new ArrayList<Variant>();
			var i = 0;
			foreach (Polkit.ActionDescription action_desc in action_descriptors) {
				if (action_desc == null) {
					continue;
				}
				
				var action = create_action_from_action_description(action_desc);
				
				var action_variant = action.to_variant();
				action_variants.add(action_variant);
				i++;
			}
			stdout.printf("Converted %d actions\n", i);
			
			return action_variants.to_array();
		}
		
		public void set_actions(Variant[] action_variants, BusName bus_name) throws GLib.Error {
			
		}
		
		private static Authorization get_authorization_from_impl(ImplicitAuthorization implicit_authorization) {
			switch(implicit_authorization) {
				case ImplicitAuthorization.NOT_AUTHORIZED:
					return Authorization.NOT_AUTHORIZED;
				case ImplicitAuthorization.AUTHENTICATION_REQUIRED:
					return Authorization.AUTHENTICATION_REQUIRED;
				case ImplicitAuthorization.ADMINISTRATOR_AUTHENTICATION_REQUIRED:
					return Authorization.ADMINISTRATOR_AUTHENTICATION_REQUIRED;
				case ImplicitAuthorization.AUTHENTICATION_REQUIRED_RETAINED:
					return Authorization.AUTHENTICATION_REQUIRED_RETAINED;
				case ImplicitAuthorization.ADMINISTRATOR_AUTHENTICATION_REQUIRED_RETAINED:
					return Authorization.ADMINISTRATOR_AUTHENTICATION_REQUIRED_RETAINED;
				case ImplicitAuthorization.AUTHORIZED:
					return Authorization.AUTHORIZED;
				default:
					return Authorization.NOT_AUTHORIZED;
			}
		}
		
		private static PolicyMan.Common.Action create_action_from_action_description(Polkit.ActionDescription action_description) {
			var action = new PolicyMan.Common.Action() {
				vendor = action_description.get_vendor_name(),
				vendor_url = action_description.get_vendor_url(),
				id = action_description.get_action_id(),
				icon_name = action_description.get_icon_name(),
				description = action_description.get_description(),
				message = action_description.get_message(),
				authorizations = new Authorizations() {
					allow_any = get_authorization_from_impl(action_description.get_implicit_any()),
					allow_active = get_authorization_from_impl(action_description.get_implicit_active()),
					allow_inactive = get_authorization_from_impl(action_description.get_implicit_inactive())
				}
			};
			
			return action;
		}
		
		private static bool grant_permission(string bus_name, string action_id, out string error) throws GLib.Error  {
			AuthorizationResult result;
			try {
				var authority = Polkit.Authority.get_sync();
				var subject = SystemBusName.new(bus_name);
				result = authority.check_authorization_sync(subject, action_id, null, CheckAuthorizationFlags.ALLOW_USER_INTERACTION, null);
			}
			catch(GLib.Error err) {
				error = err.message;
				return false;
			}

			if (!result.get_is_authorized ()) {
				error = "Unauthorized";
				return false;
			}
			
			error = "";
			return true;
		}
	}

	[DBus (name = "org.gnome.policyman.PolicyManHelperError")]
	public errordomain PolicyManHelperError
	{
		SOME_ERROR
	}

	void on_bus_aquired (DBusConnection conn) {
		try {
			conn.register_object ("/org/gnome/policyman/helper", new PolicyManHelper());
		}
		catch (IOError e) {
			stderr.printf ("Could not register service\n");
		}
	}

	void main() {
		Bus.own_name (BusType.SYSTEM, "org.gnome.policyman.helper", BusNameOwnerFlags.NONE,
					  on_bus_aquired,
					  () => {},
					  () => stderr.printf ("Could not aquire name\n"));

		new MainLoop ().run ();
	}
}
