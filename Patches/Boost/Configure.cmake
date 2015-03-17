include(${CMAKE_CURRENT_LIST_DIR}/Common.cmake)

message("Boost.Configure: Using toolset=${BOOST_TOOLSET}")

message("Boost.Configure: Creating custom user-config.jam")
if(NOT CMAKE_CXX_COMPILER_ID MATCHES MSVC)
  file(WRITE ${Boost_SOURCE_DIR}/tools/build/v2/user-config.jam "
using ${BOOST_TOOLSET} : : \"${CMAKE_CXX_COMPILER}\" ;
"
  )
endif()

if(WIN32)
  set(BOOTSTRAP ${Boost_SOURCE_DIR}/bootstrap.bat)
else()
  set(BOOTSTRAP ${Boost_SOURCE_DIR}/bootstrap.sh)
endif()
execute_command_wrapper(
  "Boost.Configure.Bootstrap"
  ${Boost_SOURCE_DIR}
  ${BOOTSTRAP}
)

# Note: BCP has known issues with some msvc release builds so we always build
# it in debug.
execute_command_wrapper(
  "Boost.Configure.BCP.Build"
  ${Boost_SOURCE_DIR}/tools/bcp
  ${Boost_SOURCE_DIR}/b2${CMAKE_EXECUTABLE_SUFFIX}
  variant=debug ${B2_ARGS}
)

execute_command_wrapper(
  "Boost.Configure.BCP.Exec"
  ${Boost_SOURCE_DIR}
  ${Boost_SOURCE_DIR}/dist/bin/bcp${CMAKE_EXECUTABLE_SUFFIX}
  --boost=${Boost_SOURCE_DIR} build config
  lexical_cast smart_ptr foreach uuid assign asio function_types
  typeof iostreams algorithm accumulators
  context date_time thread filesystem regex chrono system signals2 timer
  integer property_tree graph spirit fusion
  ${Boost_BUILD_DIR}
)