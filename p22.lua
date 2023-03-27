#!luajit

local function coord_create(r, c)
	local coord = {
		r = r,
		c = c,
	}
	return coord
end

local function coord_clone(pos)
	local coord = {
		r = pos.r,
		c = pos.c,
	}
	return coord
end

local function rotate(dir, rot)
	if rot == "R" then
		return dir % 4 + 1
	end
	if dir == 1 then
		return 4
	end
	return dir - 1
end

local function region_get(pos)
	if pos.c >= 1 and pos.c <= 50 then
		if pos.r >= 101 and pos.r <= 150 then
			return 5
		else
			return 6
		end
	elseif pos.c >= 51 and pos.c <= 100 then
		if pos.r >= 1 and pos.r <= 50 then
			return 1
		elseif pos.r >= 51 and pos.r <= 100 then
			return 3
		else
			return 4
		end
	elseif pos.c >= 101 and pos.c <= 150 then
		return 2
	end
	assert(false)
end

local function walk1(grid, nrows, ncols, pos, dir)
	local npos = coord_clone(pos)
	while true do
		if dir == 1 then
			npos.c = npos.c % ncols + 1
		elseif dir == 2 then
			npos.r = npos.r % nrows + 1
		elseif dir == 3 then
			npos.c = npos.c - 1
			if npos.c == 0 then
				npos.c = ncols
			end
		elseif dir == 4 then
			npos.r = npos.r - 1
			if npos.r == 0 then
				npos.r = nrows
			end
		end
		if grid[npos.r][npos.c] ~= nil then
			break
		end
	end
	if grid[npos.r][npos.c] == "#" then
		npos = coord_clone(pos)
	end
	return npos
end

local function walk2(grid, nros, ncols, pos, dir)
	local cur_reg = region_get(pos)
	local npos = coord_clone(pos)
	local ndir = dir
	if cur_reg == 1 then
		if dir == 1 then
			npos.c = npos.c + 1
		elseif dir == 2 then
			npos.r = npos.r + 1
		elseif dir == 3 then
			if npos.c == 51 then
				npos.r = 51 - ((npos.r - 1) % 50 + 1) + 100
				npos.c = 1
				ndir = 1
			else
				npos.c = npos.c - 1
			end
		else
			if npos.r == 1 then
				npos.r = (npos.c - 1) % 50 + 1 + 150
				npos.c = 1
				ndir = 1
			else
				npos.r = npos.r - 1
			end
		end
	elseif cur_reg == 2 then
		if dir == 1 then
			if npos.c == 150 then
				npos.r = 51 - ((npos.r - 1) % 50 + 1) + 100
				npos.c = 100
				ndir = 3
			else
				npos.c = npos.c + 1
			end
		elseif dir == 2 then
			if npos.r == 50 then
				npos.r = (npos.c - 1) % 50 + 1 + 50
				npos.c = 100
				ndir = 3
			else
				npos.r = npos.r + 1
			end
		elseif dir == 3 then
			npos.c = npos.c - 1
		else
			if npos.r == 1 then
				npos.r = 200
				npos.c = (npos.c - 1) % 50 + 1
				ndir = 4
			else
				npos.r = npos.r - 1
			end
		end
	elseif cur_reg == 3 then
		if dir == 1 then
			if npos.c == 100 then
				npos.c = (npos.r - 1) % 50 + 1 + 100
				npos.r = 50
				ndir = 4
			else
				npos.c = npos.c + 1
			end
		elseif dir == 2 then
			npos.r = npos.r + 1
		elseif dir == 3 then
			if npos.c == 51 then
				npos.c = (npos.r - 1) % 50 + 1
				npos.r = 101
				ndir = 2
			else
				npos.c = npos.c - 1
			end
		else
			npos.r = npos.r - 1
		end
	elseif cur_reg == 4 then
		if dir == 1 then
			if npos.c == 100 then
				npos.r = 51 - ((npos.r - 1) % 50 + 1)
				npos.c = 150
				ndir = 3
			else
				npos.c = npos.c + 1
			end
		elseif dir == 2 then
			if npos.r == 150 then
				npos.r = (npos.c - 1) % 50 + 1 + 150
				npos.c = 50
				ndir = 3
			else
				npos.r = npos.r + 1
			end
		elseif dir == 3 then
			npos.c = npos.c - 1
		else
			npos.r = npos.r - 1
		end
	elseif cur_reg == 5 then
		if dir == 1 then
			npos.c = npos.c + 1
		elseif dir == 2 then
			npos.r = npos.r + 1
		elseif dir == 3 then
			if npos.c == 1 then
				npos.r = 51 - ((npos.r - 1) % 50 + 1)
				npos.c = 51
				ndir = 1
			else
				npos.c = npos.c - 1
			end
		else
			if npos.r == 101 then
				npos.r = (npos.c - 1) % 50 + 1 + 50
				npos.c = 51
				ndir = 1
			else
				npos.r = npos.r - 1
			end
		end
	else
		if dir == 1 then
			if npos.c == 50 then
				npos.c = (npos.r - 1) % 50 + 1 + 50
				npos.r = 150
				ndir = 4
			else
				npos.c = npos.c + 1
			end
		elseif dir == 2 then
			if npos.r == 200 then
				npos.c = (npos.c - 1) % 50 + 1 + 100
				npos.r = 1
			else
				npos.r = npos.r + 1
			end
		elseif dir == 3 then
			if npos.c == 1 then
				npos.c = (npos.r - 1) % 50 + 1 + 50
				npos.r = 1
				ndir = 2
			else
				npos.c = npos.c - 1
			end
		else
			npos.r = npos.r - 1
		end
	end
	if grid[npos.r][npos.c] == "#" then
		npos = coord_clone(pos)
		ndir = dir
	end
	return npos, ndir
end

local function solve1()
	local ncols = 0
	local strt = coord_create(1, 1)
	local grid = {}
	local i = 1
	local strt_found = false
	local building_grid = true
	local pos = coord_create(1, 1)
	local nrows = 0
	local dir = 1
	for line in io.lines("problems/problem_22.txt") do
		if line == "" then
			building_grid = false
			pos = coord_clone(strt)
			nrows = i - 1
			-- dbg()
			goto continue
		end
		if building_grid then
			for j = 1, string.len(line) do
				local ch = string.sub(line, j, j)
				if strt_found == false and i == 1 and ch == "." then
					strt_found = true
					strt.c = j
				end
				if ch == "#" or ch == "." then
					if grid[i] == nil then
						grid[i] = {}
					end
					grid[i][j] = ch
				end
			end
			ncols = math.max(ncols, string.len(line))
			i = i + 1
		else
			for cnt, rot in string.gmatch(line, "(%d+)([LR]*)") do
				for _ = 1, cnt do
					pos = walk1(grid, nrows, ncols, pos, dir)
				end
				if rot ~= "" then
					dir = rotate(dir, rot)
				end
			end
		end
		::continue::
	end
	return 1000 * pos.r + 4 * pos.c + dir - 1
end

local function solve2()
	local ncols = 0
	local strt = coord_create(1, 1)
	local grid = {}
	local i = 1
	local strt_found = false
	local building_grid = true
	local pos = coord_create(1, 1)
	local nrows = 0
	local dir = 1
	for line in io.lines("problems/problem_22.txt") do
		if line == "" then
			building_grid = false
			pos = coord_clone(strt)
			nrows = i - 1
			-- dbg()
			goto continue
		end
		if building_grid then
			for j = 1, string.len(line) do
				local ch = string.sub(line, j, j)
				if strt_found == false and i == 1 and ch == "." then
					strt_found = true
					strt.c = j
				end
				if ch == "#" or ch == "." then
					if grid[i] == nil then
						grid[i] = {}
					end
					grid[i][j] = ch
				end
			end
			ncols = math.max(ncols, string.len(line))
			i = i + 1
		else
			for cnt, rot in string.gmatch(line, "(%d+)([LR]*)") do
				for _ = 1, cnt do
					pos, dir = walk2(grid, nrows, ncols, pos, dir)
				end
				if rot ~= "" then
					dir = rotate(dir, rot)
				end
			end
		end
		::continue::
	end
	return 1000 * pos.r + 4 * pos.c + dir - 1
end

local ans = solve1()
assert(ans == 27436)

ans = solve2()
assert(ans == 15426)
