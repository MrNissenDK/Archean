; +---------------------------------------------------------------+
; |                                                               |
; |  Grid system                                                  |
; |  by: MrNissenDK                                               |
; |  version: 1.0.0                                               |
; |  date: 2025-04-22                                             |
; |  description: Simple Grid System to align items on dashboard  |
; |                                                               |
; +---------------------------------------------------------------+

; Settings IO
var $screen = screen(0,0)

; Settings variables
const $numberOfCellsInWidth = 40

; grid variables
var $cellSize:number
var $numberOfCellsInHeight: number

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
		$x = -$screen.width
	if lower($align.y) == "bottom"
		$y = -$screen.height
	var $pressed = 0
	var $width = ceil($cellSize * $pos.sizeX)
	var $height = ceil($cellSize * $pos.sizeY)
	$x = floor(abs($x + $pos.x:number * $cellSize))
	$y = floor(abs($y + $pos.y:number * $cellSize))
	if $screen.button_rect($x, $y, $x + $width, $y + $height, $color.border:number, $color.background:number)
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
	$screen.write($tX, $tY, $color.text:number, $txt)
	return $pressed
function @init_grid()
	if $cellSize <= 0
		$cellSize = $screen.width / $numberOfCellsInWidth
	$numberOfCellsInHeight = floor($screen.height / $cellSize)