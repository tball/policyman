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
	public enum Authorization {
		NOT_AUTHORIZED,
		AUTHENTICATION_REQUIRED,
		ADMINISTRATOR_AUTHENTICATION_REQUIRED,
		AUTHENTICATION_REQUIRED_RETAINED,
		ADMINISTRATOR_AUTHENTICATION_REQUIRED_RETAINED,
		AUTHORIZED;
		
		public string to_string() {
			switch (this) {
				case NOT_AUTHORIZED:
					return "Not Authorized";
				case AUTHENTICATION_REQUIRED:
					return "Authentication Required";
				case ADMINISTRATOR_AUTHENTICATION_REQUIRED:
					return "Administrator Authentication Required";
				case AUTHENTICATION_REQUIRED_RETAINED:
					return "Authentication Required Retained";
				case ADMINISTRATOR_AUTHENTICATION_REQUIRED_RETAINED:
					return "Administrator Authentication Required Retained";
				case AUTHORIZED:
					return "Authorized";
				default:
					assert_not_reached();
			}
		}
		
		public static Authorization[] all() {
			return { 	Authorization.NOT_AUTHORIZED, Authorization.AUTHENTICATION_REQUIRED, Authorization.ADMINISTRATOR_AUTHENTICATION_REQUIRED, 
						Authorization.AUTHENTICATION_REQUIRED_RETAINED, Authorization.ADMINISTRATOR_AUTHENTICATION_REQUIRED_RETAINED, Authorization.AUTHORIZED };
		}
	}
}
