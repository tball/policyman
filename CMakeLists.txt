project("policyman" C)

cmake_minimum_required(VERSION 2.6)

list(APPEND CMAKE_MODULE_PATH
    ${CMAKE_SOURCE_DIR}/cmake/vala
)

find_package(Vala REQUIRED)
include(UseVala)
include(GNUInstallDirs)

set(POLICYMAN_DATADIR ${CMAKE_INSTALL_DATADIR}/policyman)
set(POLICYMAN_FULL_DATADIR ${CMAKE_INSTALL_FULL_DATADIR}/policyman)
set(POLKIT_ACTIONDIR ${CMAKE_INSTALL_FULL_DATADIR}/polkit-1/actions)
set(POLKIT_EXPLICIT_VAR_DIR /${CMAKE_INSTALL_LOCALSTATEDIR}/lib/polkit-1/localauthority)
set(POLKIT_EXPLICIT_ETC_DIR /${CMAKE_INSTALL_SYSCONFDIR}/polkit-1/localauthority)
set(POLICYMAN_COMMON_INCLUDE_DIR ${CMAKE_BINARY_DIR}/libpolicyman_common)
set(POLICYMAN_ACTIONMANAGER_INCLUDE_DIR ${CMAKE_BINARY_DIR}/libpolicyman_actionmanager)

add_subdirectory(libpolicyman_common)
add_subdirectory(libpolicyman_actionmanager)
add_subdirectory(policyman_helper)
add_subdirectory(policyman)

