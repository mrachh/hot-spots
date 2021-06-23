# hot-spots
This project contains test scripts for testing the hot-spots conjecture

## Solvers

### test_helmholtz_dir_solver: solver for Dirichlet boundary + Helmholtz:
1. Digits seems correct, but I don't see convergence. (i.e shrinking the MAX_CHUNK_LEN 
    variable does not reduce error.) Is "cparams.eps" a bottleneck?
2. I don't know how to clear unnecessary outputs in matlab. E.g my code prints out all weights 
    whenever I call the weight(chnkr)


### test_helmholtz_neu_solver: solver for Neumann boundary + Helmholtz


## Determinant

### helm_dir_det
1. The only change is I-2D, which assumes simply connectedness.
2. Checked error with bessel function is -3.58e-10