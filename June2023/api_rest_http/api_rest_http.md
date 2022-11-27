\setcounter{figure}{0}

# Architecture: API REST & HTTP

_Evan, David_

_Le-Point-Technique_, _November/2022_

__abstract__: Le présent article vise à présenter les conventions communes à la construction des API REST. Elle est 
issue d’un ensemble de bonnes pratiques communément appliquées et d’expériences accumulées sur la 
création des API REST.

__keywords__: API, REST, HTTP


## Architecture REST

### Manipulation des ressources

Lors de la conception des API, les règles suivantes s’appliquent : 

- Les URL doivent être construites conformément aux règles & bonnes pratiques de l’architecture REST. Les identifiants des ressources doivent être passés en route param.

- Les ressources présentes dans les URLS seront systématiquement écrites au pluriel, même si une seule ressource est accessible.
_Exemple_ : `/contract/v1/contracts/123456789`

- Toutes les ressources d’un même service doivent impérativement partager un vocabulaire commun. Un champ représentant une donnée (exemple : Prix HT) doit disposer de la même “traduction”, peu importe l’API utilisé au sein de ce service et / ou le modèle utilisé, tant que la donnée possède le même sens.

### Convention de nommage des URLs

Les conventions de nommages s’appliquent principalement à la nomenclature des URLs accessibles et composant les services API.

- Utilisation de la convention de nommage [Kebab Case](https://medium.com/better-programming/string-case-styles-camel-pascal-snake-and-kebab-case-981407998841). 

- Utilisation de la langue __anglaise__ pour le nommage des services, fonctions, attributs, ressources …

- Des __ressources__ (et non des fonctions) doivent être utilisés dans les URLs (exemple `/contracts` et non `/getallcontracts`)

- Le nom des attributs composant une ressource devrait être différent des noms des champs de la base de données auxquels ils font référence

## Utilisation HTTP

### Verbes HTTP

L’utilisation des verbes HTTP devra respecter la spécification ci-dessous, et, plus généralement, le sens de chaque méthode HTTP tel que décrit dans la [section 4.3 de la RFC 7231](https://tools.ietf.org/html/rfc7231#section-4.3) (_Table 1_)

_Table 1: Utilisation des verbes HTTP pour la construction des APIs_

<div><pre>
+--------+----------------------------------------+
| Verbe  | Description                            |
+========+========================================+
| PUT    | Modification totale d’une ressource    |
+--------+----------------------------------------+
| POST   | Création une ressource                 |
+--------+----------------------------------------+
| PATCH  | Modification partielle d’une ressource |
+--------+----------------------------------------+
| GET    | Récupération d’une ressource           |
+--------+----------------------------------------+
| DELETE | Suppression d’une ressource            |
+--------+----------------------------------------+
</div>

### Entêtes HTTP
Pour chaque réponse retournée, celle-ci doit inclure, à minima : 

- La description du format de réponse : Ajout de l’entête `Content-Type`

- La définition de l’encodage utilisé : Ajout de l’entête `Charset` 

### Code statut HTTP
L’utilisation des codes de retour HTTP devra respecter la spécification suivante, et, plus généralement, le 
sens de chaque code de retour tel que décrit dans la [section 6 de la RFC 7231](https://tools.ietf.org/html/rfc7231#section-6) (_Table 2_)

_Table 2: Utilisation des codes de statut dans les réponses HTTP_

<div><pre>
+-------+--------------------------------------------------------------------------------------------------------------------------------------------------+
| Code  | Description                                                                                                                                      |
+=======+==================================================================================================================================================+
| 2xx   | Succès                                                                                                                                           |
+-------+--------------------------------------------------------------------------------------------------------------------------------------------------+
|   200 | Succès. Des informations de retour sont disponibles.                                                                                             |
+-------+--------------------------------------------------------------------------------------------------------------------------------------------------+
|   201 | Succès. Une ressource a été créée. Généralement, la réponse contient la ressource qui vient d'être créée.                                        |
+-------+--------------------------------------------------------------------------------------------------------------------------------------------------+
|   204 | Succès. La réponse ne contient aucune donnée.                                                                                                    |
+-------+--------------------------------------------------------------------------------------------------------------------------------------------------+
| 4xx   | Échec à cause d’un problème dans la requête (exemple : création d’un utilisateur avec un e-mail déjà existant ou paramètre de requête manquant). |
+-------+--------------------------------------------------------------------------------------------------------------------------------------------------+
| 5xx   | Échec dû à une erreur du serveur                                                                                                                 |
+-------+--------------------------------------------------------------------------------------------------------------------------------------------------+
</div>

## Convention de création pour les API
Afin de maintenir une cohérence forte entre tous les services, certains besoins doivent utiliser une syntaxe 
commune décrite ci-dessous. 

### Règles communes
Le résultat de la requête devra toujours être retourné dans le champ `data` d’un objet JSON. Les 
autres attributs peuvent servir à ajouter des métadonnées à la requête.

### API Paginées
Les API paginées acceptent toujours deux paramètres optionnels :

- page - Numéro de la page à retourner (défaut : 1)

- size - Nombre de résultats par page à retourner (défaut : dépend de l’API, généralement 20)
Il doit être possible de manipuler ces paramètres pour obtenir les pages suivantes ou augmenter le 
nombre de résultat dans une seule page.

### API de recherche
Dans le cas d’une API permettant d’effectuer une recherche (Recherche exclusive) sur une ressource :

- Il doit être possible, en spécifiant des valeurs en `query params`, de filtrer les résultats 
uniquement sur un critère précis de la ressource.
 _Exemple_ : `users/?email=john.doe@contoso.com` - Liste des utilisateurs dont le nom 
est égal à la valeur indiquée.

- Les arguments de recherches de type string peuvent être préfixés/suffixés d'un `*` pour rendre la 
recherche non-limitative.
 _Exemple_ : `users/?username=Sandbob*` - Tous les utilisateurs dont le nom commence par 
"Sandbob".

- Une logique similaire existe pour les champs de type date, avec les préfixes : `<` et `>`.
 _Exemple_ : `users/?createdAt>=2020-01-15` - Tous les utilisateurs créés après le 
15/01/2015.

Il est aussi possible de créer des APIs permettant de sélectionner un ensemble de ressources, 
correspondant aux différentes valeurs des éléments indiqués dans les query params de la requête HTTP 
(Recherche inclusive). 

- Une syntaxe basée sur des crochets (`[]`) permet de spécifier la liste des différentes valeurs 
séparées par des virgules (,).
 _Exemple_ : `contracts/?id=[1124521,1124550,2102450]` - Obtient une liste des 
contrats indiqués.

- Une syntaxe supplémentaire peut être implémentée, permettant une sélection sur un range de 
valeurs, en utilisant le séparateur "`..`".
_Exemple_ : `users/?id=[1..5]` (Les utilisateurs dont l'id est contenu entre 1 et 5).

### Authenticated API
Certains services API doivent disposer de end-points adaptant leur retour en fonction du contexte 
d’identité véhiculé à travers le jeton d’authentification. Dans ce scénario, les API doivent répondre aux 
règles suivantes :

- L’url contient toujours, juste après le nom du service API et de sa version, le nom de l’identité 
utilisée.
 _Exemple_ : `/user/contracts` - Les contrats de l’utilisateur xxx. 

- Le nom de l’identité doit être au singulier.

- Une authentification de type `Authorization Code` ou `Resource Owner Password Credential` est requise.

- Une erreur `401` (`Unauthorized`) doit être levée si le jeton ne contient pas d’identité ou que 
celle-ci ne peut pas être vérifiée via le serveur d’autorisation. 

## Données manipulées par les services

### Format d'échange

Les règles suivantes s’appliquent concernant les données des services API :

- Les services API doivent être conçus pour accepter des données d’entrée au format 
`application/json`. 

- Les données retournées par les services API doivent être au format `application/json`.

Par ailleurs, les formats suivants doivent être toujours respectés (en entrée comme en sortie) (_Table 3_).

_Table 3: Format d'échanges des données au sein des APIs_

<div><pre>
+----------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------+-------------------------------+
| Type de donnees      | Format attendu                                                                                                                                            | Stockage BDD                  |
+======================+===========================================================================================================================================================+===============================+
| Dates & heures       | Date conforme à la RFC 3339. _Exemple_ : `2005-08-15T15:52:01+01:00`                                                                                      | `DATETIME`                    |
+----------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------+-------------------------------+
| Chaîne de caractères | Les `strings` doivent toujours être : - Débarrassées des espaces blancs inutiles (trim) - Utiliser le `null` si elles sont vides, sauf contrainte métier. | Variable (`VARCHAR`, `TEXT`…) |
+----------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------+-------------------------------+
| Nombre               | Les nombres doivent être représentés sous la forme `integer` ou `float` et non de chaîne de caractères.                                                   | Variable (`INT`, `NUMERIC`…)  |
+----------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------+-------------------------------+
| Booléen              | Les booléens doivent être échangés sous leur forme originelle : `true` et `false`. L’utilisation du `0` ou `1` est proscrite.                             | `BIT`                         |
+----------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------+-------------------------------+
| Mot de passe         | Les mots de passe doivent être hachés en utilisant l’algorithme `SHA256`                                                                                  | Variable (`VARCHAR`, `TEXT`…) |
+----------------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------+-------------------------------+
</div>

### Gestion des Entrées/Sorties

#### Contrôles d’intégrité des données

#### Manipulation des données par les services API

## Gestion des erreurs

### Normalisation de la sortie d’erreur (API Problem)

## Stockage des erreurs (logs)

_Table 4: Liste des codes erreurs - Syslog Protocol_

<div><pre>
+------+---------------+--------------------------------------------------------------------------+
| Code | Gravite       | Description                                                              |
+======+===============+==========================================================================+
| 0    | Emergency     | Système inutilisable.                                                    |
+------+---------------+--------------------------------------------------------------------------+
| 1    | Alert         | Une intervention immédiate est nécessaire.                               |
+------+---------------+--------------------------------------------------------------------------+
| 2    | Critical      | Erreur critique pour le système.                                         |
+------+---------------+--------------------------------------------------------------------------+
| 3    | Error         | Erreur de fonctionnement.                                                |
+------+---------------+--------------------------------------------------------------------------+
| 4    | Warning       | Avertissement (une erreur peut intervenir si aucune action n'est prise). |
+------+---------------+--------------------------------------------------------------------------+
| 5    | Notice        | Événement normal méritant d'être signalé.                                |
+------+---------------+--------------------------------------------------------------------------+
| 6    | Informational | Pour information.                                                        |
+------+---------------+--------------------------------------------------------------------------+
| 7    | Debugging     | Message de debug.                                                        |
+------+---------------+--------------------------------------------------------------------------+
</div>

## Version des API

### Version d’une API

### Teneu d'un CHANGELOG

## Documentation API

## Introduction

```
{
    "title": "string",
    "type": "string",
    "status": int
}
```

## References

https://medium.com/better-programming/string-case-styles-camel-pascal-snake-and-kebab-case-981407998841

https://tools.ietf.org/html/rfc7231#section-4.3
