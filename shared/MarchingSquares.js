/**
* Created by @sakri on 25-3-14.
*
* Javascript port of :
* http://devblog.phillipspiess.com/2010/02/23/better-know-an-algorithm-1-marching-squares/
* returns an Array of x and y positions defining the perimeter of a blob of non-transparent pixels on a canvas
*
*/

var MarchingSquares = {};

MarchingSquares.NONE = 0;
MarchingSquares.UP = 1;
MarchingSquares.LEFT = 2;
MarchingSquares.DOWN = 3;
MarchingSquares.RIGHT = 4;

// Returns true if the cell centered at (x,y) is a boundary cell
// (i.e. the cell corners are not all inside or all outside)
MarchingSquares.isBoundary = function(field, x, y, cellSize) {
    var matrix = [field(x - cellSize / 2, y + cellSize / 2),
                    field(x + cellSize / 2, y + cellSize / 2),
                    field(x - cellSize / 2, y - cellSize / 2),
                    field(x + cellSize / 2, y - cellSize / 2)];

    if (field(x - cellSize / 2, y + cellSize / 2)) {
      return !field(x + cellSize / 2, y + cellSize / 2) || 
        !field(x - cellSize / 2, y - cellSize / 2) || 
        !field(x + cellSize / 2, y - cellSize / 2);
    } else {
      return field(x + cellSize / 2, y + cellSize / 2) || 
      field(x - cellSize / 2, y - cellSize / 2) || 
      field(x + cellSize / 2, y - cellSize / 2);
    }
}

MarchingSquares.walkPerimeter = function(field, startX, startY, cellSize) {
    // Our current x and y positions, initialized
    // to the init values passed in
    var x = startX;
    var y = startY;

    // Set up our return list
    var path = [{x: startX, y: startY}];

    // The main while loop, continues stepping until
    // we return to our initial points
    var direction;
    do {
        direction = MarchingSquares.step(field, x, y, cellSize, direction);

        switch (direction) {
            case MarchingSquares.UP:    y += cellSize; break;
            case MarchingSquares.DOWN:  y -= cellSize; break;
            case MarchingSquares.LEFT:  x -= cellSize; break;
            case MarchingSquares.RIGHT: x += cellSize; break;
            default:
                break;
        }

        path.push({x: x, y: y});

    } while (Math.abs(x - startX) > cellSize/2 || Math.abs(y - startY) > cellSize/2);

    return path;
};

// Determines and sets the state of the 4 pixels that
// represent our current state, and sets our current and
// previous directions
MarchingSquares.step = function(field, x, y, cellSize, lastDirection) {
    var topLeft     = field(x - cellSize/2, y + cellSize/2);
    var topRight    = field(x + cellSize/2, y + cellSize/2);
    var bottomLeft  = field(x - cellSize/2, y - cellSize/2);
    var bottomRight = field(x + cellSize/2, y - cellSize/2);

    // Determine which state we are in
    var state = 0;

    if (topLeft) {
        state |= 1;
    }
    if (topRight) {
        state |= 2;
    }
    if (bottomLeft) {
        state |= 4;
    }
    if (bottomRight) {
        state |= 8;
    }

    // State now contains a number between 0 and 15
    // representing our state.
    // In binary, it looks like 0000-1111

    // An example. Let's say the top two pixels are filled,
    // and the bottom two are empty.
    // Stepping through the if statements above with a state
    // of 0b0000 initially produces:
    // Upper Left == true ==>  0b0001
    // Upper Right == true ==> 0b0011
    // The others are false, so 0b0011 is our state
    // (That's 3 in decimal.)

    // Looking at the chart above, we see that state
    // corresponds to a move right, so in our switch statement
    // below, we add a case for 3, and assign Right as the
    // direction of the next step. We repeat this process
    // for all 16 states.

    // So we can use a switch statement to determine our
    // next direction based on
    // console.log(state);
    switch (state) {
        case 1: return MarchingSquares.UP;
        case 2: return MarchingSquares.RIGHT;
        case 3: return MarchingSquares.RIGHT;
        case 4: return MarchingSquares.LEFT;
        case 5: return MarchingSquares.UP;
        case 6:
            if(lastDirection == MarchingSquares.UP) {
                return MarchingSquares.LEFT;
            } else {
                return MarchingSquares.RIGHT;
            }
        case 7: return MarchingSquares.RIGHT;
        case 8: return MarchingSquares.DOWN;
        case 9:
            if(lastDirection == MarchingSquares.RIGHT) {
                return MarchingSquares.UP;
            } else {
                return MarchingSquares.DOWN;
            }
        case 10: return MarchingSquares.DOWN;
        case 11: return MarchingSquares.DOWN;
        case 12: return MarchingSquares.LEFT;
        case 13: return MarchingSquares.UP;
        case 14: return MarchingSquares.LEFT;
        default: return null; // this should never happen
    }
};

module.exports = MarchingSquares;