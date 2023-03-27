#!luajit

local function from_snafu(str)
	local pos = string.len(str) - 1
	local n = 0
	for i = 1, string.len(str) do
		local ch = string.sub(str, i, i)
		if string.byte(ch) >= string.byte("0") and string.byte(ch) <= string.byte("9") then
			n = n + (string.byte(ch) - string.byte("0")) * 5 ^ pos
		elseif ch == "-" then
			n = n - 5 ^ pos
		else
			n = n - 2 * 5 ^ pos
		end
		pos = pos - 1
	end
	return n
end

local function to_snafu(n)
	local snafu = ""
	while n > 0 do
		local r = n % 5
		if r == 0 or r == 1 or r == 2 then
			snafu = snafu .. string.char(string.byte("0") + r)
		elseif r == 3 then
			snafu = snafu .. "="
			n = n + 5
		else
			snafu = snafu .. "-"
			n = n + 5
		end
		n = math.floor(n / 5)
	end
	snafu = string.reverse(snafu)
	return snafu
end

local function solve()
	local sum = 0
	for line in io.lines("problems/problem_25.txt") do
		sum = sum + from_snafu(line)
	end
	return to_snafu(sum)
end

local ans = solve()
assert(ans == "2-=2-0=-0-=0200=--21")
