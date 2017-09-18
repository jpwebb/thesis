import cv2


def add_spot(im, max_width, colour):
    r = 10
    circ_offset = r / 2
    circ_x = (max_width - r - circ_offset)
    circ_y = (r + circ_offset)
    rgb_red = (255, 0, 0)
    rgb_orange = (255, 150, 0)
    rgb_green = (0, 255, 0)
    if colour == 'green':
        circ_colour = rgb_green[::-1]
    elif colour == 'orange':
        circ_colour = rgb_orange[::-1]
    elif colour == 'red':
        circ_colour = rgb_red[::-1]
    else:
        return

    cv2.circle(im, (circ_x, circ_y), r, circ_colour, -1)
