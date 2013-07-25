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
	 public class SelectableActionsTreeStore : ActionsTreeStore {
		// Search for TreeIters corresponding to our selected actions
		private Value true_value = Value(typeof(bool));
		private Value false_value = Value(typeof(bool));
		private Gee.List<PolicyMan.Common.Action> _selected_actions { get; set; default = null; }
		public signal void selectable_action_selected(PolicyMan.Common.Action action);
		public signal void selectable_action_deselected(PolicyMan.Common.Action action);
		
		public enum SelectableColumnTypes {
			SELECTED = ColumnTypes.NUM_ACTION_CHILDREN + 1,
			SELECTED_CHILDREN,
			INCONSISTENT
		}
		
		public SelectableActionsTreeStore(ActionManagerController action_manager_controller) {
			base(action_manager_controller);
			
			// Append the new columntypes
			set_column_types(new Type[] {typeof(string), typeof (string), typeof (string), typeof(PolicyMan.Common.Action), typeof(int), typeof(bool), typeof(int), typeof(bool)});
			
			true_value.set_boolean(true);
			false_value.set_boolean(false);
		}
		
		public void set_selected_actions(Gee.List<PolicyMan.Common.Action> selected_actions) {	
			this._selected_actions = selected_actions;
			
			// Reset tree model from selectable data
			this.foreach(reset_selection_columns_foreach_func);
			
			TreeIter tree_iter;
			if (!get_iter_first(out tree_iter)) {
				return;
			}
			
			foreach (var action in selected_actions) {
				if (action_id_to_tree_path_hash_map.has_key(action.id)) {
					var tree_path = action_id_to_tree_path_hash_map.get(action.id);
					
					toggle_selection_on_tree_path_string(tree_path.to_string());
				}
			}
		}
		
		public void toggle_selection_on_tree_path_string(string tree_path_string) {
			var tree_path = new TreePath.from_string(tree_path_string);
			
			TreeIter tree_iter;
			if (!get_iter(out tree_iter, tree_path)) {
				return;
			}
			
			// Lets check the current selection status
			Value selection_status_value;
			get_value(tree_iter, SelectableColumnTypes.SELECTED, out selection_status_value);
			var selected = selection_status_value.get_boolean();
			
			// Invert the selected, since we are toggling
			selected = !selected;
			
			// Do the current tree path contains any children? If so, select them all
			if (iter_has_child(tree_iter)) {
				recursively_select_children(tree_iter, selected);
			}
			
			// Select self
			select_tree_iter(tree_iter, selected);
		}
		
		private bool reset_selection_columns_foreach_func(TreeModel tree_model, TreePath tree_path, TreeIter tree_iter) {
			set (tree_iter, SelectableColumnTypes.SELECTED_CHILDREN, 0, SelectableColumnTypes.SELECTED, false, SelectableColumnTypes.INCONSISTENT, false);
			return false;
		}
		
		private void recursively_select_children(TreeIter parent_iter, bool selected) {
			TreeIter child_iter;
			if (!iter_children(out child_iter, parent_iter)) {
				return;
			}
			
			// Select all the sister iters
			do {
				// Select child
				select_tree_iter(child_iter, selected);
				
				// If the child has children, select those
				if (iter_has_child(child_iter)) {
					recursively_select_children(child_iter, selected);
				}
			} while (iter_next(ref child_iter));
		}
		
		private void select_tree_iter(TreeIter tree_iter, bool selected) {
			// If the tree iter is an action, emit appropriate signal
			Value action_value;
			get_value(tree_iter, ColumnTypes.ACTION_REF, out action_value);
			var action = action_value.get_object() as PolicyMan.Common.Action;
			
			// Get the old selection value
			Value old_selection_state_value;
			get_value(tree_iter, SelectableColumnTypes.SELECTED, out old_selection_state_value);
			var old_selection_state = old_selection_state_value.get_boolean();
			
			// Select current iter
		    set (tree_iter, SelectableColumnTypes.SELECTED, selected, SelectableColumnTypes.INCONSISTENT, false);
		    
			
			// Only update the parent selection children num, if we have a change in selection state
			var selection_changed = old_selection_state != selected;
			if (!selection_changed) {
				return;
			}
			
			if (action != null) {
				if (selected) {
					selectable_action_selected(action);
					
					// Adjust parents accordingly. 1 as the number of selected actions has increased.
					recursively_update_parents_num_children(tree_iter, 1);
				}
				else {
					// Adjust parents accordingly. -1 as the number of selected actions has decreased.
					recursively_update_parents_num_children(tree_iter, -1);
					selectable_action_deselected(action);
				}
			}
		}
		
		private void recursively_update_parents_num_children(TreeIter tree_iter, int tree_iter_selected_changed_offset) {
			TreeIter parent_iter;
			if (!iter_parent(out parent_iter, tree_iter)) {
				return;
			}
			
			// Get total number of action children
			Value child_count_value;
			get_value(parent_iter, ColumnTypes.NUM_ACTION_CHILDREN, out child_count_value);
			var child_count = child_count_value.get_int();
			
			
			// Get current number of children and apply a selected changed offset.
			Value num_selected_children_value;
			get_value(parent_iter, SelectableColumnTypes.SELECTED_CHILDREN, out num_selected_children_value);
			var num_selected_children = num_selected_children_value.get_int();
			var new_num_selected_children = num_selected_children + tree_iter_selected_changed_offset;
			set_value(parent_iter, SelectableColumnTypes.SELECTED_CHILDREN, new_num_selected_children);

			// Set new active and inconsistent state from the number of children
			var active_state = false;
			var inconsistent_state = false;
			if (new_num_selected_children > 0) {
				if (new_num_selected_children == child_count) {
					active_state = true;
					inconsistent_state = false;
				}
				else {
					active_state = false;
					inconsistent_state = true;
				}
			}
			else {
				active_state = false;
				inconsistent_state = false;
			}
			
			// Set states
			set (parent_iter, SelectableColumnTypes.SELECTED, active_state, SelectableColumnTypes.INCONSISTENT, inconsistent_state);
			
			recursively_update_parents_num_children(parent_iter, tree_iter_selected_changed_offset);
		}
	 }
 }

