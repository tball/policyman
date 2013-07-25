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
	
	[DBus (name = "org.freedesktop.policyman.helper")]
	public class PolicyManHelper : Object {
		public Variant get_actions(BusName bus_name) throws GLib.Error {
			// Check permissions
			string error_str;
			if (!grant_permission(bus_name, "org.freedesktop.policyman.GetActions", out error_str)) {
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

			// Convert actions to our own format
			var actions = new ArrayList<PolicyMan.Common.Action>();
			for (var i = 0; i < action_descriptors.length(); i++) {
				var action_desc = action_descriptors.nth_data(i);
				if (action_desc == null) {
					continue;
				}
				var action = create_action_from_action_description(action_desc);
				actions.add(action);
			}
			
			// Create container, which we will send to our client
			var container = new Container(actions, authorities);
			container.attach_actions_to_authorities();
			
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
			Gee.List<PolicyMan.Common.Authority> authorities = new ArrayList<PolicyMan.Common.Authority>();
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
					} else if (line.contains("Identity=")) {
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
		
		private static string get_string_from_authorization(Authorization authorization) {
			switch(authorization) {
				case Authorization.NOT_AUTHORIZED:
					return "no";
				case Authorization.AUTHORIZED:
					return "yes";
				case Authorization.AUTHENTICATION_REQUIRED:
					return "auth_self";
				case Authorization.ADMINISTRATOR_AUTHENTICATION_REQUIRED:
					return "auth_admin";
				case Authorization.AUTHENTICATION_REQUIRED_RETAINED:
					return "auth_self_keep";
				case Authorization.ADMINISTRATOR_AUTHENTICATION_REQUIRED_RETAINED:
					return "auth_admin_keep";
				default:
					return "no";
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
		
		public void set_actions(Variant container_variant, BusName bus_name) throws GLib.Error {
			// Check permissions
			string error_str;
			if (!grant_permission(bus_name, "org.freedesktop.policyman.SetActions", out error_str)) {
				throw new PolicyManHelperError.SOME_ERROR("Cannot set actions due to the following error: " + error_str);
			}
			
			// Convert container variant to actual actions and authorities
			var container = new Container(null, null);
			container.from_variant(container_variant);
			var actions = container.get_actions();
			var authorities = container.get_authorities();
			
			// Save the actions
			foreach (var action in actions) {
				if ( action.action_changed ) {
					save_action(action);
				}
			}
			
			// Remove any existing authorities
			var existing_authorities = get_authorities();
			foreach (var authority in existing_authorities) {
				if (authority.file_path == "") {
					continue;
				}
				var authority_file = File.new_for_path(authority.file_path);
				if (authority_file.query_exists()) {
					authority_file.delete();
				}
			}
			
			// Save the new authorities
			foreach (var authority in authorities) {
				save_authority(authority);
			}
		}
		
		private bool find_action_path_from_id(string action_id, out string action_path) {
			var root_path = Ressources.ACTION_DIR;
			var action_search_prefixes = action_id.split(".");
			
			bool found_path = false;
			while (true) {
				action_path = root_path + "/" + string.joinv(".", action_search_prefixes) + ".policy";
				// stdout.printf("Searching for implicit action at " + action_path + "\n");
				
				var action_file = File.new_for_path(action_path );
				if (action_file.query_exists()) {
					// stdout.printf("Found implicit action at " + action_path + "\n");
					found_path = true;
					break;
				}
				
				// Should we give up our search?
				if (action_search_prefixes.length <= 2) {
					return false;
				}
				
				// Remove last search prefix
				action_search_prefixes = action_search_prefixes[0: action_search_prefixes.length - 1];
			}
			
			return found_path;
		}
		
		private void save_action(PolicyMan.Common.Action action) {
			string action_path;
			if (!find_action_path_from_id(action.id, out action_path)) {
				stdout.printf("Didn't find path for action %s\n", action.id);
				return;
			}
			
			// TODO: Write the xml entry
			Xml.Doc* doc = Parser.parse_file (action_path);
			if (doc == null) {
				stdout.printf("Doc == null for action %s\n", action.id);
				return;
        	}
			
			// Get the root node. notice the dereferencing operator -> instead of .
		    Xml.Node* root = doc->get_root_element ();
		    if (root == null) {
		        // Free the document manually before returning
		        stdout.printf("Null root element, %s\n", action.id);
		        delete doc;
		        return;
		    }
		    
		    // Search for the first action node
		    var action_node = first_child_node(root, "action");
		    if (action_node == null) {
		    	// Didn't find any action nodes
		    	stdout.printf("Didn't find any action nodes for path %s action %s\n", action_path, action.id);
		    	return;
		    }
		    
		    // Search for the action node with our action_id
		    Xml.Attr* prop = action_node->properties;
		    string attr_content = "";
		    while (action_node != null) {
		    	prop = action_node->properties;
		    	attr_content = prop->children->content;
		    	
		    	if (prop->name == "id" && attr_content == action.id) {
		    		// Correct node found
		    		break;
		    	}
		    	
		    	action_node = next_sibling_node(action_node, "action");
		    }
		    
		    if (action_node == null) {
		    	stdout.printf("Didn't find the right action node for id %s path %s\n", action.id, action_path);
		    	return;
		    }
		    
		    // Find the defaults node under the action node
		    var defaults_node = first_child_node(action_node, "defaults");
		    if (defaults_node == null) {
		    	// Didn't find any defaults nodes
		    	stdout.printf("Didn't find any defaults nodes for path %s action %s\n", action_path, action.id);
		    	return;
		    }
		    

		    // Set or overwrite the 3 nodes
		    add_child_node_with_content(defaults_node, "allow_any", get_string_from_authorization(action.authorizations.allow_any));
		    add_child_node_with_content(defaults_node, "allow_inactive", get_string_from_authorization(action.authorizations.allow_inactive));
		    add_child_node_with_content(defaults_node, "allow_active", get_string_from_authorization(action.authorizations.allow_active));
		    
		    // Now save the doc
		    doc->save_file(action_path);
		    
			// Manually cleanup the xml doc
			delete doc;
		}
		
		private void add_child_node_with_content(Xml.Node *parent, string child_name, string content) {
			Xml.Ns* ns = new Xml.Ns (null, "", "");
        	ns->type = Xml.ElementType.ELEMENT_NODE;
		
			var child_node = first_child_node(parent, child_name);
		    if (child_node == null) {
		    	// Create new child node
		    	parent->new_text_child (ns, child_name, content);
		    } else {
		    	child_node->set_content(content);
		    }
		}
		
		private Xml.Node* next_sibling_node(Xml.Node *node, string searched_node_name) {
			Xml.Node* sibling_node = node->next;
			while (sibling_node != null) {
				if (sibling_node->type != ElementType.ELEMENT_NODE) {
					sibling_node = sibling_node->next;
		            continue;
		        }
				
				if (sibling_node->name == searched_node_name) {
					return sibling_node;
				}
				sibling_node = sibling_node->next;
			}
			
			return null;
		}
		
		private Xml.Node* first_child_node(Xml.Node *parent_node, string searched_node_name) {
		    // Loop over the passed node's children
		    for (Xml.Node* iter = parent_node->children; iter != null; iter = iter->next) {
		        // Spaces between tags are also nodes, discard them
		        if (iter->type != ElementType.ELEMENT_NODE) {
		            continue;
		        }

		        if (iter->name == searched_node_name) {
		        	return iter;
		        }

		        // Followed by its children nodes
		        var child_node = first_child_node (iter, searched_node_name);
		        if (child_node != null) {
		        	return child_node;
		        }
		    }
		    
		    // We didn't find anything in this node
		    return null;
		}
		
		private static void save_authority(PolicyMan.Common.Authority authority) {
			var authority_file_path = authority.file_path;
			
			// Generate a new file name
			if (authority_file_path == "") {
				var authority_directory_path = Ressources.AUTHORITY_ETC_DIR + "/60-policyman.d";
				if (DirUtils.create(authority_directory_path, 0751) != 0) {
					// Means its already created
				}
				
				var authority_file_name = get_filename_from_authority(authority);
				authority_file_path = authority_directory_path + "/" + authority_file_name;
			}
			var authority_string = format_authority(authority);
			stdout.printf("Saving authority: %s\nAt: %s\n", authority_string, authority_file_path);
			
			// Save the actual authority
			var file = File.new_for_path(authority_file_path);
			try {
				// Append data
				var os = file.append_to(FileCreateFlags.NONE);
				os.write(authority_string.data);
			} catch (GLib.Error e) {
				stdout.printf ("Error: %s\n", e.message);
			}
		}
		
		private static string get_filename_from_authority(PolicyMan.Common.Authority authority) {
			return authority.title.replace(" ", "_").replace("/", "_").replace("\0", "_") + ".pkla";
		}
		
		private static string format_authority(PolicyMan.Common.Authority authority) {
			var retstring = "";
			retstring += "[" + authority.title + "]\n";
			retstring += "Identity=" + authority.accounts_string + "\n";
			retstring += "Action=" + authority.actions_string + "\n";
			retstring += "ResultAny=" + get_string_from_authorization(authority.authorizations.allow_any) + "\n";
			retstring += "ResultInactive=" + get_string_from_authorization(authority.authorizations.allow_inactive) + "\n";
			retstring += "ResultActive=" + get_string_from_authorization(authority.authorizations.allow_active) + "\n";
			return retstring;
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

	[DBus (name = "org.freedesktop.policyman.PolicyManHelperError")]
	public errordomain PolicyManHelperError
	{
		SOME_ERROR
	}

	void on_bus_aquired (DBusConnection conn) {
		try {
			conn.register_object ("/org/freedesktop/policyman/helper", new PolicyManHelper());
		}
		catch (IOError e) {
			stderr.printf ("Could not register service\n");
		}
	}

	void main() {
		Bus.own_name (BusType.SYSTEM, "org.freedesktop.policyman.helper", BusNameOwnerFlags.NONE,
					  on_bus_aquired,
					  () => {},
					  () => stderr.printf ("Could not aquire name\n"));

		new MainLoop ().run ();
	}
}
