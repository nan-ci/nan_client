with Lib.Console, Lib.Text, Lib.Sets, Lib.Process, Ada.Strings.Wide_Wide_Maps, Lib.Strings, Ada.Strings.Wide_Wide_Fixed, Ada.Wide_Wide_Text_IO;
use Lib, Lib.Strings;

package body Terminal is

   package Maps renames Ada.Strings.Wide_Wide_Maps;
   package Fixed renames Ada.Strings.Wide_Wide_Fixed;

   package WIO renames Ada.Wide_Wide_Text_IO;

   use type Text.T;
   use type Char_Set;
   use all type Text.Direction;

   Path : Text.T (255);

   procedure Set (Device_Path : String) is
   begin
      Path.Set (Device_Path);
   end Set;

   procedure Get_Size (Width, Height : out Positive) is
      Stty : constant Str := Process.Output ("stty -F " & Path.Get & " -a");
   begin
      Height := Value (Get (Item    => Get (Item    => Stty,
                                            Pattern => "rows " & Any (Sets.Digit)),
                            Pattern => Any (Sets.Digit)));

      Width := Value (Get (Item    => Get (Item    => Stty,
                                           Pattern => "columns " & Any (Sets.Digit)),
                           Pattern => Any (Sets.Digit)));
   end Get_Size;

   procedure Undef_Keys is
      Stty : constant Str := Process.Output ("stty -F " & Path.Get & " -a");
   begin
      for Key of Suites (Item    => Stty,
                         Pattern => Any (Sets.Lower) & " = " & (Any (Sets.Basic or "<^>\?") & ";")) loop
         Process.Spawn ("stty -F " & Path.Get & ' ' & Get (Slice (Stty, Key), Any (Sets.Lower)) & " undef");
      end loop;
   end Undef_Keys;

   procedure Unset_Features is
      Stty : constant Str := Process.Output ("stty -F " & Path.Get & " -a");
   begin
      for Item of Suites (Item    => Stty (Fixed.Index (Stty, ";", Backward) + 1 .. Stty'Last),
                          Pattern => Any (Sets.Digit or Sets.Lower or Sets.Hyphen)) loop
         declare
            Feat : constant Str := Slice (Stty, Item);
         begin
            if Feat /= "cread" and then Fixed.Index (Feat, Sets.Digit or Sets.Hyphen) = 0 then
               Process.Spawn ("stty -F " & Path.Get & " -" & Feat);
            end if;
         end;
      end loop;
   end Unset_Features;

begin
   Path.Set (Str'("/dev/tty1"));
end Terminal;
