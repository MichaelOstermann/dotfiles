local M = {}

function M.trim_to(max, parts)
    local left, right = unpack(parts)
    local len_l, len_r = #left, #right

    local excess = len_l + len_r - max

    if excess <= 0 then
        return left, right
    end

    local remove_from_left = 0
    local remove_from_right = 0

    if len_l > len_r then
        local diff = len_l - len_r
        local to_remove = math.min(excess, diff)
        remove_from_left = to_remove
        excess = excess - to_remove
    elseif len_r > len_l then
        local diff = len_r - len_l
        local to_remove = math.min(excess, diff)
        remove_from_right = to_remove
        excess = excess - to_remove
    end

    if excess > 0 then
        local from_each = math.floor(excess / 2)
        remove_from_left = remove_from_left + from_each
        remove_from_right = remove_from_right + from_each + (excess % 2)
    end

    if remove_from_left > 0 then
        remove_from_left = remove_from_left + 1
    end

    if remove_from_right > 0 then
        remove_from_right = remove_from_right + 1
    end

    remove_from_left = math.min(remove_from_left, len_l)
    remove_from_right = math.min(remove_from_right, len_r)

    local final_left = remove_from_left > 0 and "…" .. string.sub(left, remove_from_left + 1)
        or left

    local final_right = remove_from_right > 0
            and string.sub(right, 1, len_r - remove_from_right) .. "…"
        or right

    return final_left, final_right
end

return M
