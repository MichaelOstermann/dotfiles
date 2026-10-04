local M = {}
M.__index = M

function M.of(path)
    return setmetatable({
        path = path or "",
    }, M)
end

function M:eq(path)
    return self.path == path.path
end

function M:is_empty()
    return self.path == ""
end

function M:filetype()
    self.ft = self.ft or vim.filetype.match({ filename = self.path }) or ""
    return self.ft
end

function M:read(cb)
    if self:is_empty() then
        cb("")
    else
        local path = self.path
        vim.uv.fs_open(path, "r", 438, function(_, fd)
            local stat = fd and vim.uv.fs_fstat(fd)
            local contents = stat and vim.uv.fs_read(fd, stat.size, 0)
            if fd then
                vim.uv.fs_close(fd)
            end
            vim.schedule(function()
                cb(contents or "")
            end)
        end)
    end
end

function M:read_lines(cb)
    return self:read(function(contents)
        cb(vim.split(contents, "\n", { plain = true }))
    end)
end

function M:edit()
    if self:is_empty() then
        return
    end

    local buf = vim.fn.bufnr("^" .. self.path .. "$")

    if buf ~= -1 and vim.api.nvim_buf_is_loaded(buf) then
        vim.api.nvim_set_current_buf(buf)
    else
        vim.cmd("edit " .. vim.fn.fnameescape(self.path))
    end

    return self
end

return M
