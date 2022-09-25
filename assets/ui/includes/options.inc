#include "ui/headers/menudef.h"
#include "ui/includes/common.inc"

#define 	CHOICE_SEP_1		25
#define 	CHOICE_SEP_2		32

#define CHOICE_X_START			-298
#define CHOICE_Y_START			35

#define STYLE_PC				1

#include "ui/includes/style.inc"
#include "ui/templates/options.menu"

#undef CHOICE_TEXT_OFFSET_X
#define CHOICE_TEXT_OFFSET_X 	0

#undef CHOICE_HORIZONTAL_ALIGN
#define CHOICE_HORIZONTAL_ALIGN HORIZONTAL_ALIGN_CENTER

#undef	CHOICE_X_SPACING
#define CHOICE_X_SPACING 		310

#undef	CHOICE_Y_COUNT
#define CHOICE_Y_COUNT 			15

#undef	CHOICE_SIZE_X
#define CHOICE_SIZE_X 			160

#undef SR_BTN_SIZE_X
#define SR_BTN_SIZE_X 			280

#undef	CHOICE_SIZE_Y
#define CHOICE_SIZE_Y 			22

#undef 	SR_BTN_APPLY_X
#define SR_BTN_APPLY_X 			240

#undef 	SR_BTN_APPLY_Y
#define SR_BTN_APPLY_Y 			-100

#undef CHOICE_SEP_1
#define CHOICE_SEP_1            0
