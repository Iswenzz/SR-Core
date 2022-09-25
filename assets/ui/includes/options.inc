#include "ui/headers/menudef.h"
#include "ui/includes/common.inc"

#define 	BUTTON_SEP_1		25
#define 	BUTTON_SEP_2		32

#define BUTTON_X_START			-298
#define BUTTON_Y_START			15

#define STYLE_PC				1

#include "ui/includes/style.inc"
#include "ui/templates/button.menu"

#undef BUTTON_TEXT_OFFSET_X
#define BUTTON_TEXT_OFFSET_X 	0

#undef BUTTON_HORIZONTAL_ALIGN
#define BUTTON_HORIZONTAL_ALIGN HORIZONTAL_ALIGN_CENTER

#undef	BUTTON_X_SPACING
#define BUTTON_X_SPACING 		310

#undef	BUTTON_Y_COUNT
#define BUTTON_Y_COUNT 			15

#undef	BUTTON_SIZE_X
#define BUTTON_SIZE_X 			160

#undef SR_BTN_SIZE_X
#define SR_BTN_SIZE_X 			280

#undef	BUTTON_SIZE_Y
#define BUTTON_SIZE_Y 			22

#undef 	SR_BTN_APPLY_X
#define SR_BTN_APPLY_X 			240

#undef 	SR_BTN_APPLY_Y
#define SR_BTN_APPLY_Y 			-100

#undef BUTTON_SEP_1
#define BUTTON_SEP_1            0
