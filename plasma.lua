abs = math.abs
floor = math.floor
sin = math.sin
cos = math.cos
sqrt = math.sqrt

--- @type function[]
--- Array of functions to create patterns
func = {
    --- @param x number
    --- @param y number
    --- @return integer Resulting value
    --- Pattern function 1
    function(x, y)
        return abs(floor(16 * (sin(x / a + t * c) + cos(y / b + t * d)))) % 16
    end,

    --- @param x number
    --- @param y number
    --- @return integer Resulting value
    --- Pattern function 2
    function(x, y)
        return abs(floor(16 * (sin(x / y) * a + t * b))) % 16
    end,

    --- @param x number
    --- @param y number
    --- @return integer Resulting value
    --- Pattern function 3
    function(x, y)
        return abs(floor(16 * (sin(sin(t * a) * c + (t * b) + sqrt(y * y * (y * c) + x * (x / d)))))) % 16
    end,
}

--- Current pattern function index
f = 1

--- @type integer[]
--- Array to store pattern values
p = {}

--- Time variable
t = 0

--- Time step
time = 0.02

--- Parameter 'a' for patterns
a = 3.0

--- Parameter 'b' for patterns
b = 5.0

--- Parameter 'c' for patterns
c = 1.0

--- Parameter 'd' for patterns
d = 1.1

--- Flag to switch between parameter adjustment and pattern selection
alt = false

--- Grid connection
g = grid.connect()

--- Main loop function
function tick()
    while true do
        t = t + (time * 0.1)
        process()
        redraw()
        grid_redraw()
        clock.sleep(1 / 60)
    end
end

--- Initialization function
function init()
    print("hello")
    process()
    redraw()
    clock.run(tick)
end

--- Process the pattern and populate the 'p' array
function process()
    for x = 1, 16 do
        for y = 1, 16 do
            p[y * 16 + x] = func[f](x, y)
        end
    end
end

--- Redraw the grid display
function grid_redraw()
    for y = 1, 16 do
        for x = 1, 16 do
            g:led(x, y, p[x + y * 16])
        end
    end
    g:refresh()
end

--- Handle encoder input
--- @param n number Encoder number
--- @param delta number Encoder delta value
function enc(n, delta)
    if n == 1 then
        if not alt then
            time = time + delta * 0.001
        else
            f = f + delta
            f = math.min(f, #func)
            f = math.max(f, 1)
        end
    elseif n == 2 then
        if not alt then
            a = a + delta * 0.01
        else
            c = c + delta * 0.01
        end
    elseif n == 3 then
        if not alt then
            b = b + delta * 0.01
        else
            d = d + delta * 0.01
        end
    end
end

--- Handle keypress
--- @param n number Key number
--- @param z number Key state (1 for pressed, 0 for released)
function key(n, z)
    if n == 1 then
        alt = z == 1
    end
end

--- Redraw the visual display
function redraw()
    screen.clear()
    for x = 1, 16 do
        for y = 1, 16 do
            screen.level(p[y * 16 + x])
            screen.pixel((x - 1) * 4, (y - 1) * 4)
            screen.fill()
        end
    end
    screen.level(15)
    screen.move(120, 10)
    screen.text("t")
    screen.move(115, 10)
    screen.text_right(time)
    screen.move(120, 20)
    screen.text("f")
    screen.move(115, 20)
    screen.text_right(f)
    screen.move(120, 30)
    screen.text("a")
    screen.move(115, 30)
    screen.text_right(a)
    screen.move(120, 40)
    screen.text("b")
    screen.move(115, 40)
    screen.text_right(b)
    screen.move(120, 50)
    screen.text("c")
    screen.move(115, 50)
    screen.text_right(c)
    screen.move(120, 60)
    screen.text("d")
    screen.move(115, 60)
    screen.text_right(d)
    screen.update()
end
