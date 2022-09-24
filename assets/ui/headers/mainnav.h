// ----------------------------------------
// ------- General mainnav settings -------

#define MAINNAV_X_POS           0
#define MAINNAV_Y_POS           0
#define MAINNAV_WIDTH           640
#define MAINNAV_HEIGHT          25

#define MAINNAV_HORZ_ALIGN      HORIZONTAL_ALIGN_FULLSCREEN
#define MAINNAV_VERT_ALIGN      VERTICAL_ALIGN_SUBTOP

#define MAINNAV_COLOR           1 1 1 0.05

/// default mainnav rect
#define MAINNAV_RECT            MAINNAV_X_POS MAINNAV_Y_POS MAINNAV_WIDTH MAINNAV_HEIGHT MAINNAV_HORZ_ALIGN MAINNAV_VERT_ALIGN

// ----------------------------------------
// -- General mainnav seperator settings --

#define MAINNAV_SEP_X           MAINNAV_X_POS
#define MAINNAV_SEP_Y           MAINNAV_Y_POS
#define MAINNAV_SEP_WIDTH       MAINNAV_WIDTH
#define MAINNAV_SEP_HEIGHT      1

#define MAINNAV_SEP_HORZ_ALIGN      MAINNAV_HORZ_ALIGN
#define MAINNAV_SEP_VERT_ALIGN      MAINNAV_VERT_ALIGN

#define MAINNAV_SEP_ORIGIN      0 MAINNAV_HEIGHT
#define MAINNAV_SEP_COLOR       1 1 1 0.13

/// default mainnav seperator rect
#define MAINNAV_SEP_RECT        MAINNAV_SEP_X MAINNAV_SEP_Y MAINNAV_SEP_WIDTH MAINNAV_SEP_HEIGHT MAINNAV_HORZ_ALIGN MAINNAV_VERT_ALIGN


// ----------------------------------------
// -------- General subnav settings -------

#define SUBNAV_X_POS            MAINNAV_X_POS
#define SUBNAV_Y_POS            MAINNAV_Y_POS
#define SUBNAV_WIDTH 		    MAINNAV_WIDTH
#define SUBNAV_HEIGHT 		    MAINNAV_HEIGHT

#define SUBNAV_HORZ_ALIGN       MAINNAV_HORZ_ALIGN
#define SUBNAV_VERT_ALIGN       MAINNAV_VERT_ALIGN

#define SUBNAV_ORIGIN           0 0
#define SUBNAV_COLOR            1 1 1 0.04

/// subnav rect for menuDef's
#define SUBNAV_MENU_RECT        SUBNAV_X_POS (SUBNAV_Y_POS + SUBNAV_HEIGHT + MAINNAV_SEP_HEIGHT) SUBNAV_WIDTH SUBNAV_HEIGHT
/// subnav rect for itemsDef's
#define SUBNAV_ITEM_RECT        0 0 SUBNAV_WIDTH SUBNAV_HEIGHT SUBNAV_HORZ_ALIGN SUBNAV_VERT_ALIGN

// --------------------------------------------------

/// menuDef :: rect with cutoff top (mainnav + seperator + subnav)
#define NAV_MENU_FULLSCREEN_RECT                RECT_MENU_CENTER_W_TOP_H(0, (MAINNAV_HEIGHT + MAINNAV_SEP_HEIGHT + SUBNAV_HEIGHT), 640, 480 ) 
/// menuDef :: rect with cutoff top (mainnav + seperator + subnav) (less width because of server selection line ...)
#define NAV_MENU_FULLSCREEN_RECT_SERVERBROWSER  RECT_MENU_CENTER_W_TOP_H(0, (MAINNAV_HEIGHT + MAINNAV_SEP_HEIGHT + SUBNAV_HEIGHT), 820, 480 ) 

/// close all subnav menus
#define CLOSE_ALL_SUBNAVS       close main_controls; \
                                close main_options; \
                                close serverlist_subnav

/// close serverbrowser
#define CLOSE_SERVERBROWSER     close serverlist_browser; \
                                close serverlist_subnav

/// close create server
#define CLOSE_CREATE_SERVER     close createserver; \
                                close createserver_advanced

/// close all control menus
#define CLOSE_ALL_CONTROLS      close options_look; \
                                close options_move; \
                                close options_shoot; \
                                close options_misc; \
                                close controls_multi

/// close all control menus except LOOK
#define CLOSE_ALL_CONTROLS_EX_LOOK      close options_move; \
                                        close options_shoot; \
                                        close options_misc; \
                                        close controls_multi

/// close all control menus except MOVE
#define CLOSE_ALL_CONTROLS_EX_MOVE      close options_look; \
                                        close options_shoot; \
                                        close options_misc; \
                                        close controls_multi

/// close all control menus except SHOOT
#define CLOSE_ALL_CONTROLS_EX_SHOOT     close options_look; \
                                        close options_move; \
                                        close options_misc; \
                                        close controls_multi

/// close all control menus except MISC
#define CLOSE_ALL_CONTROLS_EX_INTERACT  close options_look; \
                                        close options_move; \
                                        close options_shoot; \
                                        close controls_multi           

/// close all control menus except MULTI
#define CLOSE_ALL_CONTROLS_EX_MULTI     close options_look; \
                                        close options_move; \
                                        close options_shoot; \
                                        close options_misc                                                                      

/// close all option menus
#define CLOSE_ALL_OPTIONS       close options_graphics; \
                                close options_graphics_texture; \
                                close options_sound; \
                                close options_voice; \
                                close options_game; \
                                close options_view

/// close all option except GRAPHICS
#define CLOSE_ALL_OPTIONS_EX_GRAPHICS       close options_graphics_texture; \
                                            close options_sound; \
                                            close options_voice; \
                                            close options_game; \
                                            close options_view

/// close all option except GRAPHICS TEXTURES
#define CLOSE_ALL_OPTIONS_EX_GRAPHICS_TEX   close options_graphics; \
                                            close options_sound; \
                                            close options_voice; \
                                            close options_game; \
                                            close options_view

/// close all option except SOUND
#define CLOSE_ALL_OPTIONS_EX_SOUND          close options_graphics; \
                                            close options_graphics_texture; \
                                            close options_voice; \
                                            close options_game; \
                                            close options_view

/// close all option except VOICE
#define CLOSE_ALL_OPTIONS_EX_VOICE          close options_graphics; \
                                            close options_graphics_texture; \
                                            close options_sound; \
                                            close options_game; \
                                            close options_view

/// close all option except GAME
#define CLOSE_ALL_OPTIONS_EX_GAME           close options_graphics; \
                                            close options_graphics_texture; \
                                            close options_sound; \
                                            close options_voice; \
                                            close options_view

/// close all option except VIEW
#define CLOSE_ALL_OPTIONS_EX_VIEW           close options_graphics; \
                                            close options_graphics_texture; \
                                            close options_sound; \
                                            close options_voice; \
                                            close options_game

/// close mods
#define CLOSE_MODS              close mods_menu        

/// close profile
#define CLOSE_PROFILE           close player_profile