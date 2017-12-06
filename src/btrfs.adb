with Ada.Calendar.Formatting, Ada.Calendar.Time_Zones, Ada.Strings.Wide_Wide_Fixed, Ada.Strings.Wide_Wide_Maps, Ada.Directories, NaN, Ada.Streams.Stream_IO, Log, Lib.File, Lib.Process, Lib.Sets, Lib.Text, Ada.Text_IO;
use Lib, NaN; with Lib.Strings; use Lib.Strings;

package body Btrfs is

   package Maps    renames Ada.Strings.Wide_Wide_Maps;
   package Fixed renames Ada.Strings.Wide_Wide_Fixed;
   package TIO renames Ada.Text_IO;
   package SIO renames Ada.Streams.Stream_IO;
   package Dir renames Ada.Directories;
   package Cal renames Ada.Calendar;
   package TZ  renames Ada.Calendar.Time_Zones;
   package Format renames Ada.Calendar.Formatting;

   use type Text.T;
   use all type Text.Direction;
   use type Char_Set;
   use type TZ.Time_Offset;

   function Date (Path : Str) return Time is
      Show : constant Str := Process.Output ("btrfs subvolume show " & Path);
   begin
      return Format.Value
         (Date      => To_String (Get (Item    => Show,
                                       Pattern => To_Suite (Pattern  => "dd-dd-dd dd:dd:dd",
                                                            Matching => (1 => ('d', Sets.Digit))))),
          Time_Zone => TZ.Time_Offset'Wide_Wide_Value (Get (Item    => Show,
                                                            Pattern => Suite'(1, Maps.To_Set ("-+")) &
                                                            Suite'(4, Sets.Digit))) / 100 * 60);
   end Date;

   function List (Path : Str) return Subvolume_List is
      List : constant Str := Process.Output ("btrfs subvolume list -uroR " & Path);

      L : Subvolume_List;
   begin
      for Line of Lines (List) loop
         L.Insert ((UUID => To_String
                    (Get (Item    => Slice (List, Line),
                          Pattern => To_Suite (Pattern  => "hhhhhhhh-hhhh-hhhh-hhhh-hhhhhhhhhhhh",
                                               Matching => (1 => ('h', Sets.Hexa))))),
                    Date => Date (To_UTF32 (Dir.Compose (To_UTF8 (Path),
                       To_UTF8 (List (Fixed.Index (Source  => List,
                                                   Pattern => "/",
                                                   From    => Line.First) + 1 .. Line.Last)))))));
      end loop;

      return L;
   end List;

   procedure Save (List : Subvolume_List;
                   Path : Str) is
      F : SIO.File_Type;
   begin
      File.Exclude (Path);
      SIO.Create (F, SIO.Out_File, To_UTF8 (Path));
      Subvolume_List'Write (SIO.Stream (F), List);
      SIO.Close (F);
   end Save;

   function Load (Path : Str) return Subvolume_List is
      F : SIO.File_Type;
      L : Subvolume_List;
   begin
      SIO.Open (F, SIO.In_File, To_UTF8 (Path));
      Subvolume_List'Read (SIO.Stream (F), L);
      SIO.Close (F);
      return L;
   end Load;

   function "<" (Left, Right : Subvolume_List) return Boolean is
      (not Right.Is_Empty and then (Left.Is_Empty or else Left.Last < Right.Last));

   function Name (Item : Subvolume) return Str is (To_Str (Format.Image (Item.Date)));

   procedure Rename_UTC (Path : Str) is
   begin
      Dir.Rename (To_UTF8 (Path), Format.Image (Date (Path)));
   end Rename_UTC;

   procedure Create (Path : Str) is
   begin
      Process.Spawn ("btrfs subvolume create " & Path);
      Sync (To_UTF32 (Dir.Containing_Directory (To_UTF8 (Path))));
   end Create;

   procedure Delete (Path : Str) is
   begin
      Process.Spawn ("btrfs subvolume delete -C " & Path);
      Sync (To_UTF32 (Dir.Containing_Directory (To_UTF8 (Path))));
   end Delete;

   procedure Exclude (Path : Str) is
   begin
      if File.Exists (Path) and then Process.Spawn ("btrfs subvolume delete -C " & Path) then
         Sync (To_UTF32 (Dir.Containing_Directory (To_UTF8 (Path))));
      end if;
   end Exclude;

   procedure Sync (Path : Str) is
   begin
      Process.Spawn ("btrfs subvolume sync " & Path);
      Process.Spawn ("btrfs filesystem sync " & Path);
      Process.Spawn ("sync");
   end Sync;

end Btrfs;
