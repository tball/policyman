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
using PolicyMan.Common;

namespace PolicyMan.Controllers {
	public class AuthoritiesTreeStore : TreeStore, IController {
		public enum ColumnTypes {
			TITLE = 0,
			OBJECT
		}
		
		public AuthoritiesTreeStore() {
			set_column_types(new Type[] {typeof(string), typeof(Authority)});
		}

		public void set_authorities(Gee.List<Authority> ?authorities) {
			clear();
			
			if (authorities == null) {
				return;
			}

			// Parse policies			
			foreach (var authority in authorities) {
				foreach(var account in authority.accounts) {
					stdout.printf((account.account_type == AccountType.LINUX_USER ? " user = " : " group = ") + account.user_name + "\n");
				}
				
				TreeIter root;
				append(out root, null);
				set(root, ColumnTypes.TITLE, "<b>" + authority.title + "</b>, " + "(Allow any: " + authority.authorizations.allow_any.to_string() + ", Allow active: " + authority.authorizations.allow_active.to_string() + ", Allow inactive: " + authority.authorizations.allow_inactive.to_string() + ")", ColumnTypes.OBJECT, authority, -1);
			}
		}
	}
}
