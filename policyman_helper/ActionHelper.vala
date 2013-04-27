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
	public static string last_of_string_array(string[] str_array)
	{
		return str_array[str_array.length - 1];
	}
	
	[DBus (name = "org.gnome.policyman.helper")]
	public class PolicyManHelper : Object {
		public Variant get_actions(BusName bus_name) throws GLib.Error {
			// Check permissions
			string error_str;
			if (!grant_permission(bus_name, "org.gnome.policyman.GetActions", out error_str)) {
				throw new PolicyManHelperError.SOME_ERROR("Cannot get actions due to the following error: " + error_str);
			}
			
			// Fetch actions
			var polkit_authority = Polkit.Authority.get_sync();
			GLib.List<Polkit.ActionDescription> action_descriptors;
			try {
				action_descriptors = polkit_authority.enumerate_actions_sync(null);
			}
			catch(GLib.Error err) {
				throw new PolicyManHelperError.SOME_ERROR("Could not enumerate actions.");
			}
			
			// Fetch authorities
			var authorities = get_authorities();

			// Convert action to our own format
			var actions = new ArrayList<PolicyMan.Common.Action>();
			for (var i = 0; i < action_descriptors.length(); i++) {
				var action_desc = action_descriptors.nth_data(i);
				if (action_desc == null) {
					continue;
				}
				var action = create_action_from_action_description(action_desc);
				actions.add(action);
			}
			
			// Create container, which we will sent to our client
			var container = new Container(actions, authorities);
			
			return container.to_variant();
		}
		
		private Gee.List<PolicyMan.Common.Authority> get_authorities() {
			// Search for possible policy files
			Gee.List<PolicyMan.Common.Authority> all_authorities = new ArrayList<PolicyMan.Common.Authority>();
			Gee.List<string> authorities_paths = new ArrayList<string>();
			var explicit_var_policy_paths = get_authorities_file_paths(Ressources.AUTHORITY_VAR_DIR);
			var explicit_etc_policy_paths = get_authorities_file_paths(Ressources.AUTHORITY_ETC_DIR);
			if (explicit_var_policy_paths != null) {
				authorities_paths.add_all(explicit_var_policy_paths);
			}
			if (explicit_etc_policy_paths != null) {
				authorities_paths.add_all(explicit_etc_policy_paths);
			}
			
			// Parse the files
			foreach(var path in authorities_paths) {
				var authorities = get_authorities_from_path(path);
				if (authorities != null) {
					all_authorities.add_all(authorities);
				}
			}
			
			return all_authorities;
		}
		
		private Gee.List<PolicyMan.Common.Authority>? get_authorities_from_path(string path) {
			var authorities = new ArrayList<PolicyMan.Common.Authority>();
			var file = File.new_for_path (path);

			if (!file.query_exists ()) {
				stdout.printf ("File '%s' doesn't exist.\n", file.get_path());
				return null;
			}
			
			try {
				// Open file for reading and wrap returned FileInputStream into a
				// DataInputStream, so we can read line by line
				var dis = new DataInputStream (file.read ());
				string line;
				// Read lines until end of file (null) is reached
				PolicyMan.Common.Authority current_authority = null;
				while ((line = dis.read_line (null)) != null) {
					if (line.contains("[") && line.contains("]")) {
						// Put the current authority on our list
						if (current_authority != null) {
							authorities.add(current_authority);
						}
						
						// New authority
						current_authority = new PolicyMan.Common.Authority();
						
						// Get title
						current_authority.file_path = path;
						var title_parts = line.split("[");
						current_authority.title = title_parts[title_parts.length - 1].split("]")[0];
					}
					else if (line.contains("Identity=")) {
						var identity_parts = line.split("Identity=");
						current_authority.accounts_string = last_of_string_array(identity_parts);
					} else if (line.contains("Action=")) {
						current_authority.actions_string = last_of_string_array(line.split("Action="));
					} else if (line.contains("ResultAny=")) {
						current_authority.authorizations.allow_any = get_authorization_from_string(last_of_string_array(line.split("ResultAny=")));
					} else if (line.contains("ResultInactive=")) {
						current_authority.authorizations.allow_inactive = get_authorization_from_string(last_of_string_array(line.split("ResultInactive=")));
					} else if (line.contains("ResultActive=")) {
						current_authority.authorizations.allow_active = get_authorization_from_string(last_of_string_array(line.split("ResultActive=")));
					} else {
						// End of the first authority
						return null;
					}
				}
				
				// Add the last authority
				if (current_authority != null) {
					authorities.add(current_authority);
				}
				
			} catch (GLib.Error e) {
				stdout.printf ("Catched error while reading file: %s", e.message);
				return null;
			}
			
			return authorities;
		}
		
		private Authorization get_authorization_from_string(string str) {
			switch(str) {
				case "no":
					return Authorization.NOT_AUTHORIZED;
				case "yes":
					return Authorization.AUTHORIZED;
				case "auth_self":
					return Authorization.AUTHENTICATION_REQUIRED;
				case "auth_admin":
					return Authorization.ADMINISTRATOR_AUTHENTICATION_REQUIRED;
				case "auth_self_keep":
					return Authorization.AUTHENTICATION_REQUIRED_RETAINED;
				case "auth_admin_keep":
					return Authorization.ADMINISTRATOR_AUTHENTICATION_REQUIRED_RETAINED;
				default:
					return Authorization.NOT_AUTHORIZED;
			}
		}
		
		private Gee.List<string>? get_authorities_file_paths(string search_path)
		{
			var authority_paths = new ArrayList<string>();
			var search_file = File.new_for_path(search_path);
			try {
				var file_type = search_file.query_file_type(FileQueryInfoFlags.NONE);
				if (file_type == FileType.DIRECTORY) {
					var file_enumerator = search_file.enumerate_children(FileAttribute.STANDARD_NAME, FileQueryInfoFlags.NONE);
					FileInfo file_info;
					while ((file_info = file_enumerator.next_file ()) != null) {
						var child_path = search_path + "/" + file_info.get_name();
						// stdout.printf("Child path: %s\n", child_path);
						var new_authority_paths = get_authorities_file_paths(child_path);
						
						if (new_authority_paths != null) {
							authority_paths.add_all(new_authority_paths);
						}
					}
				}
				else if (file_type == FileType.REGULAR) {
					var file_name = search_file.query_info(FileAttribute.STANDARD_NAME, FileQueryInfoFlags.NONE).get_name();
					string[] splitted_file_name = file_name.split(".");
					if (splitted_file_name[splitted_file_name.length - 1] == "pkla") {
						// stdout.printf("Adding %s file to the policy paths\n", search_path);
						authority_paths.add(search_path);
					}
				}
			}
			catch (GLib.Error err) {
				stdout.printf("Catched an error while parsing directory %s. Error: %s\n", search_path, err.message);
				return null;
			}
			return authority_paths;
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
