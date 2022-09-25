#ifdef PC
	#ifndef STYLE2_NOPOSITION
		#define ACCEPT_ALIGN_X		-2
		#define	LAYOUT_TEXTALIGN			ITEM_ALIGN_MIDDLE_CENTER
		#undef LAYOUT_SEPARATOR_OFFSET_Y
		#define LAYOUT_SEPARATOR_OFFSET_Y			-2

		#define TEXTLAYOUT_COLOR			0.9 0.9 0.92 0.4
		#define TEXTSIZE_LAYOUT_PC			0.3
		#define ORIGIN_OPTIONS_FRAME		220 0

		#define BUTTON_DVAR_TEXTALIGN		ITEM_ALIGN_MIDDLE_LEFT
		#define	BUTTON_DVAR_OFFSET_X		(LAYOUT_SIZE_X+20)
		#define BUTTON_DVAR_WIDTH_OFFSET	120

		#ifdef OPTIONS_STYLE
			#undef	LAYOUT_X_START
			#define LAYOUT_X_START			0
			#undef  LAYOUT_Y_START
			#define LAYOUT_Y_START			10

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
	#undef LAYOUT_SIZE_X
	#define LAYOUT_SIZE_X 224
	#undef LAYOUT_SIZE_Y
	#define LAYOUT_SIZE_Y 22
	#define ACCEPT_ALIGN_X	-2
	#define ACCEPT_ALIGN_Y	0

	#define	A_LAYOUT_OFFSET_Y		1

	#define	LAYOUT_TEXTALIGN		ITEM_ALIGN_MIDDLE_RIGHT
	#define ALT_HINT_X_OFFSET		-(LAYOUT_SIZE_Y)
	#undef LAYOUT_SEPARATOR_OFFSET_Y
	#define LAYOUT_SEPARATOR_OFFSET_Y		-2
	#define NEW_X_OFFSET			2
#endif

#ifdef PC
	#undef LAYOUT_TEXTSIZE
	#define LAYOUT_TEXTSIZE			TEXTSIZE_LAYOUT_PC
#else
	#undef LAYOUT_TEXTSIZE
	#define LAYOUT_TEXTSIZE			TEXTSIZE_DEFAULT
#endif

// Position setting for splitscreen
#ifdef SPLITSCREEN_ENABLED
	#undef LAYOUT_SIZE_X
	#define LAYOUT_SIZE_X 120
	#undef LAYOUT_SIZE_Y
	#define LAYOUT_SIZE_Y 18
	#define ACCEPT_ALIGN_X	-2
	#define ACCEPT_ALIGN_Y	0
	#define	LAYOUT_TEXTALIGN		ITEM_ALIGN_MIDDLE_RIGHT
	#define ALT_HINT_X_OFFSET		-(LAYOUT_SIZE_Y)
	#undef LAYOUT_SEPARATOR_OFFSET_Y
	#define LAYOUT_SEPARATOR_OFFSET_Y		-2
	#define NEW_X_OFFSET			2

	#undef LAYOUT_TEXTSIZE
	#define LAYOUT_TEXTSIZE		TEXTSIZE_SMALL

	#define BACKGROUND_COLOR			0.9 0.9 1 0.12
#endif

#undef LAYOUT_TEXTCOLOR
#define LAYOUT_TEXTCOLOR		1 1 1 1

#undef LAYOUT_TEXTSTYLE
#define LAYOUT_TEXTSTYLE		ITEM_TEXTSTYLE_NORMAL

#undef HIGHLIGHT_BORDER
#define HIGHLIGHT_BORDER		0

#undef HIGHLIGHT_SHADER
#define HIGHLIGHT_SHADER		"gradient_fadein"

#undef HIGHLIGHT_COLOR
#define HIGHLIGHT_COLOR			1 1 1 0.8

#undef A_LAYOUT_COLOR
#define A_LAYOUT_COLOR			1 1 1 1

#undef LAYOUT_HORIZONTAL_ALIGN
#define LAYOUT_HORIZONTAL_ALIGN	HORIZONTAL_ALIGN_LEFT

#undef LAYOUT_VERTICAL_ALIGN
#define LAYOUT_VERTICAL_ALIGN	VERTICAL_ALIGN_TOP

#undef RIGHTITEM_ALIGN
#define RIGHTITEM_ALIGN			HORIZONTAL_ALIGN_RIGHT

#undef RIGHTITEM_OFFSET
#define RIGHTITEM_OFFSET		0

#undef LAYOUT_FONT
#define LAYOUT_FONT				UI_FONT_NORMAL

#undef LAYOUT_Y_SPACING
#define LAYOUT_Y_SPACING		(LAYOUT_SIZE_Y+2)

#undef LAYOUT_SEPARATOR_SPACING
#define LAYOUT_SEPARATOR_SPACING		10

#undef LAYOUT_SEPARATOR_WIDTH
#define LAYOUT_SEPARATOR_WIDTH		(LAYOUT_SIZE_X - (LAYOUT_SIZE_Y/4))
