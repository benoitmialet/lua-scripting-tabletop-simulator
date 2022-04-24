# lua-scripting-tabletop-simulator


## Apprendre à scripter

Ce dossier rassemble 8 cours pour apprendre à scripter vos modules Tabletop Simulator (TTS) en LUA. Chaque cours correspondant à 1 feuille de script commenté, et est basé sur un ou deux aspects de programmation. Vous apprendrez les méthodes de base pour effectuer des mises en place automatisées de vos jeux. Il est conseillé de se renseigner sur les concepts de base en programmation, comme par exemple :

* Qu'est ce qu'une variable ? une méthode ou une fonction ?
* A quoi sert une boucle FOR ?
* Qu'est ce qu'un test IF ?
* Qu'est ce que la programmation orientée objet ? Qu'est ce qu'un objet et comment ça marche ?
* etc


## L'éditeur de code

Il est quasi indispensable d'utiliser un éditeur de code. Cela sert à bien **indenter** son code (l'aligner pour mieux le lire et éviter des fautes), et à faire de la **reconnaissance synthaxique** (colorer son code pour mieux le lire, indispensable). Je conseille très fortement Visual Studio Code (gratuit). Installez les plugins suivants sous VSCode en cliquant sur "extensions": 
* Lua (sumneko)
* Tabletop Simulator Lua (Rolandostar)

Il est également possible d'utiliser Atom avec le plugin pour TTS. Les autres éditeurs de code n'auront pas forcément de plugin spécifique pour TTS.

Ensuite suivez les étapes suivantes sur VSC : 
1) clic droit dans la sidebar de gauche contenant les fichiers, puis choisissez "open folder in a Workspace". Choisir un dossier de destination où vous stockerez vos scripts. Le but ici est de créer un workspace. Puis le sauvegarder (click droit "Save As")

![le workspace](https://github.com/benoitmialet/lua-scripting-tabletop-simulator/blob/main/img/04.png)

2) Une fois le workspace créé et sauvegardé, c'est bon. Lancez TTS et chargez un module. 
3) depuis VSC, clic droit dans une fenêtre de script VSC  puis "get Lua Script", ou bien CTRL + ALT + L :  Les scripts de la partie en cours sont importés sur VSC
4) pour envoyer le code (de la meme fenetre) sur TTS, clic droit dans la fenêtre de script VSC puis  "Save and Play", ou bien CTRL + ALT + S 
attention  de meme que sur TTS : "save & play" recharge la dernière save TTS sur votre disque dur + le nouveau code. si vous avez modifié le mod entre temps (ajouté, déplacé les objets etc), faites une vraie sauvegarde TTS avec Game -> save game, etc. sinon les modifications du mod seront perdues.

**Si tout cela vous semble confus, vous pouvez également éditer le code sous VSC puis le copier-coller sous TTS dans la fenêtre de scripts, sauvegarder la partie et la recharger pour appliquer le script**. C'est plus long mais cela fonctionne.


## C'est à vous ! 
* Placez le module tts_cours_.json dans \Documents\My Games\Tabletop Simulator\Saves 
* Lancez TTS, chargez le module
* Ouvrez le fichier cours_tts_01.lua sous VSC !

![](https://github.com/benoitmialet/lua-scripting-tabletop-simulator/blob/main/img/tts_cours2.png)

Vous pouvez maintenant utiliser les scripts des cours #1 à #8. Chacun de ces cours est fait pour fonctionner avec ce même module de cours. Ne supprimez pas d'objet sur la table si vous tenez à ce que tout fonctionne.
Il faudra de la patience et vous exercer avec vos propres modules. **Commencez avec peu d'ambition**, en suivant les cours. Trop de fonctionnalités d'un coup peut porter à confusion dans le code et vous décourager.
A vous de jouer !

