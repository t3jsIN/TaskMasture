# Install script for directory: C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/windows

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "$<TARGET_FILE_DIR:taskmasture_clean>")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/flutter/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/plugins/bitsdojo_window_windows/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/plugins/file_selector_windows/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/plugins/screen_retriever/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/plugins/system_tray/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/plugins/tray_manager/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/plugins/window_manager/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/plugins/window_size/cmake_install.cmake")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Debug/taskmasture_clean.exe")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Debug" TYPE EXECUTABLE FILES "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Debug/taskmasture_clean.exe")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Profile/taskmasture_clean.exe")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Profile" TYPE EXECUTABLE FILES "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Profile/taskmasture_clean.exe")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Release/taskmasture_clean.exe")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Release" TYPE EXECUTABLE FILES "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Release/taskmasture_clean.exe")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Debug/data/icudtl.dat")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Debug/data" TYPE FILE FILES "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/windows/flutter/ephemeral/icudtl.dat")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Profile/data/icudtl.dat")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Profile/data" TYPE FILE FILES "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/windows/flutter/ephemeral/icudtl.dat")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Release/data/icudtl.dat")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Release/data" TYPE FILE FILES "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/windows/flutter/ephemeral/icudtl.dat")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Debug/flutter_windows.dll")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Debug" TYPE FILE FILES "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/windows/flutter/ephemeral/flutter_windows.dll")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Profile/flutter_windows.dll")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Profile" TYPE FILE FILES "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/windows/flutter/ephemeral/flutter_windows.dll")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Release/flutter_windows.dll")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Release" TYPE FILE FILES "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/windows/flutter/ephemeral/flutter_windows.dll")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Debug/bitsdojo_window_windows_plugin.lib;C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Debug/file_selector_windows_plugin.dll;C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Debug/screen_retriever_plugin.dll;C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Debug/system_tray_plugin.dll;C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Debug/tray_manager_plugin.dll;C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Debug/window_manager_plugin.dll;C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Debug/window_size_plugin.dll")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Debug" TYPE FILE FILES
      "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/plugins/bitsdojo_window_windows/Debug/bitsdojo_window_windows_plugin.lib"
      "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/plugins/file_selector_windows/Debug/file_selector_windows_plugin.dll"
      "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/plugins/screen_retriever/Debug/screen_retriever_plugin.dll"
      "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/plugins/system_tray/Debug/system_tray_plugin.dll"
      "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/plugins/tray_manager/Debug/tray_manager_plugin.dll"
      "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/plugins/window_manager/Debug/window_manager_plugin.dll"
      "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/plugins/window_size/Debug/window_size_plugin.dll"
      )
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Profile/bitsdojo_window_windows_plugin.lib;C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Profile/file_selector_windows_plugin.dll;C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Profile/screen_retriever_plugin.dll;C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Profile/system_tray_plugin.dll;C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Profile/tray_manager_plugin.dll;C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Profile/window_manager_plugin.dll;C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Profile/window_size_plugin.dll")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Profile" TYPE FILE FILES
      "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/plugins/bitsdojo_window_windows/Profile/bitsdojo_window_windows_plugin.lib"
      "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/plugins/file_selector_windows/Profile/file_selector_windows_plugin.dll"
      "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/plugins/screen_retriever/Profile/screen_retriever_plugin.dll"
      "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/plugins/system_tray/Profile/system_tray_plugin.dll"
      "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/plugins/tray_manager/Profile/tray_manager_plugin.dll"
      "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/plugins/window_manager/Profile/window_manager_plugin.dll"
      "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/plugins/window_size/Profile/window_size_plugin.dll"
      )
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Release/bitsdojo_window_windows_plugin.lib;C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Release/file_selector_windows_plugin.dll;C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Release/screen_retriever_plugin.dll;C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Release/system_tray_plugin.dll;C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Release/tray_manager_plugin.dll;C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Release/window_manager_plugin.dll;C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Release/window_size_plugin.dll")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Release" TYPE FILE FILES
      "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/plugins/bitsdojo_window_windows/Release/bitsdojo_window_windows_plugin.lib"
      "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/plugins/file_selector_windows/Release/file_selector_windows_plugin.dll"
      "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/plugins/screen_retriever/Release/screen_retriever_plugin.dll"
      "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/plugins/system_tray/Release/system_tray_plugin.dll"
      "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/plugins/tray_manager/Release/tray_manager_plugin.dll"
      "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/plugins/window_manager/Release/window_manager_plugin.dll"
      "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/plugins/window_size/Release/window_size_plugin.dll"
      )
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Debug/")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Debug" TYPE DIRECTORY FILES "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/native_assets/windows/")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Profile/")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Profile" TYPE DIRECTORY FILES "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/native_assets/windows/")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Release/")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Release" TYPE DIRECTORY FILES "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/native_assets/windows/")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    
  file(REMOVE_RECURSE "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Debug/data/flutter_assets")
  
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee])$")
    
  file(REMOVE_RECURSE "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Profile/data/flutter_assets")
  
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    
  file(REMOVE_RECURSE "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Release/data/flutter_assets")
  
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Debug/data/flutter_assets")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Debug/data" TYPE DIRECTORY FILES "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build//flutter_assets")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Profile/data/flutter_assets")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Profile/data" TYPE DIRECTORY FILES "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build//flutter_assets")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Release/data/flutter_assets")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Release/data" TYPE DIRECTORY FILES "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build//flutter_assets")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "Runtime" OR NOT CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Pp][Rr][Oo][Ff][Ii][Ll][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Profile/data/app.so")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Profile/data" TYPE FILE FILES "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/app.so")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    list(APPEND CMAKE_ABSOLUTE_DESTINATION_FILES
     "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Release/data/app.so")
    if(CMAKE_WARN_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(WARNING "ABSOLUTE path INSTALL DESTINATION : ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    if(CMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION)
      message(FATAL_ERROR "ABSOLUTE path INSTALL DESTINATION forbidden (by caller): ${CMAKE_ABSOLUTE_DESTINATION_FILES}")
    endif()
    file(INSTALL DESTINATION "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/runner/Release/data" TYPE FILE FILES "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/app.so")
  endif()
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
if(CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_COMPONENT MATCHES "^[a-zA-Z0-9_.+-]+$")
    set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
  else()
    string(MD5 CMAKE_INST_COMP_HASH "${CMAKE_INSTALL_COMPONENT}")
    set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INST_COMP_HASH}.txt")
    unset(CMAKE_INST_COMP_HASH)
  endif()
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "C:/Users/t3jss/flutterbeam/flutterbeam/taskmasture_clean/build/windows/x64/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
