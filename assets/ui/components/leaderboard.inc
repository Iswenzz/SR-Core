// Leaderboard building blocks shared by the SR mods' sr_leaderboard menus. The mod's menu lists its own
// modes and ways; these draw them. Hover state lives in the local var ui_lb_hover.

// leaderboard_name is "<mode> ^7<way name>" and each way dvar holds its way name, so an exact match tells
// which mode and way are shown. Kept in groups: a statement is capped at 200 tokens.
#define LB_IS(modePrefix, wayDvar) \
	(dvarString("leaderboard_name") == (modePrefix + dvarString(wayDvar)))

#define LB_MODE_NORMAL(modePrefix) \
	(LB_IS(modePrefix, "normal_0") || LB_IS(modePrefix, "normal_1") || LB_IS(modePrefix, "normal_2") || \
	LB_IS(modePrefix, "normal_3") || LB_IS(modePrefix, "normal_4") || LB_IS(modePrefix, "normal_5"))

#define LB_MODE_SECRET(modePrefix) \
	(LB_IS(modePrefix, "secret_0") || LB_IS(modePrefix, "secret_1") || LB_IS(modePrefix, "secret_2") || \
	LB_IS(modePrefix, "secret_3") || LB_IS(modePrefix, "secret_4") || LB_IS(modePrefix, "secret_5"))

// Left strip of the way buttons: normal ways in the SR purple, secret ways in cyan.
#define LB_NORMAL_RGB		0.5 0.1 1
#define LB_SECRET_RGB		0 1 1

#define LB_FILL(x, y, w, h, color) \
	itemDef \
	{ \
		rect			x y w h SR_ALIGN_TOP_SUBLEFT \
		style			WINDOW_STYLE_FILLED \
		backcolor		color \
		visible			1 \
		decoration \
	}

#define LB_FILL_IF(x, y, w, h, color, cond) \
	itemDef \
	{ \
		rect			x y w h SR_ALIGN_TOP_SUBLEFT \
		style			WINDOW_STYLE_FILLED \
		backcolor		color \
		visible			when(cond) \
		decoration \
	}

#define LB_TEXT(x, y, w, h, textArg, scale, align, color) \
	itemDef \
	{ \
		rect			x y w h SR_ALIGN_TOP_SUBLEFT \
		exp				text(textArg) \
		textfont		UI_FONT_NORMAL \
		textscale		scale \
		textstyle		ITEM_TEXTSTYLE_SHADOWED \
		textalign		align \
		forecolor		color \
		visible			1 \
		decoration \
	}

// A titled column: dark body with a darker caption bar.
#define LB_COLUMN(x, y, w, h, title) \
	LB_FILL(x, y, w, h, 0 0 0 0.3) \
	LB_FILL(x, y, w, 18, 0 0 0 0.5) \
	LB_TEXT(x, y, w, 18, title, 0.24, ITEM_ALIGN_MIDDLE_CENTER, 0.85 0.85 0.85 1)

// Ten rows of one leaderboard block. y is the first row's baseline; rows are 48 * scale apart.
#define LB_BLOCK(id, rankX, nameX, timeX, y, scale) \
	itemDef \
	{ \
		rect			rankX y 40 10 SR_ALIGN_TOP_SUBLEFT \
		exp				text(dvarString("leaderboard_numbers_" + id)) \
		textfont		UI_FONT_NORMAL \
		textscale		scale \
		textalign		ITEM_ALIGN_LEFT \
		forecolor		0.85 0.85 0.85 1 \
		visible			1 \
		decoration \
	} \
	itemDef \
	{ \
		rect			nameX y 200 10 SR_ALIGN_TOP_SUBLEFT \
		exp				text(dvarString("leaderboard_names_" + id)) \
		textfont		UI_FONT_NORMAL \
		textscale		scale \
		textalign		ITEM_ALIGN_LEFT \
		forecolor		1 1 1 1 \
		visible			1 \
		decoration \
	} \
	itemDef \
	{ \
		rect			timeX y 80 10 SR_ALIGN_TOP_SUBLEFT \
		exp				text(dvarString("leaderboard_values_" + id)) \
		textfont		UI_FONT_NORMAL \
		textscale		scale \
		textstyle		ITEM_TEXTSTYLE_SHADOWED \
		textalign		ITEM_ALIGN_LEFT \
		forecolor		0 1 1 1 \
		visible			1 \
		decoration \
	}

// The forty times in one panel: blocks 0-1 down the left half, 2-3 down the right half, rows 48 * scale
// apart from the baseline y. Columns are relative to each half's x.
#define LB_TIMES(leftX, rightX, rankX, nameX, timeX, y, scale) \
	LB_BLOCK(0, (leftX + rankX), (leftX + nameX), (leftX + timeX), y, scale) \
	LB_BLOCK(1, (leftX + rankX), (leftX + nameX), (leftX + timeX), (y + (480 * scale)), scale) \
	LB_BLOCK(2, (rightX + rankX), (rightX + nameX), (rightX + timeX), y, scale) \
	LB_BLOCK(3, (rightX + rankX), (rightX + nameX), (rightX + timeX), (y + (480 * scale)), scale)

#define LB_PLATE(x, y, w, h, vis) \
	itemDef \
	{ \
		rect			x y w h SR_ALIGN_TOP_SUBLEFT \
		style			WINDOW_STYLE_FILLED \
		backcolor		0 0 0 0.45 \
		visible			vis \
		decoration \
	}

// Clickable part of a button. id lights the hover fill drawn under it and must be unique in the menu.
#define LB_HIT(id, x, y, w, h, textArg, scale, align, alignX, script, vis) \
	itemDef \
	{ \
		type			ITEM_TYPE_BUTTON \
		rect			x y w h SR_ALIGN_TOP_SUBLEFT \
		exp				text(textArg) \
		textfont		UI_FONT_NORMAL \
		textscale		scale \
		textstyle		ITEM_TEXTSTYLE_SHADOWED \
		textalign		align \
		textalignx		alignX \
		forecolor		1 1 1 1 \
		visible			vis \
		onFocus \
		{ \
			play "mouse_over"; \
			setLocalVarInt ui_lb_hover id; \
		} \
		leaveFocus \
		{ \
			setLocalVarInt ui_lb_hover 0; \
		} \
		action \
		{ \
			play "mouse_click"; \
			script; \
		} \
	}

// Mode button, filled while one of that mode's ways is shown.
#define LB_MODE(id, x, y, w, h, label, response, modePrefix) \
	LB_PLATE(x, y, w, h, 1) \
	LB_FILL_IF(x, y, w, h, 0.5 0.1 1 0.55, LB_MODE_NORMAL(modePrefix)) \
	LB_FILL_IF(x, y, w, h, 0.5 0.1 1 0.55, LB_MODE_SECRET(modePrefix)) \
	LB_FILL_IF(x, y, w, h, 0.5 0.1 1 0.3, localVarInt(ui_lb_hover) == id) \
	LB_HIT(id, x, y, w, h, label, 0.27, ITEM_ALIGN_MIDDLE_LEFT, 10, scriptMenuResponse response, 1)

// Way button with an rgb strip on its left edge; shown is the mod's "this way is on screen" condition,
// which lightens the fill and widens the strip.
#define LB_WAY(id, x, y, w, h, wayDvar, response, rgb, shown) \
	LB_PLATE(x, y, w, h, when(dvarString(wayDvar) != "")) \
	LB_FILL_IF(x, y, w, h, 1 1 1 0.1, shown) \
	LB_FILL_IF(x, y, 2, h, rgb 0.9, dvarString(wayDvar) != "") \
	LB_FILL_IF(x, y, 4, h, rgb 1, shown) \
	LB_FILL_IF(x, y, w, h, 1 1 1 0.12, localVarInt(ui_lb_hover) == id) \
	LB_HIT(id, x, y, w, h, dvarString(wayDvar), 0.24, ITEM_ALIGN_MIDDLE_LEFT, 10, scriptMenuResponse response, \
		when(dvarString(wayDvar) != ""))

// How many normal ways the map has, so the secret ways can follow right after them.
#define LB_NORMAL_COUNT \
	((dvarString("normal_0") != "") + (dvarString("normal_1") != "") + (dvarString("normal_2") != "") + \
	(dvarString("normal_3") != "") + (dvarString("normal_4") != "") + (dvarString("normal_5") != ""))

// LB_FILL_IF and LB_WAY with the y taken from an expression, for buttons placed after a variable number
// of others.
#define LB_FILL_AT(x, ypos, w, h, color, cond) \
	itemDef \
	{ \
		rect			x 0 w h SR_ALIGN_TOP_SUBLEFT \
		exp				rect Y(ypos) \
		style			WINDOW_STYLE_FILLED \
		backcolor		color \
		visible			when(cond) \
		decoration \
	}

#define LB_WAY_AT(id, x, ypos, w, h, wayDvar, response, rgb, shown) \
	LB_FILL_AT(x, ypos, w, h, 0 0 0 0.45, dvarString(wayDvar) != "") \
	LB_FILL_AT(x, ypos, w, h, 1 1 1 0.1, shown) \
	LB_FILL_AT(x, ypos, 2, h, rgb 0.9, dvarString(wayDvar) != "") \
	LB_FILL_AT(x, ypos, 4, h, rgb 1, shown) \
	LB_FILL_AT(x, ypos, w, h, 1 1 1 0.12, localVarInt(ui_lb_hover) == id) \
	itemDef \
	{ \
		type			ITEM_TYPE_BUTTON \
		rect			x 0 w h SR_ALIGN_TOP_SUBLEFT \
		exp				rect Y(ypos) \
		exp				text(dvarString(wayDvar)) \
		textfont		UI_FONT_NORMAL \
		textscale		0.24 \
		textstyle		ITEM_TEXTSTYLE_SHADOWED \
		textalign		ITEM_ALIGN_MIDDLE_LEFT \
		textalignx		10 \
		forecolor		1 1 1 1 \
		visible			when(dvarString(wayDvar) != "") \
		onFocus \
		{ \
			play "mouse_over"; \
			setLocalVarInt ui_lb_hover id; \
		} \
		leaveFocus \
		{ \
			setLocalVarInt ui_lb_hover 0; \
		} \
		action \
		{ \
			play "mouse_click"; \
			scriptMenuResponse response; \
		} \
	}

#define LB_DEMO(id, x, y, w, h, label) \
	LB_FILL(x, y, w, h, 0.5 0.1 1 0.5) \
	LB_FILL_IF(x, y, w, h, 1 1 1 0.12, localVarInt(ui_lb_hover) == id) \
	LB_HIT(id, x, y, w, h, label, 0.3, ITEM_ALIGN_MIDDLE_CENTER, 0, scriptMenuResponse "demo", 1)
