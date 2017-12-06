with Lib;
use Lib;

package NaN is

   SSH : constant Str := "ssh -p 22 -oStrictHostKeyChecking=no -oCheckHostIP=no";

end NaN;

-- Common
-- récuperer les outputs de toutes les commandes, passer le logging en optionnel
-- dmesg -D sur les clients et le serveur (désactive les logs du noyau)
-- centraliser et standardiser les noms de fichiers, logs, locks et dossiers
-- améliorer log, noms datés, suppression des anciens
-- vraie console
-- commenter le code, documenter l'infra
-- fichier de config
-- passer sous ncurses ou un truc du genre

-- Server
-- lock pour create (disabled) delete rename list disable enable reset (création à la connexion) password backup restore
-- pour le restore, snapshots sélectionnables en colonnes : année mois jour heure minute seconde
-- scrubing
-- suppression des snapshots d'un certain âge, côté client & serveur
-- opti : wrapper qui récupère le stream et l'analyse en passant pour déterminer s'il est vide
-- rate limiting, temps d'exécution minimale 1 sec
-- interface interactive en plus des commandes, avec support de la souris

-- Client
-- appairage bluetooth
-- sanitize password (graphics + escape)
-- choix gestionnaire de fenêtre > /etc/X11/default-display-manager
-- ssh_config
-- sshd_config
-- chiffrer le mdp en mémoire
-- zero knowledge password, échanges de hash salés
-- clefs à usage unique
--  Create Delete Enable Disable Reset Password Backup Restore Sync
-- mount avec subvol à chaque fois, par sécurité
