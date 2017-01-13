// Creates a schedule function that delays an action by the given interval since
// the previous action.
const scheduler = (interval) => {
  let timeout = 0;
  return (fn) => setTimeout(fn, timeout += interval);
};

// Changes the width and height of a canvas.
const resizeCanvas = (canvas, width, height) => {
  canvas.width = width;
  canvas.height = height;
};

const img = new Image();
img.src = "message.png";
img.onload = () => {
  const { width, height } = img;
  const secretCanvas = document.querySelector(".secret");
  const secretCtx = secretCanvas.getContext("2d");
  resizeCanvas(secretCanvas, width, height);
  secretCtx.drawImage(img, 0, 0, width, height);

  const solutionCanvas = document.querySelector(".solution");
  const solutionCtx = solutionCanvas.getContext("2d");
  resizeCanvas(solutionCanvas, width, height);

  const schedule = scheduler(16);

  document.querySelector(".solve-btn").onclick = (e) => {
    e.preventDefault();
    e.target.style.display = "none";
    solve(secretCanvas, (x, y) => {
      schedule(() => solutionCtx.fillRect(x, y, 1, 1));
    });
  }
};
