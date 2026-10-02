# Utilisation de l'image officielle GLPI comme base de notre image personnalisée
FROM glpi/glpi:latest

# Exemple d'optimisation / personnalisation requise par l'énoncé :
# Déclaration de la langue par défaut en français pour l'environnement
ENV GLPI_LANG=fr_FR

# Indique que le conteneur écoute sur le port 80
EXPOSE 80
