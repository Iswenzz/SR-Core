#undef	FOG_SCROLL_TIME
#define FOG_SCROLL_TIME 60000

#undef	THINFOG_SCROLL_TIME
#define THINFOG_SCROLL_TIME 100000

#define THEME(id) \
itemDef \
{ \
	style			WINDOW_STYLE_SHADER \
	rect			FULLSCREEN_WIDE \
	background		"sr_menu_bg_"id \
	visible			when(stat(984) == (id - 1)) \
	decoration \
}

THEME(1);
THEME(2);
THEME(3);
THEME(4);
THEME(5);
THEME(6);
THEME(7);

itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			-40 -40 1000 112 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN
	background		"black"
	border			1
	bordercolor		0 0 0 0.5
	bordersize		3
	forecolor		0 0 0 1
	visible			1
	decoration
}

itemDef
{
	style			WINDOW_STYLE_SHADER
	rect			-40 408 1000 112 HORIZONTAL_ALIGN_FULLSCREEN VERTICAL_ALIGN_FULLSCREEN
	background		"black"
	forecolor		0 0 0 1
	border			1
	bordercolor		0 0 0 1
	bordersize		3
	visible			1
	decoration
}
