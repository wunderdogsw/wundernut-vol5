require 'chunky_png'

# Start drawing upwards when the pixel color is 7, 84, 19. 122950655 0x075413ff
# Start drawing left when the pixel color is 139, 57, 137. 2335803903 0x8b3989ff
# Stop drawing when the pixel color is 51, 69, 169. 860203519 0x3345a9ff
# Turn right when the pixel color is 182, 149, 72. 3063236863 0xb69548ff
# Turn left when the pixel color is 123, 131, 154. 2072222463 0x7b839aff

def draw(pos, dir, src, out)
  out[*pos] = 0xff0000ff
  return if src[*pos] == 0x3345a9ff
  dir[0], dir[1] = -dir[1], dir[0] if src[*pos] == 0xb69548ff
  dir[0], dir[1] = dir[1], -dir[0] if src[*pos] == 0x7b839aff
  draw([pos[0] + dir[0], pos[1] + dir[1]], dir, src, out)
end

src = ChunkyPNG::Image.from_file("wundernut.png")
out = ChunkyPNG::Image.new(src.width, src.height)

src.width.times do |x|
  src.height.times do |y|
    draw([x, y], [0, -1], src, out) if src[x, y] == 0x075413ff
    draw([x, y], [-1, 0], src, out) if src[x, y] == 0x8b3989ff
  end
end

out.save('merry.png')
