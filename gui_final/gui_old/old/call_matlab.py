import matlab.engine
from helper import *
import numpy as np

eng = matlab.engine.start_matlab()
print('matlab started')
init_temp()

def draw_poly(vert_coords):
    vert_coords = matlab.double(vert_coords)
    file_id = eng.chunkie_poly(vert_coords, background = False)
    return file_id    