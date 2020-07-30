function toPointy(flatMeasure) = flatMeasure / cos(30);
function toFlat(pointyMeasure) = pointyMeasure * cos(30);
function borderFuz(measure) = measure * 1.0000001;


minSize = 30;
th = 1.5;
pth = toPointy(th);

width = 259;
depth = 115;
height = 100;

min_flatSize = minSize;
min_pointySize = toPointy(min_flatSize);


function numHexDepth(flatSize) =
    floor((depth - th) * 2 / (flatSize + th));  // 1 too high
function numHexWidth(pointySize) =
    floor(4 * (width - pointySize - 2 * pth) / (pointySize + pth) / 3);  // 1 too low

function resultingWidth(pointySize) = pointySize + pth * 2 + (pointySize + pth) * 3 / 4 * numHexWidth(pointySize);
function resultingDepth(flatSize) = (flatSize + th) * numHexDepth(flatSize) / 2 + th;



numHexDepth = numHexDepth(min_flatSize);
adjustedFlatSize = (depth - th) * 2 / (numHexDepth) - th;

numHexWidth = numHexWidth(min_pointySize);
adjustedPointySize = (4 * width - (8 + 3*numHexWidth) * pth) / (4 + 3*numHexWidth);


flatSize = min(adjustedFlatSize, adjustedPointySize * cos(30));
flatSize_th = flatSize + th*2;

pointySize = flatSize / cos(30);
pointySize_th = pointySize + th / cos(30) * 2; 




%color("cyan", 0.1)
translate([pointySize_th/2-flatSize/2, th])
cube([flatSize, flatSize, 50]);

%color("red", 0.1)
cube([pointySize_th, flatSize_th, 5]);

%color("purple", 0.1)
cube([width, depth, 1]);

module hex() {
    translate([pointySize_th/2, flatSize_th/2])
    difference() {
        circle(d=pointySize_th, $fn=6);
        circle(d=pointySize, $fn=6);
    }
}

module hexColumns(initialNudge=[0,0]) {
    for(
        i = [initialNudge[0] : (pointySize + pointySize_th) * 3 / 4 : borderFuz(width-pointySize_th)],
        j = [initialNudge[1] : (flatSize + flatSize_th)/2: borderFuz(depth - flatSize_th)]
    ) {   
        translate([i,j,0]) hex();    
    }
}


linear_extrude(height) {
    hexColumns();
    hexColumns([pointySize*3/4 + pth * 3/4, flatSize/2 + th/2]);

    widthModifier = numHexWidth(pointySize)%2;
    depthModifier = numHexDepth(flatSize)%2;


    translate([pointySize_th/2, 0])
    square([resultingWidth(pointySize) - pointySize_th * (1 + 0.75 * widthModifier),th]);

    topBarModifier = abs(2 * depthModifier - widthModifier);
    translate([pointySize_th * (0.5 + 0.75 * depthModifier ), resultingDepth(flatSize) - th])
    square([resultingWidth(pointySize) - pointySize_th * (1 + 0.75 * topBarModifier),th]);
}

