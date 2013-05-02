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
	public enum AccountType {
		LINUX_USER,
		LINUX_GROUP;
		
		public string to_string() {
			switch (this) {
				case LINUX_USER:
					return "User";
				case LINUX_GROUP:
					return "Group";
				default:
					assert_not_reached();
			}
		}
		
		public static AccountType[] all() {
			return { 	AccountType.LINUX_USER, AccountType.LINUX_GROUP };
		}
		
		public static AccountType from_string(string str) {
			switch (str) {
				case "User":
					return LINUX_USER;
				case "Group":
					return LINUX_GROUP;
				default:
					assert_not_reached();
			}
		}
	}
}
