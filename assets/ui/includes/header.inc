#include "ui/headers/menudef.h"
#include "ui/includes/common.inc"

#define OPTIONS_STYLE			1

#include "ui/includes/style.inc"
#include "ui/templates/header.menu"

#undef LAYOUT_X_SPACING
#define LAYOUT_X_SPACING		146

#undef LAYOUT_X_START
#define LAYOUT_X_START			-((LAYOUT_X_SPACING * 3))

#undef LAYOUT_Y_START
#define LAYOUT_Y_START			0

#undef	LAYOUT_SIZE_X
#define LAYOUT_SIZE_X			145

#undef	LAYOUT_SIZE_Y
#define LAYOUT_SIZE_Y			25

#undef  SECTION_X_OFFSET
#define SECTION_X_OFFSET 		0

#undef HIGHLIGHT_BORDER_COLOR
#define HIGHLIGHT_BORDER_COLOR 	1 1 1 0.02

#undef COLOR_FOCUSED
#define COLOR_FOCUSED			1 1 1 0.8

#undef LAYOUT_HORIZONTAL_ALIGN
#define LAYOUT_HORIZONTAL_ALIGN	HORIZONTAL_ALIGN_CENTER

#undef LAYOUT_VERTICAL_ALIGN
#define LAYOUT_VERTICAL_ALIGN	VERTICAL_ALIGN_SUBTOP
