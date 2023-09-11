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

abs = math.abs
floor = math.floor
sin = math.sin
cos = math.cos
sqrt = math.sqrt

func = {
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

g = grid.connect()

function tick()
	while true do
		t = t+(time*0.1)
		process()
		redraw()
		grid_redraw()
		clock.sleep(1/60)
	end
end

function init()
	print("hello")
	process()
	redraw()
	clock.run(tick)
end

function process()
  for x=1,16 do
		for y=1,16 do
			p[y*16+x] = func[f](x,y)
		end
	end
end

function grid_redraw()
	for y=1,16 do
		for x=1,16 do
			g:led(x,y,p[x+y*16])
		end
	end
	g:refresh()
end


function enc(n,delta)
	if n==1 then
		if not alt then time = time + delta*0.001
		else
			f = f + delta
			f = math.min(f,#func)
			f = math.max(f,1)
		end
	elseif n==2 then
		if not alt then a = a + delta*0.01
		else c = c + delta*0.01 end
	elseif n==3 then
		if not alt then b = b + delta*0.01
		else d = d + delta*0.01 end
	end
end

function key(n,z)
	if n==1 then alt = z==1 end
end

function redraw()
	screen.clear()
  for x=1,16 do
		for y=1,16 do
			screen.level(p[y*16+x])
			screen.pixel((x-1)*4, (y-1)*4)
			screen.fill()
		end
	end
	screen.level(15)
	screen.move(120,10)
	screen.text("t")
	screen.move(115,10)
	screen.text_right(time)
	screen.move(120,20)
	screen.text("f")
	screen.move(115,20)
	screen.text_right(f)
	screen.move(120,30)
	screen.text("a")
	screen.move(115,30)
	screen.text_right(a)
	screen.move(120,40)
	screen.text("b")
	screen.move(115,40)
	screen.text_right(b)
	screen.move(120,50)
	screen.text("c")
	screen.move(115,50)
	screen.text_right(c)
	screen.move(120,60)
	screen.text("d")
	screen.move(115,60)
	screen.text_right(d)
	screen.update()
end

