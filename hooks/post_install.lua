--- Build and install doxygen from source
function PLUGIN:PostInstall(ctx)
    local rootPath = ctx.rootPath
    local sdkInfo = ctx.sdkInfo['doxygen']
    local path = sdkInfo.path
    local version = sdkInfo.version
    local helper = require("lib.helper")
    local cmd = require("cmd")

    print("Building doxygen " .. version .. " from source...")

    -- Set up PATH for macOS Homebrew tools if needed
    local extra_path = helper.get_homebrew_build_tools_path()
    local build_env = ""
    if extra_path ~= "" then
        build_env = "PATH=" .. extra_path .. "$PATH "
        print("Using Homebrew bison/flex from: " .. extra_path:gsub(":$", ""))
    end

    -- Get parallel jobs count
    local jobs = helper.get_parallel_jobs()
    print("Using " .. jobs .. " parallel jobs for compilation")

    -- Get compiler flags
    local cxx_flags = helper.get_cxx_flags()

    -- Create build directory
    local build_dir = path .. "/build"
    local result = os.execute("mkdir -p " .. build_dir)
    if result ~= 0 then
        error("Failed to create build directory")
    end

    -- Run CMake configuration
    print("Configuring with CMake...")
    local cmake_cmd = build_env .. "cmake -G \"Unix Makefiles\" " ..
        "-DCMAKE_INSTALL_PREFIX=\"" .. path .. "\" " ..
        "-DCMAKE_CXX_FLAGS=\"" .. cxx_flags .. "\" " ..
        "-S \"" .. path .. "\" " ..
        "-B \"" .. build_dir .. "\""

    result = os.execute(cmake_cmd)
    if result ~= 0 then
        error("CMake configuration failed")
    end

    -- Build with make
    print("Compiling (this may take a few minutes)...")
    local make_cmd = build_env .. "make -C \"" .. build_dir .. "\" -j" .. jobs
    result = os.execute(make_cmd)
    if result ~= 0 then
        error("Compilation failed")
    end

    -- Install
    print("Installing...")
    local install_cmd = build_env .. "make -C \"" .. build_dir .. "\" install"
    result = os.execute(install_cmd)
    if result ~= 0 then
        error("Installation failed")
    end

    -- Clean up build artifacts to save space
    print("Cleaning up build artifacts...")
    os.execute("rm -rf \"" .. build_dir .. "\"")

    -- Remove source files that are no longer needed
    os.execute("find \"" .. path .. "\" -maxdepth 1 -type f -delete 2>/dev/null || true")
    os.execute("find \"" .. path .. "\" -maxdepth 1 -type d ! -name bin ! -name share ! -path \"" .. path .. "\" -exec rm -rf {} + 2>/dev/null || true")

    print("doxygen " .. version .. " installed successfully!")
end
