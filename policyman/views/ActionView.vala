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
	public class ActionView : Box, IBaseView {
		private Label action_vendor;
		private Label action_description;
		private Image action_icon;
		private ToolButton add_authority_rule_button;
		private ToolButton delete_authority_button;
		private AuthorityView authority_view;
		
		public string action_vendor_string {get; set; default = "";}
		public string action_vendor_url_string {get; set; default = "";}
		public signal void authority_delete_clicked(TreeIter ?tree_iter);
		public signal void authority_add_clicked();
		public AuthorizationsView authorizations_view;
		public AuthoritiesTreeView authorities_tree_view;
		public ActionView() {
			GLib.Object (orientation: Gtk.Orientation.VERTICAL,
						 spacing: 4,
						 expand : false,
						 sensitive : false,
						 margin : 10);
			Init();
		}
		
		public void connect_model(IController controller) {
			ActionController action_controller = controller as ActionController;
			if (action_controller == null) {
				return;
			}
			
			// Internal bindings
			this.notify["action-vendor-string"].connect(vendor_markup_changed);
			this.notify["action-vendor-url-string"].connect(vendor_markup_changed);
			
			// Bind to the model properties
			action_controller.bind_property("vendor", this, "action-vendor-string");
			action_controller.bind_property("vendor-url", this, "action-vendor-url-string");
			action_controller.bind_property("description", action_description, "label");
			action_controller.bind_property("icon-name", action_icon, "icon-name");
			action_controller.bind_property("action-selected", this, "sensitive");
			
			// Bind child views
			//ActionPropertiesModel action_properties_model = base_model as ActionPropertiesModel;
			//implicit_editor_view.connect_model(action_properties_model.implicit_editor_model);
			//explicit_overview_view.connect_model(action_properties_model.explicit_overview_model);
			
			authorizations_view.connect_model(action_controller.authorizations_controller);
			authorities_tree_view.connect_model(action_controller.authorities_tree_store);
			authority_delete_clicked.connect(action_controller.delete_authority);
			authority_view.connect_model(action_controller.added_or_edited_authority_controller);
			authorities_tree_view.tree_iter_edited.connect(on_tree_iter_edited);
		}
		
		protected void Init() {
			action_icon = new Image.from_icon_name("", IconSize.DIALOG);
			action_icon.notify["icon-name"].connect((sender, param) => { 
					action_icon.pixel_size = 50; 
				});

			action_description = new Label("");
			action_description.halign = Align.START;
			action_vendor = new Label("");
			action_vendor.halign = Align.START;
			authorizations_view = new AuthorizationsView();
			authorities_tree_view = new AuthoritiesTreeView();
			
			var horizontal_box = new Box(Orientation.HORIZONTAL, 4);
			var vertical_box = new Box(Orientation.VERTICAL, 4);
			vertical_box.pack_start(action_vendor, false);
			vertical_box.pack_start(action_description, false);
			horizontal_box.pack_start(action_icon, false);
			horizontal_box.pack_start(vertical_box, false);
			
			var implicit_label = new Label(null);
			implicit_label.halign = Align.START;
			implicit_label.set_markup("<b>Authorizations</b>");
			var explicit_label = new Label(null);
			explicit_label.halign = Align.START;
			explicit_label.set_markup("<b>Authorities</b>");
			
			var authority_toolbar = new Toolbar();
			add_authority_rule_button = new ToolButton(null, null);
			delete_authority_button = new ToolButton(null, null);
			add_authority_rule_button.clicked.connect(add_authority_button_clicked);
			add_authority_rule_button.icon_name = "list-add-symbolic";
			delete_authority_button.clicked.connect(delete_authority_button_clicked);
			delete_authority_button.icon_name = "list-remove-symbolic";
			authority_toolbar.insert(add_authority_rule_button, 0);
			authority_toolbar.insert(delete_authority_button, 1);
			
			this.pack_start(horizontal_box, false);
			this.pack_start(implicit_label, false);
			this.pack_start(authorizations_view, false);
			this.pack_start(explicit_label, false);
			this.pack_start(authorities_tree_view, false);
			this.pack_start(authority_toolbar, false);
			
			// Init authority window
			authority_view = new AuthorityView();
		}
		
		public void vendor_markup_changed(Object sender, ParamSpec spec) {
			action_vendor.set_markup(("""<big><a href="%s" title="%s">%s...</a></big>""").printf(action_vendor_url_string, (action_vendor_url_string == "" ? "Url not available" : action_vendor_url_string), action_vendor_string));
		}
		
		private void add_authority_button_clicked() {
			authority_view.show_all();
			authority_add_clicked();
		}
		
		private void on_tree_iter_edited(TreeIter ?tree_iter) {
			if (tree_iter == null) {
				return;
			}
			authority_view.show_all();
		}
		
		private void delete_authority_button_clicked() {
			var tree_iter = authorities_tree_view.get_selected_tree_iter();
			authority_delete_clicked(tree_iter);
		}
	}
}
