# Configure environment
configure_file(Environment.vala.in ${CMAKE_SOURCE_DIR}/libpolicyman_common/Environment.vala)

find_package(PkgConfig)

pkg_check_modules(GIO REQUIRED gio-2.0)
pkg_check_modules(GEE REQUIRED gee-1.0)
pkg_check_modules(POLBACK REQUIRED polkit-backend-1)
pkg_check_modules(GLIB REQUIRED glib-2.0)

# Compile VALA files
vala_precompile(VALA_C
SOURCES
Environment.vala
Action.vala
Account.vala
AccountType.vala
Authority.vala
Authorizations.vala
ISerializable.vala
ActionHelperInterface.vala

PACKAGES
gee-1.0
gio-2.0

GENERATE_VAPI
libpolicyman_common

CUSTOM_VAPIS
${CMAKE_SOURCE_DIR}/vapi/polkit-1.0.vapi
)

add_definitions(${GEE_CFLAGS} ${GEE_CFLAGS_OTHER} ${GIO_CFLAGS} ${GIO_CFLAGS_OTHER} ${GLIB_CFLAGS} ${GLIB_CFLAGS_OTHER} ${POLBACK_CFLAGS} ${POLBACK_CFLAGS_OTHER})
link_directories(${GEE_LIBRARY_DIRS} ${GLIB_LIBRARY_DIRS} ${POLBACK_LIBRARY_DIRS} ${GIO_LIBRARY_DIRS})
add_library(policyman_common SHARED ${VALA_C})
target_link_libraries(policyman_common ${GEE_LIBRARIES} ${GLIB_LIBRARIES} ${POLBACK_LIBRARIES} ${GIO_LIBRARIES})
set_target_properties (policyman_common PROPERTIES VERSION 0.1.0 SOVERSION 0)

install(TARGETS policyman_common DESTINATION ${CMAKE_INSTALL_PREFIX}/lib)