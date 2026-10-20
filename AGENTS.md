# `AGENTS.md`

## Projekt und Zielgruppe

Dieses Repository enthält einen Einsteigerkurs zu Linux, Git und CI. Schreibe für Lernende mit wenig oder keiner Vorerfahrung.

## Schreib- und Lernstil

- Schreibe auf Deutsch, klar und sachlich. Das gilt auch für Dateinamen, Schrittnamen in Workflows und Kommentare in Code, soweit sie für Lernende sichtbar sind.
- Erkläre Fachbegriffe bei der ersten Verwendung.
- Gib jeder Lektion ein konkretes Lernziel.
- Führe Lernende schrittweise durch Aufgabe, Ausführung und Ergebniskontrolle.
- Trenne Musterlösungen von den Aufgaben. Bewahre sie unter `lehrkraft/` auf und erwähne oder verlinke sie nicht in Einstiegen für Lernende. Markiere Musterlösungen als *ungetestet*, solange sie nicht ausgeführt wurden.
- Kennzeichne Beispieldaten und erwartete Ausgaben.
- Nutze Fehler, um zu zeigen, wie Lernende ihre Arbeit prüfen und verbessern können.

## Technische Sorgfalt

- Erfinde keine Befehle, Optionen, Versionsangaben oder Fehlermeldungen.
- Belege Aussagen zu Actions, Triggern, Fristen und Berechtigungen mit der offiziellen Dokumentation und nenne den Stand, soweit er relevant ist.
- Erkläre, wo Befehle ausgeführt werden und was sie bewirken.
- Weise bei riskanten Befehlen auf mögliche Folgen hin. Dazu zählen insbesondere `rm`, `git reset --hard`, `git push --force` und Befehle, die Dateien dauerhaft überschreiben oder löschen.
- Behaupte nicht, etwas getestet zu haben, wenn es nicht getestet wurde.
- Kennzeichne plattform- und versionsabhängige Angaben. Gib bei GitHub Actions die Action-Version an (z. B. `actions/checkout@v4`) und nenne den verwendeten Runner-Typ (z. B. `ubuntu-latest`).

## Git- und CI-Plattformen

- Verwende Git Flow.
  - Lege für jede Änderung zuerst einen eigenen Feature-Branch an, ausgehend von `develop`, mit dem Namensschema `feature/<kurzbeschreibung>` (z. B. `feature/lektion-03-grep`).
  - Führe Feature-Branches nur nach `develop` zusammen, per Pull Request bzw. Merge Request.
  - Arbeite nicht direkt auf `main` oder `develop`.
- Halte Linux-Befehle möglichst plattformneutral (POSIX-Shell). Wo GNU- und BSD-Varianten abweichen (z. B. bei `sed` oder `date`), weise darauf hin.
- Der aktuelle Kurs behandelt GitHub Actions. Codeberg/Forgejo Actions und GitLab CI/CD sind mögliche spätere Erweiterungen.
- Behaupte nicht, dass Konfigurationen unverändert zwischen Plattformen funktionieren. Wenn Inhalte für weitere Plattformen ergänzt werden, erkläre sie getrennt und stelle Unterschiede sachlich dar.
- Nenne erforderliche Runner oder andere Voraussetzungen, wenn sie für eine Übung relevant sind.

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
