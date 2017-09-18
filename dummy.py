# coding: utf-8

# An example using startStreams

import numpy as np
import cv2
import sys
from pylibfreenect2 import Freenect2, SyncMultiFrameListener
from pylibfreenect2 import FrameType, Registration, Frame

from datetime import datetime
from check_frame import *
from add_spot import *
from save_frame import *
from configure_write_directory import *
from get_intrinsics import *


# Determine full path of the directory the program resides in
program_directory = os.path.abspath(os.path.curdir)

# Specify the size of the target (ncols, nrows) - internal corners only
pattern_size = (9, 6)

flag = 0
frame_freq = 20
frame_count = frame_freq

rgb_w = 1920
rgb_h = 1080
scale = 3

try:
    from pylibfreenect2 import OpenCLPacketPipeline
    pipeline = OpenCLPacketPipeline()
except:
    try:
        from pylibfreenect2 import OpenGLPacketPipeline
        pipeline = OpenGLPacketPipeline()
    except:
        from pylibfreenect2 import CpuPacketPipeline
        pipeline = CpuPacketPipeline()
print("Packet pipeline:", type(pipeline).__name__)

enable_rgb = True
enable_depth = True

fn = Freenect2()
num_devices = fn.enumerateDevices()
if num_devices == 0:
    print("No device connected!")
    sys.exit(1)

serial = fn.getDeviceSerialNumber(0)
device = fn.openDevice(serial, pipeline=pipeline)

# Generate the full write directory (based on device serial number)
rgb_channel = 'RGB'
write_dir_rgb = configure_write_directory(program_directory, rgb_channel, serial)
d_channel = 'D'
write_dir_d = configure_write_directory(program_directory, d_channel, serial)

types = 0
if enable_rgb:
    types |= FrameType.Color
if enable_depth:
    types |= (FrameType.Ir | FrameType.Depth)
listener = SyncMultiFrameListener(types)

# Register listeners
device.setColorFrameListener(listener)
device.setIrAndDepthFrameListener(listener)

if enable_rgb and enable_depth:
    device.start()
else:
    device.startStreams(rgb=enable_rgb, depth=enable_depth)

# NOTE: must be called after device.start()
if enable_depth:
    registration = Registration(device.getIrCameraParams(),
                                device.getColorCameraParams())

undistorted = Frame(512, 424, 4)
registered = Frame(512, 424, 4)

get_intrinsics(device, rgb_channel, write_dir_rgb)
get_intrinsics(device, d_channel, write_dir_d)

while True:

    frames = listener.waitForNewFrame()

    if enable_rgb:
        color = frames["color"]
    if enable_depth:
        ir = frames["ir"]
        depth = frames["depth"]

    if enable_rgb and enable_depth:
        registration.apply(color, depth, undistorted, registered)
    elif enable_depth:
        registration.undistortDepth(depth, undistorted)

    if enable_depth:
        ir_frame = ir.asarray() / 65535.
        cv2.imshow("ir", ir_frame)
        depth_frame_small = depth.asarray() / 4500.
        depth_frame_full = np.uint8(255 * depth_frame_small)
        cv2.imshow("depth", depth_frame_small)
        undistorted_frame = undistorted.asarray(np.float32) / 4500.
        cv2.imshow("undistorted", undistorted_frame)
    if enable_rgb:
        rgb_frame_small = cv2.resize(color.asarray(), (int(rgb_w / scale), int(rgb_h / scale)))
        rgb_frame_full = cv2.resize(color.asarray(), (rgb_w, rgb_h))
        if flag and frame_count != 0:
            frame_count -= 1
            add_spot(rgb_frame_small, int(rgb_w / scale), 'orange')
            cv2.imshow("color", rgb_frame_small)
        elif flag and frame_count == 0:
            time_stamp = datetime.now().strftime('%d%m%Y_%H%M%S_%f')
            frame_count = frame_freq
            # if 1:  # checkFrame(rgb_frame_full, pattern_size):
            # time.sleep((1e6 - (float(datetime.now().strftime('%f')))) * 1e-6)
            add_spot(rgb_frame_small, int(rgb_w / scale), 'green')
            cv2.imshow("color", rgb_frame_small)
            # Save the current RGB frame (named by current time)
            save_frame(write_dir_rgb, time_stamp, rgb_frame_full)
            save_frame(write_dir_d, time_stamp, depth_frame_full)
        else:
            add_spot(rgb_frame_small, int(rgb_w / scale), 'red')
            cv2.imshow("color", rgb_frame_small)
    if enable_rgb and enable_depth:
        registered_frame = registered.asarray(np.uint8)
        cv2.imshow("registered", registered_frame)

    listener.release(frames)

    key = cv2.waitKey(delay=1)
    if key == ord('r') or key == ord('R'):
        flag = not flag
    elif key == ord('q') or key == ord('Q'):
        break

device.stop()
device.close()

sys.exit(0)