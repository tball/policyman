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
using Gtk;
using PolicyMan.Common;

namespace PolicyMan.Controllers {
	public class AccountsTreeStore : TreeStore, IController {
		public enum AccountTypeColumnTypes {
			ACCOUNT_TYPE_TEXT = 0,
			OBJECT
		}
		
		public enum AccountNameColumnTypes {
			ACCOUNT_USER_NAME_TEXT = 0,
			ACCOUNT_FULL_NAME_TEXT,
			OBJECT
		}
		
		public enum ColumnTypes {
			ACCOUNT_TYPE_TEXT = 0,
			ACCOUNT_USER_NAME,
			ACCOUNT_MODEL,
			OBJECT,
			ACCOUNT_INDEX
		}
		
		private Gee.List<Account> user_accounts = null;
		private Gee.List<Account> group_accounts = null;
		public Gee.List<Account> selected_accounts = null;
		public TreeStore user_account_tree_store = null;
		public TreeStore group_account_tree_store = null;
		public TreeStore account_types_tree_store = null;
		
		public signal void selected_accounts_changed();
		
		public class AccountsTreeStore() {
			set_column_types(new Type[] {typeof(string), typeof(string), typeof(TreeModel), typeof(Account), typeof(int)});
			init();
		}
		
		private void init() {
			// Fetch all accounts
			user_accounts = AccountUtilities.get_users();
			group_accounts = AccountUtilities.get_groups();
			
			// Init tree stores containing account types
			account_types_tree_store = new TreeStore(2, typeof(string), typeof(int));
			foreach(var account_type in AccountType.all()) {
				TreeIter tree_iter;
				account_types_tree_store.append(out tree_iter, null);
				account_types_tree_store.set(tree_iter, AccountTypeColumnTypes.ACCOUNT_TYPE_TEXT, account_type.to_string(), AccountTypeColumnTypes.OBJECT, (int)account_type, -1);
			}
			
			user_account_tree_store = new TreeStore(3, typeof(string), typeof(string), typeof(Account));
			foreach(var user_account in user_accounts) {
				TreeIter tree_iter;
				user_account_tree_store.append(out tree_iter, null);
				user_account_tree_store.set(tree_iter, AccountNameColumnTypes.ACCOUNT_USER_NAME_TEXT, user_account.user_name, AccountNameColumnTypes.ACCOUNT_FULL_NAME_TEXT, user_account.user_name, AccountNameColumnTypes.OBJECT, user_account, -1);
			}
			
			group_account_tree_store = new TreeStore(3, typeof(string), typeof(string), typeof(Account));
			foreach(var group_account in group_accounts) {
				TreeIter tree_iter;
				group_account_tree_store.append(out tree_iter, null);
				group_account_tree_store.set(tree_iter, AccountNameColumnTypes.ACCOUNT_USER_NAME_TEXT, group_account.user_name, AccountNameColumnTypes.ACCOUNT_FULL_NAME_TEXT, group_account.user_name, AccountNameColumnTypes.OBJECT, group_account, -1);
			}
		}
		
		public void delete_account(TreeIter ?account_tree_iter) {
			if (account_tree_iter == null) {
				return;
			}
			
			// Get Account
			Value account_value;
			get_value(account_tree_iter, ColumnTypes.OBJECT, out account_value);
			var account = account_value.get_object() as Account;
			gtk_tree_store_remove(this, (TreeIter *)account_tree_iter);
			
			if (account == null) {
				return;
			}
			
			// Remove it
			selected_accounts.remove(account);
			selected_accounts_changed();
		}
		
		public void add_account() {
			var new_account = user_accounts.first();
			selected_accounts.add(new_account);
			
			TreeIter tree_iter;
			append(out tree_iter, null);
			set_tree_iter_account(tree_iter, new_account, selected_accounts.size - 1);
			selected_accounts_changed();
		}
		
		public void account_name_changed(string tree_path_string, TreeIter tree_iter) {
			// Get the corresponding tree_iter in our account list
			var tree_path = new TreePath.from_string(tree_path_string);
			TreeIter account_tree_iter;
			get_iter(out account_tree_iter, tree_path);
			
			// Get Account
			Value account_value;
			get_value(account_tree_iter, ColumnTypes.OBJECT, out account_value);
			var account = account_value.get_object() as Account;
			
			// Dependent of the type, get the new account
			TreeStore account_tree_store;
			if (account.account_type == AccountType.LINUX_USER) {
				account_tree_store = user_account_tree_store;
			}
			else {
				account_tree_store = group_account_tree_store;
			}
			
			Value val;
			account_tree_store.get_value(tree_iter, AccountNameColumnTypes.OBJECT, out val);
			var new_account = val.get_object() as Account;
			
			set_account_for_tree_path(tree_path_string, new_account);
		}
		
		public void account_type_changed(string tree_path_string, TreeIter tree_iter) {
			// Get Type
			Value val;
			account_types_tree_store.get_value(tree_iter, AccountTypeColumnTypes.OBJECT, out val);
			var account_type = (AccountType)val.get_int();
			
			// Get relevant accounts
			Gee.List<Account> relevant_accounts = account_type == AccountType.LINUX_USER ? user_accounts : group_accounts;
			
			// Update the TreeIter with the current account
			set_account_for_tree_path(tree_path_string, relevant_accounts.first());
		}
		
		private void set_account_for_tree_path(string tree_path_string, Account new_account) {
			// Get the corresponding tree_iter in our account list
			var tree_path = new TreePath.from_string(tree_path_string);
			TreeIter account_tree_iter;
			get_iter(out account_tree_iter, tree_path);
			
			// Get Account index
			Value account_index_value;
			get_value(account_tree_iter, ColumnTypes.ACCOUNT_INDEX, out account_index_value);
			var account_index = account_index_value.get_int();
			
			selected_accounts[account_index] = new_account;
			
			// Update the TreeIter with the current account
			set_tree_iter_account(account_tree_iter, selected_accounts[account_index], account_index);
		}
		
		public void set_accounts(Gee.List<Account> accounts) {
			selected_accounts = accounts;	
			clear();
			
			if (accounts == null) {
				return;
			}

			// Parse accounts			
			var account_index = 0;
			foreach (var account in accounts) {		
				TreeIter root;
				append(out root, null);
				set_tree_iter_account(root, account, account_index);
				account_index++;
			}
		}
		
		private void set_tree_iter_account(TreeIter tree_iter, Account account, int account_index) {
			set(tree_iter, ColumnTypes.ACCOUNT_TYPE_TEXT, account.account_type.to_string(), ColumnTypes.ACCOUNT_USER_NAME, account.user_name, ColumnTypes.ACCOUNT_MODEL, account.account_type == AccountType.LINUX_USER ? user_account_tree_store : group_account_tree_store, ColumnTypes.OBJECT, account, ColumnTypes.ACCOUNT_INDEX, account_index, -1);
		}
	}
}
