#include "ui/headers/menudef.h"
#include "ui/includes/common_macro.inc"
#include "ui/includes/sr.inc"

//#define 	OPTIONS_STYLE		1
#define 	CHOICE_SEP_1		25
#define 	CHOICE_SEP_2		32

// starting offset
#define CHOICE_X_START			-298//145
#define CHOICE_Y_START			55

// uhm?
#define STYLE_PC				1

#include "ui/includes/menustyle.inc"
//#include "ui/templates/choices_setup_common.menu"
#include "ui/templates/options_setup_common.menu"

// button description text offset
#undef CHOICE_TEXT_OFFSET_X
#define CHOICE_TEXT_OFFSET_X 	0

//#undef CHOICE_DVAR_OFFSET_X
//#define CHOICE_DVAR_OFFSET_X 	0

#undef CHOICE_HORIZONTAL_ALIGN
#define CHOICE_HORIZONTAL_ALIGN HORIZONTAL_ALIGN_CENTER

// spacing between buttons horizontal
#undef	CHOICE_X_SPACING
#define CHOICE_X_SPACING 		310

// number of rows
#undef	CHOICE_Y_COUNT
#define CHOICE_Y_COUNT 			15

// general button + dvar width?
#undef	CHOICE_SIZE_X
#define CHOICE_SIZE_X 			160

// button & highlight width
#undef SR_BTN_SIZE_X
#define SR_BTN_SIZE_X 			280

// button height .. prob fucks up dvars
#undef	CHOICE_SIZE_Y
#define CHOICE_SIZE_Y 			22

#undef 	SR_BTN_APPLY_X
#define SR_BTN_APPLY_X 			240

#undef 	SR_BTN_APPLY_Y
#define SR_BTN_APPLY_Y 			-100

// gets rid of that nasty spacer on element 26 ..
#undef CHOICE_SEP_1
#define CHOICE_SEP_1            0