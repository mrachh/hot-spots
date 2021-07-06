import matlab.engine

eng = matlab.engine.start_matlab()
eng.chunky(nargout = 0)