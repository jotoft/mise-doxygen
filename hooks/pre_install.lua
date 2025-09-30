--- Download doxygen source code
function PLUGIN:PreInstall(ctx)
    local version = ctx.version
    local helper = require("lib.helper")

    -- Convert version to GitHub tag format (e.g., "1.9.1" -> "Release_1_9_1")
    local tag_version = helper.version_to_tag(version)

    -- Build source tarball URL
    local source_url = "https://github.com/doxygen/doxygen/archive/refs/tags/" .. tag_version .. ".tar.gz"

    return {
        version = version,
        url = source_url,
        -- Note: GitHub doesn't provide checksums in a standard location for source archives
        -- Users can verify releases manually via GPG signatures on the releases page
        note = "Downloading doxygen " .. version .. " source code for compilation"
    }
end
