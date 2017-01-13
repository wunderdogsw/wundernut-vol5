package main

import (
	"image"
	"image/color"
	"image/png"
	"os"
)

const (
	DIRECTION_UP = iota
	DIRECTION_RIGHT
	DIRECTION_DOWN
	DIRECTION_LEFT
)

var (
	STOP_PIXEL       = NewPixelFromRGBA8(51, 69, 169)
	UP_PIXEL         = NewPixelFromRGBA8(7, 84, 19)
	LEFT_PIXEL       = NewPixelFromRGBA8(139, 57, 137)
	TURN_RIGHT_PIXEL = NewPixelFromRGBA8(182, 149, 72)
	TURN_LEFT_PIXEL  = NewPixelFromRGBA8(123, 131, 154)
	PIXEL_COLOR      = color.RGBA{255, 0, 0, 255}
)

type Pixel struct {
	R uint8
	G uint8
	B uint8
}

func NewPixelFromRGBA8(r uint8, g uint8, b uint8) Pixel {
	return Pixel{
		R: r,
		G: g,
		B: b,
	}
}

func NewPixelFromRGBA16(r16 uint32, g16 uint32, b16 uint32, a16 uint32) Pixel {
	return NewPixelFromRGBA8(uint8(r16>>8), uint8(g16>>8), uint8(b16>>8))
}

func (p Pixel) IsSame(o Pixel) bool {
	return p.R == o.R && p.G == o.G && p.B == o.B
}

type Direction struct {
	Value int
}

func NewDirection(value int) Direction {
	return Direction{
		Value: value,
	}
}

func (d Direction) Delta() (int, int) {
	if d.Value == DIRECTION_UP {
		return 0, -1
	} else if d.Value == DIRECTION_DOWN {
		return 0, 1
	} else if d.Value == DIRECTION_LEFT {
		return -1, 0
	} else if d.Value == DIRECTION_RIGHT {
		return 1, 0
	}

	panic("Invalid direction value")
}

func (d *Direction) Set(value int) {
	d.Value = value
}

func (d *Direction) TurnLeft() {
	d.Value -= 1
	if d.Value < 0 {
		d.Value = 3
	}
}

func (d *Direction) TurnRight() {
	d.Value += 1
	if d.Value > 3 {
		d.Value = 0
	}
}

func main() {
	reader, err := os.Open("image.png")
	defer reader.Close()

	if err != nil {
		panic(err)
	}

	input, _, err := image.Decode(reader)
	if err != nil {
		panic(err)
	}

	bounds := input.Bounds()
	output := image.NewRGBA(image.Rect(0, 0, bounds.Dx(), bounds.Dy()))

	for x := 0; x < bounds.Dx(); x++ {
		for y := 0; y < bounds.Dy(); y++ {
			pixel := NewPixelFromRGBA16(input.At(x, y).RGBA())

			if pixel.IsSame(UP_PIXEL) {
				go draw(input, output, x, y, NewDirection(DIRECTION_UP))
			} else if pixel.IsSame(LEFT_PIXEL) {
				go draw(input, output, x, y, NewDirection(DIRECTION_LEFT))
			}
		}
	}

	destination, err := os.Create("message.png")
	defer destination.Close()

	if err != nil {
		panic(err)
	}

	png.Encode(destination, output)
}

func draw(input image.Image, output *image.RGBA, x int, y int, direction Direction) {
	for {
		otherPixel := NewPixelFromRGBA16(input.At(x, y).RGBA())

		if otherPixel.IsSame(STOP_PIXEL) {
			break
		}

		if otherPixel.IsSame(TURN_LEFT_PIXEL) {
			direction.TurnLeft()
		} else if otherPixel.IsSame(TURN_RIGHT_PIXEL) {
			direction.TurnRight()
		}

		dx, dy := direction.Delta()
		x, y = x+dx, y+dy

		output.Set(x, y, PIXEL_COLOR)
	}
}
