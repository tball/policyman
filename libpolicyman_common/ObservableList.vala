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

namespace PolicyMan.Common {
	public class ObservableList<T> : Gee.ArrayList<T> {
		public signal void object_added(T object);
		public signal void object_removed(T object);
		
		public override bool add(T object) {
			var added = base.add(object);
			object_added(object);
			return added;
		}
		
		public override bool remove(T object) {
			var removed = base.remove(object);
			object_removed(object);
			return removed;
		}
		
		public override void clear() {
			Gee.List<T> list = this;
			while(list.size > 0) {
				var object = get(0);
				remove(object);
			}
		}
		
		public override bool add_all(Collection<T> collection) {
			foreach (var object in collection) {
				if (!add(object)) {
					return false;
				}
			}
			return true;
		}
	}
}
