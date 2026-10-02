# Projet I347 - Déploiement de GLPI avec des conteneurs

## Introduction / But du projet
L'objectif de ce projet est le déploiement de GLPI grâce à Docker et Docker Compose. 

GLPI est un outil d'inventaire et de gestion de parc informatique. L'application est découpée en micro-services qui composent la stack (web, bd...).

## Architecture
L'infrastructure s'appuie sur des micro-services interconnectés et inclut la gestion de la persistance via des volumes :
* **Service Web :** Image `glpi/glpi`
* **Service Base de données :** Image `mysql`
* **Persistance :** Utilisation de deux volumes : `glpi_data` et `db_data`.

### Schéma de l'architecture réseau
```text
      [ Accès Navigateur ]
               │ (http://localhost)
               ▼
┌────────────────────────────────────────┐
│         Réseau Docker Interne          │
│                                        │
│   ┌────────────────────────────────┐   │
│   │        Conteneur Web           │   │
│   │         (glpi/glpi)            │   │
│   └──────────────┬─────────────────┘   │
│                  │                     │
│                  ▼                     │
│   ┌────────────────────────────────┐   │
│   │   Conteneur Base de Données    │   │
│   │           (mysql)              │   │
│   └────────────────────────────────┘   │
└────────────────────────────────────────┘
```

## Instructions de lancement
Pour récupérer l'environnement, configurer les fichiers et lancer les conteneurs dans le dossier de travail, exécutez la suite de commandes suivantes :

```bash
# Télécharger l'image GLPI
docker pull glpi/glpi

# Télécharger les fichiers d'exemple de configuration et d'environnement
curl --fail https://githubusercontent.com --output docker-compose.yml
curl --fail https://githubusercontent.com --output .env

# Télécharger l'image MySQL requis par la configuration SQL de GLPI
docker pull mysql

# Créer et lancer les conteneurs et les volumes en arrière-plan
docker compose up -d
```

## Informations sur le réseau, la sécurité, les variables
* **Variables d'environnement :** Initialisées à partir du fichier de configuration d'exemple `.env` téléchargé depuis le dépôt officiel de glpi-project.
* **Sécurité :** 
* **Réseau :** 

## Tests effectués et résultats
* **Accès à l'application web :** Une fois les conteneurs lancés, l'accès s'effectue en ouvrant le navigateur à l'adresse `http://localhost`.
* **Authentification :** Connexion réussie à l'interface avec les identifiants par défaut :
  * **User :** `glpi`
  * **Pwd :** `glpi`

## Problèmes rencontrés / pistes d’amélioration
* **Points à valider / Améliorations :** Il reste à vérifier la persistance des données (analyser si les volumes `glpi_data` et `db_data` sont automatiquement créés ou pas par Docker Compose).
