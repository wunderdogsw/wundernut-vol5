import png
import itertools

def zipper(l):
    it = iter(l)
    return zip(it, it, it)

def traverse(coords, speedx, speedy):
    x, y = coords
    if data[y][x] == (123, 131, 154):  # turn left
        speedx, speedy = speedy, -speedx
    elif data[y][x] == (182, 149, 72): # turn right
        speedx, speedy = -speedy, speedx
    if data[y][x] != (51, 69, 169):    # stop
        traverse((x + speedx, y + speedy), speedx, speedy)
    data[y][x] = (0, 0, 0)

src = png.Reader("static.png").read()
data = map(zipper, src[2])

for coords in itertools.product(range(src[0]), range(src[1])):
    x, y = coords
    if data[y][x] == (7, 84, 19):      # start drawing up
        traverse(coords, 0, -1)
    elif data[y][x] == (139, 57, 137): # start drawing left
        traverse(coords, -1, 0)

result = map(lambda x : [e for l in x for e in l], data)

f = open("result.png", "wb")
png.Writer(src[0], src[1]).write(f, result)
f.close()
