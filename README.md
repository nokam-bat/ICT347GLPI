# I347 - Virtualisation et Déploiement de GLPI avec Conteneurs Docker

## Introduction / But du projet
Ce projet est réalisé dans le cadre du module I347 au Centre Professionnel du Nord Vaudois (CPNV). L'objectif principal est de moderniser l'infrastructure applicative d'une organisation en conteneurisant une solution complète de gestion de parc informatique avec **GLPI**. 

L'infrastructure est entièrement virtualisée, automatisée via Docker Compose, sécurisée au niveau réseau et configurée pour garantir la persistance des données en production.

## Qu'est-ce que GLPI ?
GLPI (Gestionnaire Libre de Parc Informatique) est un logiciel libre de gestion des services informatiques (ITSM) et de gestion des services d’assistance (issue tracking system et Service Desk) crée en 2003 par l’association « INDEPNET ». Il est plus précisément un logiciel de gestion des actifs et des TI (Technologies de l’informatique) qui offre des fonctionnalités de centre de services ITIL, le suivi des licences et l’audit des logiciels.
Ce logiciel reste évolutif car étant en technologie libre, cela veut dire que toute personne peut exécuter, modifier ou développer le code, les contributeurs font alors partie de cette évolution en soumettant des modules supplémentaires sur GitHub. 

## Architecture
L'architecture logicielle est découpée en **4 micro-services interconnectés** au sein d'un réseau étanche :

*   **glpi-web (Application) :** Gère l'interface utilisateur de GLPI. Ce service est construit via un `Dockerfile` personnalisé.
*   **glpi-db (Base de données) :** Instance **MySQL** qui stocke l'inventaire, les tables de données et les configurations.
*   **glpi-admin (Administration) :** Interface graphique **phpMyAdmin** permettant de manager et de superviser la base de données.
*   **glpi-monitoring (Supervision) :** Outil **Portainer** permettant de monitorer visuellement l'état des conteneurs, les ressources (CPU/RAM) et les logs.

### Schéma de l'architecture réseau
```text
      [ Utilisateur Web ]                  [ Admin Portainer ](http://localhost:80)               (http://localhost:9001)
               │                                    │
               ▼                                    ▼
┌───────────────────────────────────────────────────────────────────────┐
│                        Réseau Docker Privé                            │
│                       (glpi-private-network)                          │
│                                                                       │
│   ┌────────────────────────┐              ┌───────────────────────┐   │
│   │     Conteneur Web      │              │ Conteneur Monitoring  │   │
│   │       (glpi-web)       │              │  (glpi-monitoring)    │   │
│   └───────────┬────────────┘              └───────────┬───────────┘   │
│               │                                       │               │
│               │           (Flux Internes)             │               │
│               └───────────────────┬───────────────────┘               │
│                                   ▼                                   │
│                       ┌───────────────────────┐                       │
│                       │     Conteneur DB      │                       │
│                       │       (glpi-db)       │                       │
│                       │  [Volume Persistant]  │                       │
│                       └───────────────────────┘                       │
└───────────────────────────────────────────────────────────────────────┘
```

## Instructions de lancement
L'infrastructure est entièrement automatisée. Pour télécharger les images, construire le Dockerfile personnalisé et lancer la stack en arrière-plan, exécutez la commande suivante :

```bash
docker compose up -d --build
```

### URL d'accès aux services locaux
*   **Application GLPI :** [http://localhost](http://localhost) (Identifiants : `glpi` / `glpi`)
*   **phpMyAdmin :** [http://localhost:8080](http://localhost:8080)
*   **Portainer (Monitoring) :** [http://localhost:9001](http://localhost:9001)

## Informations sur le réseau, la sécurité, les variables
*   **Variables d'environnement (.env) :** Toutes les configurations d'interconnexion (mots de passe SQL, ports, noms de base) sont isolées de manière étanche dans le fichier `.env` afin d'éviter l'écriture de données sensibles en dur dans le code.
*   **Sécurité et Isolation réseau :** Les conteneurs communiquent via un sous-réseau bridge isolé (`glpi-private-network`). Le conteneur de base de données MySQL n'expose aucun port vers l'hôte extérieur (port 3306 fermé), la rendant invisible et protégée contre les attaques externes.
*   **Dockerfile personnalisé :** L'image de base applicative est configurée en amont en y forçant l'environnement de production standardisé (langue en français via `ENV GLPI_LANG=fr_FR`).

## Tests effectués et résultats
*   **Test d'étanchéité réseau (Réussi) :** Les connexions externes sur le port 3306 de la base de données sont rejetées par l'hôte. Seul le conteneur `glpi-web` au sein du réseau virtuel Docker peut l'atteindre.
*   **Test de persistance des données (Réussi) :** Création d'un ticket et d'un ordinateur de test dans l'interface GLPI. Exécution d'un `docker compose down` pour détruire les conteneurs. Après exécution de `docker compose up -d`, les données saisies sont intégralement conservées grâce aux volumes nommés `glpi_data` et `db_data`.

## Problèmes rencontrés / pistes d’amélioration
*   **Problème rencontré :** Conflit sur le port par défaut de Portainer (`9000`) lors des premiers lancements locaux. Résolu avec succès en modifiant le mappage de port externe vers le port `9001` dans le fichier `docker-compose.yml`.
*   **Pistes d'amélioration :** Implémenter un build Multi-stage dans le Dockerfile pour réduire l'empreinte de stockage de l'image de production et mettre en place un Reverse Proxy Nginx pour chiffrer les flux web en HTTPS.
