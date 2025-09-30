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

    -- Run CMake configuration
    print("\n⚙️  Configuring with CMake...")
    local cmake_cmd = build_env .. "cmake -G \"Unix Makefiles\" " ..
        "-DCMAKE_INSTALL_PREFIX=\"" .. path .. "\" " ..
        "-DCMAKE_CXX_FLAGS=\"" .. cxx_flags .. "\" " ..
        "-S \"" .. path .. "\" " ..
        "-B \"" .. build_dir .. "\" 2>&1"

    local cmake_output = cmd.exec(cmake_cmd)
    if not cmake_output or cmake_output:match("CMake Error") then
        print(cmake_output)
        error("CMake configuration failed")
    end

    -- Build with make (capture output, only show on error)
    print("🏗️  Compiling (this may take a few minutes)...")
    local make_cmd = build_env .. "make -C \"" .. build_dir .. "\" -j" .. jobs .. " 2>&1"
    local make_output = cmd.exec(make_cmd)
    if not make_output or make_output:match("error:") or make_output:match("Error ") then
        print(make_output)
        error("Compilation failed")
    end

    -- Install
    print("📦 Installing...")
    local install_cmd = build_env .. "make -C \"" .. build_dir .. "\" install 2>&1"
    local install_output = cmd.exec(install_cmd)
    if not install_output or install_output:match("error:") then
        print(install_output)
        error("Installation failed")
    end

    -- Clean up build artifacts to save space
    print("🧹 Cleaning up build artifacts...")
    os.execute("rm -rf \"" .. build_dir .. "\" 2>/dev/null")
    os.execute("find \"" .. path .. "\" -maxdepth 1 -type f -delete 2>/dev/null || true")
    os.execute("find \"" .. path .. "\" -maxdepth 1 -type d ! -name bin ! -name share ! -path \"" .. path .. "\" -exec rm -rf {} + 2>/dev/null || true")

    print("✅ doxygen " .. version .. " installed successfully!\n")
end
