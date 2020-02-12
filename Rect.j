library Rect
	function BufferedRectContainsCoords takes rect r, real x, real y, real buffer returns boolean
		return x >= GetRectMinX(r) - buffer and x <= GetRectMaxX(r) + buffer /*
			*/ and y >= GetRectMinY(r) - buffer and y <= GetRectMaxY(r) + buffer
	endfunction
endlibrary