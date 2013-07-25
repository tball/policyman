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
		
		public SelectableActionsTreeStore(ActionManagerController action_manager_controller) {
			base(action_manager_controller);
			true_value.set_boolean(true);
			false_value.set_boolean(false);
		}
		
		public void tree_path_toggled(string path) {
			TreeIter tree_iter;
			if (!get_iter_from_string(out tree_iter, path)) {
				return;
			}
			
			// Get action value
			Value action_value;
			get_value(tree_iter, ColumnTypes.ACTION_REF, out action_value);
			var action = action_value.get_object() as PolicyMan.Common.Action;
			if (action == null) {
				return;
			}
			
			if (_selected_actions.contains(action)) {
				selectable_action_deselected(action);
				set_value (tree_iter, ColumnTypes.SELECTED, false_value);
			}
			else {
				selectable_action_selected(action);
				set_value (tree_iter, ColumnTypes.SELECTED, true_value);
			}
		}
		
		public void set_selected_actions(Gee.List<PolicyMan.Common.Action> selected_actions) {	
			this._selected_actions = selected_actions;
			
			TreeIter tree_iter;
			if (!get_iter_first(out tree_iter)) {
				return;
			}
			
			recursively_select_actions(tree_iter, selected_actions);
		}
		
		private void recursively_select_actions(TreeIter tree_iter, Gee.List<PolicyMan.Common.Action> selected_actions) {
			// Set siblings as selected
			do {
				// If the sibling has childs. Select those
				TreeIter child_tree_iter;
				if (iter_children(out child_tree_iter, tree_iter)) {
					recursively_select_actions(child_tree_iter, selected_actions);
				}
				
				// Get action value
				Value action_value;
				get_value(tree_iter, ColumnTypes.ACTION_REF, out action_value);
				var action = action_value.get_object() as PolicyMan.Common.Action;
				if (action == null) {
					continue;
				}
				
				if (selected_actions.contains(action)) {
					set_value (tree_iter, ColumnTypes.SELECTED, true_value);
				}
				else {
					set_value (tree_iter, ColumnTypes.SELECTED, false_value);
				}
				
			} while (iter_next(ref tree_iter));
		}
	 }
 }

