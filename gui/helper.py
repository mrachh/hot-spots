import sys, os, shutil

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