# Part 1
# ======
#  We have a point: (x1, y1), and slope from (vx1, vy1) = vy1/ (m = vy1/vx1)
#  The equation of the line is: y - y1 = m*(x - x1) => y = m*x - m*x1 + y1
#  for h1 we have: y = m1*x - m1*x1 + y1 (m1=vy1/vx1)
#  for h2 we have: y = m2*x - m2*x2 + y2 (m2=vy2/vx2)
#    solving:      -----------------------------------
#                  0 = (m1 - m2)x -m1*x1+m2*x2 + y1-y2
#                      m2*x2 - m1*x1 + y1 - y2
#                  x = -------------------------
#                         m2 - m1
# 
# No intersection when m1 == m2
# From speed equation: y(t) = x0 + v*t, we can check when the hailstone was on the intersection position:
#                      y(t) - x0 = v*t
#                          y(t) - x0
#                      t = -----------
#                              v
#                     if t is negative, we disregard this, because the hailstones had intersected in the past
# 
#
# Part 2
# ======
# There would be a single line intersecting 3 or more lines in 3D (or 0 or Inf if lines are on the same plane).
# In the input there are no coplanar lines and none of the lines are overlapping.
# 
# For line 1:
#  x0 + t*vx0 = x1 + tvx1
#  t(vx0-vx1) = (x1 - x0)
#       x1 - x0
#  t = ------------
#       vx0 - vx1
# 
# for y-axis:
# 
#      y1 - y0
# t = ---------
#      vy0 - vy1
# 
# And similar for axiz z
# 
# So, we have (for x and y axes):
# 
# x1 - x0          y1 - y0
# ------------- = ---------
# vx0 - vx1       vy0 - vy1
# 
# x1*vy0 - x1*vy1 - x0*vy0 + x0*vy1 = y1*vx0 - y1*vx1 - y0*vx0 + y0*vx1
# x1*vy0 - x1*vy1 - x0*vy0 + x0*vy1 - y1*vx0 + y1*vx1 + y0*vx0 - y0*vx1 = 0
# 
# Swap around to get all fully unknowns to one side:
# yo*vx0 - x0*vy0 = x0*vy1 - y1*vx0 - y0*vx1 + x1*vy0 + (y1*vx1 - x1*vy1)
# For line 2:
# yo*vx0 - x0*vy0 = x0*vy2 - y2*vx0 - y0*vx2 + x2*vy0 + (y2*vx2 - x2*vy2)
# Note on the left we have the same unknows, so equate
# x0*vy1 - y1*vx0 - y0*vx1 + x1*vy0 + (y1*vx1 - x1*vy1) = x0*vy2 - y2*vx0 - y0*vx2 + x2*vy0 + (y2*vx2 - x2*vy2)
# 
# Shuffle around to get all unknows on the left and constants on the right:
# 
# (vy1 - vy2) * x0 + (y2 - y1) * vx0 + (vx2 - vx1) * y0 + (x1 - x2) * vy0 = y1*vx1 - x1*vy1 - y2*vx2 + x2*vy2
#               var              var                 var              var = known
# 
# we have 4 unknowns: [x0, vx0, y0, vy0], so we need 3 more lines to get system with 4 unknows and 4 equations
# 
# Then use the matrix form to solve the system:
# 
#  A*X = B, where
# 
# A is the coefficient matrix, X is the unknowns vector and B is the vector of known values on the right:
#                         A                            X                  B
# |(vy1 - vy2)  (y2 - y1)  (vx2 - vx1)  (x1 - x2)|   |x0 |   |y1*vx1 - x1*vy1 - y2*vx2 + x2*vy2|
# |(vy1 - vy3)  (y3 - y1)  (vx3 - vx1)  (x1 - x3)| * |vx0| = |y1*vx1 - x1*vy1 - y3*vx3 + x3*vy3|
# |(vy1 - vy4)  (y4 - y1)  (vx4 - vx1)  (x1 - x4)|   |y0 |   |y1*vx1 - x1*vy1 - y4*vx4 + x4*vy4|
# |(vy1 - vy5)  (y5 - y1)  (vx5 - vx1)  (x1 - x5)|   |vy0|   |y1*vx1 - x1*vy1 - y5*vx5 + x5*vy5|
# 
# The solve it:
#  X = inv(A)*B
# 
# To find z0, use the same method, but replace y__ with z__
# 

using LinearAlgebra

struct Hailstone
    pos::Vector{Int64}
    v::Vector{Int64}
end

function intersects_2d(h1::Hailstone, h2::Hailstone)::Union{Tuple{Int64, Int64},Nothing}
    x1, y1, _ = h1.pos
    vx1, vy1, _ = h1.v
    x2, y2, _ = h2.pos
    vx2, vy2, _ = h2.v

    m1 = vy1/vx1
    m2 = vy2/vx2
    if m1 == m2
        return nothing
    end
    x = (m2*x2 - m1*x1 + y1 - y2)/(m2 - m1)
    y =  m1*x - m1*x1 + y1

    t1 = (x - x1)/vx1
    t2 = (x - x2)/vx2

    if t1 < 0 || t2 < 0
        # they intersect in the past
        return nothing
    end

    if (x != 0 && abs(typemax(Int64)/x) < 1000) || (y != 0 && abs(typemax(Int64)/y) < 1000)
        # Well out of bounds
        return nothing
    end

    return (Int64(round(x*1000)), Int64(round(y*1000)))
end

function read_input(fn)
    open(fn) do f
        hailstones = []
        for line in readlines(f)
            line = strip(line)
            if line == ""
                continue
            end
            pos, vel = split(line, "@")
            pos = map(p -> parse(Int64, strip(p)), split(strip(pos), ","))
            vel = map(p -> parse(Int64, strip(p)), split(strip(vel), ","))
            push!(hailstones, Hailstone(
                pos,
                vel,
            ))
        end
        return hailstones
    end
end


function part1(hailstones)
    bs, be = (200000000000000*1000, 400000000000000*1000)

    result = 0
    for (i, h1) in enumerate(hailstones[1:end-1])
        for h2 in hailstones[i+1:end]
            res = intersects_2d(h1, h2)
            if res !== nothing
                x, y = res
                if x < bs || x > be || y < bs || y > be
                    continue
                end
                result += 1
            end
        end
    end

    return result
end


function part2(hailstones)
    h1 = hailstones[1]
    h2 = hailstones[2]
    h3 = hailstones[3]
    h4 = hailstones[4]
    h5 = hailstones[5]

    (x1, y1, z1),(vx1, vy1, vz1) = h1.pos, h1.v
    (x2, y2, z2),(vx2, vy2, vz2) = h2.pos, h2.v
    (x3, y3, z3),(vx3, vy3, vz3) = h3.pos, h3.v
    (x4, y4, z4),(vx4, vy4, vz4) = h4.pos, h4.v
    (x5, y5, z5),(vx5, vy5, vz5) = h5.pos, h5.v


    # Equation:
    # (vy1-vy2)*x0 + (y2-y1)*vx0 + (vx2-vx1)*y0 + (x1-x2)*vy0 = y1*vx1-x1*vy1-y2*vx2+x2*vy2
    # set up as matrix linear equation system:

    # Coeff matrix:
    A = [
        (vy1-vy2) (y2-y1) (vx2-vx1) (x1-x2);
        (vy1-vy3) (y3-y1) (vx3-vx1) (x1-x3);
        (vy1-vy4) (y4-y1) (vx4-vx1) (x1-x4);
        (vy1-vy5) (y5-y1) (vx5-vx1) (x1-x5);
    ]

    # Results vector
    B = [
        y1*vx1-x1*vy1-y2*vx2+x2*vy2,
        y1*vx1-x1*vy1-y3*vx3+x3*vy3,
        y1*vx1-x1*vy1-y4*vx4+x4*vy4,
        y1*vx1-x1*vy1-y5*vx5+x5*vy5,
    ]

    # X variables vector is: [x0, vx0, y0, vy0]

    X = inv(A) * B
    x0, _, y0, _ = [trunc(Int64, p) for p in X]

    # For z, do something similar, but replace y with z
    # Coeff matrix:
    A = [
        (vz1-vz2) (z2-z1) (vx2-vx1) (x1-x2);
        (vz1-vz3) (z3-z1) (vx3-vx1) (x1-x3);
        (vz1-vz4) (z4-z1) (vx4-vx1) (x1-x4);
        (vz1-vz5) (z5-z1) (vx5-vx1) (x1-x5);
    ]

    # Results vector
    B = [
        z1*vx1-x1*vz1-z2*vx2+x2*vz2,
        z1*vx1-x1*vz1-z3*vx3+x3*vz3,
        z1*vx1-x1*vz1-z4*vx4+x4*vz4,
        z1*vx1-x1*vz1-z5*vx5+x5*vz5,
    ]

    # Z variables vector is: [x0, vx0, z0, vz0]
    Z = inv(A) * B
    _, _, z0, _ = [trunc(Int64, p) for p in Z]
    return abs(x0 + y0 + z0)
end

@time println("Part 1: ", part1(read_input("input")))
@time println("Part 2: ", part2(read_input("input")))