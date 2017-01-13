#!/usr/bin/python3
# coding: utf8
from __future__ import print_function

"""
Solution to Wunderpähkinä vol. 5 - secret message.
Nothing special, standard PIL(low) stuff, the only trick here
is that we use imaginary numbers for the delta and rotations,
as it makes handling the rotations easier.

Usage from command line

    python3 solve.py secret.png decrypted.png

which will write the decrypted message into `decrypted.png`; or

    python3 solve.py secret.png

which will show the decrypted message in a window.
"""

from PIL import Image

DRAW_UP      = 7, 84, 19
DRAW_LEFT    = 139, 57, 137
STOP_DRAWING = 51, 69, 169
TURN_RIGHT   = 182, 149, 72
TURN_LEFT    = 123, 131, 154
WHITE        = 255, 255, 255


def trace(original, decrypted, x, y, direction):
    while True:
        decrypted.putpixel((x, y), WHITE)
        pixel = original.getpixel((x, y))

        if pixel == STOP_DRAWING:
            return
        if pixel == TURN_RIGHT:
            direction *= 1j
        elif pixel == TURN_LEFT:
            direction *= -1j

        x += int(direction.real)
        y += int(direction.imag)


def solve(image_name):
    original = Image.open(image_name).convert('RGB')
    w, h = size = original.size
    decrypted = Image.new('RGB', size)

    for y in range(h):
        for x in range(w):
            colour = original.getpixel((x, y))
            if colour == DRAW_UP:
                trace(original, decrypted, x, y, direction= 0 - 1j)
            elif colour == DRAW_LEFT:
                trace(original, decrypted, x, y, direction=-1 + 0j)

    return decrypted


if __name__ == '__main__':
    import sys
    if not (2 <= len(sys.argv) <= 3):
        print('usage: solve.py encrypted.png [decrypted.png]')
        exit(2)

    decrypted = solve(sys.argv[1])
    if len(sys.argv) == 3:
        decrypted.save(sys.argv[2])
    else:
        decrypted.show()
