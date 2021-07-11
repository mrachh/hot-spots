import matlab.engine
from helper import *
import numpy as np

eng = matlab.engine.start_matlab()
print('matlab started')
init_temp()

def init_poly(num_verts):
    #generate sample vert_coords
    vert_angles = np.arange(0, 2*np.pi, 2*np.pi/num_verts)[:num_verts]
    vert_xs = [np.cos(angle)for angle in vert_angles]
    vert_ys = [np.sin(angle)for angle in vert_angles]
    vert_coords = matlab.double([vert_xs, vert_ys])

    #call matlab code
    file_id = eng.chunkie_poly(vert_coords, background = False)

    return file_id

    # delete_temp()
