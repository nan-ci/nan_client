package NaN.Logo is

   procedure Print;

private

   Logo : constant array (Positive range <>) of String (1 .. 31) :=
      ("                   .           ",
       "                  d8b          ",
       "                d88888b        ",
       "              d888Y Y888b      ",
       "            d888Y  .  Y888b    ",
       "          d888Y   d8b   Y888b  ",
       "        d888Y   d88888b   Y888b",
       "         """"   d888Y Y888b   """" ",
       "            d888Y  .  Y888b    ",
       "             """"   d8b   """"     ",
       "                d88888b        ",
       "                  Y8b          ",
       "                   '           ");
   Text : constant array (Positive range <>) of String (1 .. 39) :=
      ("8888b   88888             8888b   88888",
       " 8888b   888               8888b   888 ",
       " 88888b  888               88888b  888 ",
       " 888Y88b 888    88888b.    888Y88b 888 ",
       " 888 Y88b888    ""   ""88b   888 Y88b888 ",
       " 888  Y88888   .d8888888   888  Y88888 ",
       " 888   Y8888   888   888   888   Y8888 ",
       "88888   Y888   ""Y88888""88 88888   Y888 ");

end NaN.Logo;
