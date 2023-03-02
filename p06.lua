#!luajit

local function solve(buf, stm_cnt)
    for i = stm_cnt, string.len(buf) do
        local arr = {}
        for _ = 1, 26 do
            table.insert(arr, 0)
        end
        for j = i - stm_cnt + 1, i do
            local k = string.byte(string.sub(buf, j, j)) - string.byte("a") + 1
            if arr[k] == 1 then
                break
            end
            arr[k] = 1
            if j == i then
                return i
            end
        end
    end
end

local buf = io.input("problems/problem_06.txt"):read("*a")

local ans = solve(buf, 4)
assert(ans == 1876)

ans = solve(buf, 14)
assert(ans == 2202)
