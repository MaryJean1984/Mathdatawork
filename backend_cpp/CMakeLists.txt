cmake_minimum_required(VERSION 3.15)
project(MathDataBackend VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 包含目录
include_directories(include)

# 查找 Crow 框架 (需要本地安装或使用 vcpkg/conan)
find_package(Crow REQUIRED)

# 查找 MySQL Connector/C++ (需要本地安装)
# 实际项目中可能需要更复杂的查找逻辑
find_package(MySQL REQUIRED)

# 查找 hiredis (Redis 客户端)
find_package(hiredis REQUIRED)

# 源文件
file(GLOB_RECURSE SOURCES "src/*.cpp")

# 添加可执行文件
add_executable(${PROJECT_NAME} main.cpp ${SOURCES})

# 链接库
target_link_libraries(${PROJECT_NAME} PRIVATE
    Crow::Crow
    MySQL::MySQL
    hiredis::hiredis
    pthread
)