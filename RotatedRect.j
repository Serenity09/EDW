library RotatedRect
	function IsPointInRect takes real x, real y, real centerX, real centerY, real angle, real width, real height returns boolean
		local real angleSin = Sin(2*bj_PI - angle)
        local real angleCos = Cos(2*bj_PI - angle)
		
		local real x_new = angleCos * (x - centerX) - angleSin * (y - centerY) + centerX
		local real y_new = angleSin * (x - centerX) + angleCos * (y - centerY) + centerY
		
		return centerX - width <= x_new and centerX + width >= x_new and centerY - height <= y_new and centerY + height >= y_new
	endfunction
endlibrary