function result = make_dir(fd)
    if ~isfolder(fd)
        mkdir(fd);
    end
    result = 1;
end