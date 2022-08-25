# lua-scripting-tabletop-simulator


## Apprendre à scripter
Ce dossier rassemble 8 cours pour apprendre à scripter vos modules Tabletop Simulator (TTS) en LUA. Chaque cours correspondant à 1 feuille de script commenté, et est basé sur un ou deux aspects de programmation. Vous apprendrez les méthodes de base pour effectuer des mises en place automatisées de vos jeux. Il est conseillé de se renseigner sur les concepts de base en programmation, comme par exemple :

* Qu'est ce qu'une variable ? une méthode ou une fonction ?
* A quoi sert une boucle FOR ?
* Qu'est ce qu'un test IF ?
* Qu'est ce que la programmation orientée objet ? Qu'est ce qu'un objet et comment ça marche ?
* etc



## Installer Visual Studio Code et essayez les scripts du cours

Pour scripter, il est quasi indispensable d'utiliser un éditeur de code. Cela sert à bien indenter son code (l'aligner pour mieux le lire et éviter des fautes) et à faire de la reconnaissance syntaxique (colorer son code pour mieux le lire, indispensable). Je conseille très fortement Visual Studio Code (gratuit). Il est possible d'utiliser Atom avec le plugin pour TTS (bien que chez moi il fonctionne mal), mais je ne pourrai pas vous aider en cas de problème. Les autres éditeurs de code n'auront pas forcément de plugin spécifique pour TTS.

### 1) Télécharger et installer VSCode
https://code.visualstudio.com/

### 2) Installer les plugins
Installez les plugins suivants sous VSCode en cliquant sur "extensions":
* Lua (sumneko)
* Tabletop Simulator Lua (Rolandostar)

### 3) création du Workspace
Cette étape permet de relier VSCode à TTS. Ainsi, plus besoin de copier coller son code sous TTS.
Suivez les étapes suivantes : 

* Créez un dossier dans lequel vous mettrez tout vos scripts
* Dans "Fichiers" choisissez "Add folder to Workspace".Choisir le dossier précédemment créé.
Une fois le workspace créé et sauvegardé, c'est tout bon. 
![le workspace](https://github.com/benoitmialet/lua-scripting-tabletop-simulator/blob/main/img/04.png)

### 4) Tester le tout !
* Lancez une nouvelle partie sous TTS. Sauvegardez-la, puis chargez-la (oui oui).
* Sur VSCode, cliquez "Fichier" -> "New text file"
* clic droit au milieu de la fenêtre de script VSC puis **"Get Lua Script"**, ou bien **CTRL + ALT + L** : Les scripts de la partie en cours sont directement importés sur VSC.
* écrivez print('ça fonctionne') quelque part dans la fonction onLoad()
* Envoyez le code (depuis cette fenêtre) sur TTS en faisant clic droit dans la fenêtre de script VSC puis **"Save and Play"**, ou bien **CTRL + ALT + S**. 
**Attention** de meme que sur TTS : "save & play" recharge la dernière sauvegarde TTS sur votre disque dur + le nouveau code. si vous avez modifié le module entre temps (ajouté, déplacé les objets etc), faites une vraie sauvegarde TTS avec Game -> save game, etc. sinon les modifications du mod seront perdues.
*Si vous voyez apparaître "coucou" dans la console de Chat, alors tout fonctionne et vous êtes fin prêt(e). 

### 5) Charger les scripts des cours et les essayer
* Placez le module tts_cours.json dans \Documents\My Games\Tabletop Simulator\Saves
* Lancez TTS, chargez le module tts_cours
* Ouvrez par exemple cours_tts_01.lua sous VSC !
* Refaites la manip expliquée en 4) : Get Lua Script ou  CTRL+ATL+L
* Copiez collez un des cours dans la fenêtre Global
* Lancez le avec CTRL+ATL+S. Un ou plusieurs boutons doivent apparaître sur des objets.

![](https://github.com/benoitmialet/lua-scripting-tabletop-simulator/blob/main/img/tts_cours2.png)

Vous pouvez maintenant utiliser les scripts des cours #1 à #8. Chacun de ces cours est fait pour fonctionner avec ce même module de cours. Ne supprimez pas d'objet sur la table si vous tenez à ce que tout fonctionne. Il faudra de la patience et vous exercer avec vos propres modules. Commencez avec peu d'ambition, en suivant les cours. Trop de fonctionnalités d'un coup peut porter à confusion dans le code et vous décourager. 

A vous de jouer !
