# Snake-Moduldokumentation

## Überblick

Die Snake-Logik ist in vier klar getrennte Dateien aufgeteilt:

1. [snake_game.gd](snake_game.gd)
2. [snake_state.gd](snake_state.gd)
3. [snake_rules.gd](snake_rules.gd)
4. [snake_renderer.gd](snake_renderer.gd)

Zusätzlich gibt es [snake_game.tscn](snake_game.tscn) als direkt startbare Godot-Szene und [test.gd](test.gd) als alten Einstiegspunkt.

## Datei für Datei

### snake_game.gd

Diese Datei ist der Einstiegspunkt der Szene. Sie enthält die Godot-Lifecycle-Funktionen und verbindet die Module miteinander.

Wichtige Funktionen:

- `_ready()` startet das Spiel und initialisiert Schrift und Zufall.
- `start_game()` setzt den Zustand zurück und erzeugt eine neue Frucht.
- `restart_game()` startet ein frisches Spiel nach Game Over.
- `stop_game()` beendet das laufende Spiel.
- `get_score()` liefert den aktuellen Punktestand.
- `_unhandled_input()` liest die Pfeiltasten und die Enter-Taste.
- `_process()` steuert Tempo, Beschleunigung und einzelne Spielschritte.
- `_draw()` übergibt das Zeichnen an den Renderer.

Beginn und Ende der Hauptlogik:

- Der technische Startpunkt ist `_ready()`.
- Die zentrale Spielschleife ist `_process()`.
- Die visuelle Ausgabe endet in `_draw()`, weil dort nur noch gerendert wird.

### snake_state.gd

Diese Datei speichert nur Daten.

Wichtige Funktionen:

- `reset()` setzt Schlange, Richtung, Score, Timer und Geschwindigkeit zurück.
- `current_length()` gibt die aktuelle Länge der Schlange zurück.

Beginn und Ende:

- Die Datei beginnt mit den Variablen für den Spielzustand.
- Die Datei endet mit Hilfsfunktionen, die nur diesen Zustand beschreiben.

### snake_rules.gd

Diese Datei enthält die eigentlichen Regeln des Spiels.

Wichtige Funktionen:

- `set_next_direction()` verhindert das direkte Umdrehen in die eigene Körperrichtung.
- `step()` führt genau einen Bewegungs-Schritt aus, prüft Kollisionen und erhöht den Score.
- `spawn_food()` legt eine neue Frucht auf ein freies Feld.
- `is_outside_playfield()` prüft, ob eine Position außerhalb des Spielfelds liegt.

Beginn und Ende:

- Die Datei beginnt mit den Regel-Funktionen.
- Sie endet mit der Randprüfung für das Spielfeld.

### snake_renderer.gd

Diese Datei zeichnet nur die Grafik.

Wichtige Funktionen:

- `draw_game()` malt Hintergrund, braune Wände, Spielfeld, Schlange, Frucht und HUD.

Die Optik ist absichtlich thematisch gestaltet:

- Die Außenwände wirken wie eine Burg mit Zinnen und Tor.
- Die Schlange wirkt wie ein Skelettdrache.
- Die Frucht erscheint zufällig als goldener Apfel, Kiwi oder Kirsche.

Beginn und Ende:

- Die Datei beginnt mit den Farbwählern.
- Sie endet nach dem Zeichnen des HUDs und der Game-Over-Meldung.

## Lesereihenfolge zum Verstehen des Spiels

Wenn du das Spiel als Ganzes verstehen willst, lies die Dateien in dieser Reihenfolge:

1. [snake_game.tscn](snake_game.tscn)
2. [snake_game.gd](snake_game.gd)
3. [snake_state.gd](snake_state.gd)
4. [snake_rules.gd](snake_rules.gd)
5. [snake_renderer.gd](snake_renderer.gd)

Warum diese Reihenfolge:

- Die Szene zeigt, welcher Script-Einstiegspunkt wirklich läuft.
- Das Hauptscript verbindet alle Module.
- Der Zustand erklärt, welche Daten überhaupt existieren.
- Die Regeln erklären Bewegung, Punkte, Frucht und Kollision.
- Der Renderer erklärt die Darstellung.

## Hinweise für die Web-Einbindung

Die Weboberfläche kann später nur [snake_game.gd](snake_game.gd) oder die Szene [snake_game.tscn](snake_game.tscn) laden.
Für die Einbindung in ein größeres Minigame-System ist wichtig:

- `score_changed` für die Punkteanzeige.
- `game_over` für das Ende einer Runde.
- `start_game()`, `restart_game()` und `stop_game()` für die Steuerung von außen.
