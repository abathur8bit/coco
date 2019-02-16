cmake_minimum_required(VERSION 3.13)
project(gomokuc C)

set(CMAKE_C_STANDARD 99)
find_package(Curses REQUIRED)
include_directories(${CURSES_INCLUDE_DIR})

add_executable(gomokuc main.c)
target_link_libraries(gomokuc ${CURSES_LIBRARIES})
