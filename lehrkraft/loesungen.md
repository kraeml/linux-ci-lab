# Musterlösungen: Linux + GitHub Actions

> **Hinweis zur Ausführung:** Die Shell-Ausgaben in diesem Dokument wurden gegen die im Kurs angegebenen Beispieldateien lokal geprüft. GitHub-spezifische Ergebnisse (Runner-Ausgaben, Job-Graphen, Artefakte, Secrets-Maskierung, Cron-Zeitpunkte und tatsächliches Abbruchverhalten) sind als **ungetestet** gekennzeichnet. Zeit- und Runner-abhängige Werte können abweichen.

## Teil 1

### Lektion 1: Hallo Linux

#### Aufgabe 1
Im Workflow `01-hallo-linux.yml` einen weiteren Schritt ergänzen, zum Beispiel nach der Begrüßung:

```yaml
      - name: Mein Name
        run: echo "Mein Name ist Max Mustermann"
```

**Erwartete Ausgabe:** `Mein Name ist Max Mustermann` (mit dem eigenen Namen ersetzen). Der Schritt ist lokal als Shell-Befehl reproduzierbar; das Ausführen im GitHub-Runner ist **ungetestet**.

#### Aufgabe 2

```yaml
      - name: Aktuelles Datum
        run: date +%Y-%m-%d
```

**Erwartete Ausgabe:** das Datum des Ausführungstags, beispielsweise `2026-10-20`. Der konkrete Wert ist zeitabhängig; lokal nicht als fester Wert verifiziert.

#### Aufgabe 3

```yaml
      - name: Kernel-Version
        run: uname -r
```

**Erwartete Ausgabe:** eine Kernel-Version, etwa `6.x.y-...`. Die genaue Version hängt vom Runner ab und ist **ungetestet**.

### Lektion 2: Dateien und Ordner

#### Aufgabe 1
Diesen Schritt nach dem Checkout ergänzen:

```yaml
      - name: Backup anlegen
        run: |
          mkdir -p backup
          cp daten/einkauf.txt backup/einkauf.txt
          ls -l backup
```

**Erwartete Ausgabe:** eine Zeile für `backup/einkauf.txt` mit Dateirechten, Größe und Zeitstempel. Die fünf Inhaltszeilen bleiben `Brot`, `Milch`, `Käse`, `Äpfel`, `Kaffee`.

#### Aufgabe 2
Da `arbeit/liste.txt` im vorherigen Schritt erzeugt wurde, folgt:

```yaml
      - name: Butter ergänzen
        run: |
          echo "Butter" >> arbeit/liste.txt
          cat arbeit/liste.txt
```

**Erwartete Ausgabe:**

```text
Brot
Milch
Käse
Äpfel
Kaffee
Butter
```

Lokal gegen eine nachgebaute Einkaufsliste verifiziert; GitHub-Job-Kontext **ungetestet**.

#### Aufgabe 3
Der Workflow enthält den isolierten Test bereits:

```yaml
      - name: Wiederholtes mkdir ohne -p testen
        continue-on-error: true
        run: |
          mkdir testordner
          mkdir testordner
          echo "Dieser Befehl wird nach dem Fehler nicht ausgeführt"
```

**Erwartete Ausgabe:** Der zweite Aufruf meldet, dass `testordner` bereits existiert; die `echo`-Zeile wird wegen des fehlgeschlagenen Befehls nicht ausgeführt. Der Workflow setzt sich wegen `continue-on-error: true` fort. Ersetzt man beide Aufrufe durch `mkdir -p testordner-p`, funktionieren beide. Lokales Shell-Verhalten ist geprüft; die genaue GitHub-Anzeige des tolerierten Schritts ist **ungetestet**.

### Lektion 3: Texte durchsuchen und auswerten

#### Aufgabe 1
Der Level steht in Spalte 3:

```bash
awk '$3 == "INFO" { count++ } END { print count }' daten/server.log
```

**Ausgabe:** `5`. Lokal mit `daten/server.log` verifiziert.

#### Aufgabe 2

```bash
grep 'anna' daten/server.log
```

**Ausgabe:**

```text
2026-10-19 08:05:33 INFO Benutzer anna angemeldet
2026-10-19 08:20:41 INFO Benutzer anna abgemeldet
```

Lokal verifiziert.

#### Aufgabe 3

```bash
grep -E ' (WARNING|ERROR) ' daten/server.log
```

**Ausgabe:** die drei `ERROR`-Zeilen und die eine `WARNING`-Zeile:

```text
2026-10-19 08:07:45 ERROR Datenbank nicht erreichbar
2026-10-19 08:12:10 WARNING Speicher bei 85 Prozent
2026-10-19 08:15:27 ERROR Zeitüberschreitung bei Anfrage
2026-10-19 08:25:55 ERROR Datenbank nicht erreichbar
```

Lokal verifiziert.

#### Aufgabe 4

Beim manuellen Start des Workflows `03 - Texte auswerten` im Lern-Repository die Eingabe `fehlerfall` auf `true` setzen. Der optionale Schritt führt aus:

```bash
grep -c "FATAL" daten/server.log
```

**Ausgabe:** `0`, aber `grep` liefert Exit-Code `1`, weil kein Treffer gefunden wurde. `continue-on-error: true` macht den Fehler tolerierbar, sodass der Workflow weiterläuft. Der genaue Status, den GitHub in der Oberfläche anzeigt, ist **ungetestet**. Wenn kein Treffer ein gültiges Ergebnis ist, kann `|| true` den Status abfangen; echte Dateifehler würden dadurch aber ebenfalls verdeckt.

#### Aufgabe 5

```bash
grep ' ERROR ' daten/server.log | tail -n 1
```

**Ausgabe:**

```text
2026-10-19 08:25:55 ERROR Datenbank nicht erreichbar
```

Lokal verifiziert. `tail` ist hier korrekt, weil das Log chronologisch sortiert ist.

### Lektion 4: Variablen und das erste Shell-Skript

#### Aufgabe 1
Beim manuellen Start als Eingabe beispielsweise `Anna` wählen. Der vorhandene Workflow übergibt sie sicher:

```yaml
      - name: Skript ausführen
        env:
          NAME: ${{ inputs.name }}
        run: ./skripte/begruessung.sh "$NAME"
```

**Erwartete Ausgabe (Wochentag abhängig):**

```text
Hallo, Anna!
Heute ist Tuesday.
Ich zähle bis 3:
  -> 1
  -> 2
  -> 3
```

Die englische Tagesbezeichnung ist typisch, aber Runner-/Locale-abhängig und im GitHub-Runner **ungetestet**.

#### Aufgabe 2
Vollständiger geänderter Skriptinhalt:

```bash
#!/bin/bash
# Ein einfaches Skript mit Variable und Schleife
NAME="$1"
if [ -z "$NAME" ]; then NAME="Unbekannt"; fi
echo "Hallo, $NAME!"
echo "Heute ist $(date +%A)."
echo "Ich zähle bis 5:"
for i in 1 2 3 4 5; do
  echo "  -> $i"
done
```

**Erwartete Ausgabe:** die Zahlen `1` bis `5`, je eine Zeile.

#### Aufgabe 3
Vor der Schleife ergänzen:

```bash
echo "Uhrzeit: $(date +%H:%M)"
```

Die Ausgabe hat das Format `Uhrzeit: HH:MM`; der konkrete Wert ist zeitabhängig.

#### Aufgabe 4
Beim manuellen Start von `04-skript.yml` die Eingabe `fehlerfall` auf `true` setzen. Der Workflow führt `chmod -x skripte/begruessung.sh` aus und versucht danach `./skripte/begruessung.sh "$NAME"` direkt zu starten. Dadurch wird unabhängig vom gespeicherten Git-Dateimodus typischerweise `Permission denied` erwartet. `continue-on-error: true` lässt den Job fortsetzen. Das genaue Verhalten und die Anzeige auf GitHub sind **ungetestet**. Alternative `bash skripte/begruessung.sh "$NAME"` braucht kein Ausführungsbit.

## Teil 2

### Lektion 5: Mehrere Jobs und `needs:`

Arbeite in deinem eigenen Lern-Repository aus Teil 1 weiter. Für die Lektionen 5 bis 8 überträgst du die aufgelisteten Workflows und Beispieldateien aus dem Kurs-Repository ins Lern-Repository und startest die Läufe dort. `daten/server.log` stammt aus Teil 1.

#### Aufgabe 1
Im Workflow `.github/workflows/05-mehrere-jobs.yml` des Lern-Repositorys starten `zaehlen` und `parallel-a` ohne `needs:` parallel. `melden` wartet wegen `needs: zaehlen` auf `zaehlen`. Erwartet werden `Gefunden: 3` und `Der Job zaehlen meldet 3 Fehler`. Lokale Daten-/Shell-Ausgabe geprüft; Actions-Graph **ungetestet**.

#### Aufgabe 2
Füge den folgenden Job in `.github/workflows/05-mehrere-jobs.yml` des Lern-Repositorys ein:

```yaml
  abschluss:
    runs-on: ubuntu-latest
    needs: [melden, parallel-a]
    steps:
      - name: Abschluss melden
        run: echo "Beide vorgelagerten Jobs sind abgeschlossen"
```

`abschluss` startet erst, wenn `melden` und `parallel-a` erfolgreich beendet sind. Job-Graph **ungetestet**.

#### Aufgabe 3
Ändere im Workflow `.github/workflows/05-mehrere-jobs.yml` im Job `zaehlen` den Suchbegriff von `ERROR` auf `FATAL`:

```yaml
          ANZAHL=$(grep -c ' FATAL ' daten/server.log || true)
          echo "Gefunden: $ANZAHL"
          echo "anzahl=$ANZAHL" >> "$GITHUB_OUTPUT"
```

Für die Beispieldatei wird `0` weitergereicht. Wegen `|| true` bleibt `zaehlen` grün; `melden` läuft weiter und meldet sinngemäß `Der Job zaehlen meldet 0 Fehler`. GitHub-Output-Weitergabe **ungetestet**, Shell-/Datenwert lokal plausibilisiert.

#### Aufgabe 4
Ohne Checkout fehlt `daten/server.log`. `grep` gibt den Dateifehler auf stderr aus und liefert Exit-Code 2. `|| true` unterdrückt den Fehlertext nicht, fängt aber den Status ab. Da die Befehlssubstitution keinen Wert enthält, ist `ANZAHL` leer. Erwartet werden im Protokoll `Gefunden: ` und danach `Der Job zaehlen meldet  Fehler` (ohne Zahl). Bash-Verhalten lokal reproduziert; der GitHub-Joblauf und die Anzeige sind **ungetestet**.

### Lektion 6: Häufigkeiten zählen und Dateien durchsuchen

Übertrage `.github/workflows/06-auswerten.yml` sowie die Beispieldateien `daten/zugriffe.log` und `daten/bericht.txt` aus dem Kurs-Repository ins Lern-Repository. Die Auswertungsbefehle filtern Kommentarzeilen heraus.

#### Aufgabe 1

```bash
grep -v '^#' daten/zugriffe.log | cut -d' ' -f1 | sort | uniq -c | sort -nr | head -n 1
```

**Ausgabe:** `4 anna`. Lokal verifiziert. Bei Gleichstand würde `head -n 1` nur eine der gleich häufigen Personen zeigen.

Die Seitenzählung wird analog ausgeführt:

```bash
grep -v '^#' daten/zugriffe.log | cut -d' ' -f2 | sort | uniq -c | sort -nr
```

Ergebnis: `/produkte=4`, `/start=3`, `/kontakt=3`.

#### Aufgabe 2

```bash
grep -v '^#' daten/server.log | awk '{print $3}' | sort | uniq -c | sort -nr
```

**Ausgabe:**

```text
      5 INFO
      3 ERROR
      1 WARNING
```

Lokal mit den Daten aus dem Lern-Repository geprüft. `grep -v '^#'` entfernt die Kommentarzeilen der Beispieldatei; die Schweregrade stehen danach in Spalte 3.

#### Aufgabe 3

```bash
find daten -type f -name "*.txt"
```

Im Lern-Repository ergibt sich für diesen Befehl folgende Ausgabe:

```text
daten/einkauf.txt
daten/bericht.txt
```

Ein Aufruf von `find . -type f -name "*.txt"` durchsucht stattdessen das ganze Lern-Repository. Dabei können abhängig von den vorhandenen Dateien weitere Treffer erscheinen.

#### Aufgabe 4
Entferne im Workflow im Lern-Repository `sort`, und zwar das direkt vor `uniq -c`:

```bash
grep -v '^#' daten/zugriffe.log | cut -d' ' -f1 | uniq -c | sort -nr
```

werden nur direkt benachbarte gleiche Namen gezählt. Für die Beispieldaten im Lern-Repository entstehen dadurch mehrere Teilgruppen statt der korrekten Summen; `anna` erscheint z. B. als einzelne Gruppen mit `1`, statt insgesamt `4`. `sort` muss vor `uniq -c` stehen. Lokal mit den Beispieldaten im Lern-Repository verifiziert.

### Lektion 7: Artefakte hochladen und herunterladen

Übertrage `.github/workflows/07-artefakte.yml` und die benötigten Beispieldateien aus dem Kurs-Repository in dein Lern-Repository. Pushe alle Dateien, bevor du den Workflow startest. Der Workflow im Lern-Repository lädt den Bericht mit `actions/upload-artifact@v7` hoch; `actions/download-artifact@v8` zeigt, wie ein zweiter Job das Artefakt weiterverwendet.

#### Aufgabe 1
Starte den Workflow im Lern-Repository. Job `bericht` erzeugt `ergebnis/bericht.txt` und lädt die Datei unter dem Artefaktnamen `auswertung` hoch. Job `weiterverarbeiten` wartet mit `needs: bericht`, lädt das Artefakt mit `actions/download-artifact@v8` nach `weitergabe/` herunter und gibt die Datei aus. Im Browser kann dasselbe Artefakt als ZIP heruntergeladen werden.

**Erwarteter Inhalt der Datei `bericht.txt`** (das Datum variiert):

```text
Auswertung vom YYYY-MM-DD
Fehler im Server-Log: 3
Datensätze im Zugriffslog: 10
Beliebteste Seite:
      4 /produkte
```

Berichtinhalt und lokale Berichtserzeugung sind geprüft. GitHub-Upload, Browser-Download, Job-Abhängigkeit und Job-zu-Job-Download sind **ungetestet**.

#### Aufgabe 2
Der Browser-Download wurde bereits in Aufgabe 1 beschrieben. Er ist vom automatischen Download im Job `weiterverarbeiten` zu unterscheiden. Der Download durch `actions/download-artifact@v8` ist **ungetestet**.

#### Aufgabe 3
Im Block des Jobs `bericht` die folgende Zeile vor `} | tee ergebnis/bericht.txt` ergänzen:

```bash
            echo "Warnungen im Server-Log: $(grep -c ' WARNING ' daten/server.log || true)"
```

Erwartete zusätzliche Zeile: `Warnungen im Server-Log: 1`. Lokal verifiziert.

#### Aufgabe 4
Dem `with:`-Block des Schritts `Ergebnis hochladen` den Wert `retention-days` hinzufügen:

```yaml
        with:
          name: auswertung
          path: ergebnis/
          retention-days: 1
```

Committe und pushe die Änderung im Lern-Repository und starte den Workflow erneut. Nur neu erstellte Artefakte erhalten die neue Frist. Ob die Fristangabe in der Ansicht erscheint, wurde **nicht getestet**.

#### Aufgabe 5
Ändere im Upload-Schritt `Ergebnis hochladen` den Wert `path` auf diese mehrzeilige Liste:

```yaml
        with:
          name: auswertung
          path: |
            ergebnis/
            daten/server.log
```

Damit werden der Bericht und zusätzlich `daten/server.log` in dasselbe Artefakt aufgenommen. Upload-Inhalt **ungetestet**.



### Lektion 8: Zeitplan mit Cron und weitere Trigger

Übertrage `.github/workflows/08-zeitplan.yml` aus dem Kurs-Repository ins Lern-Repository und pushe sie auf den Standardbranch. Dort ist der manuelle Start verfügbar; der Schedule-Test gehört zur betreuten Aufgabe im Kurs-Repository.

Vor den Aufgaben: Pushe `.github/workflows/08-zeitplan.yml` auf den Standardbranch deines Lern-Repositorys, damit `workflow_dispatch` in **Actions** verfügbar wird. Beim manuellen Start wird `workflow_dispatch` ausgegeben. Ein realer manueller Lauf ist **ungetestet**.

#### Aufgabe 1
Ändere im Lern-Repository `daten/einkauf.txt`, committe und pushe die Änderung auf einen Arbeitsbranch, der Workflow 08 enthält. Wegen `push.paths: ["daten/**"]` sollte ein Lauf mit

```text
Ausgelöst durch: push
```

entstehen. GitHub-Trigger **ungetestet**.

#### Aufgabe 2
Cron-Ausdrücke, passend zu den drei Zeitangaben:


```text
# täglich 12:00 UTC
0 12 * * *
# jeden Freitag 17:45 UTC
45 17 * * 5
# alle 30 Minuten
*/30 * * * *
```

#### Aufgabe 3
Betreute Zusatzaufgabe im Kurs-Repository: Die Schedule-Datei muss auf dessen Standardbranch liegen. Die Kursleitung nimmt über den Git-Flow des Kurs-Repositories eine geprüfte Änderung auf `*/5 * * * *` vor und integriert sie in den Standardbranch.

```yaml
  schedule:
    - cron: "*/5 * * * *"
```

Nach einigen Minuten kann die Kursleitung mit der Gruppe im Actions-Tab prüfen, ob ein `schedule`-Lauf erscheint. Anschließend stellt sie den ursprünglichen Cron-Ausdruck über eine weitere geprüfte Änderung wieder her. Ein manueller `workflow_dispatch`-Lauf testet den Zeitplan nicht. Geplante Läufe können verzögert sein oder ausbleiben; der Live-Test ist **ungetestet**.

### Abschlussprojekt: Der Auto-Prüfer

Übertrage `.github/workflows/09-pruefer.yml` aus dem Kurs-Repository ins Lern-Repository und pushe sie zunächst auf dessen Standardbranch, damit `workflow_dispatch` verfügbar ist. Erstelle dann einen Arbeitsbranch vom aktualisierten Standardbranch; so enthält auch er den Workflow. Lege dort `loesungen/aufgabe1.txt` mit der Antwort `3` an und pushe sie. Der `push`-Trigger kann nun starten.

#### Aufgabe 1
In deinem Lern-Repository `loesungen/aufgabe1.txt` auf `5` setzen, committen und pushen:

```bash
printf '5\n' > loesungen/aufgabe1.txt
git add loesungen/aufgabe1.txt
git commit -m "Falsche Antwort testen"
git push
```

Der Prüfschritt gibt `Erwartet: 3, Antwort: 5`, danach `Leider falsch. Tipp: grep -c`, dann beendet er sich mit `exit 1`. GitHub-Status **ungetestet**, lokale Vergleichslogik geprüft.

#### Aufgabe 2
Die Datei in deinem Lern-Repository auf `3` korrigieren, committen und pushen:

```bash
printf '3\n' > loesungen/aufgabe1.txt
git add loesungen/aufgabe1.txt
git commit -m "Antwort korrigieren"
git push
```

Erwartete Meldung: `Erwartet: 3, Antwort: 3` und `Richtig!`; der Schritt sollte grün werden (**ungetestet**).

#### Aufgabe 3
Erstelle im Lern-Repository `loesungen/aufgabe2.txt` mit der Beispielantwort `5` und pushe die Datei.

Füge diesen Schritt zum Auto-Prüfer in deinem Lern-Repository hinzu:

```yaml
      - name: Aufgabe 2 prüfen
        run: |
          ERWARTET=$(grep -vc '^#' daten/einkauf.txt)
          ANTWORT=$(tr -d '[:space:]' < loesungen/aufgabe2.txt)
          echo "Erwartet: $ERWARTET, Antwort: $ANTWORT"
          if [ "$ANTWORT" = "$ERWARTET" ]; then
            echo "Richtig!"
          else
            echo "Leider falsch."
            exit 1
          fi
```

Erwartet: `5`, Antwort: `5`, danach `Richtig!`. Lokal verifiziert.

#### Aufgabe 4
Beispiel für eine eigene Frage: meistbesuchte Seite. Lege im Lern-Repository `loesungen/aufgabe3.txt` mit `/produkte` an und pushe die Datei:

```text
/produkte
```

Ergänze folgenden Schritt im Auto-Prüfer deines Lern-Repositorys:

```yaml
      - name: Aufgabe 3 prüfen
        run: |
          ERWARTET=$(grep -v '^#' daten/zugriffe.log | cut -d' ' -f2 | sort | uniq -c | sort -nr | awk 'NR==1 {print $2}')
          ANTWORT=$(tr -d '[:space:]' < loesungen/aufgabe3.txt)
          echo "Erwartet: $ERWARTET, Antwort: $ANTWORT"
          if [ "$ANTWORT" = "$ERWARTET" ]; then
            echo "Richtig!"
          else
            echo "Leider falsch."
            exit 1
          fi
```

Erwartete Werte sind `ERWARTET=/produkte` und `ANTWORT=/produkte`; lokal verifiziert. (Bei gleichen Häufigkeiten wäre dieses `head`-ähnliche Verfahren nicht eindeutig.)

## Teil 3

### Lektion 9: Matrix-Builds

#### Aufgabe 1
Die Matrix `[INFO, WARNING, ERROR]` erzeugt drei Jobs: `suchen (INFO)`, `suchen (WARNING)` und `suchen (ERROR)`. Die Job-Namen/Ansicht sind **ungetestet**.

#### Aufgabe 2

```yaml
        stufe: [INFO, WARNING, ERROR, FATAL]
```

Es entstehen vier Läufe. Für `FATAL` gibt `grep -c` `0` aus; `|| true` verhindert den Fehlerstatus. Erwartete Meldung: `Stufe FATAL: 0 Einträge`. Lokal verifiziert; Matrixausführung **ungetestet**.

#### Aufgabe 3
Vollständiger Matrixblock:

```yaml
      fail-fast: false
      matrix:
        stufe: [INFO, ERROR]
        datei: [daten/server.log, daten/zugriffe.log]
```

Das ergibt `2 × 2 = 4` Läufe. `ERROR` passt sinnvoll zu `server.log`; `INFO` ebenfalls. Beide Suchstufen sind für `zugriffe.log` fachlich sinnlos, weil diese Datei keine Log-Level enthält; technisch können sie trotzdem Treffer liefern, falls ein Suchwort im Text vorkommt.

#### Aufgabe 4
Im `run:`-Block ergänzen:

```bash
          [ "$STUFE" != "WARNING" ] || exit 1
```

Bei `WARNING` schlägt ein Matrix-Lauf absichtlich fehl. Mit `fail-fast: true` versucht GitHub laufende andere Matrix-Läufe abzubrechen; bereits beendete Läufe bleiben bestehen. Mit `false` laufen die anderen weiter. Das konkrete Timing/der Graph ist **ungetestet**.

### Lektion 10: Secrets und Variablen

#### Aufgabe 1
Nach dem Anlegen von `KURS_GEHEIMNIS=Pinguin42` und `KURS_THEMA=Linux` lautet die erwartete Ausgabe:

```text
Das Kursthema ist Linux
Länge des Geheimnisses: 9
Wert: ***
```

`Pinguin42` hat 9 Zeichen; GitHub soll den exakten Secret-Wert maskieren. Anlegen und Maskierung sind **ungetestet**.

#### Aufgabe 2
Nur den Repository-Wert `KURS_THEMA` ändern und den Workflow erneut starten; die YAML-Datei bleibt unverändert. Tatsächlicher Settings-/Workflow-Effekt **ungetestet**.

#### Aufgabe 3

```yaml
        run: echo "$GEHEIMNIS" | rev
```

Für `Pinguin42` wäre der veränderte Text `24niugniP`. Ob bzw. wie dieser veränderte Wert maskiert wird, darf nicht vorausgesetzt werden: die Maskierung zielt auf den exakten Wert und ist kein verlässlicher Schutz gegen Transformationen. **Ungetestet; Secret nicht ausgeben.**

#### Aufgabe 4
Ein echtes Passwort gehört als Secret gespeichert, weil Variablenwerte lesbar und für normale Konfiguration gedacht sind. Ein Secret wird dagegen geschützt und im Log maskiert; trotzdem darf man es nicht absichtlich ausgeben oder in Artefakte schreiben.

### Lektion 11: Wiederverwendbare Workflows

#### Aufgabe 1
Der Aufrufer erzeugt die Jobs `fehler` und `zugriffe`, die jeweils `.github/workflows/12-zaehler.yml` verwenden; anschließend wartet `ergebnis` auf beide. Graphdarstellung **ungetestet**.

#### Aufgabe 2
Zusätzlicher Job im Aufrufer:

```yaml
  warnungen:
    uses: ./.github/workflows/12-zaehler.yml
    with:
      datei: daten/server.log
      suchwort: WARNING
```

`ergebnis` muss die Abhängigkeit und Ausgabe ergänzen:

```yaml
    needs: [fehler, zugriffe, warnungen]
    steps:
      - name: Ergebnisse ausgeben
        env:
          FEHLER: ${{ needs.fehler.outputs.anzahl }}
          ZUGRIFFE: ${{ needs.zugriffe.outputs.anzahl }}
          WARNUNGEN: ${{ needs.warnungen.outputs.anzahl }}
        run: |
          echo "Fehler im Server-Log: $FEHLER"
          echo "Zugriffe auf /produkte: $ZUGRIFFE"
          echo "Warnungen im Server-Log: $WARNUNGEN"
```

Erwartete Werte: `3`, `4`, `1`; Zählungen lokal verifiziert, Workflow-Call **ungetestet**.

#### Aufgabe 3
Im wiederverwendbaren Workflow beide Felder ändern:

```yaml
      suchwort:
        description: "Gesuchtes Wort"
        required: false
        default: "ERROR"
        type: string
```

Beim Weglassen wird `ERROR` verwendet; `grep` zählt somit die drei Fehlerzeilen. GitHub-Workflow-Call **ungetestet**.

#### Aufgabe 4
Wird nur die Schritt-ID von `suche` umbenannt, aber nicht

```yaml
outputs:
  anzahl: ${{ steps.suche.outputs.anzahl }}
```

angepasst, verweist der Job-Output auf eine nicht mehr passende Schritt-ID. Der Workflow-Output bzw. der Aufrufer erhält keinen gültigen Wert; je nach GitHub-Validierung kann der Workflow bereits validierungsseitig scheitern. Die genaue GitHub-Meldung ist **ungetestet**. Lösung: ID und Referenz gemeinsam umbenennen.

### Lektion 12: Bedingungen, Zusammenfassungen und Fehlerbehandlung

#### Aufgabe 1
Bei `modus=normal` läuft `Immer`, der absichtliche Fehler wird übersprungen, `Nur bei Erfolg`, `Aufräumen` und `Zusammenfassung` laufen. `optional` läuft ebenfalls; sein Fehler wird toleriert. Die Zusammenfassung enthält `Modus: normal` und typischerweise `Status: success`. Laufansicht **ungetestet**.

#### Aufgabe 2
Bei `modus=fehler`: `Immer` läuft, `Absichtlicher Fehler` endet mit `exit 1`, `Nur bei Erfolg` wird übersprungen, `Nur bei Fehler` und `Aufräumen` laufen, die Zusammenfassung läuft mit `always()`. Sie enthält `Modus: fehler` und typischerweise `Status: failure`. Die Summary erscheint oben auf der Laufübersicht. GitHub-Verhalten **ungetestet**.

#### Aufgabe 3
Ohne `if: ${{ always() }}` gilt die Standardbedingung `success()`. Nach dem absichtlichen Fehler wird der Aufräumschritt daher im Fehlermodus übersprungen. Im Normalmodus läuft er weiter. Das ist gemäß Actions-Semantik, aber **ungetestet**.

#### Aufgabe 4

```yaml
    timeout-minutes: 1
    # ...
      - name: Langer Schritt
        run: sleep 90
```

Nach etwa einer Minute wird der Job wegen des Zeitlimits abgebrochen; nachfolgende Standardschritte werden nicht normal weitergeführt. Exakte Abbruchmeldung und Status **ungetestet**.

### Abschlussprojekt: Auswertungs-Pipeline

#### Aufgabe 1
Die drei Matrix-Läufe erzeugen:

```text
INFO=5
WARNING=1
ERROR=3
```

Die Zusammenfassung steht in der Laufübersicht und enthält entsprechend `- INFO=5`, `- WARNING=1`, `- ERROR=3` (Reihenfolge der Dateiglobs kann abweichen). Lokale Zählwerte verifiziert; Matrix, Artefakte und Summary **ungetestet**.

#### Aufgabe 2
Matrix ändern zu:

```yaml
        stufe: [INFO, WARNING, ERROR, FATAL]
```

Zusätzliche Datei `FATAL.txt` mit `FATAL=0`; die übrigen Zahlen bleiben `INFO=5`, `WARNING=1`, `ERROR=3`. Lokal verifiziert; Upload/Download **ungetestet**.

#### Aufgabe 3
Ein direkter `uses:`-Aufruf kann nicht zugleich eigene `steps:` für den Upload enthalten. Deshalb muss der wiederverwendbare Workflow um einen Upload-Schritt erweitert werden, z. B.:

```yaml
      - name: Teilergebnis hochladen
        uses: actions/upload-artifact@v7
        with:
          name: ergebnis-${{ inputs.suchwort }}
          path: ergebnis/
```

Dafür braucht `12-zaehler.yml` zusätzlich eine Datei-/Ergebnis-Erzeugung, etwa:

```yaml
          mkdir -p ergebnis
          ANZAHL=$(grep -c -- "$SUCHWORT" "$DATEI" || true)
          echo "$SUCHWORT=$ANZAHL" > "ergebnis/$SUCHWORT.txt"
          echo "anzahl=$ANZAHL" >> "$GITHUB_OUTPUT"
```

Der Pipeline-Matrixjob wird dann zu einem aufgerufenen Job mit `uses: ./.github/workflows/12-zaehler.yml`, `with: datei: daten/server.log` und `suchwort: ${{ matrix.stufe }}`. Der Job kann dabei nicht zusätzlich `runs-on:` oder `steps:` enthalten. Der Job `zusammenfassen` und sein Download-/Summary-Code bleiben unverändert, sofern die Artefaktnamen und Dateien gleich bleiben. Workflow-Call/Artefaktverhalten **ungetestet**.

#### Aufgabe 4a
Vor dem Speichern:

```bash
          [ "$STUFE" != "WARNING" ] || exit 1
```

Der `WARNING`-Lauf beendet sich vor dem Upload; in `sammlung/` fehlt `WARNING.txt`. Wegen `if: ${{ !cancelled() }}` startet `zusammenfassen` trotz des fehlgeschlagenen Matrix-Laufs. Der Download findet die übrigen Artefakte und die Summary enthält nur `INFO=5` und `ERROR=3` (plus ggf. vorhandene weitere Läufe). Das konkrete Actions-Verhalten ist **ungetestet**.

#### Aufgabe 4b
Direkt nach dem Erzeugen des Ordners:

```bash
          mkdir -p ergebnis
          exit 1
```

Im Schritt `Zusammenfassung schreiben` zum Testen ergänzen:

```yaml
        env:
          LADEN: ${{ steps.laden.outcome }}
          CONCLUSION: ${{ steps.laden.conclusion }}
        run: |
          echo "outcome=$LADEN, conclusion=$CONCLUSION"
          if [ "$LADEN" != "success" ]; then
            echo "Download fehlgeschlagen (Status: $LADEN), Details im Log des Schritts 'Teilergebnisse laden'." | tee -a "$GITHUB_STEP_SUMMARY"
            exit 1
          fi
```

Bei einem tatsächlich fehlgeschlagenen Download werden `outcome=failure` und wegen `continue-on-error: true` typischerweise `conclusion=success` erwartet. Der Folgeschritt läuft weiter, weil sein Download-Schritt den Job nicht fehlschlagen lässt. Die Summary soll `Download fehlgeschlagen ...` statt Zahlen enthalten; der Job `zusammenfassen` endet anschließend mit Fehler. Ob `download-artifact@v8` bei null Treffern `failure` oder `success` meldet, ist laut Kurstext nicht ausdrücklich garantiert und hier **ungetestet**. Falls `outcome=success` gilt, greift die anschließende `ls sammlung/*.txt`-Prüfung und meldet `Download erfolgreich, aber keine Teilergebnis-Dateien gefunden.`. Die genaue Download-Logmeldung ist ebenfalls **ungetestet**.

#### Aufgabe 5
Mit `if: ${{ !cancelled() }}` soll `zusammenfassen` nach einem Abbruch nicht mehr starten; war es bereits gestartet, kann es je nach Zeitpunkt weiterlaufen oder beendet werden. Mit `if: ${{ always() }}` darf der Job auch nach einer Abbruchanforderung noch starten, kann aber anschließend ebenfalls abgebrochen werden. Das Ergebnis hängt vom Zeitpunkt und GitHub-Abbruchverhalten ab und ist **ungetestet**.

## Lokale Validierung und aufgefallene Unstimmigkeiten

### Lokal verifiziert

- `grep -c ' ERROR ' daten/server.log` ergibt `3`.
- `wc -l daten/einkauf.txt` ergibt `5`; `daten/server.log` enthält `9` Logzeilen.
- `grep -vc '^#' daten/zugriffe.log` ergibt `10` Zugriffsdatensätze; mit zwei Kopfzeilen sind es `12` physische Zeilen.
- `grep -vc '^#' daten/bericht.txt` ergibt `4` Berichtzeilen.
- Der simulierte Berichtschritt gibt `Auswertung vom <Datum>`, `Fehler im Server-Log: 3`, `Datensätze im Zugriffslog: 10` und `      4 /produkte` aus. Das Datum hängt vom Ausführungszeitpunkt ab.
- `bash -n skripte/begruessung.sh` und `shellcheck skripte/begruessung.sh` laufen für die eingecheckte Skriptfassung ohne Meldungen.
- `INFO` ergibt `5`, `WARNING` ergibt `1`.
- `grep 'anna' daten/server.log` liefert zwei Zeilen.
- `grep -E ' (WARNING|ERROR) ' daten/server.log` liefert vier Zeilen.
- `grep ' ERROR ' ... | tail -n 1` liefert den Zeitstempel `2026-10-19 08:25:55`.
- `grep -v '^#' daten/zugriffe.log | cut -d' ' -f1 | sort | uniq -c | sort -nr` ergibt Personen `anna=4`, `clara=3`, `ben=3`.
- Nach Herausfiltern der Kommentarzeilen ergeben sich Seiten `/produkte=4`, `/start=3`, `/kontakt=3`; Top 1 ist `/produkte`. Die Beispieldatei enthält 12 physische Zeilen (2 Hinweise, 10 Datensätze).
- `grep -v '^#' daten/bericht.txt | wc -l` ergibt vier Zeilen Berichtstext.
- `grep -v '^#' daten/server.log | awk '{print $3}' | sort | uniq -c | sort -nr` ergibt `INFO=5`, `ERROR=3`, `WARNING=1`.
- `wc -l daten/einkauf.txt` ergibt `5`; die Auto-Prüfung mit Antwort `3` ergibt `match=yes` für Aufgabe 1.
- `find daten -type f -name "*.txt"` findet im Lern-Repository genau `daten/einkauf.txt` und `daten/bericht.txt`.
- `uniq -c` ohne vorheriges `sort` zeigt nur Nachbargruppen und ist deshalb für Gesamthäufigkeiten falsch.

### Unstimmigkeiten / Fehler im Kurstext

1. **Teil 1, Lektion 1, Aufgabe 2:** Als Beispiel steht `2026-10-19`, während der aktuelle Ausführungstag laut Arbeitskontext **2026-10-20** ist. Das Beispiel ist ausdrücklich nur ein Beispiel; `date` liefert den tatsächlichen Tag.
2. **Teil 1, Lektion 2:** Der doppelte `mkdir`-Fehlertest läuft in einem eigenen Schritt unter `testordner`; `continue-on-error: true` verhindert, dass der absichtliche Fehler den gesamten Workflow fehlschlagen lässt.
3. **Teil 2, Lektion 6:** In der Musterzählung für Personen ist die Reihenfolge bei Gleichstand nicht fachlich eindeutig: `ben` und `clara` haben beide `3`. `sort -nr` kann bei gleicher Zahl eine Reihenfolge liefern, auf die man sich nicht als fachliche Rangfolge verlassen sollte. Die Kommentarzeilen der Beispieldatei müssen beim Zählen herausgefiltert werden.
4. **Teil 2, Lektion 7:** `|| true` beim `grep` fängt wie beschrieben nicht nur „keine Treffer“, sondern auch echte Dateifehler ab. Das ist als Kursvereinfachung markiert, sollte in produktiven Workflows aber nicht unverändert verwendet werden.
5. **Teil 3, Lektion 9, Aufgabe 3:** Die zweidimensionale Matrix mit `stufe` und `datei` erzeugt technisch auch sinnlose Kombinationen (`INFO`/`WARNING`/`ERROR` gegen `daten/zugriffe.log`). Das ist keine Rechenfehler, aber eine fachliche Unstimmigkeit, die der Kurs selbst erwähnt.
6. **Teil 3, Lektion 10, Aufgabe 3:** Die Aussage zur Secret-Maskierung nach `rev` ist absichtlich vorsichtig. Es darf nicht behauptet werden, dass der veränderte Wert sicher maskiert wird.
7. **Teil 3, Abschlussprojekt, Aufgabe 4b:** Das Verhalten von `download-artifact@v8` bei null passenden Artefakten wird im Kurs selbst als nicht ausdrücklich dokumentierte Zusage bezeichnet. Deshalb ist eine eindeutige erwartete Meldung hier nicht garantiert; die vorhandene `ls`-Absicherung ist notwendig.
8. **Teil 3, Lektion 12:** `always()` kann nach einer Abbruchanforderung noch starten, garantiert aber kein vollständiges Weiterlaufen. Ein beobachtetes Ergebnis hängt vom Zeitpunkt ab und ist kein stabiler Sollwert.
9. **YAML-Parserprüfung:** Die ursprüngliche YAML-Beispielzeile mit Doppelpunkt und unquotiertem `run:`-Scalar war mehrdeutig. Die ausführbare `.github/workflows/08-zeitplan.yml` nutzt einen Block-Scalar und wird im Rahmen der Überarbeitung mit `actionlint` geprüft. Markdown-Codeblöcke sind nicht mehr die ausführbare Quelle.
