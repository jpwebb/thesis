import cv2
import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime


num_iterations = 10
run_times = []

run = 1

for x in range(0, num_iterations):
    print 'Run #', x + 1
    init_time = datetime.now()

    im = cv2.imread('/Users/jasonwebb/PycharmProjects/untitled/Kinect_005224162247/RGB_05092017_143236_000081.png')
    # im = cv2.imread('/Users/jasonwebb/PycharmProjects/untitled/Kinect_080723134947/RGB_02092017_161908.png')

    print 'Pre-Processing'
    start_time = datetime.now()
    [nrows, ncols, _] = im.shape
    scale = 2
    im = cv2.resize(im, (int(ncols/scale), int(nrows/scale)))
    # im = cv2.cvtColor(im, cv2.COLOR_BGR2GRAY)
    end_time = datetime.now()
    print 'Start Time:', start_time
    print 'End Time:', end_time
    dt = (end_time - start_time).total_seconds()
    print 'dt:', dt

    print 'Looking for Checkerboard'
    pattern_size = (9, 6)
    start_time = datetime.now()
    found = cv2.findChessboardCorners(image=im, patternSize=pattern_size, flags=cv2.CALIB_CB_ADAPTIVE_THRESH + cv2.CALIB_CB_NORMALIZE_IMAGE + cv2.CALIB_CB_FAST_CHECK)
    end_time = datetime.now()
    if found[0]:
        print 'Found'
    else:
        print 'Not Found'
    print 'Start Time:', start_time
    print 'End Time:', end_time
    dt = (end_time - start_time).total_seconds()
    print 'dt:', dt

    print 'Computing Total Runtime'
    final_time = datetime.now()
    dt = (final_time - init_time).total_seconds()
    print 'Start Time:', start_time
    print 'End Time:', end_time
    print 'dt:', dt
    # cv2.imshow('image', im)
    # cv2.waitKey()
    # cv2.destroyAllWindows()
    run_times.append(dt)
    print ' '

mean = np.mean(run_times)
print '{:.5f}'.format(mean)
