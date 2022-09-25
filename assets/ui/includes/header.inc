#include "ui/headers/menudef.h"
#include "ui/includes/common.inc"

#define OPTIONS_STYLE			1

#include "ui/includes/style.inc"
#include "ui/templates/header.menu"

#undef CHOICE_X_SPACING
#define CHOICE_X_SPACING		146

#undef CHOICE_X_START
#define CHOICE_X_START			-((CHOICE_X_SPACING * 3))

#undef CHOICE_Y_START
#define CHOICE_Y_START			0

#undef	CHOICE_SIZE_X
#define CHOICE_SIZE_X			145

#undef	CHOICE_SIZE_Y
#define CHOICE_SIZE_Y			25

#undef  SECTION_X_OFFSET
#define SECTION_X_OFFSET 		0

#undef HIGHLIGHT_BORDER_COLOR
#define HIGHLIGHT_BORDER_COLOR 	1 1 1 0.02

#undef COLOR_FOCUSED
#define COLOR_FOCUSED			0.80 0.04 0.32 1

#undef CHOICE_HORIZONTAL_ALIGN
#define CHOICE_HORIZONTAL_ALIGN	HORIZONTAL_ALIGN_CENTER

#undef CHOICE_VERTICAL_ALIGN
#define CHOICE_VERTICAL_ALIGN	VERTICAL_ALIGN_SUBTOP
