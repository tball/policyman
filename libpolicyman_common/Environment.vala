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

namespace PolicyMan.Common {
	public class Ressources {
		public static const string DATA_DIR = """/usr/share/policyman""";
		public static const string ACTION_DIR = """/usr/share/polkit-1/actions""";
		public static const string AUTHORITY_VAR_DIR = """/var/lib/polkit-1/localauthority""";
		public static const string AUTHORITY_ETC_DIR = """/etc/polkit-1/localauthority""";
	}
}
