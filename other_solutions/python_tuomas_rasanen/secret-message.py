import math
import PIL.Image

RGB_START_DRAWING_UP   = (  7,  84,  19)
RGB_START_DRAWING_LEFT = (139,  57, 137)
RGB_STOP_DRAWING       = ( 51,  69, 169)
RGB_TURN_RIGHT         = (182, 149,  72)
RGB_TURN_LEFT          = (123, 131, 154)

def draw_line(input_image, output_image, x, y, direction):
    output_image.putpixel((x, y), 1)

    rgb = input_image.getpixel((x, y))[:3]
    if rgb == RGB_STOP_DRAWING:
        return
    elif rgb == RGB_TURN_RIGHT:
        direction -= math.pi / 2
    elif rgb == RGB_TURN_LEFT:
        direction += math.pi / 2

    x += int(math.cos(direction))
    y -= int(math.sin(direction))

    return draw_line(input_image, output_image, x, y, direction)

if __name__ == "__main__":
    input_image  = PIL.Image.open("3663c24c-c5db-11e6-8be5-e358d0e0215a.png")
    output_image = PIL.Image.new("1", input_image.size)

    for x in range(input_image.size[0]):
        for y in range(input_image.size[1]):
            rgb = input_image.getpixel((x, y))[:3]
            if rgb == RGB_START_DRAWING_UP:
                draw_line(input_image, output_image, x, y, math.pi / 2)
            elif rgb == RGB_START_DRAWING_LEFT:
                draw_line(input_image, output_image, x, y, math.pi)

    output_image.save("secret-message.png")
