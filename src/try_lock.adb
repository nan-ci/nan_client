with Ada.Command_Line, Lib.Locking;
use Lib;

procedure Try_Lock is
   Lock : Locking.T;
begin
   Lock.Create (To_UTF32 (Ada.Command_Line.Argument (1)), Timeout => 0.0);
   Lock.Delete;
end Try_Lock;
