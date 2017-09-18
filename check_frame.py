import cv2
import numpy as np


def check_frame(rgb_frame, pattern_size):
    rgb_frame = np.delete(rgb_frame, 3, 2)
    found = cv2.findChessboardCorners(image=rgb_frame, patternSize=pattern_size, flags=cv2.CALIB_CB_FAST_CHECK)
    if found[0]:
        return True
    else:
        return False
