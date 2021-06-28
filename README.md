# hot-spots
This project contains test scripts for testing the hot-spots conjecture

## Solvers

### test_helmholtz_dir_solver: solver for Dirichlet boundary + Helmholtz:
1. Changed kern('sprime') to kern('D') (The block under "compute D[sigma](x_in)")


### test_helmholtz_neu_solver: solver for Neumann boundary + Helmholtz


## Determinant

### helm_dir_det
1. Added two ways to verify eigenfunction:
    a. analytical: error has the same scale as hx, but it is not white noise
    b. numerical: same error as above
