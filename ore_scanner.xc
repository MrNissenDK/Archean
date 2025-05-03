; +-------------------------------------------------------------------------------------------------------------------------------------+
; |                                                                                                                                     |
; |  Ore Scanner                                                                                                                        |
; |  by: MrNissenDK                                                                                                                     |
; |  version: 2.1.0                                                                                                                     |
; |  date: 2025-04-22                                                                                                                   |
; |  description: visable ore scanning showing density of ores with appropiat color and a terrain scanner that show if its Sea or Land  |
; |                                                                                                                                     |
; +-------------------------------------------------------------------------------------------------------------------------------------+
include "grid.xc"
var $distancColoring = gray
const $pivot_io = 3
const $scanner_io = 1
const $scannerTerrain_io = 2
const $speed = 1
var $scanDistance = 1000
var $show = ""
var $minimumDensity = 0.7
var $radius: number
var $colorMap: text
var $scanning = 0
function @toAngle($deg:number):number
	return $deg / 360
function @scan($dist:number, $channel: number):text
	$channel%=2048
	output_number($scanner_io, $channel, $dist)
	output_number($scannerTerrain_io, $channel, $dist)
	var $data = input_text($scanner_io, $channel)
	var $level = input_number($scannerTerrain_io, $channel)
	if $level > 0
		$data.Land = $level
	else
		$data.Sea = -$level
	return $data
var $angle = 0
init
	@init_grid()
	$radius = max($screen.width, $screen.height - 20) / 2
	$screen.blank(black)
	output_number($pivot_io, 1, 3)
	$angle = input_number($pivot_io, 0) * 360
	
	$colorMap.Ag = color(192, 192, 192)
	$colorMap.Al = color(200, 200, 210)
	$colorMap.Au = color(255, 215, 0)
	$colorMap.C  = color(30, 30, 30)
	$colorMap.Cu = color(184, 115, 51)
	$colorMap.Cr = color(0, 255, 255)
	$colorMap.Fe = color(128, 64, 64)
	$colorMap.Ni = color(155, 155, 155)
	$colorMap.Pb = color(90, 90, 90)
	$colorMap.Si = color(192, 192, 200)
	$colorMap.Sn = color(200, 200, 200)
	$colorMap.Ti = color(180, 180, 190)
	$colorMap.U  = color(102, 255, 102)
	$colorMap.W  = color(80, 80, 80)

	$colorMap.land = color(34, 139, 34)
	$colorMap.sea  = color(0, 105, 148)
	$show.land = 1
	$show.sea = 1
function @getRGB($ore:text):text
	var $color = ""
	var $col = $colorMap.$ore:number / 256
	$color.r = ($col - floor($col)) * 256
	$col = floor($col) / 256
	$color.g = ($col - floor($col)) * 256
	$col = floor($col) / 256
	$color.b = ($col - floor($col)) * 256
	return $color
var $maxLand = ".last{0}.current{0}"
var $maxSea = ".last{0}.current{0}"
function @scanning()
	var $doRad = sqrt(pow($radius, 2)*2)
	var $cx = $screen.width / 2
	var $cy = $screen.height / 2 + 5
	repeat $speed ($_discard)
		var $ang = @toAngle($angle)
		output_number($pivot_io, 0, $ang)
		$angle = ($angle + 1) % 360
		var $sin = sin($ang * PI * 2)
		var $cos = cos($ang * PI * 2)
		#var $sin2 = sin(($ang + @toAngle(2)) * PI * 2 + PI)
		#var $cos2 = cos(($ang + @toAngle(2)) * PI * 2 + PI)
		#$screen.draw_line( $cx + $sin2 * $radius / 5 * 2, $cy + $cos2 * $radius / 5 * 2, $cx + $sin2 * $radius / 5 * 4, $cy + $cos2 * $radius / 5 * 4, red)
		var $last = @scan(0, 0)
		repeat $doRad ($j)
			var $ores = @scan($j * $scanDistance / $radius, $j)
			var $x = $sin * $j + $cx
			var $y = $cos * $j + $cy
			var $col = ""
			if $show.Land:number == 1 && $ores.Land != ""
				$maxLand.current = max($maxLand.current, $ores.Land:number)
				$col = @getRGB("Land")
				var $_maxLand = max($maxLand.current, $maxLand.last)
				$col.r *= 1 - $ores.Land:number / max($_maxLand, 1)
				$col.g *= 1 - $ores.Land:number / max($_maxLand, 1)
				$col.b *= 1 - $ores.Land:number / max($_maxLand, 1)
			elseif $show.Sea:number == 1 && $ores.Sea != ""
				$maxSea.current = max($maxSea.current, $ores.Sea:number)
				$col = @getRGB("Sea")
				var $_maxSea = max($maxSea.current, $maxSea.last)
				$col.r *= 1 - $ores.Sea:number / max($_maxSea, 1)
				$col.g *= 1 - $ores.Sea:number / max($_maxSea, 1)
				$col.b *= 1 - $ores.Sea:number / max($_maxSea, 1)
			else
				$col = ".r{0}.g{0}.b{0}"
			var $k = 0
			foreach $ores ($ore, $density)
				if $show.$ore:number == 0 || $density < $minimumDensity || $ore == "land" || $ore == "sea"
					continue
				if $k == 0
					$col.r *= 0.5
					$col.g *= 0.5
					$col.b *= 0.5
				$k++
				var $oreCol = @getRGB($ore)
				$col.r += $oreCol.r * $density
				$col.g += $oreCol.g * $density
				$col.b += $oreCol.b * $density
			if $k != 0
				$col.r /= $k
				$col.g /= $k
				$col.b /= $k
			$screen.draw_point($x, $y, color($col.r:number,$col.g:number,$col.b:number))
	$maxLand.last = $maxLand.current
	$maxSea.last = $maxSea.current
	var $distanceCircles = min($screen.width, $screen.height - 20) / 8;
	var $do = floor(sqrt(pow(max($screen.width, $screen.height - 20) / 2, 2) * 2) / $distanceCircles)
	$screen.text_align(top)
	$screen.text_size(0.5)
	repeat $do ($i)
		var $dist = $i * $distanceCircles
		if $i == 0
			$dist += 3
		$screen.draw_circle($cx, $cy, $dist, $distancColoring)
		if $i < 5
			var $dist2 = $dist * $scanDistance / $radius
			var $distText = ""
			if $dist2 < 1000
				$distText = text("{0}m", $dist2)
			else
				$dist2 = $dist2 / 1000
				$distText = text("{0.0}km", $dist2)
			$screen.write(1, $dist + $cy + 4, white, $distText)
			$screen.write(0, $dist + $cy + 3, $distancColoring, $distText)
	$screen.text_align(top_left)
	$screen.text_size(1)
var $changeVisables = 0
function @showMenu($showMenu:number)
	var $x = $numberOfCellsInWidth - 6
	var $y = 2
	foreach $colorMap ($ore, $color)
		var $buttonColors = @color(black, black, black)
		if $showMenu
			$buttonColors = @color(black, white, black)
		if $showMenu && $show.$ore
			$buttonColors.background = $color
		if @addbutton(@pos($x,$y,6,2), $ore, $buttonColors, @align("", "", "center"))
			$show.$ore = !$show.$ore
		$y+=2
		if $y >= $numberOfCellsInHeight
			$y = 0
			$x -= 6
update
	var $toggleScanningColor = @color(black, red, black)
	var $scanningOn = "Off"
	if $scanning
		$toggleScanningColor.background = green
		$scanningOn = "On"
		@scanning()
	if @addbutton(@pos(0,0,6,4),$scanningOn,$toggleScanningColor)
		$scanning = !$scanning
	if @addbutton(@pos(6,0,2,2),"-",@color(black, black, red))
		$scanDistance = max($scanDistance - 100, 100)
	if @addbutton(@pos(8,0,2,2),"+",@color(black, black, green))
		$scanDistance = max($scanDistance + 100, 100)
	if @addbutton(@pos(6,2,2,2),"-",@color(black, black, red))
		$minimumDensity = clamp($minimumDensity - 0.1, 0, 1)
	if @addbutton(@pos(8,2,2,2),"+",@color(black, black, green))
		$minimumDensity = clamp($minimumDensity + 0.1, 0, 1)
	@addbutton(@pos(10,0,24,2),text("R: {}m", $scanDistance),@color(black, black, white), @align("", "", "left"))
	@addbutton(@pos(10,2,30,2),text("D: {0}%", $minimumDensity * 100),@color(black, black, white), @align("", "", "left"))
	
	if @addbutton(@pos(34,0,6,2),text("conf", $scanDistance),@color(gray, white, gray), @align("", "", "center"))
		$changeVisables = !$changeVisables
		if !$changeVisables
			@showMenu(0)
	if $changeVisables == 1
		@showMenu(1)