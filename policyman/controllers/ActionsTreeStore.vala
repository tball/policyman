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
 
 using Gtk;
 using Gee;
 using PolicyMan.Common;
 
 namespace PolicyMan.Controllers {
	 public class ActionsTreeStore : TreeStore, IController {
		private ActionManagerController action_manager_controller { get; private set; }
		protected Map<string, TreePath> action_id_to_tree_path_hash_map { get; private set; }
		public signal void action_selected(PolicyMan.Common.Action action);
		public string search_string {get; set; default="";}
		
		public enum ColumnTypes
		{
			ICON = 0,
			GROUP_ID,
			DESCRIPTION,
			ACTION_REF,
			NUM_ACTION_CHILDREN
		}
		
		public TreeModelFilter tree_store_filter { get; private set; }
		
		public void on_save_changes() {
			action_manager_controller.save_changes();
		}
	
		public ActionsTreeStore(ActionManagerController action_manager_controller) {
			this.action_manager_controller = action_manager_controller;
			
			tree_store_filter = new TreeModelFilter(this, null);
			tree_store_filter.set_visible_func(visibility_func);
			set_column_types(new Type[] {typeof(string), typeof (string), typeof (string), typeof(PolicyMan.Common.Action), typeof(int)});
			
			init_bindings();
		}

		private void init_bindings() {
			this.notify["search-string"].connect((sender) => { tree_store_filter.refilter();});
			action_manager_controller.actions_changed.connect(set_actions);
		}

		private bool visibility_func(TreeModel model, TreeIter iter) {
			if (search_string == "") {
				// Search aborted
				return true;	
			}
			
			var lower_case_filter_string = search_string.down();
			
			//
			var parent_contains_string = parent_contains_string(lower_case_filter_string, new int [] { ColumnTypes.GROUP_ID, ColumnTypes.DESCRIPTION }, iter);
			if (parent_contains_string) {
				return true;
			}
			
			// Search if current TreeIter or any of its childs contains the search string
			return current_or_children_contains_string(lower_case_filter_string, new int [] { ColumnTypes.GROUP_ID, ColumnTypes.DESCRIPTION }, iter);
		}
		
		private bool parent_contains_string(string search_string, int [] columns, TreeIter child)
		{
			TreeIter parent;
			if (!iter_parent(out parent, child)) {
				return false;
			}

			foreach (var column in columns) {
				Value parent_value;
				get_value(parent, column, out parent_value);
				var parent_string = parent_value.get_string();
			
				if (parent_string != null) {
					parent_string = parent_string.down();
					if (parent_string.contains(search_string)) {
						return true;
					}
				}
			}
			
			var parent_containts_string = parent_contains_string(search_string, columns, parent);
			if (parent_containts_string) {
				return true;
			}
			
			return false;
		}
		
		private bool current_or_children_contains_string(string search_string, int [] columns, TreeIter parent)
		{
			// See if parent contains string
			foreach (var column in columns) {
				Value parent_value;
				get_value(parent, column, out parent_value);
				var parent_string = parent_value.get_string();
			
				if (parent_string != null) {
					parent_string = parent_string.down();
					if (parent_string.contains(search_string)) {
						return true;
					}
				}
			}
				
			// Search children
			TreeIter child_iter;
			if (iter_n_children(parent) > 0) {
				iter_children(out child_iter, parent);
				do {
					var string_found_in_child = current_or_children_contains_string(search_string, columns, child_iter);
					if (string_found_in_child)
						return true;
				} while (iter_next(ref child_iter));
			}
			
			// We did not find the string
			return false;
		}

		public void set_actions(Gee.List<PolicyMan.Common.Action> ?actions) {
			clear();
			action_id_to_tree_path_hash_map = new HashMap<string, TreePath>();
			
			if (actions == null) {
				return;
			}
			
			// Parse policies			
			foreach (PolicyMan.Common.Action action in actions) {
				var action_ids = action.id.split(".");
				
				if (action_ids.length > 2) {
					// We start at array index 1, in order to skip 'org'
				    // var first_action_id = action_ids[1];
				    insert_or_update(action_ids, action, null, 1);
				} else if (action_ids.length > 1) {
				    // although pretty weird and probably
				    // bad behavior, here we check if the action
				    // id is bigger than "org"
				    //insert_or_update(action_ids, action, root, 0);
				}
				
				//TreeIter root;
				//append(out root, null);
				//set(root, 0, policy.Identity, -1);
			}
		}
		
		private void insert_or_update(string[] action_ids, PolicyMan.Common.Action action, TreeIter? parent, int level) {
			// Lets see if we have come to the 'end' of the path
			if (action_ids.length - 1 <= level) {
				// now bind the action to this iter
				//stdout.printf("Reached outter level at %d with group %s\n", level, action_ids[level]);
				
				// Set icon to the parent of this entry
				set(parent, ColumnTypes.ICON, action.icon_name != "" ? action.icon_name : "folder-symbolic", -1);
				
				TreeIter child_iter;
				
				append(out child_iter, parent);
				set(child_iter, ColumnTypes.ICON, "channel-secure-symbolic", ColumnTypes.GROUP_ID, action.description, ColumnTypes.ACTION_REF, action,-1);
				
				// Register tree path for this action id
				var tree_path = get_path(child_iter);
				action_id_to_tree_path_hash_map.set(action.id, tree_path);
				
				return;
			}
		
			TreeIter child_iter;
			var group_found = false;
			if (iter_n_children(parent) > 0) {
				//stdout.printf("parent does have children\n");
				// Lets see if the group has already been added
				iter_children(out child_iter, parent);
				do {
					Value child_value;
					get_value(child_iter, ColumnTypes.GROUP_ID, out child_value);
					
					var child_string = child_value.get_string();
					if (child_string == action_ids[level]) {
						//stdout.printf("Found group match: %s\n", child_string);
						group_found = true;
						break;
					}
				} while (iter_next(ref child_iter));
				
				// If we didn't find a group, append a new group
				if (!group_found) {
					// Add new child
					//stdout.printf("No group found\n");
					append(out child_iter, parent);
				}
			} else {
				//stdout.printf("parent does not have children\n");
				append(out child_iter, parent);
			}
			
			set(child_iter, ColumnTypes.ICON, "folder-symbolic", ColumnTypes.GROUP_ID, action_ids[level], -1);
			increment_action_child_count(child_iter);
			insert_or_update(action_ids, action, child_iter, level + 1);
		}
		
		private void increment_action_child_count(TreeIter tree_iter) {
			Value child_count_value;
			get_value(tree_iter, ColumnTypes.NUM_ACTION_CHILDREN, out child_count_value);
			var child_count = child_count_value.get_int();
			child_count++;
			set_value(tree_iter, ColumnTypes.NUM_ACTION_CHILDREN, child_count);
		}
		
		public void search_string_changed(string search_string) {
			this.search_string = search_string;
		}
		
		public void select_action_tree_iter(TreeIter tree_iter) {
			// Get the selected action
			Value action_value;
			tree_store_filter.get_value(tree_iter, ActionsTreeStore.ColumnTypes.ACTION_REF, out action_value);
			var selected_action = action_value.get_object() as PolicyMan.Common.Action;

			action_selected(selected_action);
		}
	 }
 }

