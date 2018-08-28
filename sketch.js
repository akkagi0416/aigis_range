'use strict';

let canvas;
let map;
let cell;
let px, py;         // position of pressed mouseX, mouseY
let ranges = [];    // Range objects
let icons = [];     // Icon objects

let mode = "move";  // move, pen, eraser, save

const icon_width  = 74;
const icon_height = 72;

// let json_maps;

function preload(){
  map  = loadImage("img/map.jpg");
  cell = loadImage("img/cell.png");
  // json_maps = loadJSON("maps.json");
}

function setup(){
  canvas = createCanvas(960, 640);
  canvas.parent("#canvas");
  canvas.drop(gotFile);   // drag & drop
  imageMode(CENTER);

  // set .operation action
  let operations = selectAll(".operation");
  for(let operation of operations){
    operation.mousePressed(selectMode);
  }

  // make maps menu to html#maps & bind select map
  // make_maps_menu("#maps");
  let maps = selectAll(".map");
  for(let m of maps){
    m.mousePressed(selectMap);
  }

  // select icon
  let dot_icons = selectAll(".icon");
  for(let i of dot_icons){
    i.mousePressed(selectIcon);
  }
}

function draw(){
  image(map, width / 2, height / 2);

  // show ranges
  for(let range of ranges){
    range.show();
  }

  // show icons
  //image(icon, 100, 550, 55.5, 54);
  for(let icon of icons){
    icon.show();
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
  if(mode == "pen")    penDragged();
  // if(mode == "eraser") eraserDragged();
  // if(mode == "save")   saveDragged();
}

function mouseReleased(){
  if(mode == "hand")   handReleased();
  if(mode == "pen")    penReleased();
  // if(mode == "eraser") eraserReleased();
  // if(mode == "save")   saveReleased();
}

function gotFile(file){
  map = createImg(file.data);
  map.hide();
}

function drawRange(px1, py1, px2, py2){
  let d = dist(px1, py1, px2, py2);
  let range = d * 4 / 3;  // px -> range

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
    this.set(_px1, _py1, _px2, _py2, true);
  }

  set(_px1, _py1, _px2, _py2, _isSelected = false){
    this.px1 = _px1;
    this.py1 = _py1;
    this.px2 = _px2;
    this.py2 = _py2;
    this.d   = dist(_px1, _py1, _px2, _py2);
    this.range = this.d * 4 / 3;   // px -> range
    this.isSelected = _isSelected;
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

class Icon{
  constructor(_img, _px, _py){
    this.img = loadImage(_img);
    this.px  = _px;
    this.py  = _py;
  }

  move(_px, _py){
    this.px  = _px;
    this.py  = _py;
  }

  show(){
    image(this.img, this.px, this.py, icon_width, icon_height);
  }
}

function selectMode(){
  // avoid duplication of ".selected"
  for(let operation of selectAll(".operation")){
    operation.removeClass("selected");
  }
  // add ".selected"
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
    px = mouseX;
    py = mouseY;
    
    let r = new Range(px, py, px, py);
    ranges.push(r);
  }
}

function penDragged(){
  for(let range of ranges){
    if(range.isSelected == true){
      range.set(px, py, mouseX, mouseY, true);
    }
  }
}

function penReleased(){
  for(let range of ranges){
    range.isSelected = false;
  }
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
  // for saving only once, change mode "save" -> "hand"
  select("#save").removeClass("selected");
  mode = "hand";
  select("#hand").addClass("selected");
}

function saveReleased(){
}


// make maps menu to html#maps
function make_maps_menu(selector){
  let sel = select(selector);
  let i = 0;
  for(let key in json_maps){
    let div = createDiv();
    div.addClass("accordion");
    sel.child(div);
    let html = `<label for="label${i}">${key}</label>
                <input type="checkbox" id="label${i}">
                  <ul class="accordion_show">`;
    for(let row of json_maps[key]){
      let img_name = row['img'];
      let basename = img_name.replace(/\.(.+)$/, ''); 
      html += `<li id="${basename}" class="map" data-img="${img_name}"><a href="#">${row['text']}</a></li>`;
    }
    html += "</ul>";
    div.html(html);
    i++;
  }
}

function selectMap(){
  let img = this.attribute('data-img');
  // TODO error check
  map = loadImage(img);
}

function selectIcon(){
  let img = this.attribute('data-img');
  let i = new Icon(img, icon_width * (icons.length + 1), 550);
  icons.push(i);
}
