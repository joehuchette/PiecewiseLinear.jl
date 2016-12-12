# PiecewiseLinear

A package for modeling optimization problems containing piecewise linear functions. Current support is for (the graphs of) continuous univariate functions.

[![Build Status](https://travis-ci.org/joehuchette/PiecewiseLinear.jl.svg?branch=master)](https://travis-ci.org/joehuchette/PiecewiseLinear.jl)

[![Coverage Status](https://coveralls.io/repos/joehuchette/PiecewiseLinear.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/joehuchette/PiecewiseLinear.jl?branch=master)

[![codecov.io](http://codecov.io/github/joehuchette/PiecewiseLinear.jl/coverage.svg?branch=master)](http://codecov.io/github/joehuchette/PiecewiseLinear.jl?branch=master)

This package offers helper functions for the [JuMP algebraic modeling language](https://github.com/JuliaOpt/JuMP.jl).

Consider a piecewise linear function. The function is described in terms of the breakpoints between pieces, and the function value at those breakpoints.

Consider a JuMP model

```julia
using JuMP
m = Model()
@variable(m, x)
```

To model the graph of a piecewise linear function ``f(x)``, take ``d`` as some set of breakpoints along the real line, and ``fd = [f(x) for x in d]`` as the corresponding function values. You can model this function in JuMP using the following function:

```julia
z = piecewiselinear(m, x, d, fd)
@objective(m, Min, z) # minimize f(x)
```

Current support is limited to modeling the graph of a continuous univariate piecewise linear function, with the goal of adding support for the epigraphs of lower semicontinuous multivariate piecewise linear functions.
