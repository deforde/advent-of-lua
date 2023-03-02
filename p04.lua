#!luajit

local cnt1 = 0
local cnt2 = 0
for line in io.lines("problems/problem_04.txt") do
    local nums = {}
    local idx = 1
    for num in string.gmatch(line, "[0-9]+") do
        nums[idx] = tonumber(num)
        idx = idx + 1
    end
    if (nums[1] >= nums[3] and nums[2] <= nums[4]) or (nums[3] >= nums[1] and nums[4] <= nums[2]) then
        cnt1 = cnt1 + 1
    end
    local strt = math.max(nums[1], nums[3])
    local stop = math.min(nums[2], nums[4])
    if stop >= strt then
        cnt2 = cnt2 + 1
    end
end

assert(cnt1 == 534)
assert(cnt2 == 841)
