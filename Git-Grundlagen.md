# Git-Grundlagen

> Lernmaterial: CC BY 4.0 (siehe `LICENSE-CONTENT.txt`).

## Ziel

Du kannst Änderungen im eigenen Lern-Repository über die GitHub-Oberfläche nachvollziehen, auf einem Arbeitsbranch speichern und als Pull Request zur Übernahme vorschlagen.

## Was macht Git?

Git ist ein Versionsverwaltungssystem. Es speichert Änderungen an Dateien als **Commits** (gesicherte Projektstände), sodass du den Verlauf ansehen und Änderungen vergleichen kannst. GitHub ist ein Webdienst, auf dem ein Git-Repository gespeichert und gemeinsam bearbeitet werden kann.

In diesem Kurs arbeitest du in deinem eigenen Lern-Repository. Das Kurs-Repository enthält die Vorlagen. Für dein Lern-Repository brauchst du keinen Git Flow.

## Repository und Dateien auf GitHub

Ein **Repository** (kurz: Repo) enthält Projektdateien und deren Git-Verlauf. In der GitHub-Weboberfläche kannst du Dateien anzeigen, neue Dateien anlegen und vorhandene Dateien bearbeiten. Die Kursvorbereitung in [Teil 1](Linux%20%2B%20GitHub%20Actions,%20Teil%201.md) zeigt, wie du dein Lern-Repository einrichtest und Dateien im Browser speicherst.

**Aufgabe:** Öffne dein Lern-Repository auf GitHub und finde den Standardbranch sowie eine Workflow-Datei.

**Ausführung:** Öffne den Tab **Code**. Nutze die Branch-Auswahl, um den aktuellen Branch zu sehen. Navigiere zu `.github/workflows/`.

**Kontrolle:** Du siehst die Dateien des ausgewählten Branches. Der Standardbranch ist der Branch, den GitHub als Hauptversion des Repositorys verwendet; häufig heißt er `main`.

## Änderungen und Commits

Ein **Commit** ist ein gespeicherter Stand der Änderungen. Auf GitHub kannst du eine Datei bearbeiten und mit **Commit changes** speichern. Die Weboberfläche erstellt den Commit direkt; der lokale Git-Zwischenschritt **Staging** wird dabei nicht separat angezeigt.

Ein Commit gehört zu einem Branch. Die Commit-Nachricht sollte knapp beschreiben, was geändert wurde, zum Beispiel `Ergänze YAML-Schrittbeschreibung`.

## Remote, Push und Pull

Ein **Remote** ist ein anderes Git-Repository, das als Ziel für den Austausch von Änderungen eingetragen ist. Im Kurs ist das dein online gespeichertes Lern-Repository auf GitHub. **Push** überträgt lokale Commits zum Remote; **Pull** holt Änderungen vom Remote in ein lokales Repository. Diese Begriffe gehören zum lokalen Git-Ablauf. Wenn du im Browser auf GitHub bearbeitest und commitest, speicherst du direkt in dem online ausgewählten Repository und Branch – ein separater Push-Schritt ist dort nicht sichtbar.

Ein Pull Request ist etwas anderes als `git pull`: Ein Pull Request schlägt Änderungen aus einem Branch zur Prüfung und möglichen Übernahme in einen anderen Branch vor.

Die praktische Übung zum Erstellen der `README.md` steht in [Markdown-Grundlagen](Markdown-Grundlagen.md). Verwende dort die GitHub-Oberfläche, um die README im eigenen Lern-Repository zu speichern. Die Commit-Schritte und die Kontrolle im Verlauf sind in dieser Lerneinheit beschrieben.

## Branches: getrennte Arbeitslinien

Ein **Branch** ist eine benannte Entwicklungslinie im Repository. Auf einem Arbeitsbranch kannst du Änderungen vorbereiten, ohne sie sofort in den Standardbranch zu übernehmen. Die Dateien und der Verlauf können sich je nach ausgewähltem Branch unterscheiden.

**Aufgabe:** Erstelle in deinem Lern-Repository einen Arbeitsbranch für eine Kursänderung.

**Ausführung:** Öffne die Branch-Auswahl auf dem Tab **Code**, gib einen neuen Namen ein und wähle die angezeigte Möglichkeit, den Branch vom Standardbranch aus zu erstellen. Die genaue Beschriftung der Oberfläche kann sich ändern. Wechsle anschließend in den neuen Branch.

**Kontrolle:** Die Branch-Auswahl zeigt den neuen Namen als aktuell ausgewählten Branch. Prüfe vor dem Bearbeiten, dass du im richtigen Repository und Branch bist.

Lege neue Branches im Lern-Repository nach den Anweisungen der jeweiligen Kursaufgabe an. Die Git-Flow-Regeln zur Pflege dieses Kurs-Repositories gelten nicht für dein Lern-Repository. In diesem Grundlagenmodul ist der Ablauf auf GitHub zentral; die lokalen Begriffe zu Remote, Push und Pull ordnen einen möglichen späteren Terminalweg ein.

## Pull Request: Änderung zur Prüfung vorschlagen

Ein **Pull Request** (PR) ist ein Vorschlag, Änderungen aus einem Branch in einen anderen Branch zu übernehmen. Auf GitHub können Beteiligte die Änderungen ansehen, besprechen und prüfen, bevor sie zusammengeführt werden.

**Aufgabe:** Erstelle einen Pull Request für eine kleine Änderung in deinem Übungsbranch.

**Ausführung:** Ändere eine Datei im Arbeitsbranch und speichere die Änderung mit **Commit changes**. Öffne danach den Bereich **Pull requests** und erstelle einen Vorschlag, der deinen Arbeitsbranch als Quellbranch und den Standardbranch als Zielbranch verwendet. Lies vor dem Erstellen die angezeigten Branch-Namen und die Dateiansicht aufmerksam.

**Kontrolle:** Der Pull Request zeigt den Titel, die Branches und die geänderten Dateien. Auf der Registerkarte **Files changed** kannst du prüfen, ob nur die beabsichtigte Änderung enthalten ist. Einen Pull Request zu erstellen führt nicht automatisch dazu, dass die Änderung in den Standardbranch übernommen wird; das geschieht erst durch das Zusammenführen (Merge).

Erstelle in deinem eigenen Lern-Repository keinen Pull Request, wenn die Kursaufgabe stattdessen ausdrücklich eine direkte Änderung oder einen anderen Ablauf verlangt.

## Der Git-Ablauf auf einen Blick

1. **Branch wählen:** Auf dem vorgesehenen Branch arbeiten.
2. **Datei ändern:** Inhalt im Browser oder lokal bearbeiten.
3. **Commit erstellen:** Änderung mit einer Nachricht speichern. Auf GitHub geschieht das über **Commit changes**.
4. **Änderung vorschlagen:** Bei einem Pull Request den Unterschied prüfen und besprechen.
5. **Zusammenführen:** Nur wenn es die Aufgabe vorsieht, den Pull Request in den Zielbranch integrieren.

GitHub-Oberfläche und lokale Git-Befehle sind verschiedene Arbeitsweisen. Lokal gibt es unter anderem einen Staging-Bereich, in dem ausgewählt wird, welche Änderungen in den nächsten Commit kommen. Der Browserablauf zeigt diesen Schritt nicht separat. Diese Anleitung behandelt den Browserweg; ein Terminalablauf wäre eine eigene ergänzende Anleitung.

## Workflow-Dateien und GitHub Actions

Eine Workflow-Datei ist eine Datei im Repository. Ein Commit mit einer Workflow-Änderung ändert deshalb den gespeicherten Inhalt des Branches. GitHub Actions verarbeitet die Workflow-Datei abhängig von ihren Triggern.

Für einen manuellen Start mit `workflow_dispatch` muss die Workflow-Datei auf dem Standardbranch liegen. Danach kann beim manuellen Start ein Branch ausgewählt werden. Ein Commit auf einem Arbeitsbranch allein macht den Workflow daher nicht automatisch im Actions-Tab manuell startbar. Weitere Einzelheiten stehen in der Vorbereitung von Teil 1.

In Teil 2, Lektion 8, sind `push`, `pull_request` und `schedule` ausdrücklich als zusätzliche Trigger behandelte Kursbeispiele dokumentiert. Die allgemeine Regel des Kurses bleibt, ausführbare Beispiele nur mit den dort beschriebenen Triggern zu verwenden; füge keine Trigger hinzu, nur um eine Übung auszulösen.

## Änderungen kontrollieren und sicher arbeiten

Bevor du einen Commit oder Pull Request speicherst, prüfe:

- Ist das richtige Repository geöffnet?
- Ist der richtige Branch ausgewählt?
- Zeigt die Dateiansicht nur die beabsichtigten Änderungen?
- Enthält die Commit-Nachricht eine klare Beschreibung?

Übe zunächst an einer kleinen Änderung im eigenen Lern-Repository. Verwende keine Befehle oder Schaltflächen, deren Wirkung du nicht kennst, um Änderungen zu verwerfen oder den Verlauf umzuschreiben. Insbesondere können Befehle wie `git reset --hard` ungesicherte Arbeit löschen; `git push --force` kann einen veröffentlichten Verlauf verändern.

## Weiterlernen

Die Oberfläche von GitHub ändert sich gelegentlich. Für aktuelle Schritte siehe die offizielle GitHub-Dokumentation zu [Branches](https://docs.github.com/en/pull-requests/how-tos/commit-changes/managing-branches-within-your-repository) und [Pull Requests](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests). Für lokale Git-Grundlagen bietet *Pro Git* die Abschnitte zu [Git-Grundlagen](https://git-scm.com/book/en/v2/Git-Basics-Getting-a-Git-Repository) und [Branches](https://git-scm.com/book/en/v2/Git-Branching-Branches-in-a-Nutshell).
