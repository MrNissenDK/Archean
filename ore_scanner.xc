# +-------------------------------------------------------------------------------------------------------------------------------------+
# |                                                                                                                                     |
# |  Ore Scanner                                                                                                                        |
# |  by: MrNissenDK                                                                                                                     |
# |  version: 2.0                                                                                                                       |
# |  date: 2025-04-22                                                                                                                   |
# |  description: visable ore scanning showing density of ores with appropiat color and a terrain scanner that show if its Sea or Land  |
# |                                                                                                                                     |
# +-------------------------------------------------------------------------------------------------------------------------------------+
var $screen = screen(0,0)
const $pivot_io = 2
const $scanner_io = 1
const $scannerTerrain_io = 3
const $speed = 4
var $scanDistance = 100000
var $show = ""
var $minimumDensity = 0.7
var $width: number
var $height: number
var $radius: number
var $colorMap: text
function @toAngle($deg:number):number
	return $deg / 360
function @scan($dist:number, $channel: number):text
	$channel%=2048
	output_number($scanner_io, $channel, $dist)
	output_number($scannerTerrain_io, $channel, $dist)
	var $data = input_text($scanner_io, $channel)
	var $level = input_number($scannerTerrain_io, $channel)
	if $level > 0
		$data.Land = clamp($level / 10000, 0, 1) + 0.5
	else
		$data.Sea = clamp(-$level / 10000, 0, 1) + 0.5
	return $data
var $angle = 0
init
	$width = $screen.width
	$height = $screen.width
	$radius = max($width, $height - 20) / 2
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

	// Environment
	$colorMap.land = color(34, 139, 34)
	$colorMap.sea  = color(0, 105, 148)
	foreach $colorMap ($ore, $_discard)
		$show.$ore = 1
function @getRGB($ore:text):text
	var $color = ""
	var $col = $colorMap.$ore:number / 256
	$color.r = ($col - floor($col)) * 256
	$col = floor($col) / 256
	$color.g = ($col - floor($col)) * 256
	$col = floor($col) / 256
	$color.b = ($col - floor($col)) * 256
	return $color
function @scanning()
	var $doRad = sqrt(pow($radius, 2)*2)
	repeat $speed ($_discard)
		var $ang = @toAngle($angle)
		output_number($pivot_io, 0, $ang)
		$angle = ($angle + 0.25) % 360
		var $sin = sin($ang * PI * 2 + PI)
		var $cos = cos($ang * PI * 2 + PI)
		var $sin2 = sin(($ang + @toAngle(2)) * PI * 2 + PI)
		var $cos2 = cos(($ang + @toAngle(2)) * PI * 2 + PI)
		var $cx = $width / 2
		var $cy = $height / 2 + 5
		$screen.draw_line( $cx + $sin2 * $radius / 5 * 2, $cy + $cos2 * $radius / 5 * 2, $cx + $sin2 * $radius / 5 * 4, $cy + $cos2 * $radius / 5 * 4, red)
		var $last = @scan(0, 0)
		repeat $doRad ($j)
			var $ores = @scan($j * $scanDistance / $radius, $j)
			var $x = $sin * $j + $cx
			var $y = $cos * $j + $cy
			var $col = ""
			if $show.Land:number == 1 && $ores.Land != ""
				$col = @getRGB("Land")
				$col.r *= $ores.Land:number
				$col.g *= $ores.Land:number
				$col.b *= $ores.Land:number
			elseif $show.Sea:number == 1 && $ores.Sea != ""
				$col = @getRGB("Sea")
				$col.r *= $ores.Sea:number
				$col.g *= $ores.Sea:number
				$col.b *= $ores.Sea:number
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
var $changeVisables = 0
update
	@scanning()
	$screen.text_size(1)
	$screen.draw_rect(0, 0, $width, 20, black, black)
	$screen.write(20, 0, white, text("R: {}m", $scanDistance))
	$screen.write(20, 10, white, text("D: {}", $minimumDensity))
	if $screen.button_rect(0, 0, 10, 10, black)
		$scanDistance = max($scanDistance - 100, 100)
	if $screen.button_rect(10, 0, 20, 10, black)
		$scanDistance = max($scanDistance + 100, 100)
	$screen.write(2, 2, red, "-")
	$screen.write(12, 2, green, "+")
	if $screen.button_rect(0, 10, 10, 20, black)
		$minimumDensity = clamp($minimumDensity - 0.1, 0, 1)
	if $screen.button_rect(10, 10, 20, 20, black)
		$minimumDensity = clamp($minimumDensity + 0.1, 0, 1)
	$screen.write(2, 12, red, "-")
	$screen.write(12, 12, green, "+")
	if $screen.button_rect($width - 30, 0, $width, 12, gray, white)
		$changeVisables = ($changeVisables + 1) % 2
		if $changeVisables == 0
			var $x = $width - 30
			var $y = 12	
			foreach $colorMap ($ore, $color)
				$screen.draw_rect($x, $y, $x + 40, $y + 12, black, black)
				$y+=12
				if $y >= $height
					$y = 0
					$x -= 40
	$screen.write($width - 27, 2, black, "conf")
	if $changeVisables == 1
		var $x = $width - 30
		var $y = 12	
		foreach $colorMap ($ore, $color)
			if $screen.button_rect($x, $y, $x + 40, $y + 12, $color:number, white)
				$show.$ore = ($show.$ore:number + 1)%2
			$screen.write($x + 3, $y + 2, $color:number, text($ore & " {}", $show.$ore))
			$y+=12
			if $y >= $height
				$y = 0
				$x -= 40
	