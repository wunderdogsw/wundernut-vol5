// Colors defining the deciphering rules.
const COLOR_DIRECTION_UP   = [7,    84,  19];
const COLOR_DIRECTION_LEFT = [139,  57, 137];
const COLOR_STOP           = [51,   69, 169];
const COLOR_TURN_LEFT      = [123, 131, 154];
const COLOR_TURN_RIGHT     = [182, 149,  72];

// Absolute drawing directions. Defines the change required to move to the next
// point in a canvas. The starting point (0, 0) of a canvas is the top left
// corner.
const DIRECTION_UP    = [ 0, -1];
const DIRECTION_LEFT  = [-1,  0];
const DIRECTION_RIGHT = [ 1,  0];
const DIRECTION_DOWN  = [ 0,  1];

// Defines all absolutes directions in a circular order, allowing to change
// direction moving to the previous/next direction.
const DIRECTIONS = [
  DIRECTION_UP,
  DIRECTION_RIGHT,
  DIRECTION_DOWN,
  DIRECTION_LEFT
];

// Defines the required index change to move from an absolute direction to
// another by turning left, right, or doing nothing.
const TURN_LEFT  = -1;
const TURN_RIGHT =  1;
const TURN_NONE  =  0;
