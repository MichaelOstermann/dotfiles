local Promise = require("lib.promise")
local Job = require("plenary.job")

local M = {
    Promise = Promise,
}

M.batch = function(fn)
    local inflight = nil
    return function(...)
        if inflight then
            return inflight
        end
        local next = fn(...)
        inflight = next
        inflight:finally(function()
            inflight = nil
        end)
        return next
    end
end

M.system = function(cmd, args, opts)
    return Promise(function(resolve, reject)
        local ok, err = pcall(function()
            Job:new({
                command = cmd,
                args = args or {},
                cwd = opts and opts.cwd or vim.uv.cwd(),
                on_exit = function(j, code)
                    if code == 0 then
                        resolve(table.concat(j:result(), "\n"))
                    else
                        reject(table.concat(j:stderr_result(), "\n"))
                    end
                end,
            }):start()
        end)

        if not ok then
            reject(err)
        end
    end)
end

M.prompt = function(prompt, initial)
    return Promise(vim.schedule_wrap(function(resolve, reject)
        vim.cmd.redraw()
        vim.ui.input({ prompt = prompt .. " ", default = initial }, function(result)
            if result == nil then
                reject("canceled")
            else
                resolve(result)
            end
        end)
    end))
end

M.success = function(message, use_output)
    return function(output)
        return Promise(vim.schedule_wrap(function(resolve)
            local msg = vim.trim(use_output and (message .. output) or message)
            vim.notify(msg)
            resolve(output)
        end))
    end
end

M.error = function(message, use_output)
    return function(output)
        if output == "canceled" then
            return
        end
        return Promise(vim.schedule_wrap(function(_, reject)
            local msg = vim.trim(use_output and (message .. output) or message)
            vim.notify(msg, vim.log.levels.ERROR)
            reject(output)
        end))
    end
end

M.print_error = M.error("", true)

return M
