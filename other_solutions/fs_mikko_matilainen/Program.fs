open System
open System.IO
open ImageSharp

type PixelType = DrawUp | DrawLeft | Stop | TurnRight | TurnLeft | Continue

let (|RGB|) (color: Color) = (int color.R, int color.G, int color.B)

let toPixelType = function
    | RGB(7, 84, 19) -> DrawUp
    | RGB(139, 57, 137) -> DrawLeft
    | RGB(51, 69, 169) -> Stop
    | RGB(182, 149, 72) -> TurnRight
    | RGB(123, 131, 154) -> TurnLeft
    | _ -> Continue

type Direction = Up | Down | Left | Right

let turnLeft = function
    | Up -> Left
    | Left -> Down
    | Down -> Right
    | Right -> Up

let turnRight = function
    | Up -> Right
    | Right -> Down
    | Down -> Left
    | Left -> Up

let getDirection currentDirection = function
    | DrawUp -> Some Up
    | DrawLeft -> Some Left
    | TurnRight -> Some (turnRight currentDirection)
    | TurnLeft -> Some (turnLeft currentDirection)
    | Continue -> Some currentDirection
    | Stop -> None

let assuming isValid value = if isValid then (Some value) else None

let getPath (width, height) (input: PixelType[]) idx startPixelType =
    let move (x, y) = function
        | Up -> assuming (y > 0) (x, y - 1)
        | Left -> assuming (x > 0) (x - 1, y)
        | Right -> assuming (x < width - 1) (x + 1, y)
        | Down -> assuming (y < height - 1) (x, y + 1)

    let rec loop acc (x, y) dir =
        let idx = y * width + x
        let pixelType = input.[idx]
        let dir = getDirection dir pixelType

        if Set.contains ((x, y), dir) acc
        then acc // We have already moved to same direction from this pixel
        else
            let acc = Set.add ((x, y), dir) acc
            match Option.bind (move (x, y)) dir with
                | Some (x, y) -> loop acc (x, y) dir.Value
                | _ -> acc

    let startDir =
        match startPixelType with
        | DrawUp -> Up
        | DrawLeft -> Left
        | _ -> failwith (sprintf "Invalid start pixel type %A" startPixelType)

    let (x, y) = (idx % width, idx / width)
    loop Set.empty (x, y) startDir |> Set.toArray |> Array.map fst

let getPixels size input =
    input
    |> Array.Parallel.mapi (fun i t -> i, t)
    |> Array.filter (fun (_, t) -> t = DrawUp || t = DrawLeft)
    |> Array.Parallel.collect (fun (i, t) -> getPath size input i t)

let processImage size (inputImg: Image) (outputImg: Image) =
    let input = inputImg.Pixels |> Array.Parallel.map toPixelType
    use pixels = outputImg.Lock()
    getPixels size input
    // Set the pixel colors in output image
    |> Array.Parallel.iter (fun (x, y) -> pixels.[x, y] <- Color.Red)

[<EntryPoint>]
let main argv =
    let stopWatch = System.Diagnostics.Stopwatch.StartNew()
    let (inputFileName, outputFileName) =
        match argv.Length with
        | 0 -> ("img/input.png", "output.png")
        | 1 -> (argv.[0], "output.png")
        | _ -> (argv.[0], argv.[1])

    use stream = File.OpenRead(inputFileName)
    let input = Image(stream)
    let size = (input.Width, input.Height)
    let output = Image(input.Width, input.Height)
    printfn "Image `%s` read in %f ms"
        inputFileName stopWatch.Elapsed.TotalMilliseconds
    stopWatch.Restart()

    processImage size input output
    printfn "Processing done in %f ms" stopWatch.Elapsed.TotalMilliseconds
    stopWatch.Restart()

    use outputStream = File.Create(outputFileName)
    output.Save(outputStream) |> ignore
    stopWatch.Stop()
    printfn "Output `%s` written to disk in %f ms"
        outputFileName stopWatch.Elapsed.TotalMilliseconds

    0 // return an integer exit code
