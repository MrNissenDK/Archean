# +------------------------------------------------------------------------------------------+
# |                                                                                          |
# |  Auto crafter                                                                            |
# |  by: MrNissenDK                                                                          |
# |  version: 1.0.0                                                                          |
# |  date: 2025-04-22                                                                        |
# |  description: Auto crafting with custom disblay to enable crafting of x amount of items  |
# |                                                                                          |
# +------------------------------------------------------------------------------------------+

# Settings IO
const $crafter_io = 5
const $container_io = 4

# Settings variables
var $numberOfCellsInWidth = 40
const $isDebug = 0

# Crafter variables
var $craftTo = "1"
var $isCrafting = 0
array $autocraftList:text
var $categories:text
var $cellSize:number
var $selected:text


function @pos($x: number, $y:number, $sizeX: number, $sizeY: number): text
	var $pos = ""
	$pos.x = $x
	$pos.y = $y
	$pos.sizeX = $sizeX
	$pos.sizeY = $sizeY
	return $pos
function @color($border:number, $background:number, $text:number): text
	var $color = ""
	$color.border = $border
	$color.background = $background
	$color.text = $text
	return $color
function @align($x:text, $y:text, $text:text, $textPadding:number): text
	var $align = ""
	$align.x = $x
	$align.y = $y
	$align.text = $text
	$align.textPadding = $textPadding
	return $align
function @addButton($pos:text, $txt:text, $color: text, $align:text): number
	var $x = 0
	var $y = 0
	if lower($align.x) == "right"
		$x = -screen_w
	if lower($align.y) == "bottom"
		$y = -screen_h
	var $pressed = 0
	var $width = ceil($cellSize * $pos.sizeX)
	var $height = ceil($cellSize * $pos.sizeY)
	$x = floor(abs($x + $pos.x:number * $cellSize))
	$y = floor(abs($y + $pos.y:number * $cellSize))
	if button_rect($x, $y, $x + $width, $y + $height, $color.border:number, $color.background:number)
		$pressed = 1
	if $txt == ""
		return $pressed
	var $tX = $x
	var $tY = $y + ($height - 8) / 2
	if($align.text == "left")
		if $align.textPadding:number == 0
			$tX += 3
		else
			$tX += $align.textPadding:number
	elseif($align.text == "right")
		$tX += ($width - size($txt) * 6)
		if $align.textPadding:number == 0
			$tX -= 3
		else
			$tX -= $align.textPadding:number
	else
		$tX += ($width - size($txt) * 6) / 2
	write($tX, $tY, $color.text:number, $txt)
	return $pressed
init
	if $cellSize <= 0
		$cellSize = screen_w / $numberOfCellsInWidth
	array $recipesCategories : text
	$recipesCategories.from(get_recipes_categories("crafter"), ",")
	foreach $recipesCategories ($i, $category)
		$categories.$category = 0
var $showNumPad = 0
function @debugMode()
	if $isDebug
		var $cellsWidht = ceil(screen_w / $cellSize)
		var $cellsHieght = ceil(screen_h / $cellSize)
		repeat $cellsWidht ($x)
			draw_line($x * $cellSize, 0, $x * $cellSize, screen_h, red)
		repeat $cellsHieght ($y)
			draw_line(0, $y * $cellSize, screen_w, $y * $cellSize, red)
function @numPad()
	var $buttonCol = red
	var $buttonText = "Off"
	if $isCrafting
		$buttonCol = green
		$buttonText = "On "
	
	if @addButton(@pos(9,0,9,3), $buttonText, @color($buttonCol, black, white), @align("right","top"))
		$isCrafting = ($isCrafting + 1) % 2
	var $inputX = 9
	if $showNumPad
		$inputX = 7
	if @addButton(@pos(9,3,$inputX,3), $craftTo, @color(gray, white, black), @align("right","top", "left"))
		$showNumPad = ($showNumPad + 1) % 2
	if $showNumPad
		if @addButton(@pos(2,3,2,3), "<", @color(red, black, red), @align("right","top"))
			$craftTo = substring($craftTo, 0, size($craftTo) - 1)
		if @addButton(@pos(6,15,6,3), "cls",  @color(red, black, red), @align("right","top"))
			$craftTo = ""
		if @addButton(@pos(9,15,3,3), "0", @color(gray, black, white), @align("right","top"))
			$craftTo &= "0"
		var $i = 0
		repeat 3 ($y)
			repeat 3 ($x)
				$i++
				var $_X = 9 - $x * 3
				var $_Y = 12 - $y * 3
				if @addButton(@pos($_X,$_Y,3,3), text($i), @color(gray, black, white), @align("right","top"))
					$craftTo &= text($i)
	if size($craftTo) > 5
		$craftTo = substring($craftTo, 0, 5)
var $offSet = 0
var $max = 0
function @craftingScreen()
	var $dpIndex = -$offSet
	var $scrollCells = floor(ceil(screen_h / $cellSize) / 2)
	var $lineWidth = text($numberOfCellsInWidth - 12)
	if @addButton(@pos(12, 0, 3, $scrollCells), "", @color(black,color(10,10,10),color(200,200,200)),  @align("right", "top"))
		$offSet -= 5
	if @addButton(@pos(12, $scrollCells, 3, $scrollCells), "", @color(black,color(10,10,10),color(200,200,200)),  @align("right", "top"))
		$offSet += 5
	$offSet = clamp($offSet, 0, max($max-$scrollCells, 0))
	var $rectHight = $scrollCells * $cellSize
	var $triangleX = screen_w - 11 * $cellSize - 1
	var $triangleY = $rectHight / 2
	var $halfCell = $cellSize / 2
	draw_triangle($triangleX, $triangleY + $halfCell, $triangleX + $halfCell - 1, $triangleY - $halfCell, $triangleX + $cellSize,  $triangleY + $halfCell, white, white)
	draw_triangle($triangleX, $triangleY - $halfCell + $rectHight, $triangleX + $halfCell, $triangleY + $halfCell + $rectHight, $triangleX + $cellSize,  $triangleY - $halfCell + $rectHight, white, white)
	foreach $categories ($category, $open)
		if $dpIndex >= 0
			if @addButton(@pos(0, $dpIndex * 2, $lineWidth, 2), $category, @color(black,color(10,10,10),color(200,200,200)),  @align("left", "top", "left", 3))
				$categories.$category = !$categories.$category
		$dpIndex++
		if $open
			array $craftArray:text
			$craftArray.from(get_recipes("crafter", $category), ",")
			foreach $craftArray ($index, $craft)
				var $colorsCraft = @color(black,color(10,10,10),color(200,200,200))
				var $thisIndex = $dpIndex
				$dpIndex++
				if $selected == $craft
					$colorsCraft.border = black
					$colorsCraft.background = color(0,128/256*64,0)
					$colorsCraft.text = color(20,80,0)
					var $recipeInputs = get_recipe("crafter", $selected)
					foreach $recipeInputs ($item, $qty)
						@addButton(@pos(0, $dpIndex * 2, $lineWidth, 2), $item & ":", @color(black,black,color(200,200,200)), @align("left", "top", "left", 15))
						@addButton(@pos(0, $dpIndex * 2, $lineWidth, 2), $qty, @color(0,0,color(150,200,150)), @align("left", "top", "right"))
						$dpIndex++
				if @addButton(@pos(0, $thisIndex * 2, $lineWidth, 2), $craft, $colorsCraft, @align("left", "top", "left", 7))
					$selected = $craft

	$max = $dpIndex + $offSet
update
	blank(black)
	text_size(1)
	@debugMode()
	@numPad()
	@craftingScreen()