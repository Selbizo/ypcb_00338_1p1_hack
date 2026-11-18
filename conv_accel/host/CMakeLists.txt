cmake_minimum_required(VERSION 3.16)
project(conv_accel_host C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()
add_compile_options(-Wall -Wextra)

find_package(OpenCV REQUIRED COMPONENTS core imgproc imgcodecs highgui videoio features2d calib3d video)

# --- platform library -------------------------------------------------------
add_library(accel STATIC
    src/xdma.cpp
    src/pipeline.cpp
    src/userbar.cpp
    src/axidma.cpp
    src/conv2d.cpp
    src/filters.cpp
    src/deblur.cpp
    src/deblur_fpga.cpp
    src/deblur_cpu.cpp
    src/deblur_ocl.cpp
)
target_include_directories(accel PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${OpenCV_INCLUDE_DIRS}
)
target_link_libraries(accel PUBLIC ${OpenCV_LIBS})

# --- applications -----------------------------------------------------------
add_executable(conv_demo apps/conv_demo.cpp)
target_link_libraries(conv_demo PRIVATE accel)

add_executable(deblur_demo apps/deblur_demo.cpp)
target_link_libraries(deblur_demo PRIVATE accel)

add_executable(deblur_video apps/deblur_video.cpp)
target_link_libraries(deblur_video PRIVATE accel)

# low-level DDR3 round-trip test (no OpenCV needed)
add_executable(dma_pattern tests/dma_pattern.c)
