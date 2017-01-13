// Creates a color picker for the ImageData of a 2D canvas. Returns a function
// that returns the pixel value as a 3 element array (red, green, blue) of a
// given coordinate (x, y).
const colorPicker = (imageData) => (x, y) => {
  const start = y * imageData.width * 4 + x * 4;
  return imageData.data.slice(start, start + 3);
};

// Compares two colors (array of RGB values) and returns whether they are the
// same.
const colorMatches = (a, b) => a.every((c, i) => c === b[i]);

// For a given pixel color, returns the turn relative to the current direction
// (left, right, or no turn).
const determineTurn = (color) => {
  if (colorMatches(color, COLOR_TURN_RIGHT)) return TURN_RIGHT;
  if (colorMatches(color, COLOR_TURN_LEFT))  return TURN_LEFT;
  return TURN_NONE;
};

// For a given pixel color, and current absolute direction (relative to the
// canvas), returns the absolute direction of the next point.
const determineDirection = (color, currentDirection) => {
  const turn = determineTurn(color);
  const index = (DIRECTIONS.indexOf(currentDirection) + turn + 4) % 4;
  return DIRECTIONS[index];
};

// Returns the next point (x, y) for a given point and absolute direction of
// that next point.
const nextPoint = (x, y, direction) => [x + direction[0], y + direction[1]];

// Returns a recursive walk function that, given a starting point (x, y) and
// direction (relative to the canvas), will emit each point that it walks
// through. Requires a color picker function and callback function for each
// point.
const walker = (colorAt, pointFn) => {
  const walk = (x, y, direction) => {
    pointFn(x, y);
    const color = colorAt(x, y);
    if (colorMatches(color, COLOR_STOP)) return;
    const newDirection = determineDirection(color, direction);
    const [nextX, nextY] = nextPoint(x, y, newDirection);
    walk(nextX, nextY, newDirection);
  };
  return walk;
};

// Loops through each pixel on a canvas, calling the iterator function with the
// coordinates (x, y) of each pixel.
const eachPixel = (canvas, iterator) => {
  for (let y = 0; y < canvas.height; y++) {
    for (let x = 0; x < canvas.width; x++) {
      iterator(x, y);
    }
  }
};

// Solves the secret message from a canvas, by looping through each pixel to
// find the starting points, and then walks them all. Calls pointFn with each
// decoded message point (x, y).
const solve = (canvas, pointFn) => {
  const context = canvas.getContext("2d");
  const imageData = context.getImageData(0, 0, canvas.width, canvas.height);
  const colorAt = colorPicker(imageData);
  const walk = walker(colorAt, pointFn);

  eachPixel(canvas, (x, y) => {
    const color = colorAt(x, y);
    if (colorMatches(color, COLOR_DIRECTION_UP))   walk(x, y, DIRECTION_UP);
    if (colorMatches(color, COLOR_DIRECTION_LEFT)) walk(x, y, DIRECTION_LEFT);
  });
};
