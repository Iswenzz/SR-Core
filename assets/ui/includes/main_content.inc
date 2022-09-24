
	itemDef
    {
        name        				"content_container"
        rect        				-300 0 600 250 HORIZONTAL_ALIGN_CENTER VERTICAL_ALIGN_SUBTOP
        origin      				0 (80 + ui_maincontent_lnr_Y)
        style       				1
        backcolor   				1 1 1 0.02
        visible						when (!localvarint("ui_maincontent_lnr") == 1)
        decoration
    }

    itemDef
    {
        name                        "username"
        rect                        -300 0 600 30 HORIZONTAL_ALIGN_CENTER VERTICAL_ALIGN_SUBTOP
        origin                      0 (80 + ui_maincontent_lnr_Y)
        style                       WINDOW_STYLE_FILLED
        borderSize                  0
        foreColor                   1 1 1 1
        backColor                   1 1 1 0.02
        borderColor                 1 1 1 1
        outlineColor                0 0 0 0
		textstyle 					ITEM_TEXTSTYLE_SHADOWED
        exp							text("Username: ^1" + dvarString("name"));
        textFont                    UI_FONT_NORMAL
        textAlign                   ITEM_ALIGN_MIDDLE_CENTER
        textAlignX                  10
        textScale                   0.20
        visible						when (!localvarint("ui_maincontent_lnr") == 1)
        decoration
    }