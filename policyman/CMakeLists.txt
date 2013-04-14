find_package(PkgConfig)
pkg_check_modules(GTK REQUIRED gtk+-3.0)
pkg_check_modules(GEE REQUIRED gee-1.0)
pkg_check_modules(GMODULE REQUIRED gmodule-2.0)
pkg_check_modules(GLIB REQUIRED glib-2.0)
pkg_check_modules(LIBOOBS REQUIRED liboobs-1)


# Compile VALA files
vala_precompile(VALA_C
SOURCES
main.vala
Program.vala
controllers/AccountsTreeStore.vala
controllers/ActionController.vala
controllers/ActionManagerController.vala
controllers/ActionMembersTreeStore.vala
controllers/ActionsTreeStore.vala
controllers/AuthoritiesTreeStore.vala
controllers/AuthorityController.vala
controllers/AuthorizationTreeStore.vala

PACKAGES
gtk+-3.0
gmodule-2.0
gee-1.0

CUSTOM_VAPIS
${CMAKE_BINARY_DIR}/libpolicyman_common/libpolicyman_common.vapi
${CMAKE_BINARY_DIR}/libpolicyman_actionmanager/libpolicyman_actionmanager.vapi
${CMAKE_SOURCE_DIR}/vapi/liboobs-1.vapi
)
include_directories(${POLICYMAN_COMMON_INCLUDE_DIR} ${POLICYMAN_ACTIONMANAGER_INCLUDE_DIR})
add_definitions(${LIBOOBS_CFLAGS} ${GTK_CFLAGS} ${GTK_CFLAGS_OTHER} ${GEE_CFLAGS} ${GEE_CFLAGS_OTHER} ${GMODULE_CFLAGS} ${GMODULE_CFLAGS_OTHER} ${GLIB_CFLAGS} ${GLIB_CFLAGS_OTHER})
link_directories(${LIBOOBS_LIBRARY_DIRS} ${GTK_LIBRARY_DIRS} ${GEE_LIBRARY_DIRS} ${GMODUlE_LIBRARY_DIRS} ${DBUS-GLIB_LIBRARY_DIRS} ${GLIB_LIBRARY_DIRS})
add_executable(policyman ${VALA_C})
target_link_libraries(policyman policyman_common policyman_actionmanager ${LIBOOBS_LIBRARIES} ${GTK_LIBRARIES} ${GEE_LIBRARIES} ${GMODULE_LIBRARIES} ${GLIB_LIBRARIES})

install(TARGETS policyman DESTINATION ${CMAKE_INSTALL_BINDIR})
