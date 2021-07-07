import matlab.engine

eng = matlab.engine.start_matlab()
eng.chunkie_poly(nargout = 0)