/*

                        ,_____________
                   ,__NNNNNNNNNNNNNNNNNNN__
                ,_NNNNNNNF"""""""""""4NNNNNNN_.
              _NNNNNN""                 ""NNNNNL_
              "NNN"`                       ´"NNNNN.
               ,N.                            "NNNNL
              _NNNL.                            4NNNN.
            ,JNNNF`´\.                           ´NNNN.
            NNNN"    ´\.                          ´NNNN.
           JNNN`       ´\.        __               (NNNL
          ,NNN)          ´\.      NN                4NNN.
          NNNF____       __JL_    NN    ,__   ,____.(NNN)
         (NNNF"""4N_   _NF""""N.  NN  ,JN"  ,JN""""4NNNNN
         (NNN     NN  ,NF    ,NF\.NN,JN"    JN      NNNNN
         (NNN     NN  (NF""""""  ´NNN"4N.   NN      NNNNF
         (NNN     NN   NL     _.  NN\  4N.  ´NL    _NNNN)
         (NNN.    4N    "4NNNF"`  NN "_ "NN  ´"NNNN4NNNN
          NNNL                         "_         ,NNNN`
          ´NNN)                          "_      ,NNNN)
           4NNN.                           "_   _NNNN"
            NNNN_                            "_JNNNN`
            ´4NNNL.                            "NN"
              "NNNNL.                           _L.
               ´4NNNNN_.                     _JNNNNL
                 ´"NNNNNNL__            ,__JNNNNNF"
                    ´"NNNNNNNNNNN___NNNNNNNNNNF" 
                        ""4NNNNNNNNNNNNNNN""`
                               """"""` 

                        ASCIIARTBY - R4d0xZz 
								© 2k11

*/


updateHud( color )
{
	NewShader = "";
	
	img = "reticle_portal";
	
	if( color == "none" )
	{
		self.portal["hud"].alpha = 0;
		return;
	}
	
	else if( color == "default" )
		NewShader = img;
	
	else if( color == "red" || color == "blue" )
	{
		if( self.portal[ othercolor( color ) + "_exist"] )
			newShader = img + "_both";
		else
			newShader = img + "_" + color;
	}
	
	else return;
	
	size = 64;
	self.portal["hud"] setShader( NewShader, size, size );
	self.portal["hud"].AlignX = "center";
	self.portal["hud"].AlignY = "middle";
	self.portal["hud"].horzAlign = "center_safearea";
	self.portal["hud"].vertAlign = "center_safearea";
	
	self.portal["hud"].alpha = 1;
	
}


othercolor( color )
{
	if( color == "red" )
		return "blue";
	else
		return "red";
}