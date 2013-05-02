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
using PolicyMan.Controllers;
 
namespace PolicyMan.Views {
	public class AccountsView : Box, IBaseView {
		private TreeView tree_view;
		private CellRendererCombo account_type_renderer_combo;
		private CellRendererCombo account_user_name_renderer_combo;
		private Button add_account_button;
		
		public AccountsView() {
			GLib.Object (orientation: Orientation.VERTICAL);
			init();
		}
		
		private void init() {
			var horizontal_box = new Box(Orientation.HORIZONTAL, 5);
			var scrolled_window = new ScrolledWindow(null, null) { expand = true, shadow_type = ShadowType.IN };
			add_account_button = new Button.with_label("Add");
			tree_view = new TreeView();
			
			// Add renderers to the treeview
			account_type_renderer_combo = new CellRendererCombo() { editable = true, text_column = AccountsTreeStore.AccountTypeColumnTypes.ACCOUNT_TYPE_TEXT };
			account_user_name_renderer_combo = new CellRendererCombo() { editable = true, text_column = AccountsTreeStore.AccountNameColumnTypes.ACCOUNT_FULL_NAME_TEXT };
			// var account_remove_renderer_button = new CellRendererPixbuf();
			
			// Create columns
			var account_type_column = new TreeViewColumn() { title = "Account Type" };
			var account_user_name_column = new TreeViewColumn() { title = "Account Name" };
			account_type_column.pack_start(account_type_renderer_combo, false);
			account_user_name_column.pack_start(account_user_name_renderer_combo, false);
			//account_column.pack_start(account_remove_renderer_button, false);
			
			// Set renderers attributes
			account_type_column.set_attributes(account_type_renderer_combo, "text", AccountsTreeStore.ColumnTypes.ACCOUNT_TYPE_TEXT, null);
			account_user_name_column.set_attributes(account_user_name_renderer_combo, "text", AccountsTreeStore.ColumnTypes.ACCOUNT_USER_NAME, "model", AccountsTreeStore.ColumnTypes.ACCOUNT_MODEL, null);
			//account_column.set_attributes(account_remove_renderer_button, "icon_name", 0, null);
			
			tree_view.insert_column(account_type_column, 0);
			tree_view.insert_column(account_user_name_column, 1);
			
			scrolled_window.add(tree_view);
			horizontal_box.pack_end(add_account_button, false);
			pack_start(scrolled_window, false);
			pack_start(horizontal_box, false);
		}
		
		public void connect_model(IController controller) {
			var accounts_tree_store = controller as AccountsTreeStore;
			if (accounts_tree_store == null) {
				return;
			}
			tree_view.set_model(accounts_tree_store);
			account_type_renderer_combo.model = accounts_tree_store.account_types_tree_store;
			account_type_renderer_combo.changed.connect(accounts_tree_store.account_type_changed);
			account_user_name_renderer_combo.changed.connect(accounts_tree_store.account_name_changed);
			add_account_button.clicked.connect(accounts_tree_store.add_account);
			
			//account_type_renderer_combo.text_column = AccountsTreeStore.ColumnTypes.ACCOUNT_USER_NAME;
		}
	}
}
