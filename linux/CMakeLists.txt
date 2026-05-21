cmake_minimum_required(VERSION 3.13)
project(runner LANGUAGES CXX)

set(BINARY_NAME "ucakmodel")
cmake_policy(SET CMP0063 NEW)

set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/bundle" CACHE PATH "..." FORCE)
set(BUILD_BUNDLE_DIR "${PROJECT_BINARY_DIR}/bundle")
set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)

set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
add_subdirectory(${FLUTTER_MANAGED_DIR} ${CMAKE_CURRENT_BINARY_DIR}/flutter)

function(apply_standard_settings target)
  target_compile_features(${target} PUBLIC cxx_std_14)
  target_compile_options(${target} PRIVATE -Wall -Werror)
  target_compile_options(${target} PRIVATE "$<$<NOT:$<CONFIG:Debug>>:-O3>")
  set_target_properties(${target} PROPERTIES
    POSITION_INDEPENDENT_CODE ON)
endfunction()

find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK REQUIRED IMPORTED_TARGET gtk+-3.0)

add_subdirectory("runner")

include(flutter/generated_plugins.cmake)

set(INSTALL_BUNDLE_DATA_DIR "${CMAKE_INSTALL_PREFIX}/data")
set(INSTALL_BUNDLE_LIB_DIR "${CMAKE_INSTALL_PREFIX}/lib")

install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}"
    COMPONENT Runtime)
install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
    COMPONENT Runtime)
install(FILES "${FLUTTER_LIBRARY}" DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
    COMPONENT Runtime)

if(PLUGIN_BUNDLED_LIBRARIES)
  install(FILES "${PLUGIN_BUNDLED_LIBRARIES}"
      DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
      COMPONENT Runtime)
endif()

# ✅ flutter_assets'i kopyala
install(DIRECTORY "${CMAKE_SOURCE_DIR}/../build/flutter_assets"
    DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
    COMPONENT Runtime)

foreach(component ${FLUTTER_ADDITIONAL_FLUTTER_DATA_COMPONENTS})
  install(DIRECTORY "${component}/" DESTINATION "${INSTALL_BUNDLE_DATA_DIR}"
      COMPONENT Runtime)
endforeach()

# ✅ libflutter_angle_plugin.so'yu bundle root'a da kopyala
install(CODE "
  file(GLOB ANGLE_LIBS
    \"\${CMAKE_INSTALL_PREFIX}/lib/libflutter_angle_plugin.so\"
  )
  foreach(lib \${ANGLE_LIBS})
    file(COPY \${lib} DESTINATION \"\${CMAKE_INSTALL_PREFIX}\")
  endforeach()
")