-- plasma!
-- 
-- e1    time
-- k1+e1 func
-- e2    a
-- e3    b
-- k1+e2 c
-- k1+e3 d
--
-- submit new funcs!

local abs = math.abs
local floor = math.floor
local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt

local func = {
	function(x,y) return abs(floor(16*(sin(x/a + t*c) + cos(y/b + t*d))))%16 end, -- @tehn
	function(x,y) return abs(floor(16*(sin(x/y)*a + t*b)))%16 end, -- @tehn
	function(x,y) return abs(floor(16*(sin(sin(t*a)*c + (t*b) + sqrt(y*y*(y*c) + x*(x/d))))))%16 end, -- @mei
	function(x,y) return abs(floor(16*(sin(x/a + t*c) + cos(y/b + t*d) + (sin(x/a)/c))))%16 end, -- @jasonw22
	function(x,y) return abs(floor(16*(sin(x/a + t*c) + cos(y/b + (sin(x/a)*c) + (cos(y/b - t)*c*2 + cos(x/b+y/(a/2)+t*c*2))))))%16 end, -- @jasonw22
}

f = 1
p = {}
t = 0
time = 0.02
a = 3.0
b = 5.0
c = 1.0
d = 1.1
alt = false
cols = 16
rows = 16
density = 4
screen_mod = 0

g = grid.connect()

-- add params for modulation
params:add_separator('PLASMA')

params:add{
	id = 'function',
	name = 'function',
	type = 'number',
	min = 1,
	max = #func,
	default = 1,
	action = function(value)
		f = value
	end
}

params:add{
	id = 'time',
	name = 'time',
	type = 'control',
	controlspec = controlspec.new(-1, 1, 'lin', 0, 0.02),
	action = function(value)
		time = value
	end
}
params:add{
	id = 'a',
	name = 'a',
	type = 'control',
	controlspec = controlspec.new(-10, 10, 'lin', 0, 3.0),
	action = function(value)
		a = value
	end
}

params:add{
	id = 'b',
	name = 'b',
	type = 'control',
	controlspec = controlspec.new(-10, 10, 'lin', 0, 5.0),
	action = function(value)
		b = value
	end
}

params:add{
	id = 'c',
	name = 'c',
	type = 'control',
	controlspec = controlspec.new(-10, 10, 'lin', 0, 1.0),
	action = function(value)
		c = value
	end
}

params:add{
	id = 'd',
	name = 'd',
	type = 'control',
	controlspec = controlspec.new(-10, 10, 'lin', 0, 1.1),
	action = function(value)
		d = value
	end
}

params:add{
	id = "rotation",
	name = "rotation",
	type = "option",
	options = {"0", "90", "180", "270"},
	default = 1,
	action = function(value)
		g:rotation(value - 1)
	end
}

-- end params

function tick()
	while true do
		t = t+(time*0.1)
		process()
		grid_redraw()
		clock.sleep(1/60)
	end
end

-- synced 1/30fps screen rendering+refresh
function refresh()
  screen_mod = screen_mod + 1
  if screen_mod % 2 == 0 then
    redraw()
  end
end

function init()
  grid_size()
	process()
	clock.run(tick)
end

function grid.add(dev)
  grid_size()
end

-- adjusts viz to grid size, including nonstandard "virtual" grids
function grid_size()
  cols = g.cols > 0 and g.cols or 16
  rows = g.rows > 0 and g.rows or 16
	for y=1,rows do
		for x=1,cols do
			p[y*cols+x] = 0
		end
	end
  local density_cols = math.floor(101 / (cols + 1))
  local density_rows = math.floor(64 / (rows))
  density = math.min(density_cols, density_rows)
end  

function process()
  for x=1,cols do
		for y=1,rows do
  		local val = func[f](x,y)
  		p[y*cols+x] = val == val and val or 0 -- fix for some funcs generating NaN values
		end
	end
end

function grid_redraw()
	for y=1,rows do
		for x=1,cols do
			g:led(x,y,p[x+y*cols])
		end
	end
	g:refresh()
end

function enc(n,delta)
	if n==1 then
		if not alt then params:set('time', time + delta*0.001)
		else params:set('function', f + delta) end
	elseif n==2 then
		if not alt then params:set('a', a + delta*0.01)
		else params:set('c', c + delta*0.01) end
	elseif n==3 then
		if not alt then params:set('b', b + delta*0.01)
		else params:set('d', d + delta*0.01) end
	end
end

function key(n,z)
	if n==1 then alt = z==1 end
end

function redraw()
	screen.clear()
  for x=1,cols do
		for y=1,rows do
		  screen.level(p[y*cols+x])
			screen.pixel((x-1)*density, (y-1)*density)
			screen.fill()
		end
	end
	screen.level(15)
	screen.move(128,10)
	screen.text_right("t")
	screen.move(120,10)
	screen.text_right(string.format("%.3f", time))
	screen.move(128,20)
	screen.text_right("f")
	screen.move(120,20)
	screen.text_right(f)
	screen.move(128,30)
	screen.text_right("a")
	screen.move(120,30)
	screen.text_right(string.format("%.2f", a))
	screen.move(128,40)
	screen.text_right("b")
	screen.move(120,40)
	screen.text_right(string.format("%.2f", b))
	screen.move(128,50)
	screen.text_right("c")
	screen.move(120,50)
	screen.text_right(string.format("%.2f", c))
	screen.move(128,60)
	screen.text_right("d")
	screen.move(120,60)
	screen.text_right(string.format("%.2f", d))
  screen.update()
end