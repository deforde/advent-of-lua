#!luajit

local DIR_NORTH = 1
local DIR_EAST= 2
local DIR_SOUTH = 3
local DIR_WEST = 4

local function coord_create(r, c)
	local coord = {
		r = r,
		c = c,
	}
	return coord
end

local function coord_init()
	return coord_init(0, 0)
end

local function map_insert(map, coord, dir_arr)
	local r = coord.r
	local c = coord.c
	if map[r] == nil then
		map[r] = {}
	end
	map[r][c] = dir_arr
end

local function map_update_entry(map, pos, dir)
	if map[pos.r] == nil or map[pos.r][pos.c] == nil then
		local dir_arr = {0,0,0,0}
		dir_arr[dir] = 1
		map_insert(map, pos, dir_arr)
	else
		local blizz = map[pos.r][pos.c]
		blizz[dir] = blizz[dir] + 1
		assert(blizz[dir] == 1)
	end
end

local function map_init()
	local map = {}
	local ncols = 0
	local r = 0
	for line in io.lines("problems/problem_24.txt") do
		if string.sub(line, 3, 3) == "#" or string.sub(line, string.len(line) - 2, string.len(line) - 2) == "#" then
			goto continue
		end
		for i = 2, string.len(line) - 1 do
			local ch = string.sub(line, i , i)
			if ch == "^" or ch == ">" or ch == "v" or ch == "<" then
				local dir_arr = {0,0,0,0}
				if ch == "^" then
					dir_arr[DIR_NORTH] = 1
				elseif ch == ">" then
					dir_arr[DIR_EAST] = 1
				elseif ch == "v" then
					dir_arr[DIR_SOUTH] = 1
				else
					dir_arr[DIR_WEST] = 1
				end
				local c = i - 2
				local coord = coord_create(r, c)
				map_insert(map, coord, dir_arr)
			end
		end
		ncols = string.len(line) - 2
		r = r + 1
		::continue::
	end
	local nrows = r
	return map, nrows, ncols
end

local function blizz_move(pos, dir, nrows, ncols)
	if dir == DIR_NORTH then
		if pos.r == 0 then
			return coord_create(nrows - 1, pos.c)
		end
		return coord_create(pos.r - 1, pos.c)
	elseif dir == DIR_EAST then
		if pos.c == ncols - 1 then
			return coord_create(pos.r, 0)
		end
		return coord_create(pos.r, pos.c + 1)
	elseif dir == DIR_SOUTH then
		if pos.r == nrows - 1 then
			return coord_create(0, pos.c)
		end
		return coord_create(pos.r + 1, pos.c)
	else
		if pos.c == 0 then
			return coord_create(pos.r, ncols - 1)
		end
		return coord_create(pos.r, pos.c - 1)
	end
	assert(false)
end

local function map_iterate(map, nrows, ncols)
	local nmap = {}
	for r, cs in pairs(map) do
		for c, dir_arr in pairs(cs) do
			local pos = coord_create(r, c)
			for dir, cnt in ipairs(dir_arr) do
				assert(cnt == 0 or cnt == 1)
				if cnt == 1 then
					local npos = blizz_move(pos, dir, nrows, ncols)
					map_update_entry(nmap, npos, dir)
				end
			end
		end
	end
	return nmap
end

local function map_print(map, nrows, ncols)
	for r = 0, nrows - 1 do
		local str = ""
		for c = 0, ncols - 1 do
			if map[r] == nil or map[r][c] == nil then
				str = str .. "."
			else
				for dir, v in ipairs(map[r][c]) do
					if v == 1 then
						if dir == DIR_NORTH then
							str = str .. "^"
						elseif dir == DIR_EAST then
							str = str .. ">"
						elseif dir == DIR_SOUTH then
							str = str .. "v"
						else
							str = str .. "<"
						end
						break
					end
				end
			end
		end
		print(str)
	end
	print()
end

local function moves_append_if_open(map, moves, pos)
	if map[pos.r] == nil or map[pos.r][pos.c] == nil then
		table.insert(moves, pos)
	end
end

local function moves_get_viable(map, pos, nrows, ncols)
	local moves = {}
	moves_append_if_open(map, moves, pos)
	if pos.r == -1 then
		moves_append_if_open(map, moves, coord_create(0, 0))
	elseif pos.r == nrows then
		moves_append_if_open(map, moves, coord_create(nrows - 1, ncols - 1))
	else
		if pos.r ~= 0 then
			moves_append_if_open(map, moves, coord_create(pos.r - 1, pos.c))
		end
		if pos.r ~= nrows - 1 then
			moves_append_if_open(map, moves, coord_create(pos.r + 1, pos.c))
		end
		if pos.c ~= 0 then
			moves_append_if_open(map, moves, coord_create(pos.r, pos.c - 1))
		end
		if pos.c ~= ncols - 1 then
			moves_append_if_open(map, moves, coord_create(pos.r, pos.c + 1))
		end
	end
	return moves
end

local function pathtips_is_contained(pathtips, pos)
	for _, pt in ipairs(pathtips) do
		if pt.r == pos.r and pt.c == pos.c then
			return true
		end
	end
	return false
end

local function pathtips_append_unique(pathtips, pos)
	if pathtips_is_contained(pathtips, pos) == false then
		table.insert(pathtips, pos)
	end
end

local function get_quickest_path(map, strt, stop, nrows, ncols)
	local pathtips = {strt}
	local min = 0
	while true do
		map = map_iterate(map, nrows, ncols)
		local npathtips = {}
		for _, pt in ipairs(pathtips) do
			local moves = moves_get_viable(map, pt, nrows, ncols)
			for _, move in ipairs(moves) do
				if move.r == stop.r and move.c == stop.c then
					-- map_print(map, nrows, ncols)
					-- print(min)
					return min + 1, map
				end
				pathtips_append_unique(npathtips, move)
			end
		end
		pathtips = npathtips
		min = min + 1
	end
end

local function solve1()
	local map, nrows, ncols = map_init()
	local strt = coord_create(-1, 0)
	local stop = coord_create(nrows - 1, ncols - 1)
	local dur, _ = get_quickest_path(map, strt, stop, nrows, ncols)
	return dur + 1
end

local function solve2()
	local map, nrows, ncols = map_init()
	local mins = 0

	local strt = coord_create(-1, 0)
	local stop = coord_create(nrows - 1, ncols - 1)
	local dur = 0
	dur, map = get_quickest_path(map, strt, stop, nrows, ncols)
	mins = mins + dur + 1

	strt = coord_create(nrows, ncols - 1)
	stop = coord_create(0, 0)
	dur, map = get_quickest_path(map, strt, stop, nrows, ncols)
	mins = mins + dur

	strt = coord_create(-1, 0)
	stop = coord_create(nrows - 1, ncols - 1)
	dur, map = get_quickest_path(map, strt, stop, nrows, ncols)
	mins = mins + dur

	return mins
end

local ans = solve1()
assert(ans == 238)

ans = solve2()
assert(ans == 751)
