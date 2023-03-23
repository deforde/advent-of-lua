#!luajit

local function node_create(op, l, r, v)
	local n = {
		op = op,
		l = l,
		r = r,
		v = v,
	}
	return n
end

local function node_calc(nm, nodes)
	local n = nodes[nm]

	if n.op == nil then
		return n.v
	end

	local l = node_calc(n.l, nodes)
	local r = node_calc(n.r, nodes)

	if n.op == "+" then
		return l + r
	elseif n.op == "-" then
		return l - r
	elseif n.op == "*" then
		return l * r
	elseif n.op == "/" then
		return math.floor(l / r)
	end

	assert(false)
end

local function nodes_create()
	local nodes = {}

	for line in io.lines("problems/problem_21.txt") do
		local nm, l, op, r, v
		nm, l, op, r = string.match(line, "(%a+): (%a+) ([%+%-/%*]) (%a+)")
		if nm == nil then
			nm, v = string.match(line, "(%a+): (%d+)")
		end
		local n = node_create(op, l, r, v)
		nodes[nm] = n
	end

	return nodes
end

local function solve1()
	local nodes = nodes_create()
	return node_calc("root", nodes)
end

local function solve2()
	local nodes = nodes_create()
	nodes["root"].op = "-"
	local min = 0
	local max = 1000000000000000
	local n = nodes["humn"]
	n.v = max
	if node_calc("root", nodes) < 0 then
		local tmp = nodes["root"].l
		nodes["root"].l = nodes["root"].r
		nodes["root"].r = tmp
	end
	while true do
		n.v = math.floor((max - min) / 2) + min
		local delta = node_calc("root", nodes)
		if delta == 0 then
			while node_calc("root", nodes) == 0 do
				n.v = n.v - 1
			end
			n.v = n.v + 1
			break
		elseif delta > 0 then
			max = n.v
		else
			min = n.v
		end
	end
	return n.v
end

local ans = solve1()
assert(ans == 87457751482938)

ans = solve2()
assert(ans == 3221245824363)
