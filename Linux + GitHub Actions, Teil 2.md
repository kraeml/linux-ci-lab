# Kurs: Linux + GitHub Actions, Teil 2 (v4)

Teil 2 baut auf Teil 1 auf. Du brauchst dieselbe Repo-Struktur, insbesondere `daten/server.log` aus Lektion 3. Es gibt **4 Lektionen** und ein Abschlussprojekt.

> Die Befehlsausgaben in den Erklärungen sind Beispiele. Prüfe sie immer gegen dein echtes Log im Actions-Tab.

## Vorbereitung

Lege zusätzlich diese Dateien an (Ordner entstehen automatisch über den Pfad im Dateinamen):

**`daten/zugriffe.log`** (erfundene Beispieldaten):

```
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

Erwartete Zählung: `/produkte` 4, `/start` 3, `/kontakt` 3. Damit ist die meistbesuchte Seite eindeutig.

> Hast du die Datei schon mit dem alten Inhalt angelegt, ändere die letzte Zeile von `clara /start` auf `clara /kontakt`.

**`daten/bericht.txt`**:

```
Quartalsbericht
Umsatz steigt
Kosten sinken
Ausblick positiv
```

---

## Lektion 5: Mehrere Jobs und `needs:`

**Lernziele:** Jobs parallel und nacheinander ausführen, `needs:`, Job-Ausgaben mit `GITHUB_OUTPUT`

**Datei:** `.github/workflows/05-mehrere-jobs.yml`

```yaml
name: 05 - Mehrere Jobs

on:
  workflow_dispatch:

jobs:
  zaehlen:
    runs-on: ubuntu-latest
    outputs:
      fehler: ${{ steps.zaehle.outputs.anzahl }}
    steps:
      - uses: actions/checkout@v4

      - name: Fehler zählen
        id: zaehle
        run: |
          ANZAHL=$(grep -c "ERROR" daten/server.log || true)
          echo "Gefunden: $ANZAHL"
          echo "anzahl=$ANZAHL" >> "$GITHUB_OUTPUT"

  parallel-a:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Ich laufe gleichzeitig mit zaehlen"

  melden:
    runs-on: ubuntu-latest
    needs: zaehlen
    steps:
      - name: Ergebnis ausgeben
        env:
          FEHLER: ${{ needs.zaehlen.outputs.fehler }}
        run: echo "Der Job zaehlen meldet $FEHLER Fehler"
```

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

> **`|| true` hier bewusst:** Ohne Treffer liefert `grep -c` zwar `0`, aber Exit-Code 1, und der Schritt würde rot. Hier ist "keine Fehler" ein gültiges Ergebnis, daher fangen wir den Fehlerstatus ab. Das verschluckt allerdings auch echte `grep`-Fehler (Exit-Code 2), etwa bei einem falschen Dateipfad. Prüfe deshalb die Ausgabe im Log.

**Aufgaben**
1. Starte den Workflow und sieh dir die Graph-Ansicht an. Welche Jobs laufen parallel?
2. Füge einen vierten Job `abschluss` hinzu, der erst nach `melden` und `parallel-a` startet: `needs: [melden, parallel-a]`
3. Ändere in `zaehlen` den Suchbegriff auf `FATAL`. Läuft `melden` trotzdem? Was meldet er?
4. Entferne `actions/checkout` aus `zaehlen`. Im Log erscheint eine `grep`-Fehlermeldung (Datei nicht gefunden). Warum läuft `zaehlen` trotzdem grün durch, und warum läuft `melden` weiter? Was steht in der Ausgabe von `melden`? Das ist genau das Verhalten, vor dem der `|| true`-Hinweis oben warnt.

---

## Lektion 6: Häufigkeiten zählen und Dateien durchsuchen

**Lernziele:** `sort | uniq -c`, `sort -nr`, `awk` (Grundlagen), `find`

**Datei:** `.github/workflows/06-auswerten.yml`

```yaml
name: 06 - Auswerten

on:
  workflow_dispatch:

jobs:
  auswerten:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Wer war wie oft da?
        run: |
          echo "--- Besuche pro Person ---"
          cut -d' ' -f1 daten/zugriffe.log | sort | uniq -c | sort -nr

      - name: Welche Seiten sind beliebt?
        run: |
          echo "--- Seitenaufrufe ---"
          cut -d' ' -f2 daten/zugriffe.log | sort | uniq -c | sort -nr

      - name: Top 1
        run: |
          echo "--- Beliebteste Seite ---"
          cut -d' ' -f2 daten/zugriffe.log | sort | uniq -c | sort -nr | head -n 1

      - name: Mit awk eine Spalte holen
        run: awk '{print $2}' daten/zugriffe.log | sort -u

      - name: Dateien finden
        run: |
          echo "--- alle .log-Dateien ---"
          find . -name "*.log"
          echo "--- alle Dateien in daten/ ---"
          find daten -type f
```

**Das Zählmuster (merken!)**

```
cut -d' ' -f1 datei  |  sort  |  uniq -c  |  sort -nr
   ↓ Spalte holen        ↓        ↓ zählt      ↓ größte zuerst
                    gleiche      gleiche
                    nebeneinander Zeilen
```

`uniq` erkennt nur **direkt aufeinanderfolgende** gleiche Zeilen. Darum steht immer `sort` davor. Probiere es aus: Entferne `sort` im ersten Schritt und vergleiche die Ausgabe.

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

> `find` mit Platzhaltern: Setze das Muster in Anführungszeichen (`"*.log"`), damit die Shell es nicht schon vorher auflöst, sondern `find` es bekommt.

**Aufgaben**
1. Welche Person hat die meisten Zugriffe? Passe das Muster an und nutze `head -n 1`.
2. Zähle, wie oft jeder Log-Level (`INFO`, `ERROR`, `WARNING`) in `daten/server.log` vorkommt. Tipp: Der Level steht in einer bestimmten Spalte, mit `awk '{print $N}'` oder `cut -d' ' -f N` holst du sie. Prüfe zuerst mit `head`, in welcher Spalte der Level steht.
3. Finde alle `.txt`-Dateien im Repo
4. Entferne `sort` vor `uniq -c` und beschreibe, was sich ändert

---

## Lektion 7: Artefakte hochladen und herunterladen

**Lernziele:** Ergebnisse speichern, `upload-artifact`, Datei umleiten mit `>`, `tee`

**Datei:** `.github/workflows/07-artefakte.yml`

```yaml
name: 07 - Artefakte

on:
  workflow_dispatch:

jobs:
  bericht:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Bericht erzeugen
        run: |
          mkdir -p ergebnis
          {
            echo "Auswertung vom $(date +%Y-%m-%d)"
            echo "Fehler im Server-Log: $(grep -c 'ERROR' daten/server.log || true)"
            echo "Zeilen im Zugriffslog: $(wc -l < daten/zugriffe.log)"
            echo "Beliebteste Seite:"
            cut -d' ' -f2 daten/zugriffe.log | sort | uniq -c | sort -nr | head -n 1
          } | tee ergebnis/bericht.txt

      - name: Ergebnis hochladen
        uses: actions/upload-artifact@v4
        with:
          name: auswertung
          path: ergebnis/
```

> Wie in Lektion 5 fängt `|| true` auch echte `grep`-Fehler ab. Hier ist es nur vertretbar, weil die Kursdatei vorausgesetzt wird. Bei eigenen Workflows solltest du Fehler getrennt behandeln.

**So funktioniert es**

| Element | Bedeutung |
|---------|-----------|
| `{ ... } \| tee datei` | Fasst mehrere Befehle zusammen und schreibt die Ausgabe **gleichzeitig** ins Log und in die Datei |
| `wc -l < datei` | Zeilen zählen **ohne** Dateinamen in der Ausgabe |
| `upload-artifact@v4` | Lädt Dateien als Artefakt am Workflow-Lauf hoch |
| `name:` | Name des Artefakts |
| `path:` | Datei oder Ordner, der hochgeladen wird |

**Ergebnis herunterladen:** Öffne den fertigen Lauf und scrolle ganz nach unten zum Bereich **Artifacts**. Dort liegt `auswertung` als ZIP zum Herunterladen. Artefakte werden nach einer Aufbewahrungsfrist automatisch gelöscht. Mit `retention-days:` lässt sie sich festlegen. Für öffentliche Repositories sind grundsätzlich 1 bis 90 Tage möglich; Organisationen oder Unternehmen können die Höchstfrist weiter einschränken. `retention-days: 1` ist daher im Kurs-Repository normalerweise zulässig, sofern keine strengere Richtlinie greift. Eine geänderte Frist gilt nur für **neu erstellte** Artefakte, nicht rückwirkend für bereits hochgeladene.

**Mit `>` statt `tee`:**

```bash
echo "Hallo" > ergebnis/datei.txt     # nur in die Datei, keine Ausgabe im Log
echo "Hallo" | tee ergebnis/datei.txt # in Datei und ins Log
```

> **Artefakte verbinden Jobs:** Da jeder Job eine eigene Umgebung hat, lassen sich mit `upload-artifact` in einem Job und `actions/download-artifact` im nächsten Job ganze Dateien weitergeben. `GITHUB_OUTPUT` aus Lektion 5 eignet sich nur für kurze Werte.

**Aufgaben**
1. Starte den Workflow und lade das Artefakt herunter. Entpacke es und lies `bericht.txt`.
2. Ergänze eine zusätzliche Zeile im Bericht: Anzahl der `WARNING`-Einträge
3. Setze `retention-days: 1` unter `with:` und **starte den Workflow danach erneut**. Die Einstellung wirkt nur auf neu erstellte Artefakte, das Artefakt aus dem ersten Lauf behält seine alte Frist. Vergleiche in der Artefaktansicht die Ablauf- oder Aufbewahrungsinformation beider Läufe.
4. Lade zusätzlich `daten/server.log` im selben Schritt hoch, indem du unter `path:` mehrere Zeilen angibst:
   ```yaml
   path: |
     ergebnis/
     daten/server.log
   ```

---

## Lektion 8: Zeitplan mit Cron und weitere Trigger

**Lernziele:** `schedule:`, Cron-Syntax, `push` mit `paths:`, `pull_request`, mehrere Trigger

**Datei:** `.github/workflows/08-zeitplan.yml`

```yaml
name: 08 - Zeitplan

on:
  workflow_dispatch:
  push:
    paths:
      - "daten/**"
  pull_request:
    paths:
      - "daten/**"
  schedule:
    - cron: "30 6 * * 1"

jobs:
  taeglich:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Was hat mich ausgelöst?
        env:
          EREIGNIS: ${{ github.event_name }}
        run: echo "Ausgelöst durch: $EREIGNIS"

      - name: Log-Auswertung
        run: |
          echo "Zeilen im Log: $(wc -l < daten/server.log)"
          echo "Datum: $(date -u)"
```

**Trigger im Überblick**

| Trigger | Wann läuft der Workflow? |
|---------|--------------------------|
| `workflow_dispatch` | Auf Knopfdruck |
| `push` | Bei jedem Push (hier nur, wenn sich etwas in `daten/` ändert, dank `paths:`) |
| `pull_request` | Wenn ein Pull Request erstellt oder aktualisiert wird (hier ebenfalls nur bei Änderungen in `daten/`) |
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
- Ohne angegebene Zeitzone gelten die Zeiten in **UTC**, nicht in deiner lokalen Zeit. GitHub unterstützt bei Zeitplänen auch eine explizit angegebene Zeitzone; die genaue Schreibweise findest du in der aktuellen GitHub-Dokumentation. In diesem Kurs bleiben wir bei UTC.
- Geplante Workflows laufen nur, wenn die Workflow-Datei auf dem **Standardbranch** liegt. Sie verwenden den neuesten Commit dieses Branches.
- GitHub garantiert keinen pünktlichen Start. Bei hoher Last kann es zu Verzögerungen kommen oder ein Lauf ausfallen.
- In öffentlichen Repositories werden geplante Workflows nach 60 Tagen ohne Repository-Aktivität automatisch deaktiviert. Du kannst sie dann im Actions-Tab wieder aktivieren.
- Der kürzeste Abstand ist 5 Minuten.

**`push` testen:** Ändere eine Datei in `daten/` und committe. Der Workflow startet automatisch. Im Lauf siehst du `Ausgelöst durch: push`.

**Aufgaben**
1. Starte den Workflow manuell und prüfe, was bei `Ausgelöst durch` steht
2. Ändere `daten/einkauf.txt` per Commit und beobachte, ob der Workflow von selbst startet
3. Schreibe Cron-Ausdrücke für:
   - jeden Tag um 12:00 UTC
   - jeden Freitag um 17:45 UTC
   - alle 30 Minuten
4. Ändere den Cron-Ausdruck auf `*/5 * * * *` und committe die Workflow-Datei auf den Standardbranch. Warte einige Minuten und prüfe, ob der Zeitplan einen Lauf auslöst. Ein Push-Lauf startet durch diese Änderung **nicht**, weil der `push`-Trigger nur Änderungen unter `daten/` berücksichtigt. Der Lauf kann verzögert erscheinen; ein einzelner ausgebliebener Lauf beweist nicht, dass der Cron-Ausdruck falsch ist. Stelle den Cron-Ausdruck danach wieder zurück, damit du nicht dauerhaft Läufe erzeugst.

---

## Abschlussprojekt: Der Auto-Prüfer

Verbinde die Lektionen zu einem Workflow, der Aufgaben **automatisch prüft**.

**Vorbereitung:** Lege `loesungen/aufgabe1.txt` an. Sie enthält die Antwort eines Lernenden, nämlich die Anzahl der Fehler im Log (richtig wäre `3`):

```
3
```

**Datei:** `.github/workflows/09-pruefer.yml`

```yaml
name: 09 - Auto-Prüfer

on:
  workflow_dispatch:
  push:
    paths:
      - "loesungen/**"

jobs:
  pruefen:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Aufgabe 1 prüfen
        run: |
          ERWARTET=$(grep -c "ERROR" daten/server.log || true)
          ANTWORT=$(tr -d '[:space:]' < loesungen/aufgabe1.txt)
          echo "Erwartet: $ERWARTET, Antwort: $ANTWORT"
          if [ "$ANTWORT" = "$ERWARTET" ]; then
            echo "Richtig!"
          else
            echo "Leider falsch. Tipp: grep -c"
            exit 1
          fi
```

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
1. Ändere `loesungen/aufgabe1.txt` auf `5` und committe. Der Workflow sollte rot werden.
2. Korrigiere sie auf `3`. Der Workflow sollte grün werden.
3. Erweitere den Prüfer um Aufgabe 2: "Wie viele Zeilen hat `daten/einkauf.txt`?" (Lösungsdatei `loesungen/aufgabe2.txt`)
4. Ergänze Aufgabe 3 mit einer eigenen Frage auf Basis von `daten/zugriffe.log`

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
upload-artifact                 Ergebnisdateien speichern
cron: "min std tag mon wtag"    Zeitplan (ohne Angabe: UTC)
[ "$A" = "$B" ]                 Texte vergleichen
exit 1                          Schritt bewusst fehlschlagen lassen
```
