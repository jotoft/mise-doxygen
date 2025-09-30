--- Helper functions for mise-doxygen plugin
local M = {}

--- Normalize version string from GitHub tag format
--- Converts "Release_1_9_1" or "1_9_1" to "1.9.1"
--- @param tag_name string GitHub release tag name
--- @return string Normalized version string
function M.normalize_version(tag_name)
    -- Remove "Release_" prefix if present
    local version = tag_name:gsub("^Release_", "")
    -- Convert underscores to dots
    version = version:gsub("_", ".")
    return version
end

--- Convert version to GitHub tag format
--- Converts "1.9.1" to "Release_1_9_1"
--- @param version string Version string
--- @return string GitHub tag name
function M.version_to_tag(version)
    local tag = version:gsub("%.", "_")
    return "Release_" .. tag
end

--- Get number of parallel jobs for compilation
--- @return number Number of jobs to use with make -j
function M.get_parallel_jobs()
    local cmd = require("cmd")

    -- Try nproc (Linux)
    local result = cmd.exec("nproc 2>/dev/null || true")
    if result and result:match("%d+") then
        return tonumber(result:match("%d+"))
    end

    -- Try sysctl (macOS, BSD)
    result = cmd.exec("sysctl -n hw.ncpu 2>/dev/null || true")
    if result and result:match("%d+") then
        return tonumber(result:match("%d+"))
    end

    -- Default fallback
    return 2
end

--- Check if running on macOS
--- @return boolean True if macOS
function M.is_macos()
    return RUNTIME.osType == "Darwin"
end

--- Get macOS Homebrew paths for bison and flex
--- Returns PATH prefix string to use Homebrew versions instead of system versions
--- @return string PATH prefix or empty string
function M.get_homebrew_build_tools_path()
    if not M.is_macos() then
        return ""
    end

    local paths = {}

    -- Check Apple Silicon location first
    local homebrew_locations = {
        "/opt/homebrew/opt",
        "/usr/local/opt"
    }

    local tools = {"bison", "flex"}

    for _, location in ipairs(homebrew_locations) do
        for _, tool in ipairs(tools) do
            local tool_path = location .. "/" .. tool .. "/bin"
            -- Check if directory exists
            local check = os.execute("test -d " .. tool_path .. " 2>/dev/null")
            if check == 0 then
                table.insert(paths, tool_path)
            end
        end
    end

    if #paths > 0 then
        return table.concat(paths, ":") .. ":"
    end

    return ""
end

--- Get C++ compiler flags for compatibility
--- @return string Compiler flags
function M.get_cxx_flags()
    -- Detect compiler
    local cxx = os.getenv("CXX") or "c++"
    local cmd = require("cmd")
    local version_output = cmd.exec(cxx .. " --version 2>&1 || true")

    -- Check if using clang
    if version_output:lower():match("clang") then
        -- Clang-specific flag for template issues in older doxygen versions
        return "-Wno-error=missing-template-arg-list-after-template-kw"
    end

    return ""
end

return M
