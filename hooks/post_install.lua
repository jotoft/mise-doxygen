--- Build and install doxygen from source
function PLUGIN:PostInstall(ctx)
    local rootPath = ctx.rootPath
    local sdkInfo = ctx.sdkInfo['doxygen']
    local path = sdkInfo.path
    local version = sdkInfo.version
    local helper = require("lib.helper")
    local cmd = require("cmd")

    print("\n🔨 Building doxygen " .. version .. " from source...")

    -- Set up PATH for macOS Homebrew tools if needed
    local extra_path = helper.get_homebrew_build_tools_path()
    local build_env = ""
    if extra_path ~= "" then
        build_env = "PATH=" .. extra_path .. "$PATH "
        print("   Using Homebrew bison/flex")
    end

    -- Get parallel jobs count
    local jobs = helper.get_parallel_jobs()
    print("   Using " .. jobs .. " parallel jobs")

    -- Get compiler flags
    local cxx_flags = helper.get_cxx_flags()

    -- Create build directory
    local build_dir = path .. "/build"
    os.execute("mkdir -p " .. build_dir .. " 2>&1")

    -- Run CMake configuration (suppress output, only show on error)
    print("\n⚙️  Configuring with CMake...")
    local cmake_cmd = build_env .. "cmake -G \"Unix Makefiles\" " ..
        "-DCMAKE_INSTALL_PREFIX=\"" .. path .. "\" " ..
        "-DCMAKE_CXX_FLAGS=\"" .. cxx_flags .. "\" " ..
        "-S \"" .. path .. "\" " ..
        "-B \"" .. build_dir .. "\" > /dev/null 2>&1"

    local cmake_result = os.execute(cmake_cmd)
    if cmake_result ~= 0 then
        -- Re-run without suppression to show the error
        os.execute(build_env .. "cmake -G \"Unix Makefiles\" " ..
            "-DCMAKE_INSTALL_PREFIX=\"" .. path .. "\" " ..
            "-DCMAKE_CXX_FLAGS=\"" .. cxx_flags .. "\" " ..
            "-S \"" .. path .. "\" " ..
            "-B \"" .. build_dir .. "\"")
        error("CMake configuration failed")
    end

    -- Build with make (suppress output for clean UI)
    print("🏗️  Compiling with " .. jobs .. " parallel jobs (this may take a few minutes)...")
    print("    Tip: Use 'mise install --raw doxygen@version' to see build progress")
    local make_cmd = build_env .. "make -C \"" .. build_dir .. "\" -j" .. jobs .. " > /dev/null 2>&1"
    local make_result = os.execute(make_cmd)
    if make_result ~= 0 then
        -- Re-run without suppression to show the error
        print("\n⚠️  Compilation failed. Re-running to show errors:")
        os.execute(build_env .. "make -C \"" .. build_dir .. "\" -j" .. jobs)
        error("Compilation failed")
    end

    -- Install (suppress output, only show on error)
    print("\n📦 Installing...")
    local install_cmd = build_env .. "make -C \"" .. build_dir .. "\" install > /dev/null 2>&1"
    local install_result = os.execute(install_cmd)
    if install_result ~= 0 then
        -- Re-run without suppression to show the error
        os.execute(build_env .. "make -C \"" .. build_dir .. "\" install")
        error("Installation failed")
    end

    -- Clean up build artifacts to save space
    print("🧹 Cleaning up build artifacts...")
    os.execute("rm -rf \"" .. build_dir .. "\" 2>/dev/null")
    os.execute("find \"" .. path .. "\" -maxdepth 1 -type f -delete 2>/dev/null || true")
    os.execute("find \"" .. path .. "\" -maxdepth 1 -type d ! -name bin ! -name share ! -path \"" .. path .. "\" -exec rm -rf {} + 2>/dev/null || true")

    print("✅ doxygen " .. version .. " installed successfully!\n")
end
