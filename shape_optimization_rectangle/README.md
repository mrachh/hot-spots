# Output format

1. objective and gradient as a function of iteration number
2. objective as a function of the parameter (plotting only the values you get using your iterations). 
3. what are the optimal values?

# TODO: 
1.  Set M = 4 for now, and consider the family of polygons with vertices of the form
    (0,0), r_1 (cos(theta_1),sin(theta_1)), ... , r_M (cos(theta_M),sin(theta_M)),
    where r_1,...,r_M are real numbers and 
    theta_j = pi*(j-1)/(M-1).

2.  Find the values of r_1,...,r_M that maximize the objective function, where the gradient of the eigenfunction is only evaluated at (0, 0)  . If you want to do something faster you can choose r_1 = r_M, r_2 = r_(M-1),... since we expect the extremizer to be symmetric.
