# Intégration continue avec GitLab
_Nicolas, BERTRAND_

_Le-Point-Technique_, _Janvier/2022_

__abstract__: GitLab est une plateforme de développement open source dédiée à la gestion de project informatique. De la gestion de version du code source, en passant par son tableau de bord permettant de suivre les tâches en cours ou encore par la définition précise des rôles de chaque membre de l'équipe, GitLab offre un grand nombre de fonctionnalités qui facilitent le travail collaboratif. Dans ce tutoriel, je vais tenter d'expliquer quelques notions techniques et fournir des extraits de code en me concentrant sur l'aspect intégration continue. Pour ce faire, je vais utiliser la plateforme DevOps accessible en ligne à l'adresse [gitlab.com](https://about.gitlab.com). L'objectif est de créer un pipeline d'intégration continue contenant quatre étapes d'automatisation, à savoir, l'étape de 'build', de 'unit test', de 'code coverage' et de 'code quality'.

__keywords__: pipeline CI, intégration continue, GitLab, build, unit test, code coverage, code quality, Spring, Maven

## Introduction
Afin de garantir une certaine compréhension, je vais commencer par décrire quelques concepts, en fournissant la définition des mots clés utilisés sur la plateforme GitLab. Je vais poursuivre avec un mot sur l'installation de l'outil et sur la création d'un nouveau projet. Enfin, je vais expliquer comment mettre en place le pipeline en fournissant d'abord un exemple basique, puis des exemples plus complets de manière à créer notre pipeline d'intégration continue.

## Concepts clés
Dans cette partie, je vais définir le vocabulaire employé pour ce tutoriel d'un point de vue utilisateur de la solution GitLab.

### Intégration continue
L'intégration continue est une pratique qui consiste à mettre en place un ensemble de vérifications qui se déclenche automatiquement lorsque les développeurs envoient les modifications apportées au code source, lui même stocké dans un dépôt Git, dans notre cas sur un serveur GitLab. L'exécution de scripts automatiques permet de réduire le risque d'introduction de nouveau bug dans l'application et de garantir que les modifications passent tous les tests et respectent les différentes normes qualitatives exigées pour un projet.

### Job
Un _job_ est une tâche regroupant un ensemble de commandes à exécuter.
### Job Artifacts
L'exécution d'un job peut produire une archive, un fichier, un répertoire. Ce sont des artefacts que l'on peut télécharger ou visualiser en utilisant l'interface utilisateur de GitLab.

### Pipeline
Représente le composant de plus haut niveau. Il est composé de _Jobs_ (tâches), qui définissent ce qu'il faut faire, et de _Stages_ (étapes) qui définissent quand les tâches doivent être exécutées. Dans notre cas, les quatre Stages que nous allons mettre en place sont 'build', 'unit-test', 'coverage' et 'quality'.

### Gitlab Runners
Gitlab Runner est une application qui prend en charge l'exécution automatique des builds, tests et différents scripts avant d'intégrer le code source au dépôt et d'envoyer les rapports d'exécutions à GitLab. Ce sont des processus qui récupèrent et exécutent les jobs des pipelines pour GitLab. Nous allons utiliser les _Shared Runners_ pour notre exemple. Ils sont mis à disposition à travers la plateforme.

### Gitlab Server
Le serveur GitLab est un serveur web qui fournit à l'utilisateur des informations sur les dépôts git hébergés dans son espace. Il a essentiellement deux fonctions. Il contient le dépôt git et il contrôle les runners.

## Installation
Une inscription à l'offre gratuite de GitLab permet de profiter des fonctionnalités de la solution SaaS sans configuration technique ni téléchargement ou installation. Cela dit, il est important de préciser que tous les nouveaux inscrits, à compter du 17 Mai 2021 doivent fournir une carte de paiement valide afin d'utiliser les shared runners de GitLab.com (voir [article](https://about.gitlab.com/blog/2021/05/17/prevent-crypto-mining-abuse/)). L'objectif de cette décision est de mettre fin aux consommations abusives des minutes gratuites de pipeline offertes par GitLab pour miner des crypto-monnaies. Si vous ne pouvez pas fournir ces informations vous avez la possibilité d'installer un runner sur votre machine (voir [documentation](https://docs.gitlab.com/runner/install/)).


## Création d'un nouveau projet
Une fois inscrit et connecté nous pouvons créer un nouveau projet (voir _Figure 1_ ci-dessous). Remplissez les champs avec les informations de votre choix.

> ![image](images/figure1.png)
>
> _Figure 1: Page de création d'un nouveau projet_

Gitlab crée un repository vide  (voir _Figure 2_ ci-dessous) et nous indique les commandes git à executer  (voir _Figure 3_ ci-dessous) afin de poursuivre la création du projet.

> ![image](images/figure2.png)
>
> _Figure 2: Page d'accueil du nouveau projet vide'_

> ![image](images/figure3.png)
>
> _Figure 3: Commandes git à exécuter_

## Création du pipeline
Nous allons maintenant construire le pipeline et mettre en place les différents jobs. Pour continuer cette présentation, je vais utiliser le projet accessible à cette [adresse](https://gitlab.com/cocowaterswing/ocr-p11-medhead-poc) (voir _Figure 4_ ci-dessous). Tous les extraits de code et figures qui vont suivre sont tirés de ce projet, réalisé dans le cadre d'une formation qualifiante de la plateforme [OpenClassrooms](https://openclassrooms.com/fr/). Il s'agit de plusieurs applications Spring Boot, qui utilisent l'outil Maven et le langage Java.

> ![image](images/figure4.png)
>
> _Figure 4: Repository du projet MedHead_

### .gitlab-ci.yml, exemple simple
Afin de paramétrer un pipeline sur la plateforme GitLab, nous devons commencer par créer un fichier .gitlab-ci.yml à la racine de notre repository. Ce fichier est organisé autour de deux notions importantes, les _stages_ et les _jobs_. Les stages indiquent le nom et l'ordre d'exécution des jobs, qui sont eux-mêmes attachés à un stage. L'extrait de code ci-dessous montre une écriture minimale du fichier.

```yml
stages:
  - build
  - test

build-job:
    stage: build
    script:
        - echo "Le projet build..."

test-job:
    stage: test
    script:
        - echo "Les tests s'exécutent..."

```

Maintenant que le fichier est créé nous pouvons effectuer un commit, cette action va démarrer l'exécution automatique du pipeline, que nous pouvons suivre dans l'onglet _Pipelines_ de l'interface (voir _Figure 5_ ci-dessous). Le pipeline peut avoir différents états, _running_ quand il est en cours d'exécution puis, _passed_ ou _failed_, qui indiquent respectivement que l'exécution s'est déroulée sans erreur ou, au contraire, qu'elle est stoppée car des erreurs ont été trouvées.

> ![image](images/figure5.png)
>
> _Figure 5: Exécution du pipeline_

### .gitlab-ci.yml, build et tests unitaires

Voyons maintenant un extrait du code permettant de compiler puis d'exécuter les tests de l'application _emergency_ du projet MedHead.

```yml
image: maven:latest # J'ajoute l'image docker que le runner va utiliser pour exécuter mes scripts

stages:
  - build
  - unit-test

build-ms-emergency:
  stage: build
  script:
    - cd emergency
    - ./mvnw compile # Commande maven pour compiler le code source du projet

unit-test-ms-emergency:
  stage: unit-test
  script:
    - cd emergency
    - ./mvnw surefire-report:report # Crée un rapport d'exécution des tests au format html
  artifacts:
    when: always
    # paths permet de sauvegarder les artefacts générés pendant l'exécution du script sur le GitLab Server
    # et de les retrouver dans l'onglet browse du job ou le bouton download du pipeline
    paths:
      - emergency/target/site/surefire-report.html
    # reports:junit permet de récupérer les artefacts TEST-com.ocr.medhead.emergency.*.xml
    #afin d'intégrer les rapports dans l'onglet test des détails d'un job
    reports:
      junit:
        - emergency/target/surefire-reports/TEST-*.xml

```

Dans cet extrait de code, le mot clé _image_ indique quelle image docker doit être employée par le _runner_ pour exécuter les jobs.

Une fois le job _build-ms-emergency_ traité par le pipeline, nous pouvons visualiser le résultat du build en naviguant dans l'onglet _Jobs_ et en le sélectionnant dans la liste (voir _Figure 6_ ci-dessous).

> ![image](images/figure6.png)
>
> _Figure 6: Visualisation du résultat du build_

Le pipeline poursuit son exécution avec le job nommé _unit-test-ms-emergency_. Ce job va nous permettre d'exécuter les tests unitaires développés pour l'application _emergency_. En complément, nous allons générer un rapport que nous allons pouvoir sauvegarder grâce à l'utilisation du mot clé _artifacts_. Nous allons spécifier la fréquence de création de ce rapport avec _when_ et le sauvegarder, dans un format html avec _paths_ pour le consulter ou le télécharger ultérieurement (voir _Figure 7_ ci-dessous), et dans un format xml avec _reports:junit_ pour qu'il soit intégré dans l'interface utilisateur de Gitlab (voir _Figure 8_ ci-dessous).

> ![image](images/figure7.png)
>
> _Figure 7: Télécharger ou visualiser un rapport d'exécution des tests unitaires_

> ![image](images/figure8.png)
>
> _Figure 8: Intégration du rapport d'exécution des tests unitaires dans GitLab_

### .gitlab-ci.yml, Code Coverage

Dans l'extrait de code suivant, j'ai ajouté le stage _coverage_ et le job _coverage-ms-emergency_. Cela va nous permettre de générer automatiquement un rapport de couverture du code par les tests. Comme pour le job précédent un rapport de couverture est généré puis sauvegardé afin d'être consulté ou téléchargé ultérieurement (voir _Figure 9_ ci-dessous). L'intégration des résultats du rapport dans l'interface GitlLab n'est pas abordée dans ce tutoriel. Si vous le souhaitez vous trouverez les informations nécessaires pour activer cette visualisation à cette [adresse](https://docs.gitlab.com/ee/user/project/merge_requests/test_coverage_visualization.html#maven-example).

```yml
image: maven:latest

stages:
  - build
  - unit-test
  - coverage

build-ms-emergency:
  ...

unit-test-ms-emergency:
  ...

coverage-ms-emergency:
  stage: coverage
  script:
    - cd emergency
    # Le plugin JaCoCo (Java Code Coverage) génère un rapport de couverture du code source par les tests
    - ./mvnw jacoco:report
  artifacts:
    when: always
    # paths permet de sauvegarder les artefacts générés pendant l'execution du script sur le GitLab Server
    # et de les retrouver dans l'onglet browse du job ou download du pipeline
    paths:
      - emergency/target/site/jacoco/
```

> ![image](images/figure9.png)
>
> _Figure 9: Rapport html généré par JaCoCo_

### .gitlab-ci.yml, Code Quality

Dans ce paragraphe, je vais décrire la dernière phase de notre pipeline d'intégration continue, le stage _quality_.
Pour l'exécution du job _code_quality_job_ nous allons utiliser une _image_ docker, différente de l'image maven utilisée jusqu'à maintenant.
Une chose intéressant à remarquer est le mot clé _services_ qui spécifie _docker:stable-dind_. Le _dind_ signifie Docker in Docker et veut dire que le runner va utiliser Docker comme _executor_, pour exécuter les scripts, et que le script utilise lui même une image Docker de Code Climate afin de créer un rapport sur la qualité du code source. Nous ajoutons le plugin _SonarJava_, un analyseur de code qui nous permet de détecter les code smells, bugs et failles de sécurité. Pour activer ce plugin nous créons un fichier nommé _.codeclimate.yml_ à la racine du projet. Ce fichier nous permet non seulement d'activer le plugin mais aussi d'exclure les répertoires _mvn_, _test_ et _target_ de l'analyse.
Une fois terminé, comme pour les autres jobs, un artefact est créé et peut être téléchargé ou visualisé dans un navigateur (voir _Figure 10_ ci-dessous).

> _.gitlab-ci.yml_
```yml
image: maven:latest

stages:
  - build
  - unit-test
  - coverage
  - quality

build-ms-emergency:
  ...

unit-test-ms-emergency:
  ...

coverage-ms-emergency:
  ...

code_quality_job:
  stage: quality
  image: docker:stable
  services:
    - docker:stable-dind
  script:
    - mkdir codequality-results
    - docker run
      --env CODECLIMATE_CODE="$PWD"
      --volume "$PWD":/code
      --volume /var/run/docker.sock:/var/run/docker.sock
      --volume /tmp/cc:/tmp/cc
      codeclimate/codeclimate analyze -f html > ./codequality-results/index.html
  artifacts:
    paths:
      - codequality-results/

```

> _.codeclimate.yml_
```yml
plugins:
  sonar-java:
    enabled: true
    config:
      sonar.java.source: "17"
exclude_patterns:
  - "**/.mvn/"
  - "**/target/"
  - "**/test/"
```

> ![image](images/figure10.png)
>
> _Figure 10: Rapport html généré par Code Climate_

## Conclusion
Dans cette présentation, nous avons vu comment construire un pipeline d'intégration continue avec GitLab. Les différentes étapes du pipeline nous permettent dorénavant de récupérer des rapports sur l'exécution des tests unitaires, sur la couverture du code par les tests et sur la qualité du code source de notre projet. Cette configuration peut évidemment être améliorée. Elle constitue une base de travail à laquelle nous pouvons par exemple ajouter des tests d'intégration mais aussi une étape de création de conteneur pour nos applications afin de compléter d'autres aspects DevOps, comme la mise en production automatisée de nos applications.

## References

https://docs.gitlab.com/ee/ci/pipelines/job_artifacts.html <br/>
https://docs.gitlab.com/ee/ci/quick_start/ <br/>
https://docs.gitlab.com/ee/ci/yaml/gitlab_ci_yaml.html <br/>
https://docs.gitlab.com/ee/user/project/merge_requests/code_quality.html <br/>
https://docs.gitlab.com/ee/ci/docker/using_docker_build.html#use-the-docker-executor-with-the-docker-image-docker-in-docker <br/>
https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html <br/>
https://maven.apache.org/surefire/maven-surefire-report-plugin/report-mojo.html <br/>
https://www.jacoco.org/jacoco/trunk/doc/maven.html <br/>
https://docs.codeclimate.com/docs/sonar-java