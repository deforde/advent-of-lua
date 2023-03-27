#!luajit

local function coord_create(x, y)
	local coord = {
		x = x,
		y = y,
	}
	return coord
end

local function coord_clone(c)
	local nc = {
		x = c.x,
		y = c.y,
	}
	return nc
end

local function map_insert(map, x, y, c)
	if map[x] == nil then
		map[x] = {}
	end
	map[x][y] = coord_clone(c)
end

local function map_create()
	local map = {}
	local y = 1
	for line in io.lines("problems/problem_23.txt") do
	-- for line in io.lines("/home/danielforde/dev/deforde/advent-of-zig/problems/example_23.txt") do
		for x = 1, string.len(line) do
			local ch = string.sub(line, x, x)
			if ch == "#" then
				map_insert(map, x, y, coord_create(x, y))
			end
		end
		y = y + 1
	end
	return map
end

local function map_clone(map)
	local nmap = {}
	for x, ys in pairs(map) do
		for y, c in pairs(ys) do
			map_insert(map, x, y, coord_clone(c))
		end
	end
	return nmap
end

local function map_move_elf(map, dirs, c)
	local cnt = 0
	for x = c.x - 1, c.x + 1 do
		for y = c.y - 1, c.y + 1 do
			if (c.x ~= x or c.y ~= y) and map[x] ~= nil and map[x][y] ~= nil then
				cnt = cnt + 1
			end
		end
	end
	if cnt == 0 then
		return c
	end

	for _, dir in ipairs(dirs) do
		if dir == 'N' then
			cnt = 0
			local y = c.y - 1
			for x = c.x - 1, c.x + 1 do
				if map[x] ~= nil and map[x][y] ~= nil then
					cnt = cnt + 1
				end
			end
			if cnt == 0 then
				return coord_create(c.x, c.y - 1)
			end
		elseif dir == 'E' then
			cnt = 0
			local x = c.x + 1
			for y = c.y - 1, c.y + 1 do
				if map[x] ~= nil and map[x][y] ~= nil then
					cnt = cnt + 1
				end
			end
			if cnt == 0 then
				return coord_create(c.x + 1, c.y)
			end
		elseif dir == 'S' then
			cnt = 0
			local y = c.y + 1
			for x = c.x - 1, c.x + 1 do
				if map[x] ~= nil and map[x][y] ~= nil then
					cnt = cnt + 1
				end
			end
			if cnt == 0 then
				return coord_create(c.x, c.y + 1)
			end
		else
			cnt = 0
			local x = c.x - 1
			for y = c.y - 1, c.y + 1 do
				if map[x] ~= nil and map[x][y] ~= nil then
					cnt = cnt + 1
				end
			end
			if cnt == 0 then
				return coord_create(c.x - 1, c.y)
			end
		end
	end
	return coord_clone(c)
end

local function map_sim(map, dirs)
	local nmap = {}
	local banned = {}
	local mv_cnt = 0
	for x, ys in pairs(map) do
		for y, _ in pairs(ys) do
			local kc = coord_create(x, y)
			local dst = map_move_elf(map, dirs, kc)
			if banned[dst.x] ~= nil and banned[dst.x][dst.y] ~= nil then
				map_insert(nmap, kc.x, kc.x, kc)
			else
				if nmap[dst.x] ~= nil and nmap[dst.x][dst.y] ~= nil then
					local src = coord_clone(nmap[dst.x][dst.y])
					nmap[dst.x][dst.y] = nil
					mv_cnt = mv_cnt - 1
					map_insert(nmap, src.x, src.y, src)
					map_insert(banned, dst.x, dst.y, dst)
					map_insert(nmap, kc.x, kc.y, kc)
				else
					map_insert(nmap, dst.x, dst.y, kc)
					if dst.x ~= kc.x or dst.y ~= kc.y then
						mv_cnt = mv_cnt + 1
					end
				end
			end
		end
	end

	local dir = table.remove(dirs, 1)
	table.insert(dirs, dir)

	local res = mv_cnt == 0
	return res, nmap
end

local function map_cnt_empty(map)
	local cnt = 0
	local xmin = 1000000000
	local xmax = -1000000000
	local ymin = 1000000000
	local ymax = -1000000000


	for x, ys in pairs(map) do
		for y, _ in pairs(ys) do
			xmin = math.min(xmin, x)
			xmax = math.max(xmax, x)
			ymin = math.min(ymin, y)
			ymax = math.max(ymax, y)
			cnt = cnt + 1
		end
	end

	cnt = (ymax - ymin + 1) * (xmax - xmin + 1) - cnt
	return cnt
end

local function map_print(map)
	local xmin = 1000000000
	local xmax = -1000000000
	local ymin = 1000000000
	local ymax = -1000000000


	for x, ys in pairs(map) do
		for y, _ in pairs(ys) do
			xmin = math.min(xmin, x)
			xmax = math.max(xmax, x)
			ymin = math.min(ymin, y)
			ymax = math.max(ymax, y)
		end
	end

	local str = ""
	for x = xmin, xmax do
		for y = ymin, ymax do
			if map[x] ~= nil and map[x][y] ~= nil then
				str = str .. "#"
			else
				str = str .. "."
			end
		end
		print(str)
		str = ""
	end
	print()
end

local function solve1()
	local map = map_create()
	-- map_print(map)
	local dirs = { 'N', 'S', 'W', 'E' }
	for _ = 1, 10 do
		_, map = map_sim(map, dirs)
		-- map_print(map)
	end
	return map_cnt_empty(map)
end

local function solve2()
	local map = map_create()
	local dirs = { 'N', 'S', 'W', 'E' }
	local i = 0
	local exit = false
	while exit == false do
		exit, map = map_sim(map, dirs)
		i = i + 1
	end
	return i
end

local ans = solve1()
assert(ans == 4091)

ans = solve2()
assert(ans == 1036)
