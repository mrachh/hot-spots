import numpy as np
from matplotlib import pyplot as plt

def convexity(verts):
    n = verts.shape[0]
    res = np.zeros(n)
    for i in range(n):
        x1, y1 = verts[(i-1)%n]
        x2, y2 = verts[(i)%n]
        x3, y3 = verts[(i+1)%n]
        res[i] = (x2 - x1) * (y3 - y2) - (x3 - x2) * (y2 - y1)
    return res

def check_convex(verts, convex_eps = 1e-4):
    return np.min(convexity(verts)) < convex_eps

def get_active_indices(verts, active_eps = 1e-2):
    arr = convexity(verts) < active_eps
    return [i for i in range(len(arr)) if arr[i]]

def get_verts(rad, active_vertices = None):
    # return N by 2
    n = len(rad)
    if active_vertices is None:
        active_vertices = [i for i in range(n)]
    thetas = np.array([2*np.pi*i/n for i in range(n)])
    verts = np.array([np.cos(thetas) * rad, np.sin(thetas) * rad]).T
    return verts[active_vertices]
                

def plot_polygon(verts, **plot_arg):
    plot_verts = list(verts)
    plot_verts = np.array(plot_verts + [plot_verts[0]]).T
    plt.plot(plot_verts[0], plot_verts[1], **plot_arg)
    return