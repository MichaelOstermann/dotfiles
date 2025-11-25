local signals = require("utils.signals")
local au = require("utils.autocommand")

local function get_signature(result)
    if result and result.signatures and result.activeSignature then
        return result.signatures[result.activeSignature + 1]
    end
end

local function get_range(result)
    local signature = get_signature(result)
    if signature and signature.parameters and result.activeParameter then
        local parameter = signature.parameters[result.activeParameter + 1]
        if parameter and parameter.label[1] and parameter.label[2] and parameter.label[1] < parameter.label[2] then
            return {
                parameter.label[1] + 1,
                parameter.label[2],
            }
        end
    end
end

local function get_request_id()
    local buf = vim.api.nvim_get_current_buf()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    return buf .. ":" .. row .. ":" .. col
end

local function fetch_signature()
    local bufnr = 0
    local method = "textDocument/signatureHelp"

    local client = vim.lsp.get_clients({
        bufnr = bufnr,
        method = method,
    })[1]

    if not client then
        signals.signature:set(nil)
        return
    end

    local request_id = get_request_id()
    local params = vim.lsp.util.make_position_params(0, client.capabilities.general.positionEncodings[1])

    vim.lsp.buf_request(bufnr, method, params, function(err, result, ctx, config)
        if request_id ~= get_request_id() then
            return
        end

        local signature = get_signature(result)
        local range = get_range(result)

        if signature and range then
            signals.signature:set({
                hint = string.sub(signature.label, range[1], range[2]),
                label = signature.label,
                range = range,
            })
        elseif signature then
            signals.signature:set({
                hint = signature.label,
                label = signature.label,
            })
        else
            signals.signature:set(nil)
        end
    end)
end

au("CursorHold", fetch_signature)
au("CursorHoldI", fetch_signature)
