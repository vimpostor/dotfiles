cmake_minimum_required(VERSION 4.3)
project(project VERSION 0.1 DESCRIPTION "")

set(CMAKE_C_STANDARD 23)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

file(GLOB_RECURSE SRCS "src/*.c")

add_executable("${PROJECT_NAME}" ${SRCS})
