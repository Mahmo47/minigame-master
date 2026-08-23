# Snake User Guide

Diese Anleitung ist dafür da, das Spiel direkt in Godot zu testen.

## Was du brauchst

- Godot 4.x
- den Ordner mit den Dateien aus diesem Projekt

## So startest du das Spiel

1. Öffne Godot.
2. Importiere den Projektordner.
3. Öffne die Szene [snake_game.tscn](snake_game.tscn).
4. Drücke auf Play Scene oder F6.

Wenn du nur eine Script-Datei testen willst, kannst du auch eine neue `Node2D`-Szene anlegen und [snake_game.gd](snake_game.gd) daran hängen.

## Steuerung

- Pfeil nach oben, unten, links, rechts: Schlange steuern
- Enter: Nach Game Over neu starten

## Was du im Spiel sehen sollst

- Die Wände sehen wie eine Burg aus.
- Die Schlange sieht wie ein Skelettdrache aus.
- Die Frucht wechselt zufällig zwischen goldenem Apfel, Kiwi und Kirsche.
- Oben links werden Punkte, Tempo und Länge angezeigt.

## Spielregeln

- Jede gefressene Frucht gibt 1 Punkt.
- Alle 10 Sekunden wird das Spiel etwas schneller.
- Das Tempo steigt bis maximal auf das 5-fache.
- Die Schlange wächst nur bis zur festgelegten Maximal-Länge.
- Danach bleibt sie gleich lang, damit du theoretisch sehr lange weiterspielen kannst.

## Wenn etwas nicht funktioniert

- Prüfe, ob du wirklich die Szene [snake_game.tscn](snake_game.tscn) startest.
- Prüfe, ob Godot 4.x verwendet wird.
- Prüfe, ob die Eingabebelegung `ui_up`, `ui_down`, `ui_left`, `ui_right` und `ui_accept` vorhanden ist.
