/**
 * PolicyMan is a gtk based polkit authorization manager.
 * Copyright (C) 2012 Thomas Balling Sørensen
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
	public class AuthorizationTreeStore : TreeStore {
		public enum ColumnTypes
		{
			TEXT = 0,
			INDEX
		}
		public signal void authorization_selected(Authorization authorization);
		public int selected_authorization_index { get; set; }
		
		public AuthorizationTreeStore() {
			init();
		}
		
		private void init() {
			// Init column types
			set_column_types(new Type[] {typeof(string), typeof (int)});
			
			// Init our tree store
			foreach (var authorization in Authorization.all()) {
				TreeIter tree_iter;
				append(out tree_iter, null);
				set(tree_iter, ColumnTypes.TEXT, authorization.to_string(), ColumnTypes.INDEX, (int)authorization, -1);
			}
		}
		
		public void select_authorization_index(int authorization_index) {
			select_authorization((Authorization)authorization_index);
		}
		
		public void select_authorization(Authorization authorization) {
			selected_authorization_index = (int)authorization;
			authorization_selected(authorization);
		}
	}
}
