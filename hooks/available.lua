--- List all available doxygen versions from GitHub releases
function PLUGIN:Available(ctx)
    local http = require("http")
    local json = require("json")
    local helper = require("lib.helper")

    -- Build request headers
    local headers = {}
    local github_token = os.getenv("GITHUB_API_TOKEN") or os.getenv("GITHUB_TOKEN")
    if github_token and github_token ~= "" then
        headers["Authorization"] = "token " .. github_token
    end

    -- Fetch releases from GitHub API
    local resp, err = http.get({
        url = "https://api.github.com/repos/doxygen/doxygen/releases",
        headers = headers
    })

    if err ~= nil then
        error("Failed to fetch doxygen releases: " .. err)
    end

    if resp.status_code ~= 200 then
        error("GitHub API returned status " .. resp.status_code .. ": " .. resp.body)
    end

    -- Parse JSON response
    local releases = json.decode(resp.body)
    local result = {}

    for _, release in ipairs(releases) do
        local tag_name = release.tag_name

        -- Filter for Release_* tags
        if tag_name:match("^Release_") then
            local version = helper.normalize_version(tag_name)

            -- Determine if this is a pre-release
            local note = nil
            if release.prerelease then
                note = "pre-release"
            end

            table.insert(result, {
                version = version,
                note = note
            })
        end
    end

    if #result == 0 then
        error("No doxygen releases found")
    end

    return result
end
