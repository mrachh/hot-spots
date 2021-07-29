function res = test1(xval)
    %test function with local minimum at xval = \pm 1
    res = -(2/pi) * (xval^1.5) / (xval^2+1);
end