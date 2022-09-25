#include "ui/headers/menudef.h"
#include "ui/includes/common.inc"

#define OPTIONS_STYLE			1

#include "ui/includes/style.inc"
#include "ui/templates/header.menu"

#undef BUTTON_X_SPACING
#define BUTTON_X_SPACING		146

#undef BUTTON_X_START
#define BUTTON_X_START			-((BUTTON_X_SPACING * 3))

#undef BUTTON_Y_START
#define BUTTON_Y_START			0

#undef	BUTTON_SIZE_X
#define BUTTON_SIZE_X			145

#undef	BUTTON_SIZE_Y
#define BUTTON_SIZE_Y			25

#undef  SECTION_X_OFFSET
#define SECTION_X_OFFSET 		0

#undef HIGHLIGHT_BORDER_COLOR
#define HIGHLIGHT_BORDER_COLOR 	1 1 1 0.02

#undef COLOR_FOCUSED
#define COLOR_FOCUSED			1 1 1 0.8

#undef BUTTON_HORIZONTAL_ALIGN
#define BUTTON_HORIZONTAL_ALIGN	HORIZONTAL_ALIGN_CENTER

#undef BUTTON_VERTICAL_ALIGN
#define BUTTON_VERTICAL_ALIGN	VERTICAL_ALIGN_SUBTOP
