# Projet I347 - Virtualisation de GLPI avec des conteneurs

## Introduction / But du projet
Ce projet s'inscrit dans le cadre du module I347 au Centre Professionnel du Nord Vaudois (CPNV). L'objectif est de moderniser une infrastructure informatique en déployant une solution complète de gestion de parc avec **GLPI**, entièrement virtualisée à l'aide de conteneurs Docker et Docker Compose. 

La solution intègre une architecture micro-services, un réseau isolé personnalisé, la persistance automatique des données et une gestion sécurisée des secrets d'environnement.

## Architecture
L'architecture de production est segmentée en **3 services interconnectés** au sein d'un réseau étanche :

*   **glpi-web (Service Application) :** Gère l'interface utilisateur et la logique métier de GLPI, construit à partir d'un `Dockerfile` personnalisé.
*   **glpi-db (Service Base de données) :** Système de gestion de base de données **MySQL** gérant les fiches de parc, tickets et configurations.
*   **glpi-admin (Service Outil d'administration) :** Instance **phpMyAdmin** permettant de superviser et administrer graphiquement la base de données.

### Schéma de l'architecture réseau
```text
      [ Accès Utilisateur ]               [ Accès Admin ](http://localhost)               (http://localhost:8080)
               │                                   │
               ▼                                   ▼
┌──────────────────────────────────────────────────────────────────┐
│                      Réseau Docker Isolé                         │
│                     (glpi-private-network)                       │
│                                                                  │
│   ┌───────────────────────┐             ┌────────────────────┐   │
│   │     Conteneur Web     │             │  Conteneur Admin   │   │
│   │      (glpi-web)       │             │    (phpmyadmin)    │   │
│   └───────────┬───────────┘             └─────────┬──────────┘   │
│               │                                   │              │
│               │         (Flux Internes)           │              │
│               └─────────────────┬─────────────────┘              │
│                                 ▼                                │
│                     ┌───────────────────────┐                    │
│                     │     Conteneur DB      │                    │
│                     │       (glpi-db)       │                    │
│                     │  [Volume Persistant]  │                    │
│                     └───────────────────────┘                    │
└──────────────────────────────────────────────────────────────────┘
```

## Instructions de lancement
L'ensemble de l'infrastructure est automatisé. Pour déployer, construire l'image personnalisée et lancer la solution en arrière-plan, exécutez la commande suivante à la racine du projet :

```bash
docker compose up -d --build
```

### Accès aux services
*   **Interface GLPI :** `http://localhost` (Identifiants : `glpi` / `glpi`)
*   **Gestionnaire de Base de Données :** `http://localhost:8080`

## Informations sur le réseau, la sécurité, les variables
*   **Sécurité & Isolation réseau :** Les conteneurs communiquent via le driver privé `glpi-private-network`. Par mesure de sécurité, le conteneur de base de données MySQL (`glpi-db`) n'expose aucun port vers l'extérieur de l'hôte (port 3306 fermé aux connexions externes).
*   **Variables d'environnement :** Toutes les configurations sensibles et d'interconnexion (mots de passe, hôtes, noms de tables) sont externalisées de manière étanche via le fichier `.env`.
*   **Dockerfile Personnalisé :** L'image applicative GLPI est optimisée en y injectant directement des variables d'environnement de production standardisées (ex: `GLPI_LANG=fr_FR`).

## Tests effectués et résultats
*   **Test d'interconnexion :** Validation de la communication interne : le service Web parvient à joindre l'hôte `db` défini dans le `.env` pour finaliser son installation.
*   **Test de persistance (Validé) :** Création d'un ticket de test dans l'interface GLPI, suivi d'un arrêt complet des infrastructures via `docker compose down`. Après une relance complète (`docker compose up`), le ticket est toujours présent en base de données, confirmant le bon fonctionnement des volumes nommés `glpi_data` et `db_data`.

## Problèmes rencontrés / pistes d’amélioration
*   **Problème rencontré :** Lors du premier lancement, une erreur d'absence de build a été levée (`failed to read dockerfile`). Elle a été corrigée en créant un fichier `Dockerfile` strict sans extension à la racine, permettant à Docker Compose de compiler correctement le micro-service applicatif.
*   **Pistes d'amélioration :** Évoluer vers un build *multistage* dans le Dockerfile pour restreindre au maximum les dépendances et la taille de l'image de production, et implémenter des restrictions de privilèges (exécution en utilisateur non-root).
