# Linux CI

**Linux und CI/CD praktisch lernen – Schritt für Schritt und mit kleinen Übungen.**

Dieses Repository enthält kurze Lektionen, in denen du Linux-Befehle ausprobierst und sie in automatisierten Abläufen ausführst. Die Beispiele richten sich an Einsteigerinnen und Einsteiger und eignen sich auch für den Unterricht.

## Lernziele

Du lernst,

- grundlegende Linux-Befehle zu verwenden,
- dich in einer Linux-Umgebung zurechtzufinden,
- einfache Shell-Befehle in einem Workflow auszuführen,
- die Ausgabe eines automatisierten Laufs zu lesen.

## Lektionen

Jede Lektion ist auf etwa **10–15 Minuten** ausgelegt.

1. **Hallo Linux** – Benutzer, Verzeichnis, Datum und System anzeigen
2. **Dateien und Ordner** – Dateien erstellen, lesen und auflisten
3. **Befehle kombinieren** – einfache Abläufe mit mehreren Befehlen erstellen
4. **Eigene Übung** – einen kleinen Linux-Workflow anpassen

Die Lektionen werden schrittweise ergänzt.

## Plattformen

Die Beispiele können für verschiedene CI-Plattformen angepasst werden:

- GitHub Actions
- Forgejo Actions
- GitLab CI

Die Konfigurationsdateien unterscheiden sich je nach Plattform. Eine Anleitung für eine Plattform lässt sich daher nicht immer unverändert auf eine andere übertragen.

## Loslegen

Für die Übungen brauchst du ein Konto bei einer unterstützten Git-Plattform und ein Repository.

1. Erstelle ein Repository und füge die Dateien aus diesem Projekt hinzu.
2. Lege Workflow-Dateien im vorgesehenen Verzeichnis der jeweiligen Plattform ab.
3. Starte den Workflow oder löse ihn durch einen Commit aus.
4. Öffne das Protokoll des Laufs und vergleiche die Ausgabe mit der Lektion.

Bei GitHub Actions müssen Workflow-Dateien für den manuellen Start über `workflow_dispatch` auf dem Standardbranch liegen. Danach kannst du beim Start einen Branch auswählen.

## Für den Unterricht

Die Lektionen lassen sich einzeln bearbeiten und eignen sich als kurze praktische Einheiten. Lehrkräfte können die Aufgaben an den Kenntnisstand der Lerngruppe anpassen. Vor dem Einsatz empfiehlt es sich, die Workflows im eigenen Kurs-Repository zu testen.

## Mitmachen

Fehler, Verbesserungsvorschläge und zusätzliche Übungen sind willkommen. Beschreibe bei einem Vorschlag möglichst genau, welche Lektion oder Datei betroffen ist und was geändert werden sollte.

## Lizenz

- **Lerntexte und Materialien:** CC BY 4.0
- **Beispielcode:** MIT

Bei einer Weiterverwendung der Materialien bitte den Urheber nennen und Änderungen kenntlich machen. Die vollständigen Lizenzbedingungen stehen in den Lizenzdateien im Repository.
