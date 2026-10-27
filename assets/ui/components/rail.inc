// The left navigation rail of the SR windows (main menu, options, controls): a dark column with a title,
// entries that lift and light a cyan edge on hover, the main entry marked by a purple edge. Hover state is
// the local var ui_rail_hover, so entry ids must be unique within a menu.
#define RAIL_WHITE			1 1 1 1
#define RAIL_MUTED			0.85 0.85 0.85 1
#define RAIL_PURPLE			0.5 0.1 1 1
#define RAIL_CYAN			0 1 1 1
#define RAIL_LIFT			1 1 1 0.06
#define RAIL_LINE			1 1 1 0.08
#define RAIL_HOVER(id)		(localVarInt(ui_rail_hover) == id)

#define RAIL_FILL(x, y, w, h, color) \
	itemDef \
	{ \
		rect			x y w h SR_ALIGN_TOP_SUBLEFT \
		style			WINDOW_STYLE_FILLED \
		backcolor		color \
		visible			1 \
		decoration \
	}

#define RAIL_FILL_IF(x, y, w, h, color, cond) \
	itemDef \
	{ \
		rect			x y w h SR_ALIGN_TOP_SUBLEFT \
		style			WINDOW_STYLE_FILLED \
		backcolor		color \
		visible			when(cond) \
		decoration \
	}

#define RAIL_TEXT(x, y, w, h, textArg, scale, align, alignX, color) \
	itemDef \
	{ \
		rect			x y w h SR_ALIGN_TOP_SUBLEFT \
		exp				text(textArg) \
		textfont		UI_FONT_NORMAL \
		textscale		scale \
		textstyle		ITEM_TEXTSTYLE_SHADOWED \
		textalign		align \
		textalignx		alignX \
		forecolor		color \
		visible			1 \
		decoration \
	}

// Clickable part of an entry or button; id lights the hover pieces drawn under it.
#define RAIL_HIT(id, x, y, w, h, textArg, scale, align, alignX, script) \
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
		forecolor		RAIL_WHITE \
		visible			1 \
		onFocus \
		{ \
			play "mouse_over"; \
			setLocalVarInt ui_rail_hover id; \
		} \
		leaveFocus \
		{ \
			setLocalVarInt ui_rail_hover 0; \
		} \
		action \
		{ \
			play "mouse_click"; \
			script \
		} \
	}

// The rail's column, its title and the rule under it, w wide and h high from the menu's corner.
#define RAIL_PANEL(w, h, title) \
	RAIL_FILL(0, 0, w, h, 0 0 0 0.55) \
	RAIL_FILL(w, 0, 1, h, RAIL_PURPLE) \
	RAIL_TEXT(0, 0, w, 46, title, 0.42, ITEM_ALIGN_MIDDLE_CENTER, 0, RAIL_WHITE) \
	RAIL_FILL(18, 46, ((w) - 36), 1, 1 1 1 0.1)

#define RAIL_ENTRY(id, x, y, w, h, textArg, script) \
	RAIL_FILL_IF(x, y, w, h, RAIL_LIFT, RAIL_HOVER(id)) \
	RAIL_FILL_IF(x, y, 2, h, RAIL_CYAN, RAIL_HOVER(id)) \
	RAIL_HIT(id, x, y, w, h, textArg, 0.32, ITEM_ALIGN_MIDDLE_LEFT, 14, script)

// The main entry, such as Play: a faint plate and a purple left edge, never a fill.
#define RAIL_ENTRY_PRIMARY(id, x, y, w, h, textArg, script) \
	RAIL_FILL(x, y, w, h, 1 1 1 0.04) \
	RAIL_FILL(x, y, 2, h, RAIL_PURPLE) \
	RAIL_ENTRY(id, x, y, w, h, textArg, script)

// A window's page entry, marked with the purple edge while its page menuName is open.
#define RAIL_PAGE(id, x, y, w, h, textArg, menuName, script) \
	RAIL_FILL_IF(x, y, w, h, 1 1 1 0.04, menuisopen(menuName)) \
	RAIL_FILL_IF(x, y, 2, h, RAIL_PURPLE, menuisopen(menuName)) \
	RAIL_ENTRY(id, x, y, w, h, textArg, script)

// A thin rule set apart from the entries, such as the one above Quit.
#define RAIL_RULE(x, y, w) \
	RAIL_FILL(((x) + 8), y, ((w) - 16), 1, 1 1 1 0.1)

// Button on a dark plate with a purple left edge; hovering lifts it and turns the edge cyan.
#define RAIL_BUTTON(id, x, y, w, h, textArg, scale, script) \
	RAIL_FILL(x, y, w, h, 0 0 0 0.4) \
	RAIL_FILL(x, y, 2, h, RAIL_PURPLE) \
	RAIL_FILL_IF(x, y, w, h, RAIL_LIFT, RAIL_HOVER(id)) \
	RAIL_FILL_IF(x, y, 2, h, RAIL_CYAN, RAIL_HOVER(id)) \
	RAIL_HIT(id, x, y, w, h, textArg, scale, ITEM_ALIGN_MIDDLE_CENTER, 0, script)
