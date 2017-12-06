with Ada.Calendar, Ada.Containers.Ordered_Sets;
use  Ada.Calendar;

with Lib;
use Lib;

package Btrfs is

   type Subvolume is record
      UUID : String (1 .. 36);
      Date : Time;
   end record;

   function "<" (Left, Right : Subvolume) return Boolean is (Left.Date < Right.Date);

   package Subvolumes is new Ada.Containers.Ordered_Sets (Subvolume);
   use     Subvolumes;

   type Subvolume_List is new Subvolumes.Set with null record;

   function "<" (Left, Right : Subvolume_List) return Boolean;

   function List (Path : Str) return Subvolume_List;

   procedure Save (List : Subvolume_List;
                   Path : Str);

   function Load (Path : Str) return Subvolume_List;

   function Date (Path : Str) return Time;

   function Name (Item : Subvolume) return Str;

   procedure Rename_UTC (Path : Str);

   procedure Create (Path : Str);

   procedure Delete (Path : Str);

   procedure Exclude (Path : Str);

   procedure Sync (Path : Str);

end Btrfs;

-- génération du send en local
-- les noms des snapshots sont des heures locales avec la TZ ou random
-- laisser le client recréer current et faire les snapshots, du coup séparer complètement la "sync" et la
-- rendre bidirectionnelle

-- procedure Client_Sync NO_LOCK
-- snapshot
-- si le snapshot est vide, suppression, quitter
-- if not Server_Sync then
--    signaler désynchro

-- procedure Client
-- loop
--    next := now + 5 mins
--    Server_Sync
--    delay until next
-- end loop;
-- Server_Sync

-- procedure Server_Sync
-- liste serveur
-- liste client
-- si client < server alors
--    server => client
-- sinon si server < client alors
--    client => server
--     serveur & client, sinon receive
-- sinon

-- si "tmp" est ro alors le renommer en date

-- push/pull synonymes
-- Le client fait un instantané du répertoire utilisateur de l'étudiant.
-- Si l'instantané ne comporte aucune modification, il est supprimé et la synchronisation est finie.
-- Sinon, le client notifie le serveur d'une demande de synchronisation
-- Le serveur notifié examine les instantanés du client et côté serveur

-- Delete partially received subvolumes on error
