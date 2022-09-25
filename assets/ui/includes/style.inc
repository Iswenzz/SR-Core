#ifdef PC
	#ifndef STYLE2_NOPOSITION
		#define BUTTON_ACCEPT_ALIGN_X		-2
		#define	BUTTON_TEXTALIGN			ITEM_ALIGN_MIDDLE_CENTER
		#undef BUTTON_SEP_OFFSET_Y
		#define BUTTON_SEP_OFFSET_Y			-2

		#define TEXTBUTTON_COLOR			0.9 0.9 0.92 0.4
		#define TEXTSIZE_BUTTON_PC			0.3
		#define ORIGIN_OPTIONS_FRAME		220 0

		#define BUTTON_DVAR_TEXTALIGN		ITEM_ALIGN_MIDDLE_LEFT
		#define	BUTTON_DVAR_OFFSET_X		(BUTTON_SIZE_X+20)
		#define BUTTON_DVAR_WIDTH_OFFSET	120

		#ifdef OPTIONS_STYLE
			#undef	BUTTON_X_START
			#define BUTTON_X_START			0
			#undef  BUTTON_Y_START
			#define BUTTON_Y_START			10

			#define LOCAL_CLOSE_ALL \
				close options_look; \
				close options_move; \
				close options_shoot; \
				close options_misc; \
				close options_graphics; \
				close options_sound; \
				close options_game; \
				close options_view; \
				close options_defaults; \
				close options_driverinfo; \
				close options_credits; \
				close options_multi; \
				close options_graphics_defaults; \
				close options_graphics_texture; \
				close options_control_defaults; \
				close options_voice; \
				close options_multi; \
				close controls_multi; \
				close main_options; \
				close main_controls

			#define LOCAL_CLOSE_ALL_CUSTOM \
				close options_look; \
				close options_move; \
				close options_shoot; \
				close options_misc; \
				close options_graphics; \
				close options_sound; \
				close options_game; \
				close options_view; \
				close options_defaults; \
				close options_driverinfo; \
				close options_credits; \
				close options_multi; \
				close options_graphics_defaults; \
				close options_graphics_texture; \
				close options_control_defaults; \
				close options_voice; \
				close options_multi; \
				close controls_multi
		#endif

		// Disable the other positioning overrides
		#undef STYLE2_NOPOSITION
		#define STYLE2_NOPOSITION			1
		#undef SPLITSCREEN_ENABLED

	#endif

	#define TITLE_X_OFFSET				-36
	#define TITLE_Y_OFFSET				-36

#endif

// Position setting
#ifndef STYLE2_NOPOSITION
	#undef BUTTON_SIZE_X
	#define BUTTON_SIZE_X 224
	#undef BUTTON_SIZE_Y
	#define BUTTON_SIZE_Y 22
	#define BUTTON_ACCEPT_ALIGN_X	-2
	#define BUTTON_ACCEPT_ALIGN_Y	0

	#define	A_BUTTON_OFFSET_Y		1

	#define	BUTTON_TEXTALIGN		ITEM_ALIGN_MIDDLE_RIGHT
	#define ALT_HINT_X_OFFSET		-(BUTTON_SIZE_Y)
	#undef BUTTON_SEP_OFFSET_Y
	#define BUTTON_SEP_OFFSET_Y		-2
	#define NEW_X_OFFSET			2
#endif

#ifdef PC
	#undef BUTTON_TEXTSIZE
	#define BUTTON_TEXTSIZE			TEXTSIZE_BUTTON_PC
#else
	#undef BUTTON_TEXTSIZE
	#define BUTTON_TEXTSIZE			TEXTSIZE_DEFAULT
#endif

// Position setting for splitscreen
#ifdef SPLITSCREEN_ENABLED
	#undef BUTTON_SIZE_X
	#define BUTTON_SIZE_X 120
	#undef BUTTON_SIZE_Y
	#define BUTTON_SIZE_Y 18
	#define BUTTON_ACCEPT_ALIGN_X	-2
	#define BUTTON_ACCEPT_ALIGN_Y	0
	#define	BUTTON_TEXTALIGN		ITEM_ALIGN_MIDDLE_RIGHT
	#define ALT_HINT_X_OFFSET		-(BUTTON_SIZE_Y)
	#undef BUTTON_SEP_OFFSET_Y
	#define BUTTON_SEP_OFFSET_Y		-2
	#define NEW_X_OFFSET			2

	#undef BUTTON_TEXTSIZE
	#define BUTTON_TEXTSIZE		TEXTSIZE_SMALL

	#define BUTTON_BG_COLOR			0.9 0.9 1 0.12
#endif

#undef BUTTON_TEXTCOLOR
#define BUTTON_TEXTCOLOR		1 1 1 1

#undef BUTTON_TEXTSTYLE
#define BUTTON_TEXTSTYLE		ITEM_TEXTSTYLE_NORMAL

#undef HIGHLIGHT_BORDER
#define HIGHLIGHT_BORDER		0

#undef HIGHLIGHT_SHADER
#define HIGHLIGHT_SHADER		"gradient_fadein"

#undef HIGHLIGHT_COLOR
#define HIGHLIGHT_COLOR			1 1 1 0.8

#undef A_BUTTON_COLOR
#define A_BUTTON_COLOR			1 1 1 1

#undef BUTTON_HORIZONTAL_ALIGN
#define BUTTON_HORIZONTAL_ALIGN	HORIZONTAL_ALIGN_LEFT

#undef BUTTON_VERTICAL_ALIGN
#define BUTTON_VERTICAL_ALIGN	VERTICAL_ALIGN_TOP

#undef RIGHTITEM_ALIGN
#define RIGHTITEM_ALIGN			HORIZONTAL_ALIGN_RIGHT

#undef RIGHTITEM_OFFSET
#define RIGHTITEM_OFFSET		0

#undef BUTTON_FONT
#define BUTTON_FONT				UI_FONT_NORMAL

#undef BUTTON_Y_SPACING
#define BUTTON_Y_SPACING		(BUTTON_SIZE_Y+2)

#undef BUTTON_SEP_SPACING
#define BUTTON_SEP_SPACING		10

#undef BUTTON_SEP_WIDTH
#define BUTTON_SEP_WIDTH		(BUTTON_SIZE_X - (BUTTON_SIZE_Y/4))
