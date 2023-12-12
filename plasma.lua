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

f = 1
p = {}
t = 0
time = 0.02
a = 3.0
b = 5.0
c = 1.0
d = 1.1
alt = false
local cols = 16
local rows = 16
local func = {
	function(x,y) return abs(floor(16*(sin(x/a + t*c) + cos(y/b + t*d))))%16 end, -- @tehn
	function(x,y) return abs(floor(16*(sin(x/y)*a + t*b)))%16 end, -- @tehn
	function(x,y) return abs(floor(16*(sin(sin(t*a)*c + (t*b) + sqrt(y*y*(y*c) + x*(x/d))))))%16 end, -- @mei
	function(x,y) return abs(floor(16*(sin(x/a + t*c) + cos(y/b + t*d) + (sin(x/a)/c))))%16 end, -- @jasonw22
	function(x,y) return abs(floor(16*(sin(x/a + t*c) + cos(y/b + (sin(x/a)*c) + (cos(y/b - t)*c*2 + cos(x/b+y/(a/2)+t*c*2))))))%16 end, -- @jasonw22
}


local g = grid.connect()


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

function refresh()
  redraw()  -- still getting 'screen event Q full' errors
end

function init()
  cols = g.cols
  rows = g.rows
	process()
	clock.run(tick)
end

function grid.add(dev)
  cols = g.cols
  rows = g.rows
end

function process()
  for x=1,cols do
		for y=1,rows do
			p[y*16+x] = func[f](x,y)
		end
	end
end

function grid_redraw()
	for y=1,rows do
		for x=1,cols do
			g:led(x,y,p[x+y*16])
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
			-- todo look into issue drawing nils with some funcs
			-- screen.level(p[y*16+x])
      screen.level(p[y*16+x] or 0)
			screen.pixel((x-1)*4, (y-1)*4)
			screen.fill()
		end
	end
	screen.level(15)
	screen.move(120,10)
	screen.text("t")
	screen.move(115,10)
	screen.text_right(string.format("%.3f", time))
	screen.move(120,20)
	screen.text("f")
	screen.move(115,20)
	screen.text_right(f)
	screen.move(120,30)
	screen.text("a")
	screen.move(115,30)
	screen.text_right(string.format("%.2f", a))
	screen.move(120,40)
	screen.text("b")
	screen.move(115,40)
	screen.text_right(string.format("%.2f", b))
	screen.move(120,50)
	screen.text("c")
	screen.move(115,50)
	screen.text_right(string.format("%.2f", c))
	screen.move(120,60)
	screen.text("d")
	screen.move(115,60)
	screen.text_right(string.format("%.2f", d))
	screen.update()
end

