import os


# Store the intrinsic parameters that are on the device.
# Inputs:
#   device      - Directory of the main program.
#   channel     - Sensor channel (RGB or D expected).
#   write_dir   - Directory for the specified channel.
# Outputs:
#   None.
def get_intrinsics(device, channel, program_dir, serial_number):

    # Get the parameters off the device, dependent on the specified channel.
    if channel == 'RGB':
        cx = device.getColorCameraParams().cx
        cy = device.getColorCameraParams().cy
        fx = device.getColorCameraParams().fx
        fy = device.getColorCameraParams().fy
    elif channel == 'D':
        cx = device.getIrCameraParams().cx
        cy = device.getIrCameraParams().cy
        fx = device.getIrCameraParams().fx
        fy = device.getIrCameraParams().fy
    else:
        return

    # Create an intrinsics.txt file and write the data to it.
    write_dir = program_dir + os.sep + 'Kinect_' + serial_number
    intrinsics = write_dir + os.sep + channel + '_intrinsics.txt'
    f = open(intrinsics, "w")
    f.write('%f\n' % cx)
    f.write('%f\n' % cy)
    f.write('%f\n' % fx)
    f.write('%f\n' % fy)
    f.close()

    return
