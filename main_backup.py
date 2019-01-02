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
frame_freq = 27
frame_count = frame_freq

rgb_width = 1920
rgb_height = 1080
rgb_scale = 3

d_width = 512
d_height = 424
height_offset = 46

move_windows = False

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
print serial
device = fn.openDevice(serial, pipeline=pipeline)

# Generate the full write directory (based on device serial number)
rgb_channel = 'RGB'
write_dir_rgb = configure_write_directory(program_directory, rgb_channel, serial)
d_channel = 'D'
write_dir_d = configure_write_directory(program_directory, d_channel, serial)

types = (FrameType.Color | FrameType.Ir | FrameType.Depth)
listener = SyncMultiFrameListener(types)

# Register listeners
device.setColorFrameListener(listener)
device.setIrAndDepthFrameListener(listener)

device.start()

# NOTE: must be called after device.start()

registration = Registration(device.getIrCameraParams(),
                            device.getColorCameraParams())

undistorted = Frame(512, 424, 4)
registered = Frame(512, 424, 4)

get_intrinsics(device, rgb_channel, write_dir_rgb)
get_intrinsics(device, d_channel, write_dir_d)

while True:

    frames = listener.waitForNewFrame()

    # Extract individual frames.
    color = frames["color"]
    depth = frames["depth"]
    ir = frames["ir"]

    # Configure frames for display.
    rgb_frame_show = cv2.resize(color.asarray(), (int(rgb_width / rgb_scale), int(rgb_height / rgb_scale)))
    depth_frame_show = depth.asarray() / 4500.
    ir_frame_show = ir.asarray() / 65535.
    registration.apply(color, depth, undistorted, registered)
    registration.undistortDepth(depth, undistorted)
    undistorted_frame_show = undistorted.asarray(np.float32) / 4500.
    registered_frame_show = registered.asarray(np.uint8)

    # Configure frames for storing.
    rgb_frame_save = cv2.resize(color.asarray(), (rgb_width, rgb_height))
    depth_frame_save = np.uint8(255 * depth_frame_show)

    # Display frames to the screen.
    cv2.imshow("ir", ir_frame_show)
    cv2.imshow("undistorted", undistorted_frame_show)
    cv2.imshow("registered", registered_frame_show)
    cv2.imshow("depth", depth_frame_show)

    # Move displays around the screen for easier viewing (optional).
    if move_windows:
        cv2.moveWindow("ir", 0, 0)
        cv2.moveWindow("undistorted", 2 * d_width, 0)
        cv2.moveWindow("registered", 0, d_height + height_offset)
        cv2.moveWindow("depth", d_width, 0)

    # Display an orange circle on the colour frame if ready to capture image.
    if flag and frame_count != 0:
        frame_count -= 1
        add_spot(rgb_frame_show, int(rgb_width / rgb_scale), 'orange')
        cv2.imshow("color", rgb_frame_show)
        if move_windows: cv2.moveWindow("color", d_width, d_height + height_offset)
    # Save the Colour and Depth frames and flash a green circle on the colour frame display.
    elif flag and frame_count == 0:
        time_stamp = datetime.now().strftime('%d%m%Y_%H%M%S_%f')
        frame_count = frame_freq
        if 1:  # checkFrame(rgb_frame_full, pattern_size):
            add_spot(rgb_frame_show, int(rgb_width / rgb_scale), 'green')
            cv2.imshow("color", rgb_frame_show)
            if move_windows: cv2.moveWindow("color", d_width, d_height + height_offset)
            # Save the current RGB frame (named by current time)
            save_frame(write_dir_rgb, time_stamp, rgb_frame_save)
            save_frame(write_dir_d, time_stamp, depth_frame_save)
    # Display a red circle on the colour frame if in standby mode.
    else:
        add_spot(rgb_frame_show, int(rgb_width / rgb_scale), 'red')
        cv2.imshow("color", rgb_frame_show)
        if move_windows: cv2.moveWindow("color", d_width, d_height + height_offset)

    listener.release(frames)

    key = cv2.waitKey(delay=1)
    # Invert the recording mode flag or quit the program as the user desires.
    if key == ord('r') or key == ord('R'):
        flag = not flag
    elif key == ord('q') or key == ord('Q'):
        cv2.destroyAllWindows()
        break

device.stop()
device.close()

sys.exit(0)