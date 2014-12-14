# - Try to find QHttpServer
# Once done this will define
#  QHTTPSERVER_FOUND - System has QHttpServer
#  QHTTPSERVER_INCLUDE_DIRS - The QHttpServer include directories
#  QHTTPSERVER_LIBRARIES - The libraries needed to use QHttpServer
#  QHTTPSERVER_DEFINITIONS - Compiler switches required for using QHttpServer

find_package(PkgConfig)

pkg_check_modules(PC_QHTTPSERVER QUIET @QHttpServer_LIB_NAME@-@QHttpServer_LIB_VERSION@)

set(QHTTPSERVER_DEFINITIONS ${PC_QHTTPSERVER_CFLAGS_OTHER})

find_path(QHTTPSERVER_INCLUDE_DIR @QHttpServer_LIB_NAME@/qhttpserver.h
          HINTS ${PC_QHTTPSERVER_INCLUDEDIR} ${PC_QHTTPSERVER_INCLUDE_DIRS}
          PATH_SUFFIXES QHttpServer )

find_library(QHTTPSERVER_LIBRARY NAMES @QHttpServer_LIB_NAME@ lib@QHttpServer_LIB_NAME@
             HINTS ${PC_QHTTPSERVER_LIBDIR} ${PC_QHTTPSERVER_LIBRARY_DIRS} )

set(QHTTPSERVER_LIBRARIES ${QHTTPSERVER_LIBRARY} )
set(QHTTPSERVER_INCLUDE_DIRS ${QHTTPSERVER_INCLUDE_DIR} )

include(FindPackageHandleStandardArgs)

# handle the QUIETLY and REQUIRED arguments and set QHTTPSERVER_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(QHttpServer  DEFAULT_MSG
                                  QHTTPSERVER_LIBRARY QHTTPSERVER_INCLUDE_DIR)

mark_as_advanced(QHTTPSERVER_INCLUDE_DIR QHTTPSERVER_LIBRARY )

