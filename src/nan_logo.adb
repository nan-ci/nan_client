with Ada.Text_IO, Lib.Console, Lib.Term;
use Lib;

package body NaN_Logo is

   package TIO renames Ada.Text_IO;

   use all type Term.Color;

   procedure Print is
   begin
      Console.Set_Origin (X => (Console.Width + 1) / 2 - Text (1)'Length / 2,
                          Y => Console.Height / 6);
      TIO.Put (Term.Clear_Screen);
      Console.Reset;

      for Line of Logo loop
         Console.Put_Line (Line);
      end loop;

      for Line of Text loop
         Console.Put_Line (Line);
      end loop;

      Console.New_Line;
      Console.Set_Origin;
   end Print;

end NaN_Logo;
