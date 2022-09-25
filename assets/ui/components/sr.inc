#define SR_ALIGN_TOP_LEFT 			HORIZONTAL_ALIGN_SUBLEFT 	VERTICAL_ALIGN_SUBTOP
#define SR_ALIGN_TOP_CENTER 		HORIZONTAL_ALIGN_CENTER 	VERTICAL_ALIGN_SUBTOP
#define SR_ALIGN_TOP_RIGHT 			HORIZONTAL_ALIGN_RIGHT 		VERTICAL_ALIGN_SUBTOP
#define SR_ALIGN_BOTTOM_LEFT 		HORIZONTAL_ALIGN_SUBLEFT 	VERTICAL_ALIGN_BOTTOM
#define SR_ALIGN_BOTTOM_CENTER 		HORIZONTAL_ALIGN_CENTER 	VERTICAL_ALIGN_BOTTOM
#define SR_ALIGN_BOTTOM_RIGHT 		HORIZONTAL_ALIGN_RIGHT 		VERTICAL_ALIGN_BOTTOM

#define SR_WINDOW_X 0
#define SR_WINDOW_Y 35
#define SR_WINDOW_W 640
#define SR_WINDOW_H 410

#define SR_WINDOW_ORIGIN SR_WINDOW_X SR_WINDOW_Y
#define SR_WINDOW_SIZE SR_WINDOW_W SR_WINDOW_H

#define SR_WINDOW_RECT SR_WINDOW_ORIGIN SR_WINDOW_SIZE SR_ALIGN_TOP_LEFT
#define SR_WINDOW_HEADER_H 25

#define SR_WINDOW_CONTENT_RECT \
	SR_WINDOW_X \
	(SR_WINDOW_Y + SR_WINDOW_HEADER_H) \
	SR_WINDOW_W \
	(SR_WINDOW_H - SR_WINDOW_HEADER_H) \
	SR_ALIGN_TOP_LEFT \

#define SR_WINDOW_HEADER(headerName) \
	itemdef \
	{ \
		name			headerName \
		rect			0 0 SR_WINDOW_W SR_WINDOW_HEADER_H SR_ALIGN_TOP_LEFT \
		style			1 \
		backcolor		0 0 0 0.5 \
		visible			1 \
		decoration \
	}

#define SR_WINDOW_HEADER_BORDER(r, g, b, a) \
	itemdef \
	{ \
		name			"headerBorder" \
		rect			0 SR_WINDOW_HEADER_H SR_WINDOW_W 2 SR_ALIGN_TOP_LEFT \
		style			1 \
		backcolor		r g b a \
		visible			1 \
		decoration \
	}

#define SR_WINDOW(menuName) \
	name menuName \
	rect SR_WINDOW_RECT \
	itemdef \
	{ \
		name			"window" \
		rect			0 0 SR_WINDOW_SIZE SR_ALIGN_TOP_LEFT \
		style			1 \
		backcolor		0 0 0 0.3 \
		visible			1 \
		decoration \
	} \
	SR_WINDOW_HEADER("header") \
	SR_WINDOW_HEADER_BORDER(0.5, 0.1, 1, 1)

#define SR_FRAME(x, y, w, h) \
	itemdef \
	{ \
		name			"frame" \
		rect			x y w h SR_ALIGN_TOP_LEFT \
		style			1 \
		backcolor		0 0 0 0.4 \
		visible			1 \
		border			5 \
		bordersize		1 \
		bordercolor		0.5 0.1 1 1 \
		decoration \
	}

#define SR_WINDOW_CONTENT(menuName) \
	name menuName \
	rect SR_WINDOW_CONTENT_RECT
