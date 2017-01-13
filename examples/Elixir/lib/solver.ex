defmodule Solver do
    require ExPNG.Image, as: Image
    require ExPNG.Color, as: Color
    
    @background Color.white
    @stroke Color.black

    @rules %{
        <<7, 84, 19, 255>> => :up,
        <<139, 57, 137, 255>> => :left,
        <<51, 69, 169, 255>> => :stop,
        <<182, 149, 72, 255>> => :turn_right,
        <<123, 131, 154, 255>> => :turn_left
    }

    def get_direction(image, x, y, direction) do
        color = Image.get_pixel(image, x, y)
        rule = Map.get(@rules, color)
        case {direction, rule} do
            {:up, :turn_left} -> :left
            {:up, :turn_right} -> :right
            {:right, :turn_left} -> :up
            {:right, :turn_right} -> :down
            {:down, :turn_left} -> :right
            {:down, :turn_right} -> :left
            {:left, :turn_left} -> :down
            {:left, :turn_right} -> :up
            {_, :stop} -> :stop
            _ -> :continue
        end 
    end

    def draw_lines(output, _, x, y, :stop) do
        Image.set_pixel(output, x, y, @stroke)
    end

    def draw_lines(output, image, x, y, direction) do
        output_ = Image.set_pixel(output, x, y, @stroke)
        {xx, yy} = case direction do
            :up -> {x, y-1}
            :right -> {x+1, y}
            :down -> {x, y+1}
            :left -> {x-1, y}
        end
        case get_direction(image, xx, yy, direction) do
            :continue -> draw_lines(output_, image, xx, yy, direction)
            other -> draw_lines(output_, image, xx, yy, other)
        end
    end

    def run() do
        IO.puts("Reading secret message")
        input_image = ExPNG.read("secret_message.png")
        {width, height} = Image.size(input_image)
        pixels = 0..height-1 
            |> Enum.flat_map(fn y -> 
                0..width-1 |> Enum.map(fn x -> 
                    {x, y, Image.get_pixel(input_image, x, y)} end ) end)
        
        starts = pixels |> Enum.filter(fn {_, _, col} ->
                case Map.get(@rules, col) do
                    :up -> true
                    :left -> true
                    _ -> false
                end
            end)   

        result = starts 
            |> Enum.reduce(ExPNG.image(width, height, @background), 
                fn ({x,y, _}, output) ->
                    direction = Map.get(@rules, Image.get_pixel(input_image, x,y))
                    draw_lines(output, input_image, x, y, direction)
                end)
        ExPNG.write(result, "output.png")
        IO.puts("Result written to output.png")
    end
end