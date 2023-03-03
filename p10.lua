#!luajit

local function inc_cycle(vm)
    vm.cycle = vm.cycle + 1
    if ((vm.cycle - 19) % 40 == 0) then
        vm.sig_stren_sum = vm.sig_stren_sum + (vm.cycle + 1) * (vm.x - 1)
    end
    local idx = vm.cycle % 40 + 1
    local ch = "."
    if (idx >= (vm.x - 1) and idx <= (vm.x + 1)) then
        ch = "#"
    end
    vm.crt_line = string.sub(vm.crt_line, 1, idx - 1) .. ch .. string.sub(vm.crt_line, idx + 1)
    if (idx == #vm.crt_line) then
        print(vm.crt_line)
    end
end

local function exec(vm, op, val)
    if op == "noop" then
        inc_cycle(vm)
    else
        inc_cycle(vm)
        vm.x = vm.x + val
        inc_cycle(vm)
    end
end

local vm = {
    x = 2,
    cycle = 0,
    sig_stren_sum = 0,
    crt_line = '#.......................................',
}

for line in io.lines("problems/problem_10.txt") do
    local op = string.sub(line, string.find(line, "^%a+"))
    local val = nil
    if op == "addx" then
        val = string.sub(line, string.find(line, "[%d-]+$"))
    end
    exec(vm, op, val)
end

assert(vm.sig_stren_sum == 12880)
