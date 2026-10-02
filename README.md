# I347 - Virtualisation de GLPI avec des conteneurs Docker

## Introduction / But du projet
L’inventaire matériel et logiciel est le recensement des équipements matériels (ordinateurs, serveurs…) et logiciels (systèmes d’exploitation, applications…) d’une organisation. Ce processus permet également de suivre certaines informations du matériel et des logiciels utilisés. Pour les équipements matériels, il s’agit généralement du numéro de série, modèle, fabricant, adresse IP, emplacement physique, utilisateur(s) de la machine, ainsi que l’état de la garantie. Dans le cas des logiciels, on retrouve la version du programme, la gestion des licences et parfois également la gestion des applications autorisées ou non.

Avoir un inventaire matériel et logiciel au sein d’une organisation permet d’augmenter l’efficacité de la gestion des machines physiques et des composantes logicielles. Les principaux intérêts sont les suivants :
*   **Maîtrise des coûts :** En ayant conscience du nombre de machines, de licences, ainsi que leur état permet d’éviter les achats inutiles.
*   **Sécurité :** Grâce aux informations des machines et des logiciels, les failles, causées par des versions obsolètes par exemple, peuvent être identifiées avant d’être un problème pour l’organisation.
*   **Gestion du cycle de vie :** En identifiant les vieux équipements et les expirations de garanties et de licences, des mesures peuvent être prises pour remplacer le matériel ou renouveler les garanties et licences requises.

## Architecture
Le rôle de l’intégration de protocoles informatiques automatisés supprime les erreurs humaines liées aux comptages manuels. Cela permet de synchroniser en temps réel la réalité physique des éléments (produit vendu, etc.) avec la base de données centrale.

GLPI agrège quatre fonctions historiquement vendues séparément. Inventaire matériel et logiciel via l’agent GLPI ou OCS Inventory NG, GLPI collecte hardware, software installé, licences, et stocke les fiches dans une base MariaDB ou PostgreSQL. La granularité dépend du système : Windows expose plus de signaux que MacOS. Helpdesk ITIL, tickets d’incident, demandes, problèmes, changements. Catégories SLA, escalades, satisfaction. C’est l’un des seuls outils open source qui implémente sérieusement le processus ITIL v3.

### Schéma d'architecture des conteneurs
```text
      [ Utilisateur / Navigateur Web ]
                     │ (Port Exposé: 80/443)
                     ▼
┌──────────────────────────────────────────────┐
│             Réseau Docker Interne            │
│                                              │
│   ┌──────────────────────────────────────┐   │
│   │        Conteneur GLPI (Web)          │   │
│   │  (PHP 8.2+, Extensions obligatoires)  │   │
│   └──────────────────┬───────────────────┘   │
│                      │                       │
│                      │ (Connexion Interne)   │
│                      ▼                       │
│   ┌──────────────────────────────────────┐   │
│   │     Conteneur Base de Données        │   │
│   │        (MariaDB / PostgreSQL)        │   │
│   └──────────────────────────────────────┘   │
└──────────────────────────────────────────────┘
```

## Instructions de lancement
En utilisant Docker et Docker Compose, le déploiement devient standardisé et automatisé. À la place d’installer et de lier un par un le serveur web, MariaDB et les multiples extensions requises, il suffit d’exécuter un fichier de configuration prêt à l’emploi. Docker télécharge et lance automatiquement des conteneurs isolés et préconfigurés avec exactement les bonnes versions de PHP et les dépendances nécessaires. C’est une méthode moderne qui transforme une installation prenant autrefois plusieurs heures en une simple ligne de commande, garantissant au passage une stabilité parfaite du système.

Pour lancer l'application, exécutez la commande suivante à la racine du projet :
```bash
docker-compose up -d
```

## Informations sur le réseau, la sécurité, les variables
*   **SNMP (Simple Network Management Protocol) :** C’est un protocole de communication standard de la coupe application (OSI 7) étant important pour la logistique. Il interroge à distance le matériel réseau et les périphériques (imprimantes d’étiquettes, terminaux de numérisation, serveurs de stockage) sans intervention humaine. Il permet de gérer et surveiller les infrastructures réseau compatibles SNMP. Ce protocole fonctionne selon un modèle composé de trois éléments, le superviseur (manager), les nœuds (nodes) et les agents :
    *   Le NMS (Network Management System), c’est la station centrale d’administration qui centralise la supervision.
    *   La MIB (Management Information Base), c’est la base de données de l’agent où chaque information (charge CPU, niveau d’encre) possède un ID unique appelé OID.
    *   L’agent SNMP, c’est un micro-programme local installé sur le périphérique servant à enregistrer en temps réel l’état de la machine.
*   **WMI/Win RM :** Ce sont des protocoles Microsoft (pour Windows) utilisés pour inventorier la configuration logicielle et matérielle précise (disques, cartes réseau…) des stations de travail fixes et des serveurs d’administration.
*   **SSH (Secure Shell) :** Cela permet le transfert de données et des connexions à distance chiffrées.

## Tests effectués et résultats
*   **Création d’un compte GLPI et accès :** Après s’être connecté, on arrive à la page d’accueil de GLPI.
*   **Créer un téléphone :** Les options type « fabricant », « numéro de série », etc. sont toutes des informations libres à entrer manuellement et à créer à notre guise. Par exemple, nous avons pu créer le fabricant « IPhone » en appuyant sur le petit « + » de cette ligne.
*   **Créer un ordinateur :** Il y a diverses informations à noter dont des listes déroulantes. Ces listes permettent de récupérer des informations déjà entrées dans le logiciel. On peut remplir le champ technicien et utilisateur grâce aux données créées précédemment.
*   **Installer un logiciel et sa licence sur une machine :** Retournons voir les informations de notre ordinateur SC-C313-PC07. Choisissons logiciels. Sélectionnons notre logiciel Photoshop, ainsi que sa version. Puis, cliquer sur installer. Notre ordinateur possède maintenant Photoshop. Il faut maintenant ajouter la licence Photoshop à cette machine. On procède de manière similaire. On constate que mon logiciel dit que la licence est valide.

## Problèmes rencontrés / pistes d’amélioration
*   **Gestion et dépassement des licences :** Nous n’avons qu’une licence pour la suite Adobe, voyons ce qu’il se passe si j’attribue également Photoshop et la licence sur un autre ordinateur. Pour les deux appareils, la licence de Photoshop n’est plus valide. En allant voir la licence en détail, on constate une alerte, car le nombre de licence est dépassée. En modifiant le nombre à 10, il n’y a plus de problème, et la barre nous montre qu’on a des licences restantes.
*   **Risques liés aux profils d'accès :** Si le profil « Super-Admin » est supprimé ou si l’interface simplifiée est associée à ce profil, l’accès à la configuration de GLPI peut être perdue définitivement.
*   **Complexité de l'environnement :** Bien que puissant, GLPI présente une complexité de déploiement significative nécessitant des compétences techniques pour configurer l’environnement serveur (Web, MariaDB/MySQL) et PHP 8.2+ avec de nombreuses extensions obligatoires (curl, mysqli, openssl, etc.). L’installation implique la gestion d’un environnement robuste, incluant des extensions suggérées (LDAP, OPcache) et des prérequis navigateurs stricts, rendant sa mise en œuvre technique et non automatisée.
