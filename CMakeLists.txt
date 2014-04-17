
project(qhttpserver)

cmake_minimum_required(VERSION 2.8.11)

SET(QHTTPSERVER_MAIN true)

SET(qhttpserver_LIB_NAME "QHttpServer")
SET(qhttpserver_LIB_VERSION "0.0.1")


IF (NOT CMAKE_BUILD_TYPE)
    SET(CMAKE_BUILD_TYPE "DEBUG")
    message(STATUS "Setting CMAKE_BUILD_TYPE to: DEBUG")
ENDIF()


IF(MINGW)
    SET(CMAKE_CXX_FLAGS "-std=gnu++0x ${CMAKE_CXX_FLAGS}")
    SET(BUILD_CHAIN "mingw")
ELSEIF(UNIX)
    if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
        # using Clang
        set ( CMAKE_CXX_FLAGS "-std=c++11 ${CMAKE_CXX_FLAGS}")
        SET(BUILD_CHAIN "clang")
    elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
        # using GCC
        SET( CMAKE_CXX_FLAGS "-std=c++0x ${CMAKE_CXX_FLAGS}")
        SET(BUILD_CHAIN "gcc")
    endif()
       
    IF(APPLE)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -stdlib=libc++")
        message(STATUS "Apple Machine detected, Using libc++")
    ENDIF()
ENDIF()

message(STATUS "Found build chain: ${BUILD_CHAIN}")

SET(INCLUDE_OUTPUT_DIR "${CMAKE_BINARY_DIR}/include")
SET(INCLUDE_OUTPUT_UTIL_DIR "${INCLUDE_OUTPUT_DIR}/util")

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

set(CMAKE_AUTOMOC ON)

# Qt5:
find_package(Qt5Core REQUIRED)
find_package(Qt5Network REQUIRED)

SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DQHTTPSERVER_EXPORT")

# HTTP Parser:
include_directories("http-parser/")
SET( http-parser_SRCS 
    http-parser/http_parser.c
    )

SET(qhttpserver_SRC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src/")

# qhttpserver:

SET( qhttpserver_SRCS 
    src/qhttpconnection.cpp 
    src/qhttpresponse.cpp
    src/qhttprequest.cpp    
    src/qhttpserver.cpp
)

SET( qhttpserver_PUBLIC_HEADER
    src/qhttpserver.h
    src/qhttprequest.h
    src/qhttpresponse.h
    src/qhttpserverapi.h
    src/qhttpserverfwd.h
)

SET( qhttpserver_SHARE_CONFIGS
    share/libqhttpserver.pc
    share/QHttpServerConfig.cmake
)

add_custom_target(qhttpserver_headers)
INCLUDE_DIRECTORIES(${INCLUDE_OUTPUT_DIR})

IF("${CMAKE_BUILD_TYPE}" STREQUAL "RELEASE")
    MESSAGE(STATUS "Copying Headers for release")

    foreach(header ${qhttpserver_PUBLIC_HEADER})
        add_custom_command(
            TARGET qhttpserver_headers
            COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CURRENT_SOURCE_DIR}/${header} ${INCLUDE_OUTPUT_DIR}/${header}
            MAIN_DEPENDENCY ${header})
    endforeach()
else()
    INCLUDE_DIRECTORIES( ${qhttpserver_SRC_DIR})
endif()

include_directories(${INCLUDE_OUTPUT_DIR})

add_library(qhttpserver SHARED
    ${qhttpserver_SRCS}
    ${qhttpserver_PUBLIC_HEADER}
    ${http-parser_SRCS}
)

add_dependencies(qhttpserver
    qhttpserver_headers
)

target_link_libraries(qhttpserver
        #installed libs:
        Qt5::Network 
        Qt5::Core
    )

# configure:
SET(BINARY_SHARE_PATH "${CMAKE_CURRENT_BINARY_DIR}/share")
SET(INSTALL_SHARE_PATH "share/${qhttpserver_LIB_NAME}")

foreach(file ${qhttpserver_SHARE_CONFIGS})
    get_filename_component(file_NAME ${file} NAME)

    set(OUTPATH "${BINARY_SHARE_PATH}/${file_NAME}")
    configure_file(${file} "${OUTPATH}" @ONLY)

    install(FILES ${OUTPATH} DESTINATION ${INSTALL_SHARE_PATH})
endforeach()

# INSTALL components:

install(TARGETS qhttpserver
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib/static)

install(DIRECTORY src/
        DESTINATION "include/${qhttpserver_LIB_NAME}"
        FILES_MATCHING PATTERN "*.h" )

