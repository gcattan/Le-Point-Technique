\setcounter{figure}{0}

# Outils de collaboration web : Etude exploratoire

_LeFrançois, Marc_

_Le-Point-Technique_, _January/2023_

__abstract__: blablablablabla

__keywords__: bla1, bla2

## Démarche exploratoire
La démarche de l’étude exploratoire a été réalisée selon les étapes suivantes :
- *Options du marché* : pour déterminer quelles sont les solutions offertes par le marché.
- *Options architecturales* : pour déterminer les options architecturales disponibles, et définir la 
composition architecturale la plus pertinente à la réponse du besoin.
- *Solution retenue* : pour déterminer les options de solutions, et définir celle permettant de répondre 
au besoin.


## Options du marché
Cette étude a pour objectif d’étudier et de comparer les solutions offertes par le marché, dans le but de 
déterminer si une ou plusieurs solutions pourraient répondre au besoin d’outils collaboratifs.

Elle permettra également l’étude fonctionnelle desdits outils collaboratifs, pour déterminer les solutions qui 
sont nécessaires et pertinentes pour chacun d’eux.

### Outil de visioconférence
En ce qui concerne l’outil de visioconférence, les solutions suivantes ont été étudiées :
- *Cisco WebEx Meetings (Webex Suite)* de la société Cisco ;
- *Zoom* de la société Zoom Video Communications ;
- *Solution applicative* de la société Google Inc.
- *Microsoft Teams* de la société Microsoft ;
- *NextCloud Talk* de la communauté NextCloud Gmbh. ;
- *Jitsi* de la société Atlassian.

#### Cisco WebEx Meetings (Webex Suite)
#### Zoom
#### Solution applicative Google
#### Microsoft Teams
#### NextCloud Talk
#### Jitsi

### Outil de partage de fichiers 
En ce qui concerne l’outil de partage de fichiers, les solutions suivantes ont été étudiées :
- *Google Drive* de la société Google Inc.
- *NextCloud Files* de la communauté NextCloud Gmbh. ;
- *SharePoint* de la société Microsoft ;
- *Liferay* de la société éponyme.

#### Google Drive
#### NextCloud Files
#### SharePoint
#### Liferay
### Conclusion
Au regard des solutions étudiées, des besoins, des contraintes et spécifiés de chacune des solution, 
trois d’entre elles ont été retenues :
- *Jitsi* et *NextCloud Talk* pour l’outil de visioconférence.
2. *NextCloud Files* pour l’outil de partage de fichiers.

Les autres solution n’ont pu être retenues dans la mesure où ce sont des solutions ne s’intégrant pas 
dans le système, mais fonctionnant en marge de celui-ci. De plus, elles ne répondent pas aussi bien aux 
besoins et contraintes du projet que ceux qui ont été retenus.

## Options architecturales
Il s’agit ici d’étudier et de déterminer quelle composition architecturale est la plus pertinente pour répondre au 
besoin d’outils de visioconférence et de partage de fichier, dans le cas où l’on choisirait de développer nous-même la solution ou spécialiser une solution existante que nous souhaiterions intégrer à notre système actuel.

### Critères architecturaux
Ci-dessous les critères définissant une architecture de référence, et sur lesquels l’évaluation architecturale a 
été basée.

#### Évolutivité
#### Simplicité
#### Maintenabilité 
#### Compatibilité
#### Interconnectivité 

### Options architecturales
Il s’agit ici avant tout de déterminer quelles sont les architectures logicielles qui sont à notre disposition 
et qui pourraient convenir aux outils de visioconférence et de partage de fichiers, s’il était décidé de 
faire nous même le développement.

#### Typologie architecturale
#### Architecture client-serveur
#### Architecture pilotée par les évènements
#### Architecture orientée services
#### Architecture modulaire
#### Architecture en couches 
#### Architecture centrée sur les données

### Architecture cible de visioconférence 
Cette section détermine l’architecture cible la mieux adaptée à l’outil de visioconférence, parmi les six 
modèles standards d’architecture défini dans la section précédente.

#### Architectures non retenues
#### Architecture retenue

### Architecture cible de partage de fichiers 
Cette section détermine l’architecture cible la mieux adaptée à l’outil de partage de fichiers, parmi les 
six modèles standards d’architecture défini dans la section précédente.

#### Architectures non retenues
#### Architecture retenue

## Option retenue
Globalement deux choix s’offre à nous :
- Celui de la solution interne, id. de développer nous même les outils de visioconférence et de partage 
de fichiers.
- Celui de la solution externe, id. d’utiliser une solution en partie pré-faite à implémenter en tant que 
composante du système actuel

### Comparatif des options

Ci-dessous la comparaison entre solution interne et externe.

#### Solution interne
#### Solution externe
#### Conclusion
Au regard des éléments de comparaison, notamment sur le coût, le délai et la facilité de déploiement, 
ainsi que sur la réponse aux besoins et contraintes du projet, le choix doit s’orienter sur une solution 
externe. En effet, la société Astra n’a pas pour vocation d’être une société éditrice de logiciel, et n’a 
donc aucune raison d’investir autant, financièrement et en temps, et ni aucune prétention à se 
substituer aux références du marché. D’autant plus que certaines solutions permettent une grande 
spécialisation aux besoins et contraintes de leurs clients / utilisateurs.

### Autre comparaison
Ci-dessous une autre comparaison à titre informatif entre une solution propriétaire et open source.

#### Propriétaire
#### OpenSource
#### Conclusion
Au regard des éléments de comparaison, notamment sur le coût, l’autonomie d’implémentation et 
de maintenance, et donc sur la nécessité de répondre au plus juste aux besoins et contraintes du 
projet, le choix doit s’orienter sur une solution OpenSource. En effet, une solution propriétaire nous 
rendrait trop dépendant, autant sur l’implémentation que la maintenance, et notamment en cas de 
bugs majeurs. De plus, l’accès au code permet une bien plus grande et meilleure spécialisation des 
fonctionnalités, qu’une solution propriétaire qui est de facto plus limitée. Même si le coût de 
déploiement OpenSource est généralement plus élevé, qu’une solution propriétaire, celui-ci est très 
largement compensé par le coût de la solution OpenSource, qui ne comprend généralement que le 
support ; id. pas de loyer de licence à payer.

### Choix final

Pour résumé, le choix doit s’orienter sur une solution externe et OpenSource. 
Aussi, ce choix offre à la société Astra, le meilleur des deux mondes, à savoir celui du développement 
spécifique sans pour autant réinventer la roue et sans les délais inhérents, et celui de la solution touten-un, sans le coût inhérent au prix des licences, et sans la dépendance fournisseur, tout en gardant les 
données entreprise dans son giron.
En conclusion de l’étude de marché, nous avons retenue trois solutions pour nos 
besoins d’outils de visioconférence et de partage de fichiers, et correspondant à notre besoin :
- Visioconférence :
    - Jitsis
    - NextCloud Talk
- Partage de fichiers :
    - NextCloud Files
Pour des raisons évidentes de rationalisation de coût et de simplicité, le choix doit se porter sur la 
solution *NextCloud*, solution tout-en-un répondant à l’ensemble de notre besoin.

Check this link [link](google.fr).

Please check _Figure 1_

> ![legend](https://user-images.githubusercontent.com/6229031/142882134-04839c93-ce4d-4af5-88f6-97feb5cf7373.png)
> <pre>
> Figure 1: legend
> </pre>

I am joining table either as a figure or using [pandoc tables](https://pandoc.org/MANUAL.html#tables).

Please check _Table 1_. Note the hack with the lack of closing `</pre>` tag,
enforcing tables to be rendered as text in markdown (and in the same time not be ignored by pandoc).

_Table 1: legend_

<div><pre>
+---------------+---------------+
| Fruit         | Price         | 
+===============+===============+
| Bananas       | $1.34         |
|               |               |
+---------------+---------------+
| Oranges       | $2.10         |
|               |               |
+---------------+---------------+
</div>

Here is an awesome list:

- first item

- second item

### Subsection II
## Section II

## References

Use the Chicago Manual of Style 17th Edition (full note), e.g.:

‘Web API Fuzz Testing | GitLab’. Accessed 29 June 2022.
[https://docs.gitlab.com/ee/user/application_security/api_fuzzing/](https://docs.gitlab.com/ee/user/application_security/api_fuzzing/).
