local Range = require("utils.Range")

local M = {}

M.request_locations = function(win, buf, method, ctx, callback)
    local clients = vim.tbl_filter(function(client)
        return client:supports_method(method, buf)
    end, vim.lsp.get_clients())

    local list = {}
    local pending = #clients

    if pending == 0 then
        return callback(list)
    end

    local canceled = false
    local requests = {}

    for _, client in ipairs(clients) do
        local params = vim.lsp.util.make_position_params(win, client.offset_encoding)
        params.context = ctx

        local status, request_id = client:request(method, params, function(_, result)
            if canceled then
                return
            end

            local items = vim.lsp.util.locations_to_items(result or {}, client.offset_encoding)

            for _, item in ipairs(items) do
                table.insert(list, {
                    path = vim.fs.relpath(vim.fn.getcwd(), item.filename),
                    text = item.text,
                    range = Range.empty()
                        :set_anchor_row(item.lnum)
                        :set_anchor_col(item.col - 1)
                        :set_focus_row(item.end_lnum)
                        :set_focus_col(item.end_col - 1),
                })
            end

            requests[client] = nil
            pending = pending - 1

            if pending == 0 then
                callback(list)
            end
        end)

        if status and request_id then
            requests[client] = request_id
        end
    end

    return {
        cancel = function()
            canceled = true
            for client, request_id in pairs(requests) do
                client:cancel_request(request_id)
                requests[client] = nil
            end
        end,
    }
end

return M
