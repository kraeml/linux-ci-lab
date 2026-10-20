# Kurs: Linux + GitHub Actions, Teil 2 (v5)

Teil 2 baut auf Teil 1 auf. Du brauchst dieselbe Repo-Struktur, insbesondere `daten/server.log` aus Teil 1. Es gibt **4 Lektionen** und ein Abschlussprojekt.

Die Ausgaben werden im GitHub-Actions-Lauf im Tab **Actions** geprüft. Eine Datei, die nur auf deinem Rechner liegt, ist für den Runner nicht verfügbar: Neue oder geänderte Kursdateien müssen committet und in das GitHub-Repository übertragen werden, bevor du einen Workflow startest. Ein Workflow mit `workflow_dispatch` kann manuell gestartet werden, wenn seine Datei auf dem Standardbranch liegt; beim Start kannst du einen Branch wählen. Zum manuellen Start brauchst du Schreibzugriff auf das Repository. Stand 20.10.2026, siehe [GitHub-Dokumentation zu manuellen Workflow-Starts](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow).

## Vorbereitung

Die fünf Workflows sowie `daten/zugriffe.log` und `daten/bericht.txt` sind im Kurs-Repository bereits vorhanden. Prüfe im Tab **Code**, dass sie auf dem Branch liegen, den du startest. Für ein eigenes Lern-Repository überträgst du die Dateien mit denselben Pfaden und pushst sie dorthin; lokal vorhandene Dateien sind für den Runner nicht verfügbar.

`daten/server.log` kommt aus Teil 1. Die Zugriffsdatei ist eine Beispieldatei mit zehn erfundenen Zugriffen. Die separate Berichtdatei dient zum Üben der Dateisuche und des Lesens.

**`daten/zugriffe.log`** (erfundene Beispieldaten):

```text
anna /start
ben /produkte
anna /produkte
clara /start
anna /kontakt
ben /start
clara /produkte
anna /produkte
ben /kontakt
clara /kontakt
```

Erwartete Seitenaufrufe: `/produkte` 4, `/start` 3, `/kontakt` 3. Damit ist die meistbesuchte Seite eindeutig. Im Repository stehen vor den zehn Zugriffen zwei Kommentarzeilen mit Datenherkunft und Lizenz; Workflows filtern sie vor der Auswertung heraus.

**`daten/bericht.txt`** (Beispielinhalt für die Übung „Berichtdatei lesen“):

```text
Quartalsbericht
Umsatz steigt
Kosten sinken
Ausblick positiv
```

Führe die Datei nach dem Anlegen mit dem Workflow aus Lektion 6 auf. Der Schritt „Dateien finden“ listet sie unter `daten/` auf; der anschließende Schritt „Bericht lesen“ zeigt den Dateiinhalt. Der Bericht enthält vier Datenzeilen; im Repository stehen zusätzlich zwei Kommentare zur Herkunft und Lizenz.

> In den Logs und Berichten sind keine echten Nutzerdaten oder Zugangsdaten enthalten; verwende für Kursübungen ausschließlich Beispieldaten.

---

## Lektion 5: Mehrere Jobs und `needs:`

**Lernziel:** Du kannst parallele und voneinander abhängige Jobs unterscheiden und einen kurzen Wert in `GITHUB_OUTPUT` speichern und als Job-Output weitergeben.

**Datei:** `.github/workflows/05-mehrere-jobs.yml` ist im Repository vorhanden. Öffne sie im Tab **Code**, um die vollständige Datei zu sehen.

**Ausprobieren und kontrollieren:** Starte den Workflow manuell unter **Actions**. Im Graphen können `zaehlen` und `parallel-a` parallel starten; `melden` wartet auf `zaehlen`. Prüfe im Protokoll: `Gefunden: 3` und `Der Job zaehlen meldet 3 Fehler`. `grep` sucht im Beispiel nach ` ERROR `, also nach dem Schweregrad zwischen Leerzeichen; Lizenzkommentare werden so nicht mitgezählt.

`actions/checkout@v7` lädt auf dem Runner `ubuntu-latest` die Dateien ins Arbeitsverzeichnis. Die Hauptversion 7 verwendet Node.js 24. Stand 20.10.2026 ist `v7.0.1` die neueste Veröffentlichung. Das Tag `@v7` folgt innerhalb der Hauptversion 7 dem neuesten Patch und pinnt keine feste Patch-Version. GitHub-gehostete Runner benötigen keine manuelle Aktualisierung. Bei selbst betriebenen Runnern ist für Node.js-24-Actions mindestens Version 2.327.1 erforderlich.

**Wie das funktioniert**

| Konzept | Bedeutung |
|---------|-----------|
| Jobs ohne `needs:` | Starten parallel |
| `needs: zaehlen` | Wartet auf `zaehlen`. Standardmäßig läuft `melden` nur weiter, wenn `zaehlen` erfolgreich war. Schlägt `zaehlen` fehl, wird `melden` **übersprungen**. Mit besonderen Bedingungen lässt sich das ändern. |
| Eigene Umgebung | Jeder Job hat einen eigenen Runner. Dateien aus `zaehlen` sind in `melden` **nicht** da. |
| `echo "x=y" >> "$GITHUB_OUTPUT"` | Schreibt einen Wert für spätere Schritte oder Jobs |
| `outputs:` am Job | Reicht den Wert an andere Jobs weiter |
| `needs.zaehlen.outputs.fehler` | So liest der abhängige Job den Wert |

Im Tab **Actions** zeigt die Graph-Ansicht des Laufs, wie die Jobs zusammenhängen.

> **`|| true` hier bewusst:** Ohne Treffer gibt `grep -c` `0` aus, liefert aber Exit-Code 1 und würde den Schritt fehlschlagen lassen. Hier ist „keine Fehler“ ein gültiges Ergebnis, daher fangen wir den Status ab. Das verschluckt allerdings auch echte `grep`-Fehler (Exit-Code 2), etwa bei einem falschen Dateipfad. Prüfe deshalb sowohl die Fehlermeldung als auch den ausgegebenen Wert im Protokoll.

**Aufgaben**
1. Starte den Workflow und sieh dir die Graph-Ansicht an. Welche Jobs laufen parallel?
2. Füge einen vierten Job `abschluss` hinzu, der erst nach `melden` und `parallel-a` startet: `needs: [melden, parallel-a]`
3. Ändere in `zaehlen` den Suchbegriff auf ` FATAL `. Läuft `melden` trotzdem? Was meldet er?
4. Entferne `actions/checkout` aus `zaehlen`. Im Log erscheint eine `grep`-Fehlermeldung (Datei nicht gefunden). Warum läuft `zaehlen` trotzdem grün durch, und warum läuft `melden` weiter? Was steht in der Ausgabe von `melden`? Das ist genau das Verhalten, vor dem der `|| true`-Hinweis oben warnt.

---

## Lektion 6: Häufigkeiten zählen und Dateien durchsuchen

**Lernziel:** Du kannst mit Sortieren und Zählen Häufigkeiten ermitteln, Spalten aus Texten lesen und Dateien mit `find` suchen.

**Datei:** `.github/workflows/06-auswerten.yml` ist im Repository vorhanden. Öffne sie im Tab **Code**, um die vollständige Datei zu sehen.

**Runner:** `ubuntu-latest`; `actions/checkout@v7` (Node.js 24, Stand 20.10.2026) stellt die Dateien bereit. Der Verweis `@v7` folgt dem aktuellen Patch innerhalb der Hauptversion.

**Ausprobieren und kontrollieren:** Starte den Workflow über **Actions → 06 - Auswerten → Run workflow**. Erwartete Zählungen: `anna` vier Zugriffe, `ben` drei, `clara` drei; `/produkte` vier, `/start` drei und `/kontakt` drei. Die Top-1-Ausgabe ist `/produkte`. `find daten -type f` listet `einkauf.txt`, `server.log`, `zugriffe.log` und `bericht.txt` auf. Danach gibt der Workflow den Inhalt von `daten/bericht.txt` aus.

**Das Zählmuster (merken!)**

```
grep -v '^#' datei | cut -d' ' -f1 | sort | uniq -c | sort -nr
   ↓ Kommentare weg  ↓ Spalte holen  ↓   ↓ zählt       ↓ größte zuerst
```

`grep -v '^#'` blendet zuerst Kommentarzeilen aus. `uniq` erkennt nur **direkt aufeinanderfolgende** gleiche Zeilen; darum sortiert `sort` die Werte vorher. Probiere es aus: Entferne das `sort`, das unmittelbar vor `uniq -c` steht, und vergleiche die Ausgabe.

> **Gleichstand beachten:** `head -n 1` zeigt immer nur eine Zeile. Hätten zwei Seiten gleich viele Zugriffe, würde der Gleichstand verschwiegen. Schau bei eigenen Daten zuerst die volle Liste an.

**Kommandos erklärt**

| Kommando | Zweck |
|----------|-------|
| `uniq -c` | Aufeinanderfolgende gleiche Zeilen zählen |
| `sort -n` | Numerisch sortieren (sonst steht 10 vor 2) |
| `sort -r` | Umgekehrte Reihenfolge |
| `sort -nr` | Numerisch, größte zuerst |
| `sort -u` | Sortieren und doppelte Zeilen entfernen |
| `awk '{print $2}'` | Zweite Spalte ausgeben (Trenner: Leerraum, also Leerzeichen oder Tabs) |
| `find . -name "*.log"` | Dateien nach Namen suchen |
| `find daten -type f` | Nur Dateien (`-type d` = nur Ordner) |
| `wc -l datei` | Physische Zeilen zählen; auch Kopfzeilen und Kommentare werden gezählt |
| `grep -v '^#' datei` | Kommentarzeilen aus der Ausgabe herausfiltern |

> `find` mit Platzhaltern: Setze das Muster in Anführungszeichen (`"*.log"`), damit die Shell es nicht schon vorher auflöst, sondern `find` es bekommt.

**Aufgaben**
1. Welche Person hat die meisten Zugriffe? Passe das Zählmuster an und nutze `head -n 1`. Vergleiche mit der Kontrollzählung.
2. Zähle die Log-Level in `daten/server.log`. Filtere zuerst die Kommentarzeilen mit `grep -v '^#'` heraus, danach liest `awk '{print $3}'` die dritte Spalte. Erwartet werden `INFO=5`, `ERROR=3`, `WARNING=1`.
3. Finde alle `.txt`-Dateien im Repository. Erkläre, warum `daten/bericht.txt` auftaucht.
4. Entferne das `sort`, das direkt vor `uniq -c` steht, und beschreibe, was sich ändert. `uniq` zählt dann nur direkt benachbarte gleiche Zeilen.

---

## Lektion 7: Artefakte hochladen und herunterladen

**Lernziel:** Du kannst einen Bericht als Artefakt hochladen, ihn selbst über die Weboberfläche herunterladen und erklären, wie ein anderer Job das Artefakt automatisiert weiterverwendet.

**Datei:** `.github/workflows/07-artefakte.yml` ist im Repository vorhanden. Öffne sie im Tab **Code**, um die vollständige Datei zu sehen.

**Runner und Actions:** `ubuntu-latest`, `actions/checkout@v7` (Node.js 24), `actions/upload-artifact@v7` (Node.js 24) und `actions/download-artifact@v8` (Node.js 24). Stand 20.10.2026 sind die neuesten Veröffentlichungen v7.0.1, v7.0.2 und v8.0.2. Die Tags `@v7` und `@v8` folgen jeweils dem neuesten Patch innerhalb ihrer Hauptversion und pinnen keine feste Patch-Version. Bei selbst betriebenen Runnern ist für Node.js 24 mindestens Runner-Version 2.327.1 erforderlich; `ubuntu-latest` ist GitHub-gehostet.

**Zwei Wege, dasselbe Artefakt zu nutzen:**

1. **Selbst herunterladen:** Öffne nach dem Lauf die Laufübersicht und scrolle zum Bereich **Artifacts**. Lade `auswertung` als ZIP herunter, entpacke es auf deinem Rechner und lies `bericht.txt`.
2. **Automatisiert weitergeben:** Der Job `weiterverarbeiten` lädt das Artefakt mit `actions/download-artifact@v8` herunter. Der Job braucht dafür keinen Checkout; jeder Job hat seine eigene Arbeitsumgebung.

Erwarteter Bericht (das Datum ändert sich):

```text
Fehler im Server-Log: 3
Datensätze im Zugriffslog: 10
Beliebteste Seite:
      4 /produkte
```

Die Kommentarzeilen am Anfang der Beispieldatei sind keine Zugriffsdatensätze. Darum zählt der Bericht nur Zeilen, die nicht mit `#` beginnen. `wc -l` würde auch die Kommentarzeilen mitzählen.

> Artefakte werden nach einer Aufbewahrungsfrist gelöscht. `retention-days` kann bei `upload-artifact@v7` 1 bis 90 Tage betragen; Repository- oder Organisationsrichtlinien können die Höchstfrist verkürzen. Geänderte Werte gelten nur für neu erstellte Artefakte. Artefakte sind nicht für Geheimnisse oder echte Nutzerdaten gedacht.
>
> `grep -c ... || true` erlaubt eine Null bei keinen Treffern, fängt aber auch echte `grep`-Fehler ab. Für eigene Workflows solltest du Fehler getrennt behandeln.

**So funktioniert es**

| Element | Bedeutung |
|---------|-----------|
| `{ ... } \| tee datei` | Fasst mehrere Befehle zusammen und gibt die Ausgabe zugleich im Jobprotokoll und in einer Datei aus |
| `wc -l < datei` | Zeilen zählen ohne Dateinamen in der Ausgabe |
| `actions/upload-artifact@v7` | Hängt Dateien als Artefakt an den Workflow-Lauf an |
| `actions/download-artifact@v8` | Lädt ein Artefakt im Arbeitsverzeichnis eines Jobs herunter |
| `needs: bericht` | Wartet auf den Job `bericht` |

Beim Download innerhalb desselben Workflow-Laufs ist kein zusätzliches Token nötig. Die Actions v7 und v8 verwenden Node.js 24. Selbst betriebene Runner benötigen mindestens Runner-Version 2.327.1; für GitHub-gehostete Runner wie `ubuntu-latest` ist keine manuelle Aktualisierung nötig.

**Aufgaben**
1. Starte den Workflow. Lade `auswertung` über den Bereich **Artifacts** selbst herunter, entpacke es und lies `bericht.txt`.
2. Öffne den Job `weiterverarbeiten` und prüfe, dass `bericht.txt` auch dort ausgegeben wird. Erkläre, warum der zweite Job `needs: bericht` braucht.
3. Ergänze im Bericht eine Zeile mit der Anzahl der `WARNING`-Einträge. Starte erneut und kontrolliere, dass die neue Zeile sowohl im Browser-Download als auch im Job `weiterverarbeiten` erscheint.
4. Ergänze bei `actions/upload-artifact@v7` unter `with:` `retention-days: 1`. Starte den Workflow erneut. Prüfe die angezeigte Aufbewahrungsfrist, falls sie für dich sichtbar ist; sie gilt nur für das neu erzeugte Artefakt. Repository- oder Organisationsrichtlinien können den Wert zusätzlich begrenzen.
5. Ändere `path:` auf einen mehrzeiligen Wert und lade zusätzlich `daten/server.log` hoch. Kontrolliere die Dateien im ZIP-Download. Lade keine Geheimnisse oder persönlichen Daten hoch.

**Mit `>` statt `tee`:** `>` schreibt die Ausgabe nur in die Datei und überschreibt einen vorhandenen Inhalt; `tee` schreibt in die Datei und zugleich ins Jobprotokoll.

```bash
echo "Hallo" > ergebnis/datei.txt
echo "Hallo" | tee ergebnis/datei.txt
```

---

## Lektion 8: Zeitplan mit Cron und weitere Trigger

**Lernziel:** Du kannst die Auslöser `workflow_dispatch`, `push`, `pull_request` und `schedule` unterscheiden und einfache Cron-Zeitpläne lesen.

**Datei:** `.github/workflows/08-zeitplan.yml` ist im Repository vorhanden. Öffne sie im Tab **Code**, um die vollständige Trigger-Konfiguration zu sehen.

`ubuntu-latest` ist der Runner; `actions/checkout@v7` (Node.js 24) checkt Dateien aus. Stand 20.10.2026 ist `v7.0.1` die neueste Veröffentlichung; `@v7` folgt dem neuesten Patch innerhalb der Hauptversion und pinnt keine feste Patch-Version.

> Dieser Lernworkflow ist eine ausdrücklich gewünschte Ausnahme von der üblichen Regel, Kursbeispiele nur manuell zu starten: Er enthält `workflow_dispatch`, `push`, `pull_request` und `schedule`, damit die verschiedenen Trigger praktisch sichtbar werden.

**Trigger im Überblick**

| Trigger | Wann läuft der Workflow? |
|---------|--------------------------|
| `workflow_dispatch` | Manuell auf Knopfdruck; Workflow-Datei muss auf dem Standardbranch liegen |
| `push` | Startet bei Push-Vorgängen, die Dateien unter `daten/` ändern (`paths:`-Filter) |
| `pull_request` | Startet bei Pull Requests, die Dateien unter `daten/` ändern (`paths:`-Filter) |
| `schedule` | Nach Zeitplan |

**Cron-Syntax: 5 Felder**

```
 30   6    *    *    1
 │    │    │    │    └── Wochentag (0-6, Sonntag = 0, Montag = 1)
 │    │    │    └─────── Monat (1-12)
 │    │    └──────────── Tag im Monat (1-31)
 │    └───────────────── Stunde (0-23)
 └────────────────────── Minute (0-59)
```

`30 6 * * 1` bedeutet: Jeden Montag um 06:30 Uhr **UTC**.

| Cron | Bedeutung |
|------|-----------|
| `0 * * * *` | Jede volle Stunde |
| `*/15 * * * *` | Alle 15 Minuten |
| `0 8 * * 1-5` | Werktags um 08:00 |
| `0 0 1 * *` | Am Monatsersten um Mitternacht |

**Wichtig zu `schedule:`**
- Ohne Zeitzonenangabe gelten die Zeiten in **UTC**, nicht in deiner lokalen Zeit. GitHub erlaubt auch eine IANA-Zeitzone, zum Beispiel `timezone: "America/New_York"`. In diesem Kurs verwenden wir UTC. Stand 20.10.2026, siehe [offizielle Workflow-Syntax](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#onschedule).
- Geplante Workflows laufen nur, wenn die Workflow-Datei auf dem **Standardbranch** liegt. Sie verwenden den neuesten Commit dieses Branches. Ein manueller Lauf mit `workflow_dispatch` testet daher nicht den Zeitplan selbst.
- Ein Zeitplan startet nicht garantiert genau zum angegebenen Zeitpunkt. Bei hoher Last können Läufe verzögert werden; bei sehr hoher Last können wartende Läufe verworfen werden. Besonders stark belastet ist oft der Beginn einer Stunde. Stand 20.10.2026, siehe [GitHub-Dokumentation zu `schedule`](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#schedule).
- In öffentlichen Repositories deaktiviert GitHub geplante Workflows automatisch, wenn 60 Tage lang keine Repository-Aktivität stattgefunden hat. Du kannst sie dann im Actions-Tab wieder aktivieren.
- Der kürzeste Abstand laut GitHub-Dokumentation ist 5 Minuten.

**`push` testen:** Ändere eine Datei in `daten/`, committe und pushe sie. Der Workflow startet automatisch. Im Lauf siehst du `Ausgelöst durch: push`. Ein Pull Request mit einer Änderung unter `daten/` löst ebenfalls einen Lauf aus.

**Aufgaben**
1. Starte den Workflow manuell und prüfe, was bei `Ausgelöst durch` steht.
2. Auf einem Branch: Ändere `daten/einkauf.txt`, committe und pushe die Änderung. Wenn die Workflow-Datei auf dem Standardbranch liegt, prüfe den Lauf mit diesem Branch. Beobachte, ob der Workflow von selbst startet.
3. Schreibe Cron-Ausdrücke für:
   - jeden Tag um 12:00 UTC
   - jeden Freitag um 17:45 UTC
   - alle 30 Minuten
   Prüfe die Ausdrücke anhand der Tabelle oben und vergleiche sie mit einem Cron-Prüfer.
4. **Zeitplan praktisch prüfen:** Die Datei `.github/workflows/08-zeitplan.yml` muss dafür auf dem Standardbranch des Kurs-Repositories liegen. Der Kursverantwortliche stellt eine geprüfte Änderung über den Kurs-Git-Flow bereit. Ändere dort vorübergehend den Cron-Ausdruck auf `*/5 * * * *`, warte einige Minuten und prüfe den Actions-Lauf. Ein manueller Start testet den Zeitplan nicht. Geplante Läufe können verzögert sein oder ausbleiben. Stelle danach den ursprünglichen Cron-Ausdruck wieder her.

---

## Abschlussprojekt: Der Auto-Prüfer

Verbinde die Lektionen zu einem Workflow, der Aufgaben **automatisch prüft**. Der Workflow nutzt `workflow_dispatch` zum manuellen Test und `push` auf Änderungen unter `loesungen/` als ausdrücklich beauftragten Zusatztrigger.

**Vorbereitung:** Lege `loesungen/aufgabe1.txt` mit der Antwort `3` an. Die Datei ist eine Beispielantwort und nicht Teil des Kurs-Repositories. Übertrage sie in dein Kurs-Repository.

**Datei:** `.github/workflows/09-pruefer.yml` ist im Repository vorhanden. Öffne sie im Tab **Code**. Die Workflow-Datei muss für den automatischen `push`-Trigger bereits auf dem Standardbranch liegen. Danach startet der Prüfer bei Pushes, die Dateien unter `loesungen/` ändern. Erwartet werden `Erwartet: 3, Antwort: 3` und `Richtig!`.

Der Workflow verwendet `ubuntu-latest` und `actions/checkout@v7` (Node.js 24; Stand 20.10.2026: neueste Veröffentlichung v7.0.1). Das Tag `@v7` folgt dem neuesten Patch innerhalb der Hauptversion 7 und pinnt keine feste Patch-Version. GitHub-gehostete Runner benötigen keine manuelle Aktualisierung; bei self-hosted Runnern ist mindestens Version 2.327.1 für Node.js-24-Actions erforderlich.

**Das Prinzip**
- Der Prüfer berechnet die richtige Antwort **selbst** aus den Daten
- Er liest die Antwort aus der Lösungsdatei und vergleicht beides
- `exit 1` lässt den Schritt rot werden, `exit 0` (oder kein `exit`) grün
- `tr -d '[:space:]'` entfernt Leerzeichen, Tabs und Zeilenumbrüche, damit `3` und `3\n` gleich zählen

| Element | Bedeutung |
|---------|-----------|
| `[ "$A" = "$B" ]` | Texte vergleichen (Leerzeichen innerhalb der Klammern sind Pflicht) |
| `if ... then ... else ... fi` | Bedingung |
| `exit 1` | Mit Fehlerstatus beenden |
| `tr -d` | Zeichen löschen |

> `|| true` fängt auch hier echte `grep`-Fehler ab (siehe Lektion 5). Für den Kurs ist das eine bewusste Vereinfachung.

**Aufgaben**
1. Ändere `loesungen/aufgabe1.txt` auf `5`, committe und pushe die Änderung. Der Workflow sollte rot werden.
2. Korrigiere die Antwort auf `3`, committe und pushe erneut. Der Workflow sollte grün werden.
3. Erweitere den Prüfer um Aufgabe 2: „Wie viele Zeilen enthält der eigentliche Inhalt von `daten/einkauf.txt`?“ Die Lizenzkommentare zählen nicht als Einkaufseinträge. Verwende eine Lösungsdatei `loesungen/aufgabe2.txt` mit der Antwort `5`.
4. Ergänze Aufgabe 3 mit einer eigenen Frage auf Basis von `daten/zugriffe.log`. Filtere Kommentarzeilen vor einer Auswertung heraus.

---

## Häufige Fehler in Teil 2

| Fehler | Ursache |
|--------|---------|
| `needs`-Job startet nicht | Der vorherige Job ist fehlgeschlagen oder wurde übersprungen |
| Output ist leer | `id:` am Schritt fehlt, Name in `outputs:` stimmt nicht, oder `grep` fand die Datei nicht (durch `\|\| true` unbemerkt) |
| Dateien fehlen im nächsten Job | Jeder Job hat eine eigene Umgebung, Artefakte nutzen |
| `uniq -c` zählt falsch | `sort` davor vergessen |
| Artefakt nicht zu finden | `path:` zeigt ins Leere (Ordner existiert nicht) |
| Neue `retention-days` wirkt nicht | Gilt nur für neu erstellte Artefakte, Workflow erneut starten |
| Häufigkeitswert zu hoch | Beispieldatei enthält Kommentarzeilen; vor der Auswertung mit `grep -v '^#'` herausfiltern |
| Beispieldatei fehlt im Runner | Datei ist lokal, aber nicht in den ausgewählten Git-Branch gepusht |
| Schedule läuft nicht | Datei nicht auf dem Standardbranch, UTC-Zeit falsch gerechnet, Lauf verzögert oder Repo inaktiv |
| Push-Lauf startet nicht | Änderung liegt außerhalb der `paths:`-Filter |
| Prüfer meldet "falsch" bei richtiger Antwort | Leerzeichen oder Zeilenumbruch in der Antwortdatei |

---

## Spickzettel-Ergänzung (`CHEATSHEET.md`)

```
needs: job                      Job wartet auf anderen Job
echo "k=v" >> "$GITHUB_OUTPUT"  Wert weitergeben
sort | uniq -c | sort -nr       Häufigkeiten zählen
awk '{print $2}'                Spalte 2 ausgeben
find . -name "*.log"            Dateien suchen
cmd | tee datei                 In Datei und Log schreiben
wc -l < datei                   Zeilen ohne Dateinamen
actions/upload-artifact@v7     Artefakt hochladen
actions/download-artifact@v8   Artefakt im Job laden
cron: "min std tag mon wtag"    Zeitplan (ohne Angabe: UTC)
[ "$A" = "$B" ]                 Texte vergleichen
exit 1                          Schritt bewusst fehlschlagen lassen
```
