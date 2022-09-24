    // _UI::create_changelog uses this itemdef to get the size for ImGui
    itemDef
    {
        name        				"changelog_container"
        rect        				-300 0 600 (380 - 25) HORIZONTAL_ALIGN_CENTER VERTICAL_ALIGN_SUBTOP
        origin      				0 (60 + 25)
        style       				1
        backcolor   				1 1 1 0.01
        visible						when (!localvarint("ui_maincontent_update") == 1)
        decoration
    }

    itemDef
    {
        name                        "update_title"
        rect                        -300 0 600 25 HORIZONTAL_ALIGN_CENTER VERTICAL_ALIGN_SUBTOP
        origin                      0 60
        style                       WINDOW_STYLE_FILLED
        borderSize                  0
        foreColor                   1 1 1 1
        backColor                   1 1 1 0.035
        borderColor                 1 1 1 1
        outlineColor                0 0 0 0
		textstyle 					ITEM_TEXTSTYLE_SHADOWED
        exp							text(dvarstring(ui_changelog_title));
        textFont                    UI_FONT_DEFAULT
        textAlign                   ITEM_ALIGN_MIDDLE_LEFT
        textAlignX                  10
        textScale                   0.25
        visible						when (!localvarint("ui_maincontent_update") == 1)
        decoration
    }

    // Changelog element 1

   /*  itemDef
    {
        name                        "update_changlog01_title"
        rect                        -300 5 600 80 HORIZONTAL_ALIGN_CENTER VERTICAL_ALIGN_SUBTOP
        origin                      0 80
        exp                         rect Y(80 + dvarint(ui_changelog01_y_offs))
        type                        ITEM_TYPE_TEXT
        foreColor                   1 1 1 1
        backColor                   1 0 1 0
        textstyle                   ITEM_TEXTSTYLE_SHADOWED
        exp                         text(dvarstring(ui_changelog01_title));
        textFont                    UI_FONT_OBJECTIVE
        textAlign                   ITEM_ALIGN_TOP_LEFT
        textAlignX                  10
        textScale                   0.25
        visible                     when (!localvarint("ui_maincontent_update") == 1)
        decoration
    }

    itemDef
    {
        name                        "update_changlog01_sep"
        rect                        -300 5 590 1 HORIZONTAL_ALIGN_CENTER VERTICAL_ALIGN_SUBTOP
        origin                      5 95
        exp                         rect Y(95 + dvarint(ui_changelog01_y_offs))
        style                       1
        backcolor                   1 1 1 0.1
        visible                     when (!localvarint("ui_maincontent_update") == 1 && dvarbool(ui_changelog01_sep))
        decoration
    }

    itemDef
    {
        name                        "update_changlog01"
        rect                        -300 5 600 80 HORIZONTAL_ALIGN_CENTER VERTICAL_ALIGN_SUBTOP
        origin                      0 100
        exp                         rect Y(100 + dvarint(ui_changelog01_y_offs))
        type                        ITEM_TYPE_TEXT
        foreColor                   1 1 1 1
        backColor                   0 1 0 0
        textstyle                   ITEM_TEXTSTYLE_SHADOWED
        exp                         text(dvarstring(ui_changelog01)); //text("huh, so empty. Please fill me up, daddy, please.")
        textFont                    UI_FONT_DEFAULT
        textAlign                   ITEM_ALIGN_TOP_LEFT
        textAlignX                  10
        textScale                   0.25
        visible                     when (!localvarint("ui_maincontent_update") == 1)
        decoration
    }

    // Changelog element 2

    itemDef
    {
        name                        "update_changlog02_title"
        rect                        -300 5 600 80 HORIZONTAL_ALIGN_CENTER VERTICAL_ALIGN_SUBTOP
        origin                      0 160
        exp                         rect Y(160 + dvarint(ui_changelog02_y_offs))
        type                        ITEM_TYPE_TEXT
        foreColor                   1 1 1 1
        backColor                   1 0 1 0
        textstyle                   ITEM_TEXTSTYLE_SHADOWED
        exp                         text(dvarstring(ui_changelog02_title));
        textFont                    UI_FONT_OBJECTIVE
        textAlign                   ITEM_ALIGN_TOP_LEFT
        textAlignX                  10
        textScale                   0.25
        visible                     when (!localvarint("ui_maincontent_update") == 1)
        decoration
    }

    itemDef
    {
        name                        "update_changlog02_sep"
        rect                        -300 5 590 1 HORIZONTAL_ALIGN_CENTER VERTICAL_ALIGN_SUBTOP
        origin                      5 175
        exp                         rect Y(175 + dvarint(ui_changelog02_y_offs))
        style                       1
        backcolor                   1 1 1 0.1
        visible                     when (!localvarint("ui_maincontent_update") == 1 && dvarbool(ui_changelog02_sep))
        decoration
    }

    itemDef
    {
        name                        "update_changlog02"
        rect                        -300 5 600 80 HORIZONTAL_ALIGN_CENTER VERTICAL_ALIGN_SUBTOP
        origin                      0 180
        exp                         rect Y(180 + dvarint(ui_changelog02_y_offs))
        type                        ITEM_TYPE_TEXT
        foreColor                   1 1 1 1
        backColor                   1 0 0 0
        textstyle                   ITEM_TEXTSTYLE_SHADOWED
        exp                         text(dvarstring(ui_changelog02));
        textFont                    UI_FONT_DEFAULT
        textAlign                   ITEM_ALIGN_TOP_LEFT
        textAlignX                  10
        textScale                   0.25
        visible                     when (!localvarint("ui_maincontent_update") == 1)
        decoration
    }

    // Changelog element 3

    itemDef
    {
        name                        "update_changlog03_title"
        rect                        -300 5 600 80 HORIZONTAL_ALIGN_CENTER VERTICAL_ALIGN_SUBTOP
        origin                      0 240
        exp                         rect Y(240 + dvarint(ui_changelog03_y_offs))
        type                        ITEM_TYPE_TEXT
        foreColor                   1 1 1 1
        backColor                   1 0 1 0
        textstyle                   ITEM_TEXTSTYLE_SHADOWED
        exp                         text(dvarstring(ui_changelog03_title));
        textFont                    UI_FONT_OBJECTIVE
        textAlign                   ITEM_ALIGN_TOP_LEFT
        textAlignX                  10
        textScale                   0.25
        visible                     when (!localvarint("ui_maincontent_update") == 1)
        decoration
    }

    itemDef
    {
        name                        "update_changlog03_sep"
        rect                        -300 5 590 1 HORIZONTAL_ALIGN_CENTER VERTICAL_ALIGN_SUBTOP
        origin                      5 255
        exp                         rect Y(255 + dvarint(ui_changelog03_y_offs))
        style                       1
        backcolor                   1 1 1 0.1
        visible                     when (!localvarint("ui_maincontent_update") == 1 && dvarbool(ui_changelog03_sep))
        decoration
    }

    itemDef
    {
        name                        "update_changlog03"
        rect                        -300 5 600 80 HORIZONTAL_ALIGN_CENTER VERTICAL_ALIGN_SUBTOP
        origin                      0 260
        exp                         rect Y(260 + dvarint(ui_changelog03_y_offs))
        type                        ITEM_TYPE_TEXT
        foreColor                   1 1 1 1
        backColor                   0 0 1 0
        textstyle                   ITEM_TEXTSTYLE_SHADOWED
        exp                         text(dvarstring(ui_changelog03));
        textFont                    UI_FONT_DEFAULT
        textAlign                   ITEM_ALIGN_TOP_LEFT
        textAlignX                  10
        textScale                   0.25
        visible                     when (!localvarint("ui_maincontent_update") == 1)
        decoration
    }

    // Changelog element 4

    itemDef
    {
        name                        "update_changlog04_title"
        rect                        -300 5 600 80 HORIZONTAL_ALIGN_CENTER VERTICAL_ALIGN_SUBTOP
        origin                      0 330
        exp                         rect Y(330 + dvarint(ui_changelog04_y_offs))
        type                        ITEM_TYPE_TEXT
        foreColor                   1 1 1 1
        backColor                   1 0 1 0
        textstyle                   ITEM_TEXTSTYLE_SHADOWED
        exp                         text(dvarstring(ui_changelog04_title));
        textFont                    UI_FONT_OBJECTIVE
        textAlign                   ITEM_ALIGN_TOP_LEFT
        textAlignX                  10
        textScale                   0.25
        visible                     when (!localvarint("ui_maincontent_update") == 1)
        decoration
    }

    itemDef
    {
        name                        "update_changlog04_sep"
        rect                        -300 5 590 1 HORIZONTAL_ALIGN_CENTER VERTICAL_ALIGN_SUBTOP
        origin                      5 345
        exp                         rect Y(345 + dvarint(ui_changelog04_y_offs))
        style                       1
        backcolor                   1 1 1 0.1
        visible                     when (!localvarint("ui_maincontent_update") == 1 && dvarbool(ui_changelog04_sep))
        decoration
    }

    itemDef
    {
        name                        "update_changlog04"
        rect                        -300 5 600 80 HORIZONTAL_ALIGN_CENTER VERTICAL_ALIGN_SUBTOP
        origin                      0 350
        exp                         rect Y(350 + dvarint(ui_changelog04_y_offs))
        type                        ITEM_TYPE_TEXT
        foreColor                   1 1 1 1
        backColor                   1 0 1 0
        textstyle                   ITEM_TEXTSTYLE_SHADOWED
        exp                         text(dvarstring(ui_changelog04)); //text("huh, so empty. Please fill me up, daddy, please.")
        textFont                    UI_FONT_DEFAULT
        textAlign                   ITEM_ALIGN_TOP_LEFT
        textAlignX                  10
        textScale                   0.25
        visible                     when (!localvarint("ui_maincontent_update") == 1)
        decoration
    } */

    // ------------

    // --------------------------------------------

    itemDef
    {
        name                        "update_button"
        text                        "Reload menu"
        style                       WINDOW_STYLE_FILLED
        border                      WINDOW_BORDER_FULL
        borderSize                  0
        background                  black
        foreColor                   1 1 1 0.8
        backcolor                   0 0 0 0.01
        borderColor                 0 0 0 0.05
        outlineColor                0 0 0 0
        type                        1
        rect                        0 0 80 25 HORIZONTAL_ALIGN_CENTER VERTICAL_ALIGN_SUBTOP
        origin                      220 60
        style                       1
        textfont                    UI_FONT_DEFAULT
        textscale                   0.24
        textalign                   1
        textaligny                  17
        textstyle                   3
        mouseEnter                  {play "mouse_over";}
        mouseExit                   {}
        action
        {
            play "mouse_click";

            /*
            // re-calculate the gui layout
			GET_GGUI.menus[Game::GUI_MENUS::CHANGELOG].one_time_init = false;
			Game::Cmd_ExecuteSingleCommand(0, 0, "loadzone xcommon_iw3SR_menu\n");
            */
            execnow "mainmenu_reload";
        }
        visible                     when (!localvarint("ui_maincontent_update") == 1)
    }

    // --------------------------------------------

    itemDef
    {
        name                        "radiant_button"
        text                        "IW3xRadiant Github"
        style                       WINDOW_STYLE_FILLED
        border                      WINDOW_BORDER_FULL
        borderSize                  0
        background                  black
        foreColor                   1 1 1 0.8
        backcolor                   0 0 0 0.01
        borderColor                 0 0 0 0.05
        outlineColor                0 0 0 0
        type                        1
        rect                        0 0 80 25 HORIZONTAL_ALIGN_CENTER VERTICAL_ALIGN_SUBTOP
        origin                      140 60 // 61 60
        style                       1
        textfont                    UI_FONT_DEFAULT
        textscale                   0.24
        textalign                   1
        textaligny                  17
        textstyle                   3
        mouseEnter                  {play "mouse_over";}
        mouseExit                   {}
        action
        {
            play "mouse_click";
            execnow "iw3SR_radiant_github"; // QuickPatch.cpp
        }
        visible                     when (!localvarint("ui_maincontent_update") == 1)
    }

    // --------------------------------------------

    itemDef
    {
        name                        "iw3SR_button"
        text                        "IW3xo Github"
        style                       WINDOW_STYLE_FILLED
        border                      WINDOW_BORDER_FULL
        borderSize                  0
        background                  black
        foreColor                   1 1 1 0.8
        backcolor                   0 0 0 0.01
        borderColor                 0 0 0 0.05
        outlineColor                0 0 0 0
        type                        1
        rect                        0 0 80 25 HORIZONTAL_ALIGN_CENTER VERTICAL_ALIGN_SUBTOP
        origin                      60 60 //-19 60
        style                       1
        textfont                    UI_FONT_DEFAULT
        textscale                   0.24
        textalign                   1
        textaligny                  17
        textstyle                   3
        mouseEnter                  {play "mouse_over";}
        mouseExit                   {}
        action
        {
            play "mouse_click";
            execnow "iw3SR_github"; // QuickPatch.cpp
        }
        visible                     when (!localvarint("ui_maincontent_update") == 1)
    }

    // --------------------------------------------

    itemDef
    {
        name                        "help_button"
        text                        "Help"
        style                       WINDOW_STYLE_FILLED
        border                      WINDOW_BORDER_FULL
        borderSize                  0
        background                  black
        foreColor                   1 1 1 0.8
        backcolor                   0 0 0 0.01
        borderColor                 0 0 0 0.05
        outlineColor                0 0 0 0
        type                        1
        rect                        0 0 60 25 HORIZONTAL_ALIGN_CENTER VERTICAL_ALIGN_SUBTOP
        origin                      0 60 // 141 60
        style                       1
        textfont                    UI_FONT_DEFAULT
        textscale                   0.24
        textalign                   1
        textaligny                  17
        textstyle                   3
        mouseEnter                  {play "mouse_over";}
        mouseExit                   {}
        action
        {
            play "mouse_click";
            execnow "help"; // QuickPatch.cpp
        }
        visible			when(!localvarint("ui_maincontent_update") == 1);
    }

/*     itemDef
    {
        name                        "uiScriptTest"
        text                        "Test UI Script Addon"
        style                       WINDOW_STYLE_FILLED
        border                      WINDOW_BORDER_FULL
        borderSize                  0
        background                  black
        foreColor                   1 1 1 1
        outlineColor                0 0 0 0
        type                        1
        rect                        0 0 80 19 HORIZONTAL_ALIGN_CENTER VERTICAL_ALIGN_SUBTOP
        origin                      -39 153
        style                       1
        textfont                    1
        textscale                   0.20
        textalign                   1
        textaligny                  14
        forecolor                   1 1 1 1
        backcolor                   1 1 1 0
        borderColor                 1 1 1 0.1
        outlineColor                0 0 0 0
        textstyle                   3
        mouseEnter                  {play "mouse_over";}
        mouseExit                   {}
        action
        {
            play "mouse_click";
            uiScript StartServerCustom
        }
        visible                     when (!localvarint("ui_maincontent_update") == 1)
    } */