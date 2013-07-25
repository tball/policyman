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
using PolicyMan.Controllers;

namespace PolicyMan.Views {
	public class AuthorityView : Box, IBaseView {
		private AuthorizationsView authorizations_view;
		private SelectableActionTreeView selectable_action_tree_view;
		private AccountsView accounts_view;
		private Entry action_title_entry;

		public AuthorityView() {
			GLib.Object();
			init();
		}
		
		protected void init() {
			var vertical_box = new Box(Orientation.VERTICAL, 4) { margin = 10 };
			var horizontal_box = new Box(Orientation.HORIZONTAL, 4);
			var title_label = new Label(null);
			var action_authentication_label = new Label(null);
			var selected_accounts_label = new Label(null);
			var selected_actions_label = new Label(null);
			selectable_action_tree_view = new SelectableActionTreeView();
			accounts_view = new AccountsView();
			
			authorizations_view = new AuthorizationsView();
			action_title_entry = new Entry();

			title_label.halign = Align.START;
			title_label.set_markup("<b>Title</b>");
			action_authentication_label.halign = Align.START;
			action_authentication_label.set_markup("<b>Authentication</b>");
			selected_actions_label.halign = Align.START;
			selected_actions_label.set_markup("<b>Selected Actions</b>");
			selected_accounts_label.halign = Align.START;
			selected_accounts_label.set_markup("<b>Selected Accounts</b>");

			vertical_box.pack_start(title_label, false);
			vertical_box.pack_start(action_title_entry, false);
			vertical_box.pack_start(action_authentication_label, false);
			vertical_box.pack_start(authorizations_view, false);
			vertical_box.pack_start(selected_accounts_label, false);
			vertical_box.pack_start(accounts_view, false);
			vertical_box.pack_start(selected_actions_label, false);
			vertical_box.pack_start(selectable_action_tree_view, false);
			vertical_box.pack_start(horizontal_box, false);
			
			this.add(vertical_box);
		}

		public void connect_model(IController controller) {
			var authority_controller = controller as AuthorityController;
			authority_controller.bind_property("title", action_title_entry, "text", BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE);
			
			authorizations_view.connect_model(authority_controller.authorizations_controller);
			accounts_view.connect_model(authority_controller.accounts_tree_store);
			selectable_action_tree_view.connect_model(authority_controller.actions_tree_store);
		}
	}
}
