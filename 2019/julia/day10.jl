using OffsetArrays

data = read(joinpath(@__DIR__, "./../data/day10.txt"), String)

function count_asteroids(data, x, y)
    data[x, y] != 1 && return 0
    line_of_sight = get_line_of_sight(data, x, y)
    return length(line_of_sight)
end

function distance(a1, a2)
    x1, y1 = a1
    x2, y2 = a2
    return √((x1 - x2)^2 + (y1-y2)^2)
end

function get_line_of_sight(data, x, y)
    line_of_sight = Dict{ComplexF64, Tuple{Int, Int}}()
    rows, cols = size(data)
    for c in 0:cols-1
        for r in 0:rows-1
            if x == c && y == r
                continue
            elseif data[c, r] == 1
                z = (x - c) + (y - r)*im
                z = round(z / abs(z), digits=4)
                if z ∉ keys(line_of_sight) || distance((c,r), (x, y)) < distance(line_of_sight[z], (x, y))
                    line_of_sight[z] = (c, r)
                end
            end
        end
    end
    return line_of_sight
end

function parse_asteroid_map(data::AbstractString)
    data = reshape([
        x == '#' ? 1 : 0
        for x in data if x != '\n'
        ],
        length(split(data)),
        length(split(data)[1]),
    )
    return OffsetArray(data, -1, -1)
end


function count_asteroids(data)
    data = parse_asteroid_map(data)
    max_asteroids = 0
    px = py = 0
    for x in 0:(size(data)[1]-1), y in 0:(size(data)[2]-1)
        c = count_asteroids(data, x, y)
        if c > max_asteroids
            max_asteroids = c
            px, py = x, y
        end
    end
    return max_asteroids, (px, py)
end

tdata = """
.#..#
.....
#####
....#
...##
""" |> strip

@assert count_asteroids(tdata) == (8, (3, 4))

tdata = """
......#.#.
#..#.#....
..#######.
.#.#.###..
.#..#.....
..#....#.#
#..#....#.
.##.#..###
##...#..#.
.#....####
"""

@assert count_asteroids(tdata) == (33, (5, 8))


tdata = """
#.#...#.#.
.###....#.
.#....#...
##.#.#.#.#
....#.#.#.
.##..###.#
..#...##..
..##....##
......#...
.####.###.
"""

@assert count_asteroids(tdata) == (35, (1, 2))

tdata = """
.#..#..###
####.###.#
....###.#.
..###.##.#
##.##.#.#.
....###..#
..#.#..#.#
#..#.#.###
.##...##.#
.....#.#..
"""

@assert count_asteroids(tdata) == (41, (6, 3))

tdata = """
.#..##.###...#######
##.############..##.
.#.######.########.#
.###.#######.####.#.
#####.##.#.##.###.##
..#####..#.#########
####################
#.####....###.#.#.##
##.#################
#####.##.###..####..
..######..##.#######
####.##.####...##..#
.#####..#.######.###
##...#.##########...
#.##########.#######
.####.#.###.###.#.##
....##.##.###..#####
.#.#.###########.###
#.#.#.#####.####.###
###.##.####.##.#..##
"""

@assert count_asteroids(tdata) == (210, (11, 13))

@assert count_asteroids(data) == (260, (14, 17))

function sort_by_angles(z)
    angle = atand(z.re, z.im)
    if angle < 0
        angle += 360
    end
    return angle
end

function find_asteroid_vaporization_order(data, x, y)
    data = parse_asteroid_map(data)
    los = get_line_of_sight(data, x, y)
    sorted_keys = reverse(sort([k for k in keys(los)], by = sort_by_angles))
    if sorted_keys[end] == 0.0 + 1.0im
        pushfirst!(sorted_keys, pop!(sorted_keys))
    end
    return los, sorted_keys
end
line_of_sight, sorted_keys = find_asteroid_vaporization_order(tdata, 11, 13)

@assert line_of_sight[sorted_keys[1]] == (11, 12)
@assert line_of_sight[sorted_keys[2]] == (12, 1)
@assert line_of_sight[sorted_keys[3]] == (12, 2)
@assert line_of_sight[sorted_keys[10]] == (12, 8)
@assert line_of_sight[sorted_keys[20]] == (16, 0)
@assert line_of_sight[sorted_keys[50]] == (16, 9)
@assert line_of_sight[sorted_keys[100]] == (10, 16)
@assert line_of_sight[sorted_keys[199]] == (9, 6)
@assert line_of_sight[sorted_keys[200]] == (8, 2)
@assert line_of_sight[sorted_keys[201]] == (10, 9)

line_of_sight, sorted_keys = find_asteroid_vaporization_order(data, 14, 17)
x, y = line_of_sight[sorted_keys[200]]
@assert (x)*100 + (y) == 608
