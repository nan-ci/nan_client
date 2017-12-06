with Ada.Containers.Vectors, Ada.Streams.Stream_IO, Interfaces;
use  Ada.Containers,         Ada.Streams.Stream_IO, Interfaces;

with Lib;
use Lib;

function Empty_Stream (Path : Str) return Boolean is
   type Command is (Unspec, Subvol, Snapshot, Mkfile, Mkdir, Mknod, Mkfifo, Mksock, Symlink, Rename, Link,
                    Unlink, Rmdir, Set_Xattr, Remove_Xattr, Write, Clone, Truncate, Chmod, Chown, Utimes,
                    End_Command, Update_Extent, Max) with Size => 16;

   package Commands is new Ada.Containers.Vectors (Positive, Command);

   type Command_List is new Commands.Vector with null record;

   type Command_Header is record
      Size  : Unsigned_32;
      Kind  : Command;
      CRC32 : Unsigned_32;
   end record;

   F      : File_Type;
   Magic  : String (1 .. 13);
   Header : Command_Header;
   List   : Command_List;
begin
   Open (F, In_File, To_UTF8 (Path));
   String'Read (Stream (F), Magic);
   pragma Assert (Magic = "btrfs-stream" & Character'First and then
                  Unsigned_32'Input (Stream (F)) = 1);

   while not End_Of_File (F) loop
      Command_Header'Read (Stream (F), Header);
      Set_Index (F, Index (F) + Count (Header.Size));
      List.Append (Header.Kind);
   end loop;

   Close (F);
   return List = Snapshot & End_Command or else List = Subvol & Chown & Chmod & Utimes & End_Command;
end Empty_Stream;
