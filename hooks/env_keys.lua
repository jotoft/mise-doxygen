--- Configure environment variables for doxygen
function PLUGIN:EnvKeys(ctx)
    local mainPath = ctx.path
    local sdkInfo = ctx.sdkInfo['doxygen']
    local path = sdkInfo.path

    return {
        {
            key = "PATH",
            value = path .. "/bin"
        }
    }
end
