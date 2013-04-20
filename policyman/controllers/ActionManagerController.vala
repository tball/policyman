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



namespace PolicyMan.Controllers {
	public class ActionManagerController : Object, IController {
		public ActionsTreeStore actions_tree_store { private set; get; default = new ActionsTreeStore(); }
		public ActionController selected_action_controller { private set; get; default = new ActionController(); }
		
		public ActionManagerController() {
			init_bindings();
			init();
		}
		
		private void init_bindings() {
			actions_tree_store.action_selected.connect(selected_action_controller.set_action);
		}
		
		private void init() {
			stdout.printf("Loading action manager\n");
			var action_manager = new ActionManager();
			Gee.List<PolicyMan.Common.Action> actions;
			if (action_manager.load(out actions)) {
				stdout.printf("Number of actions %d\n", actions.size);
			}
			
			actions_tree_store.update_actions(actions);
		}
		
		public void connect_model(IController controller) {
			
		}
		
		public void save_changes() {
			stdout.printf("Saving changes");
		}
		
		public void close() {
			Gtk.main_quit();
		}
	}
}
