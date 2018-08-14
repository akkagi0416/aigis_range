let canvas;
let map;
let cell;
let isPressed = false;
let px, py;
let ranges = [];

let mode = "move";

function preload(){
  map  = loadImage("img/map.jpg");
  cell = loadImage("img/cell.png");
}

function setup(){
  canvas = createCanvas(960, 640);
  canvas.parent("#canvas");
  canvas.drop(gotFile);   // drag & drop
  imageMode(CENTER);

  let operations = selectAll(".operation");
  for(let operation of operations){
    operation.mousePressed(selectMode);
  }
}

function draw(){
  image(map, width / 2, height / 2);

  if(isPressed && mode == "pen"){
    drawRange(px, py, mouseX, mouseY);
  }

  for(let range of ranges){
    range.show();
  }
}

function mousePressed(){
  if(mode == "hand")   handPressed();
  if(mode == "pen")    penPressed();
  if(mode == "eraser") eraserPressed();
  if(mode == "save")   savePressed();
}

function mouseDragged(){
  if(mode == "hand")   handDragged();
}

function mouseReleased(){
  if(mode == "hand")   handReleased();
  if(mode == "pen")    penReleased();
  if(mode == "eraser") eraserReleased();
  if(mode == "save")   saveReleased();
}

function gotFile(file){
  map = createImg(file.data);
  map.hide();
}

function drawRange(px1, py1, px2, py2){
  let d = dist(px1, py1, px2, py2);
  let range = d * 4 / 3;

  stroke(0, 255, 0);
  fill(0, 255, 0, 50);
  line(px1, py1, px2, py2);
  ellipseMode(RADIUS);
  ellipse(px1, py1, d, d);
  textSize(24);
  text(range.toFixed(), (px1 + px2) / 2, (py1 + py2) / 2);
  image(cell, px1, py1);
}

class Range{
  constructor(_px1, _py1, _px2, _py2){
    this.px1 = _px1;
    this.py1 = _py1;
    this.px2 = _px2;
    this.py2 = _py2;
    this.d   = dist(_px1, _py1, _px2, _py2);
    this.range = this.d * 4 / 3;   // px -> range
    this.isSelected = false;
  }

  move(_x, _y){
    this.px2 = this.px2 + (_x - this.px1);
    this.py2 = this.py2 + (_y - this.py1);
    this.px1 = _x;
    this.py1 = _y;
  }

  show(){
    drawRange(this.px1, this.py1, this.px2, this.py2);
  }
}

function selectMode(){
  for(let operation of selectAll(".operation")){
    operation.removeClass("selected");
  }
  if(!this.class().includes("selected")){
    this.addClass("selected");
    mode = this.id();
  }
}

function handPressed(){
  for(let range of ranges){
    let d = dist(range.px1, range.py1, mouseX, mouseY);
    if(d <= cell.width / 2){
      range.isSelected = true;
    }
  }
}

function handDragged(){
  for(let range of ranges){
    if(range.isSelected == true){
      range.move(mouseX, mouseY);
    }
  }
}

function handReleased(){
  for(let range of ranges){
    range.isSelected = false;
  }
}

function penPressed(){
  if(mouseX >= 0 && mouseX <= width && mouseY >= 0 && mouseY <= height){
    isPressed = true;
  }
  px = mouseX;
  py = mouseY;
}
function penReleased(){
  if(mode == "pen" && isPressed == true){
    let r = new Range(px, py, mouseX, mouseY);
    ranges.push(r);
  }
  isPressed = false;
}

function eraserPressed(){
  for(let i = 0; i < ranges.length; i++){
    let d = dist(ranges[i].px1, ranges[i].py1, mouseX, mouseY);
    if(d <= cell.width / 2){
      ranges.splice(i, 1);  // erase
    }
  }
}

function eraserReleased(){
}

function savePressed(){
  saveCanvas(canvas, "map", "jpg");
}

function saveReleased(){
}
