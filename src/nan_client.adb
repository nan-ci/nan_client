with Ada.Containers, Ada.Environment_Variables, Ada.Directories, Ada.Text_IO, Lib.Console, Lib.Text,
     Lib.Locking, Lib.Process, Lib.File, Btrfs, Log, NaN.Terminal, NaN.Logo, Empty_Stream, Lib.File, Lib.Term,
     Lib.Sets, GNAT.OS_Lib;
use Lib, NaN;

procedure NaN_Client is

   package Env renames Ada.Environment_Variables;
   package Dir renames Ada.Directories;
   package TIO renames Ada.Text_IO;
   package OS  renames GNAT.OS_Lib;

   use all type Term.Color;
   use type Text.T;
   use type Char_Set;
   use type Ada.Containers.Count_Type;

   Username : Text.T (39);
   Password : Text.T (72);

   Home : Text.T (255);

   Host        : constant Str := "192.168.0.253";
   Log_Path    : constant Str := "/run/nan_client.log";
   Lock_Path   : constant Str := "/run/nan_client.lock";
   Stream_Path : constant Str := "/run/nan_client_stream.dat";

   function Server (Command : Str) return OS.Argument_List_Access is
      Output : OS.Argument_List_Access :=
         new OS.Argument_List'(new String'("sshpass"),
                               new String'("-p"),
                               new String'(Password.To_UTF8),
                               new String'("ssh"),
                               new String'("-p"),
                               new String'("22"),
                               new String'("-oStrictHostKeyChecking=no"),
                               new String'("-oCheckHostIP=no"),
                               new String'(Username.To_UTF8 & '@' & To_String (Host)),
                               new String'(To_UTF8 (Command)));
   begin
      return Output;
   end Server;

   Client_Lock, User_Lock : Locking.T;

   Status  : Integer;
   Command : OS.Argument_List_Access;

   procedure Print (Key, Val : String) is
   begin
      TIO.Put_Line (Key & '=' & Val);
   end Print;
begin
   File.Exclude (Log_Path);
--     Env.Iterate (Print'Access);
--     NaN.Terminal.Set ("/dev/pts/0");
   NaN.Terminal.Undef_Keys;
   NaN.Terminal.Unset_Features;
   Log (Log_Path, "locking");
   Client_Lock.Create (Lock_Path);
   Log (Log_Path, "locked");
   NaN.Terminal.Get_Size (Width  => Console.Width,
                          Height => Console.Height);
   NaN.Logo.Print;

   loop <<Continue>>
      Console.Clear;
      Username.Clear;
      Password.Clear;
      TIO.Put (Term.Fore (White));
      Console.Put ("login: ");
      TIO.Put (Term.Fore (Gray) & Term.Cursor_On);
      Console.Get_Line (Username, Set => Sets.Basic or Sets.Hyphen or Sets.Digit);

      if Username.Is_Empty
         or else Username.Data (1) = '-'
         or else Username.Data (Username.Last) = '-'
         or else Username.Find ("--") > 0 then
         goto Continue;
      end if;

      TIO.Put (Fore (White));
      Console.Put ("password:");
      Console.Get_Line (Password, Show => False);
      TIO.Put (Term.Cursor_On);
      Command := Server ("connect");
      Status := Process.Spawn (Command);
      TIO.Put (Term.Fore (Light_Red));

      case Status is
         when 0      => null;
         when 255    => Console.Put_Line ("cannot connect to the server");
         when others => Console.Put_Line ("unauthorized");
      end case;

      if Status /= 0 then
         delay 2.0;
         goto Continue;
      end if;

      TIO.Put (Term.Fore (Gray));
      User_Lock.Create ("/run/nan_client_" & Username.Get & ".lock");
      Home.Set ("/home/" & Username.Get);

      if not File.Exists (Home.Get) then
         Process.Spawn ("useradd --user-group --create-home --skel /root/user --shell /bin/bash " & Username.Get,
                        Raise_Error => False);
      end if;

--        set rights
--        Syncing.Start;
      Console.Clear;

      if not Process.Spawn ("su -l " & Username.Get & " -c startx\ --\ -quiet") then
         TIO.Put (Term.Fore (Light_Red));
         Console.Put_Line ("cannot startx");
         TIO.Put (Term.Fore (Gray));
         delay 2.0;
      end if;

--        Syncing.Stop;

      User_Lock.Delete;
   end loop;
exception
   when Error : others =>
      Client_Lock.Delete;
      raise;
end NaN_Client;


--  task Syncing is
--     entry Start;
--     entry Stop;
--  end Syncing;
--
--  task body Syncing is
--     procedure Sync is
--        Client : Btrfs.Subvolume_List;
--     begin
--        Dir.Set_Directory (Root.To_String);
--        Log (Log_Path, "im here : " & To_UTF32 (Dir.Current_Directory));
--        Btrfs.Exclude ("tmp");
--        Process.Spawn ("btrfs subvolume snapshot -r current tmp");
--        Btrfs.Sync (".");
--        Client := Btrfs.List (".");
--        Process.Spawn ("btrfs send --no-data -f" & ' ' & Stream_Path & " current "
--                       & (if Client.Length > 0 then
--                             "-p " & Btrfs.Name (Client.Last_Element)
--                          else
--                             ""));
--
--        if not Empty_Stream (Stream_Path) then
--           Log (Log_Path, "not empty stream, renaming");
--           Btrfs.Rename_UTC ("tmp");
--           Btrfs.Save (Btrfs.List ("."), "/run/nan_client.dat");
--
--           if not Process.Spawn (Server ("sync")) then
--              Log (Log_Path, "sync error");
--           end if;
--        else
--           Log (Log_Path, "empty stream");
--           Btrfs.Delete ("tmp");
--        end if;
--
--        File.Delete (Stream_Path);
--     end Sync;
--  begin
--     loop
--        Log (Log_Path, "starting loop");
--
--        select
--           accept Start do
--              Log (Log_Path, "first sync");
--              Sync;
--              Log (Log_Path, "first done");
--           end Start;
--
--           loop
--              Log (Log_Path, "loop");
--
--              select
--                 accept Stop;
--                 Log (Log_Path, "stopping");
--                 exit;
--              or
--                 delay 60.0;
--                 Sync;
--              end select;
--           end loop;
--
--           Log (Log_Path, "stopped ?");
--        or
--           terminate;
--        end select;
--     end loop;
--  end Syncing;

--  loop
--     TIO.Put (Fore (White));
--     Console.Put ("> ");
--     TIO.Put (Fore (Gray));
--     Console.Get_Line (Item => Command,
--                       Set  => Sets.Lower);
--
--     if Command = "exit" then
--        exit;
--     elsif Command = "clear" then
--        Console.Clear;
--     elsif Command = "start" then
--        Syncing.Start;
--     elsif Command = "stop" then
--        Syncing.Stop;
--     elsif Command /= "" then
--        null;
--     end if;
--  end loop;
