cmake_minimum_required(VERSION 3.10)
project(keydump C)

SET(CURSES_USE_NCURSES TRUE)

set(CMAKE_C_STANDARD 99)

if(MSVC)
	include_directories(../pdcurses)
	link_directories(../pdcurses)
endif()

add_executable(keydump keydump.c)

if(MSVC)
	target_link_libraries(keydump PRIVATE pdcurses)
else()
	target_link_libraries(keydump PRIVATE curses)
endif()
