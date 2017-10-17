import os
import shutil


# Setup the write directory for the current device and sensor channel.
# Inputs:
#   prog_dir        - Directory of the main program.
#   channel         - Sensor channel (RGB or D expected).
#   serial_number   - Serial number of the current device.
# Outputs:
#   write_dir       - Directory for the specified channel.
def configure_write_directory(program_dir, channel, serial_number):

    # Create the full directory name.
    write_dir_name = 'Kinect_' + serial_number
    write_dir = program_dir + os.sep + write_dir_name + os.sep + channel

    # Remove the folder and its contents if it exists already.
    # if os.path.exists(write_dir):
    #     shutil.rmtree(write_dir)

    # Create the directory.
    if not(os.path.exists(write_dir)):
        os.makedirs(write_dir)

    # Return the string for use in the rest of the program.
    return write_dir
