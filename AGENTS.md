# `AGENTS.md`

## Projekt und Zielgruppe

Dieses Repository enthält einen Einsteigerkurs zu Linux, Git und CI. Schreibe für Lernende mit wenig oder keiner Vorerfahrung.

## Schreib- und Lernstil

- Schreibe auf Deutsch, klar und sachlich. Das gilt auch für Dateinamen, Schrittnamen in Workflows und Kommentare in Code, soweit sie für Lernende sichtbar sind.
- Erkläre Fachbegriffe bei der ersten Verwendung.
- Gib jeder Lektion ein konkretes Lernziel.
- Führe Lernende schrittweise durch Aufgabe, Ausführung und Ergebniskontrolle.
- Vermeide wiederkehrende Standardpassagen. Erkläre allgemeine Abläufe einmal und verweise an späteren Stellen knapp darauf; wiederhole Informationen nur, wenn es zum Verständnis an der Stelle nötig ist.
- Zeige den für die jeweilige Erklärung oder Aufgabe nötigen Quellcode direkt im Lerntext und halte ihn zusätzlich im Kurs-Repository vor. Kennzeichne den Dateipfad und ob Lernende die Datei anlegen, ändern oder prüfen sollen. Halte eingebettete Beispiele und Repository-Dateien synchron.
- Trenne Musterlösungen von den Aufgaben. Bewahre sie unter `lehrkraft/` auf und erwähne oder verlinke sie nicht in Einstiegen für Lernende. Markiere Musterlösungen als *ungetestet*, solange sie nicht ausgeführt wurden.
- Kennzeichne Beispieldaten und erwartete Ausgaben.
- Nutze Fehler, um zu zeigen, wie Lernende ihre Arbeit prüfen und verbessern können.

## Technische Sorgfalt

- Erfinde keine Befehle, Optionen, Versionsangaben oder Fehlermeldungen.
- Belege Aussagen zu Actions, Triggern, Fristen und Berechtigungen mit der offiziellen Dokumentation und nenne den Stand, soweit er relevant ist.
- Erkläre, wo Befehle ausgeführt werden und was sie bewirken.
- Weise bei riskanten Befehlen auf mögliche Folgen hin. Dazu zählen insbesondere `rm`, `git reset --hard`, `git push --force` und Befehle, die Dateien dauerhaft überschreiben oder löschen.
- Behaupte nicht, etwas getestet zu haben, wenn es nicht getestet wurde.
- Kennzeichne plattform- und versionsabhängige Angaben. Gib bei GitHub Actions die verwendete Action-Version an und nenne den Runner-Typ (z. B. `ubuntu-latest`).
- Prüfe vor dem Erstellen oder Aktualisieren von Actions deren aktuelle stabile Version und Laufzeit in der offiziellen Quelle. Aktualisiere veraltete Versionen und berücksichtige Deprecation-Warnungen; nenne in Lernmaterialien den Versionsstand, wenn er relevant ist. Kennzeichne bei Major-Tags (z. B. `@v7`) deutlich, dass sie der jeweils aktuellen Patch-Version folgen und keine exakte Patch-Version pinnen.

## Git- und CI-Plattformen

- Verwende Git Flow nur für Änderungen am Kurs-Repository. Lege sie auf Feature-Branches ausgehend von `develop` an und integriere sie nach Prüfung ausschließlich zurück in `develop`.
  - Lege Feature-Branches mit dem Namensschema `feature/<kurzbeschreibung>` an (z. B. `feature/lektion-03-grep`).
  - Integriere diese Feature-Branches nach erfolgreicher Prüfung ausschließlich in `develop`. Das kann per Pull Request bzw. Merge Request oder lokal mit `git flow feature finish <kurzbeschreibung>` erfolgen.
  - Nach einem PR-/MR-Merge des Kurs-Repositorys wird der lokale Feature-Branch mit `git flow feature finish <kurzbeschreibung>` abgeschlossen. Bei Squash- oder Rebase-Merges ist vor dem lokalen Abschluss der Verlauf zu prüfen. Ohne PR/MR darf `git flow feature finish` nach erfolgreicher Prüfung direkt lokal ausgeführt werden.
  - Arbeite nicht direkt auf `main` oder `develop`.
- Halte Linux-Befehle möglichst plattformneutral (POSIX-Shell). Wo GNU- und BSD-Varianten abweichen (z. B. bei `sed` oder `date`), weise darauf hin.
- Für Lern-Repositorys in den Teilen 1 bis 3 gilt kein Git Flow. Befolge dort die Branch- und Commit-Schritte im jeweiligen Kurstext; erkläre notwendige Branch-Schritte so, dass Einsteiger sie über die GitHub-Oberfläche ausführen können.
- Der aktuelle Kurs behandelt GitHub Actions. Codeberg/Forgejo Actions und GitLab CI/CD sind mögliche spätere Erweiterungen.
- Kurs-Workflows sind ausführbare Lernbeispiele und werden standardmäßig ausschließlich manuell über `workflow_dispatch` gestartet. Füge keine zusätzlichen Trigger wie `push` oder eine separate CI zur Prüfung der Kursmaterialien hinzu, sofern dies nicht ausdrücklich beauftragt wurde. Dokumentiere ausdrücklich beauftragte Trigger-Ausnahmen im jeweiligen Lernmaterial.
- Halte ausführbare Kurs-Workflows klar von einer separaten CI zur Validierung der Kursmaterialien unterscheidbar, falls eine solche CI ausdrücklich ergänzt wird.
- Behaupte nicht, dass Konfigurationen unverändert zwischen Plattformen funktionieren. Wenn Inhalte für weitere Plattformen ergänzt werden, erkläre sie getrennt und stelle Unterschiede sachlich dar.
- Nenne erforderliche Runner oder andere Voraussetzungen, wenn sie für eine Übung relevant sind.
- Beachte: Ein Workflow mit `workflow_dispatch` kann auf GitHub nur manuell gestartet werden, wenn seine Workflow-Datei auf dem Standardbranch vorhanden ist. Plane Tests entsprechend, ohne den manuellen Trigger stillschweigend durch einen anderen Trigger zu ersetzen. Ein manuelles `workflow_dispatch` startet den Workflow nur für den ausgewählten Branch; es ist kein Test für `schedule` und ersetzt nicht die Voraussetzung, dass die Schedule-Datei auf dem Standardbranch liegt.

## Releases

- Verwende das Format `YYYY.MM.PATCH`, zum Beispiel `2026.10.1`.
- `PATCH` ist eine laufende Nummer pro Monat, kein SemVer-Patch. Die Zählung beginnt im jeweiligen Monat mit `1`.
- Git-Tags tragen den Präfix `v`, zum Beispiel `v2026.10.1`.
- Release-Ablauf nach Git Flow:
  1. Release-Branch `release/2026.10.1` ausgehend von `develop` anlegen.
  2. Nur Korrekturen und Vorbereitungen in diesen Branch aufnehmen.
  3. Nach `main` zusammenführen und dort den Tag `v2026.10.1` setzen.
  4. Zurück nach `develop` zusammenführen.
- Erstelle Releases nur auf ausdrückliche Anweisung. Schlage sie sonst nur vor.

## Änderungen am Repository

- Bewahre Ordnerstrukturen, Dateinamen und Lizenzhinweise.
- Vermeide unnötige Abhängigkeiten und Änderungen außerhalb des Auftrags.
- Lizenzen:
  - Lerntexte und sonstige Materialien: CC BY 4.0 (`LICENSE-CONTENT.txt`).
  - Beispielcode, Skripte und Workflow-Dateien (z. B. unter `.github/workflows/`): MIT (`LICENSE-CODE.txt`).
  - Neue Dateien erhalten den Lizenzhinweis des jeweiligen Typs. Entferne oder verändere bestehende Hinweise nicht.
