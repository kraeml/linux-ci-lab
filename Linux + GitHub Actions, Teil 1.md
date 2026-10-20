# Kurs: Linux + GitHub Actions, Teil 1 (v3)

## Vorbereitung (einmalig)

1. Lege auf GitHub ein öffentliches Repository `linux-lernen` mit README an.
2. Erstelle Dateien im Browser über **Add file → Create new file**. Gibst du als Dateinamen einen Pfad wie `daten/einkauf.txt` ein, legt GitHub die Ordner automatisch an. Leere Ordner lassen sich im Browser nicht anlegen.
3. Committe Workflow-Dateien auf den **Standardbranch** (meist `main`). Damit `workflow_dispatch` ausgelöst werden kann, muss die Workflow-Datei dort liegen. Beim manuellen Start kannst du anschließend einen Branch auswählen.

> Workflow-Dateien müssen in `.github/workflows/` liegen und auf `.yml` oder `.yaml` enden.

---

## Lektion 1: Hallo Linux

**Lernziele:** Aufbau eines Workflows, `echo`, `whoami`, `pwd`, `date`, `uname`

**Datei:** `.github/workflows/01-hallo-linux.yml`

```yaml
name: 01 - Hallo Linux

on:
  workflow_dispatch:

jobs:
  erkunden:
    runs-on: ubuntu-latest
    steps:
      - name: Begrüßung
        run: echo "Hallo aus dem Linux-Runner!"

      - name: Wer bin ich?
        run: whoami

      - name: Wo bin ich?
        run: pwd

      - name: Welches Datum ist heute?
        run: date

      - name: Welches System läuft hier?
        run: uname -a
```

**Ausprobieren**

1. Datei auf den Standardbranch committen
2. Tab **Actions** → links **„01 - Hallo Linux“** → **Run workflow**
3. Auf den Lauf klicken, dann auf den Job `erkunden`
4. Jeden Schritt aufklappen und die Ausgabe lesen

**Aufbau erklärt**

| Zeile | Bedeutung |
|-------|-----------|
| `name` | Anzeigename des Workflows |
| `on: workflow_dispatch` | Startet per Knopfdruck |
| `jobs` | Liste der Aufgaben |
| `runs-on: ubuntu-latest` | Läuft auf der von GitHub aktuell bereitgestellten Ubuntu-Umgebung. Die genaue Version kann sich mit der Zeit ändern. |
| `steps` | Schritte, die nacheinander laufen |
| `run` | Ein Linux-Kommando |

**Kommandos erklärt**

| Kommando | Zweck |
|----------|-------|
| `echo "text"` | Text ausgeben |
| `whoami` | Aktueller Benutzername (auf GitHub-Runnern üblicherweise `runner`) |
| `pwd` | Aktuelles Verzeichnis (**p**rint **w**orking **d**irectory) |
| `date` | Datum und Uhrzeit |
| `uname -a` | Systeminfos (`-a` = all). Die Ausgabe hängt von der Runner-Umgebung ab. |

**Aufgaben**

1. Füge einen Schritt hinzu, der `echo "Mein Name ist <dein Name>"` ausgibt.
2. Gib mit `date +%Y-%m-%d` nur das aktuelle Datum aus. Die Ausgabe sieht zum Beispiel so aus: `2026-10-19`.
3. Finde mit `uname -r` die Kernel-Version heraus.

---

## Lektion 2: Dateien und Ordner

**Lernziele:** `checkout` verstehen, `ls`, `cat`, `mkdir`, `touch`, `cp`, `mv`, `rm`

**Vorbereitung:** Lege die Datei `daten/einkauf.txt` an. Gib den vollständigen Pfad als Dateinamen ein; der Ordner `daten/` entsteht dabei automatisch.

```text
Brot
Milch
Käse
Äpfel
Kaffee
```

**Datei:** `.github/workflows/02-dateien.yml`

```yaml
name: 02 - Dateien und Ordner

on:
  workflow_dispatch:

jobs:
  dateien:
    runs-on: ubuntu-latest
    steps:
      - name: Repo auschecken
        uses: actions/checkout@v4

      - name: Was liegt im Repo?
        run: ls -la

      - name: Inhalt von daten/ anzeigen
        run: ls -l daten

      - name: Einkaufsliste lesen
        run: cat daten/einkauf.txt

      - name: Ordner und Dateien anlegen
        run: |
          mkdir -p arbeit
          touch arbeit/notizen.txt
          echo "Erste Notiz" > arbeit/notizen.txt
          ls -l arbeit

      - name: Kopieren, umbenennen, löschen
        run: |
          cp daten/einkauf.txt arbeit/kopie.txt
          mv arbeit/kopie.txt arbeit/liste.txt
          ls arbeit
          rm arbeit/notizen.txt
          echo "--- nach dem Löschen ---"
          ls arbeit
```

**Warum `checkout`?**

Jeder Job läuft in einer eigenen Runner-Umgebung. Damit die Dateien deines Repositorys dort bereitliegen, musst du sie mit `actions/checkout@v4` auschecken. Die Schritte **innerhalb desselben Jobs** teilen sich danach denselben Arbeitsbereich: Was ein Schritt anlegt, zum Beispiel `arbeit/`, ist im nächsten Schritt noch da.

`uses:` ruft eine fertige Action auf, `run:` führt Befehle in der Shell aus.

**Kommandos erklärt**

| Kommando | Zweck |
|----------|-------|
| `ls` | Dateien auflisten |
| `ls -l` | Mit Details wie Rechten, Größe und Datum |
| `ls -a` | Auch versteckte Dateien anzeigen (sie beginnen mit `.`) |
| `cat datei` | Dateiinhalt ausgeben |
| `mkdir ordner` | Ordner anlegen |
| `mkdir -p ordner` | Ordner anlegen, ohne Fehler, wenn er schon existiert |
| `touch datei` | Leere Datei anlegen |
| `cp quelle ziel` | Kopieren |
| `mv quelle ziel` | Verschieben oder umbenennen |
| `rm datei` | Löschen (**sofort und endgültig, kein Papierkorb**) |
| `>` | Ausgabe in eine Datei schreiben; überschreibt den bisherigen Inhalt |
| `>>` | Ausgabe an eine Datei anhängen |

**Aufgaben**

1. Lege einen zweiten Ordner `backup` an und kopiere `einkauf.txt` hinein.
2. Hänge mit `echo "Butter" >> arbeit/liste.txt` eine Zeile an und zeige die Datei mit `cat`. Das funktioniert, weil `arbeit/liste.txt` im Schritt davor im selben Job angelegt wurde.
3. Ändere `mkdir -p arbeit` zu `mkdir arbeit` und schreibe den Befehl direkt danach noch einmal in denselben `run:`-Block. Der zweite Aufruf schlägt fehl; die folgenden Befehle in diesem Schritt werden nicht mehr ausgeführt. Lies die Fehlermeldung. Warum löst `-p` das Problem?

---

## Lektion 3: Texte durchsuchen und auswerten

**Lernziele:** `head`, `tail`, `wc`, `grep`, `sort`, `cut`, Pipes (`|`)

**Vorbereitung:** Lege `daten/server.log` an. Die Zeitstempel sind frei erfundene Beispieldaten und müssen nicht zum aktuellen Datum passen.

```text
2026-10-19 08:01:12 INFO Server gestartet
2026-10-19 08:05:33 INFO Benutzer anna angemeldet
2026-10-19 08:07:45 ERROR Datenbank nicht erreichbar
2026-10-19 08:09:02 INFO Benutzer ben angemeldet
2026-10-19 08:12:10 WARNING Speicher bei 85 Prozent
2026-10-19 08:15:27 ERROR Zeitüberschreitung bei Anfrage
2026-10-19 08:20:41 INFO Benutzer anna abgemeldet
2026-10-19 08:25:55 ERROR Datenbank nicht erreichbar
2026-10-19 08:30:00 INFO Backup gestartet
```

**Datei:** `.github/workflows/03-texte.yml`

```yaml
name: 03 - Texte auswerten

on:
  workflow_dispatch:

jobs:
  logs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Anfang und Ende
        run: |
          echo "--- erste 3 Zeilen ---"
          head -n 3 daten/server.log
          echo "--- letzte 2 Zeilen ---"
          tail -n 2 daten/server.log

      - name: Zeilen zählen
        run: wc -l daten/server.log

      - name: Alle Fehler finden
        run: grep "ERROR" daten/server.log

      - name: Fehler zählen
        run: grep -c "ERROR" daten/server.log

      - name: Pipe - Fehler sortieren
        run: grep "ERROR" daten/server.log | sort

      - name: Pipe - Nur die Meldungen der Fehler
        run: grep "ERROR" daten/server.log | cut -d' ' -f4-
```

**Das Pipe-Prinzip**

```text
grep "ERROR" server.log  |  sort  |  head -n 1
   ↓ liefert Zeilen         ↓ sortiert  ↓ nimmt die erste
```

Die Ausgabe des linken Kommandos wird zur Eingabe des rechten. Achtung: Dieses Beispiel liefert die **alphabetisch erste** Fehlerzeile, nicht die zeitlich letzte. Das ist wichtig für die Knobelaufgabe unten.

**Kommandos erklärt**

| Kommando | Zweck |
|----------|-------|
| `head -n 3` | Erste 3 Zeilen |
| `tail -n 2` | Letzte 2 Zeilen |
| `wc -l` | Zeilen zählen (**w**ord **c**ount, `-l` = lines) |
| `grep "text" datei` | Zeilen mit dem Suchtext anzeigen |
| `grep -c` | Nur die Anzahl der Treffer ausgeben |
| `grep -i` | Groß- und Kleinschreibung ignorieren |
| `sort` | Zeilen sortieren |
| `cut -d' ' -f4-` | Felder ausschneiden: Leerzeichen als Trenner, ab Feld 4 |
| `|` | Pipe: Ausgabe weiterreichen |

Mit `grep -E "a|b"` suchst du nach `a` **oder** `b`.

> **Wichtig: `grep` ohne Treffer führt zu einem roten Schritt.**
> Bei einem einfachen `run:`-Befehl schlägt der Schritt fehl, wenn das Kommando einen Fehlerstatus zurückgibt. `grep` liefert bei null Treffern Exit-Code 1 – auch mit `-c`, obwohl es dabei `0` ausgibt. Exit-Code 2 bedeutet dagegen einen echten Fehler, etwa eine nicht vorhandene Datei. Probiere es mit `grep -c "FATAL" daten/server.log` aus.
>
> Mit `|| true` hinter dem Befehl lässt sich der Fehlerstatus abfangen. Das ist aber nur sinnvoll, wenn dir „keine Treffer“ egal ist, denn auch echte Fehler würden damit verschluckt.
>
> *Für Neugierige:* Unter Linux startet GitHub `run:` standardmäßig mit `bash -e`. Das aktiviert Bashs Fail-fast-Verhalten, das in bestimmten Shell-Konstruktionen Ausnahmen hat. Bei `shell: bash` kommt `pipefail` hinzu: Dann kann auch ein fehlgeschlagener Befehl **innerhalb einer Pipe** den Schritt fehlschlagen lassen.

**Aufgaben**

1. Wie viele `INFO`-Zeilen gibt es?
2. Welche Zeilen enthalten das Wort `anna`?
3. Zeige nur die Warnungen und Fehler an: `grep -E "WARNING|ERROR" daten/server.log`
4. Suche nach `FATAL`. Was passiert mit dem Schritt? Warum?
5. Knobelaufgabe: Zeige die **zeitlich letzte** Fehlermeldung an (`grep` + `tail`).

---

## Lektion 4: Variablen und das erste Shell-Skript

**Lernziele:** Variablen in Linux und in GitHub Actions, eigenes Skript, `chmod`, sichere Übergabe von Eingaben

**Vorbereitung:** Lege die Datei `skripte/begruessung.sh` an. Der Ordner `skripte/` entsteht über den Pfad im Dateinamen.

```bash
#!/bin/bash
# Ein einfaches Skript mit Variable und Schleife

NAME="$1"

if [ -z "$NAME" ]; then
  NAME="Unbekannt"
fi

echo "Hallo, $NAME!"
echo "Heute ist $(date +%A)."

echo "Ich zähle bis 3:"
for i in 1 2 3; do
  echo "  -> $i"
done
```

> Der Wochentag kommt von `date +%A`. Die Sprache der Ausgabe hängt von der Runner-Umgebung ab und ist auf GitHub-Runnern in der Regel Englisch.

**Datei:** `.github/workflows/04-skript.yml`

```yaml
name: 04 - Mein erstes Skript

on:
  workflow_dispatch:
    inputs:
      name:
        description: "Wie heißt du?"
        required: true
        default: "Welt"

env:
  KURS: "Linux lernen"

jobs:
  skript:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Variablen anzeigen
        run: |
          echo "Kurs: $KURS"
          echo "Gestartet von: $GITHUB_ACTOR"
          echo "Repository: $GITHUB_REPOSITORY"

      - name: Rechte ansehen
        run: ls -l skripte/begruessung.sh

      - name: Skript ausführbar machen
        run: chmod +x skripte/begruessung.sh

      - name: Rechte erneut ansehen
        run: ls -l skripte/begruessung.sh

      - name: Skript ausführen
        env:
          NAME: ${{ inputs.name }}
        run: ./skripte/begruessung.sh "$NAME"
```

**Warum `env:` statt direkt `${{ inputs.name }}` im Befehl?**

GitHub setzt `${{ ... }}` ein, **bevor** die Shell den Befehl sieht. Würde jemand als Namen etwa `"; rm -rf ~; echo "` eingeben, könnte der eingesetzte Wert als Teil des Shell-Codes ausgeführt werden. Bei der Übergabe über `env:` wird der Wert dagegen nicht in den Shell-Code eingesetzt. Die Shell liest ihn aus der Umgebungsvariable; durch die Anführungszeichen in `"$NAME"` wird er als **ein einzelnes Argument** an das Skript übergeben.

Die Faustregel: **Setze nicht vertrauenswürdige Eingaben nicht direkt in den Shell-Code von `run:` ein. Übergib sie über `env:` und verwende sie als quotierte Variable, zum Beispiel `"$NAME"`.** (`GITHUB_ACTOR` und `GITHUB_REPOSITORY` stellt GitHub bereits als Umgebungsvariablen bereit.)

**Zwei Arten von Variablen, nicht verwechseln**

| Schreibweise | Wer wertet aus? | Beispiel |
|---|---|---|
| `$NAME` | Die Linux-Shell zur Laufzeit | `echo "$NAME"` |
| `${{ ... }}` | GitHub Actions, vor dem Start des Befehls | `env: NAME: ${{ inputs.name }}` |

**Rechte lesen: `-rwxr-xr-x`**

```text
-  rwx  r-x  r-x
│   │    │    └─ alle anderen: lesen, ausführen
│   │    └────── Gruppe: lesen, ausführen
│   └─────────── Besitzer: lesen, schreiben, ausführen
└─────────────── Dateityp (- = Datei, d = Ordner)
```

`chmod +x` fügt das **x** (ausführbar) hinzu. Ohne dieses Recht schlägt `./skript.sh` meist mit `Permission denied` fehl. Alternativ ginge `bash skripte/begruessung.sh`; dafür braucht die Datei kein `x`-Recht.

**Kommandos und Konzepte**

| Element | Zweck |
|---------|-------|
| `#!/bin/bash` | Erste Zeile: „Führe mich mit Bash aus“ |
| `NAME="Anna"` | Variable setzen (**keine Leerzeichen** um `=`) |
| `$NAME` | Variable lesen |
| `$1` | Erster Parameter beim Aufruf |
| `$(date)` | Ergebnis eines Kommandos einsetzen |
| `if [ ... ]; then ... fi` | Bedingung |
| `for i in ...; do ... done` | Schleife |
| `chmod +x` | Datei ausführbar machen |

**Aufgaben**

1. Starte den Workflow mit deinem Namen.
2. Ändere die Schleife so, dass sie bis 5 zählt.
3. Ergänze im Skript die Uhrzeit mit `date +%H:%M`.
4. Lass den `chmod`-Schritt weg und lies die Fehlermeldung (`Permission denied`). Eine im Browser angelegte Datei hat kein Ausführungsrecht, deshalb tritt der Fehler dann auf.

---

## Häufige Anfängerfehler

| Fehler | Ursache |
|--------|---------|
| Workflow lässt sich nicht manuell starten | Falscher Ordner, falsche Endung oder Datei nicht auf dem Standardbranch |
| `mapping values are not allowed` | YAML-Einrückung falsch (nur **Leerzeichen**, keine Tabs) |
| `No such file or directory` | `actions/checkout` vergessen oder Tippfehler im Pfad |
| `Permission denied` | `chmod +x` fehlt |
| `command not found` | Tippfehler im Kommando |
| Schritt rot, obwohl „nur gesucht“ | `grep` ohne Treffer liefert Exit-Code 1 |
| `File exists` bei `mkdir` | Ordner gibt es schon; `mkdir -p` verwenden |

---

## Spickzettel (`CHEATSHEET.md`)

```text
pwd              Wo bin ich?
ls -la           Dateien anzeigen
cat datei        Datei lesen
mkdir -p ordner  Ordner anlegen
cp / mv          Kopieren / Verschieben
rm datei         Löschen (sofort, endgültig!)
head / tail      Anfang / Ende
wc -l            Zeilen zählen
grep "x" datei   Suchen (kein Treffer = Exit-Code 1)
sort             Sortieren
|                Pipe
> / >>           In Datei schreiben / anhängen
chmod +x         Ausführbar machen
$VAR             Variable lesen
env: in YAML     Eingaben an die Shell übergeben
```
