import sys, os, shutil
import numpy as np

# temp folder management

def delete_temp():
    if 'temp' in os.listdir():
        shutil.rmtree('temp')
    return

def init_temp():
    if 'temp' in os.listdir():
        delete_temp()
    os.mkdir('temp')
    return

def id2name(id):
    return 'temp/%d.png'%id

def delete_temp_file(file_id):
    os.remove(id2name(file_id))
    return 


# vertex coordinate computations
def init_poly(num_verts):
    vert_angles = np.arange(0, 2*np.pi, 2*np.pi/num_verts)[:num_verts]
    return [list(np.cos(vert_angles)),list(np.sin(vert_angles))]