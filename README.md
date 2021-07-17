# hot-spots
This project contains test scripts for testing the hot-spots conjecture

## Solvers

### test_helmholtz_dir_solver: solver for Dirichlet boundary + Helmholtz:
1. Changed kern('sprime') to kern('D') (The block under "compute D[sigma](x_in)")


### test_helmholtz_neu_solver: solver for Neumann boundary + Helmholtz


## Determinant

### helm_dir_det
1. Added two ways to verify eigenfunction:
    a. analytical: 11 digits error; figure 4 plots the error; looks like white noise
    b. numerical: 10 digits error


## Gradient Descent

### test_gd
    1. The file contains tests for 1d and 2d functions (which covers rectangle parametrizations 
        and ellipse parametrizations). It should work for any function whose input is a one
        dimensional array (row vector).
    2. good cases: TEST1, TEST2, TEST4 converges
    3. bad cases: 
        TEST3 (nonconvex with two local minima)
        TEST5 (ill-conditioned, converges but slowly).


update dir when dragging
1. when chunkie uopdated, 1. update F 2. target 250 **2, -3 to 3
                        3. precompute quad
    when freq changed: 1. update F 2. precompute quad
    when direction changed:  1. boundary_data

debug by creating new buttons