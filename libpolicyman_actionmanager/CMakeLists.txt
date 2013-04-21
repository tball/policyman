find_package(PkgConfig)
pkg_check_modules(GEE REQUIRED gee-1.0)
pkg_check_modules(GMODULE REQUIRED gmodule-2.0)
pkg_check_modules(DBUS-GLIB REQUIRED dbus-glib-1)
pkg_check_modules(DBUS REQUIRED dbus-1)
pkg_check_modules(GLIB REQUIRED glib-2.0)
pkg_check_modules(GIO REQUIRED gio-2.0)
pkg_check_modules(LIBOOBS REQUIRED liboobs-1)


# Compile VALA files
vala_precompile(VALA_C
SOURCES
ActionManager.vala
AccountUtilities.vala

PACKAGES
gio-2.0
gmodule-2.0
gee-1.0

GENERATE_VAPI
libpolicyman_actionmanager

CUSTOM_VAPIS
${CMAKE_BINARY_DIR}/libpolicyman_common/libpolicyman_common.vapi
${CMAKE_SOURCE_DIR}/vapi/liboobs-1.vapi
)
include_directories(${POLICYMAN_COMMON_INCLUDE_DIR})
add_definitions(${LIBOOBS_CFLAGS} ${GEE_CFLAGS} ${GEE_CFLAGS_OTHER} ${GMODULE_CFLAGS} ${GMODULE_CFLAGS_OTHER} ${DBUS_CFLAGS} ${DBUS_CFLAGS_OTHER} ${GLIB_CFLAGS} ${GLIB_CFLAGS_OTHER} ${DBUS-GLIB_CFLAGS} ${DBUS-GLIB_CFLAGS_OTHER})
link_directories(${LIBOOBS_LIBRARY_DIRS} ${GEE_LIBRARY_DIRS} ${GMODUlE_LIBRARY_DIRS} ${DBUS_LIBRARY_DIRS} ${DBUS-GLIB_LIBRARY_DIRS} ${GLIB_LIBRARY_DIRS})
add_library(policyman_actionmanager SHARED ${VALA_C})
target_link_libraries(policyman_actionmanager policyman_common ${LIBOOBS_LIBRARIES} ${GEE_LIBRARIES} ${GMODULE_LIBRARIES} ${DBUS_LIBRARIES} ${DBUS-GLIB_LIBRARIES} ${GLIB_LIBRARIES})
set_target_properties (policyman_actionmanager PROPERTIES VERSION 0.1.0 SOVERSION 0)

install(TARGETS policyman_actionmanager DESTINATION ${CMAKE_INSTALL_PREFIX}/lib)
