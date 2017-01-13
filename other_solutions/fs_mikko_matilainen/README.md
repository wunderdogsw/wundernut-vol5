# Wundernut 5: Secret Message

For definition of the puzzle see http://wunder.dog/secret-message-1

## Installation and usage

Install .NET Core 1.0 SDK from https://www.microsoft.com/net/download/core#/lts and run
`dotnet restore`. The program can now be run with default input and output file names
using command `dotnet run`. The file names can be specified using command line arguments
`dotnet run [input file] [output file]`.

Alternatively you can build and run the program in a Docker container. First, build the
Docker image by commanding `docker build -t secret-message .` and then run it with the
command `docker run secret-message`. To access the output image from the host use for
example command `docker run -v $(pwd)/tmp:/dv secret-message img/input.png /dv/output.png`
to mount a Docker volume. Output file will then reside under the `tmp` directory.
