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
	public interface ISerializable : Object {
		public abstract Variant to_variant();
		public abstract void from_variant(Variant variant);
		
		public static Variant[] to_variant_array<T>(Gee.List<T> objects) {
			var object_variants = new Variant[objects.size];
			for (var i = 0; i < objects.size; i++) {
				var object = objects[i];
				if (!(object is ISerializable))
					continue;
				
				object_variants[i] = (object as ISerializable).to_variant();
			}
			return object_variants;
		}
		
		public static Gee.List<T> to_object_list<T>(Variant[] object_variants) {
			Gee.List<T> objects = new ArrayList<T>();
			foreach(var object_variant in object_variants) {
				var object = Object.new(typeof(T));
				if (!(object is ISerializable))
					continue;
				
				(object as ISerializable).from_variant(object_variant);
				objects.add(object);
			}
			return objects;
		}
	}
}
