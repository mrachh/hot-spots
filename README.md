# hot-spots
This project contains test scripts for testing the hot-spots conjecture

## Solvers

### test_helmholtz_dir_solver: solver for Dirichlet boundary + Helmholtz:
1. Changed kern('sprime') to kern('D') (The block under "compute D[sigma](x_in)")


### test_helmholtz_neu_solver: solver for Neumann boundary + Helmholtz


## Determinant

### helm_dir_det
1. The only change is I-2D, which assumes simply connectedness.
2. Checked error with bessel function is -3.58e-10
3. tested on polygon (without verifying analytical value)