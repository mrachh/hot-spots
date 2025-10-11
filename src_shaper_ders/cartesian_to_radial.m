function drads = cartesian_to_radial(dvals, angles)
    
    gx = dvals(1:2:end);
    gy = dvals(2:2:end);
    
    erx = cos(angles(:));
    ery = sin(angles(:));
    
    drads = gx(:).*erx + gy(:).*ery;
    drads = drads';
end
    