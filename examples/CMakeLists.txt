cmake_minimum_required(VERSION 3.5)

find_package(SndFile REQUIRED)
find_package(cxxopts REQUIRED)
find_package(fmt REQUIRED)
find_package(mimalloc REQUIRED)

add_executable(fvadwav fvadwav.c)
target_link_libraries(
    fvadwav
    PRIVATE
    fvad
    SndFile::sndfile
    cxxopts::cxxopts
    fmt::fmt
    mimalloc-static
)
install(TARGETS fvadwav DESTINATION bin)
