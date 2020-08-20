function toPointy(flatMeasure) = flatMeasure / cos(30);
function toFlat(pointyMeasure) = pointyMeasure * cos(30);
function borderFuz(measure) = measure * 1.00000000001;

Cell_size = 30; // [10:60]

// Thickness of the outer & inner walls
Wall_thickness = 1.2; // [0.4:0.01:3.0]
th = Wall_thickness;
pth = toPointy(th);

// Maximum width of the organizer
Width = 230; // [5:500]
// Maximum depth of the organizer
Depth = 150; // [5:500]
// Height of the organizer
Height = 100; // [3:300]

// Increaze the size of the cells to fit the bounding box
Scaling_strategy="none"; // [none:Don't scale, both:Consider both dimensions, width:Fit width, depth:Fit depth]

// Create half-hexagons and flatten out sides along the "flat" edges
Close_off="none"; // [none:Don't close, one:Close on a single side, both:Close on the both sides]





min_flatSize = Cell_size;
min_pointySize = toPointy(min_flatSize);


function numHexDepth(flatSize) =
    floor((Depth - th) * 2 / (flatSize + th));  // 1 too high
function numHexWidth(pointySize) =
    floor(4 * (Width - pointySize - 2 * pth) / (pointySize + pth) / 3);  // 1 too low

function resultingWidth(pointySize) = pointySize + pth * 2 + (pointySize + pth) * 3 / 4 * numHexWidth(pointySize);
function resultingDepth(flatSize) = (flatSize + th) * numHexDepth(flatSize) / 2 + th;



numHexDepth = numHexDepth(min_flatSize);
adjustedFlatSize = (Depth - th) * 2 / (numHexDepth) - th;

numHexWidth = numHexWidth(min_pointySize);
adjustedPointySize = (4 * Width - (8 + 3*numHexWidth) * pth) / (4 + 3*numHexWidth);




flatSize =
    (Scaling_strategy == "both") ? min(adjustedFlatSize, toFlat(adjustedPointySize)) : (
    (Scaling_strategy == "depth") ? adjustedFlatSize : (
    (Scaling_strategy == "width") ? toFlat(adjustedPointySize) :
    min_flatSize));

flatSize_th = flatSize + th*2;

pointySize = toPointy(flatSize);
pointySize_th = pointySize + pth * 2; 


%color("cyan", 0.2)
translate([pointySize_th/2-flatSize/2, th])
cube([flatSize, flatSize, Height+20]);

%color("purple", 0.2)
cube([Width, Depth, 1]);


module hex() {
    translate([pointySize_th/2, flatSize_th/2])
    difference() {
        circle(d=pointySize_th, $fn=6);
        circle(d=pointySize, $fn=6);
    }
}

module hexColumns(initialNudge=[0,0]) {
    for(
        i = [initialNudge[0] : (pointySize + pointySize_th) * 3 / 4 : borderFuz(Width-pointySize_th)],
        j = [initialNudge[1] : (flatSize + flatSize_th)/2: borderFuz(Depth - flatSize_th)]
    ) {   
        translate([i,j,0]) hex();    
    }
}


linear_extrude(Height) {
    hexColumns();
    hexColumns([pointySize*3/4 + pth * 3/4, flatSize/2 + th/2]);

    widthModifier = numHexWidth(pointySize)%2;
    depthModifier = numHexDepth(flatSize)%2;

    if (Close_off=="one" || Close_off=="both") {
        translate([pointySize_th/2, 0])
        square([resultingWidth(pointySize) - pointySize_th * (1 + 0.75 * widthModifier),th]);
    }

    if (Close_off=="both") {
        topBarModifier = abs(2 * depthModifier - widthModifier);
        translate([pointySize_th * (0.5 + 0.75 * depthModifier ), resultingDepth(flatSize) - th])
        square([resultingWidth(pointySize) - pointySize_th * (1 + 0.75 * topBarModifier),th]);
    }
}

if(!$preview)
translate([pointySize_th / 4 * cos(60), pointySize_th / 4 * cos(30), 5])
rotate([0,-90,30])
linear_extrude(0.5)
intersection() {
    union() {
        textAreaSize = pointySize_th / 2 * 0.8;

        translate([0,textAreaSize / 2 * 0.1])
        text("Terpuh", size = textAreaSize / 2 * 0.9 );

        translate([0,-textAreaSize / 2])
        text("Labs", size = textAreaSize / 2 * 0.9);
    }
    
    translate([0, -pointySize_th/2])
    square([Height-10, pointySize_th]);
}