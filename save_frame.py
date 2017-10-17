import cv2
import os


# Store the current frame in an appropriate folder.
# Inputs:
#   write_dir   - Directory of the current device.
#   filename    - Name of the image file.
#   frame       - The frame to be stored.
# Outputs:
#   None.
def save_frame(write_dir, filename, frame):

    # Create the output filename (absolute) and save the image.
    out_str = write_dir + os.sep + filename + '.png'
    cv2.imwrite(out_str, frame)

    print 'Success writing ' + out_str  # Optional

    return
