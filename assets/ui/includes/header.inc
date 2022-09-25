#include "ui/headers/menudef.h"
#include "ui/includes/common.inc"

#define OPTIONS_STYLE			1

#include "ui/includes/style.inc"
#include "ui/templates/header.menu"

#undef HEADER_X_SPACING
#define HEADER_X_SPACING		146

#undef HEADER_X_START
#define HEADER_X_START			-((HEADER_X_SPACING * 3))

#undef HEADER_Y_START
#define HEADER_Y_START			0

#undef	HEADER_SIZE_X
#define HEADER_SIZE_X			145

#undef	HEADER_SIZE_Y
#define HEADER_SIZE_Y			25

#undef HEADER_HIGHLIGHT_BORDER_COLOR
#define HEADER_HIGHLIGHT_BORDER_COLOR 	1 1 1 0.02

#undef HEADER_COLOR_FOCUSED
#define HEADER_COLOR_FOCUSED			1 1 1 0.8

#undef HEADER_HORIZONTAL_ALIGN
#define HEADER_HORIZONTAL_ALIGN	HORIZONTAL_ALIGN_CENTER

#undef HEADER_VERTICAL_ALIGN
#define HEADER_VERTICAL_ALIGN	VERTICAL_ALIGN_SUBTOP
