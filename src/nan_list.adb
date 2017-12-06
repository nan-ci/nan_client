with Ada.Command_Line, Ada.Directories, Btrfs, Ada.Wide_Wide_Text_IO;
with Lib;
use Lib;

procedure NaN_List is
   List : Btrfs.Subvolume_List;
begin
   Ada.Directories.Set_Directory (Ada.Command_Line.Argument (1));
   List := Btrfs.List (To_UTF32 (Ada.Command_Line.Argument (1)));

   for E of List loop
      Ada.Wide_Wide_Text_IO.Put_Line (Btrfs.Name (E));
   end loop;
end NaN_List;
