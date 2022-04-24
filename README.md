# lua-scripting-tabletop-simulator


## Apprendre à scripter

Ce dossier rassemble 8 cours pour apprendre à scripter vos modules Tabletop Simulator (TTS) en LUA. Chaque cours correspondant à 1 feuille de script commenté, et est basé sur un ou deux aspects de programmation. Vous apprendrez les méthodes de base pour effectuer des mises en place automatisée de vos jeux. Il est conseillé de se renseigner sur les concepts de base en programmation, comme par exemple :

* Programmation orientée objet
* Qu'est ce qu'une variable ? une méthode ou fonction ?
* A quoi sert une boucle FOR ?
* Qu'est ce qu'un test IF ?
* etc


## L'éditeur de code

Il est quasi indispensable d'utiliser un éditeur de code. Je conseille très fortement Visual Studio Code (gratuit). Installez les plugins suivants sous VSCode en cliquant sur "extensions": 
* Lua (sumneko)
* Tabletop Simulator Lua (Rolandostar)

Il est également possible d'utiliser Atom avec le plugin pour TTS. Les autres éditeurs de code n'auront pas forcément de plugin spécifique pour TTS.

Ensuite suivez les étapes suivantes : 
1) click droit dans la sidebar de gauche contenant les fichiers, puis choisissez "open folder in a Workspace". Choisir un dossier de destination où vous stockerez vos scripts. Le but ici est de créer un workspace. Puis le sauvegarder (click droit "Save As")
2) Une fois le workspace créé et sauvegardé, c'est bon. On lance TTS et on charge un module. 
3) depuis VSC, clic droit dans une fenêtre de script VSC  puis "get Lua Script", ou bien CTRL + ALT + L :  Les scripts de la partie en cours sont importés sur VSC
4) pour envoyer le code (de la meme fenetre) sur TTS, clic droit dans la fenêtre de script VSC puis  "Save and Play", ou bien CTRL + ALT + S 
attention  de meme que sur TTS : "save & play" recharge la dernière save TTS sur votre disque dur + le nouveau code. si vous avez modifié le mod entre temps (ajouté, déplacé les objets etc), faites une vraie sauvegarde TTS avec Game -> save game, etc. sinon les modifications du mod seront perdues.

**Si tout cela vous semble confus, vous pouvez également éiter le code sous VSC et le copier coller sous TTS dans la fenetre de scripts, sauvegarder la partie et la relancer**. C'est plus long mais ça fonctionne.


## C'est à vous : chargez le module de cours TTS et ouvrez le cours #01 !
Vous pouvez maintenant charger le module et utiliser les scripts des cours #1 à #8. Chacun de ces cours est fait pour fonctionner avec ce même module de cours. Ne supprimez pas d'objet si vous tenez à ce que tout fonctionne.
Il faudra de la patience et vous exercer avec vos propres modules. **Commencez avec peu d'ambition**, en suivant les cours. Trop de fonctionnalités d'un coup peut porter à confusion dans le code et vous décourager.
A vous de jouer !

