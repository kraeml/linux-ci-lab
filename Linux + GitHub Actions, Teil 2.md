# Kurs: Linux + GitHub Actions, Teil 2 (v5)

Teil 2 baut auf Teil 1 auf. Du brauchst die Repository-Struktur aus Teil 1, insbesondere die Beispieldatei `daten/server.log`. Es gibt **4 Lektionen** und ein Abschlussprojekt.

In GitHub Actions erscheinen Befehlsausgaben aus `run:`-Schritten in den Job-Protokollen. Zusammenfassungen stehen in der Laufübersicht; hochgeladene Dateien findest du unter **Artifacts**. Der Runner kann nur Dateien aus dem Branch lesen, der für den Workflow-Lauf ausgecheckt wird. Für `workflow_dispatch` muss die Workflow-Datei im Standardbranch liegen, damit GitHub **Run workflow** anbietet. Du kannst den Workflow über die **Actions**-Oberfläche, die GitHub CLI oder die REST API starten. In der Actions-Oberfläche wählst du aus, welcher Branch ausgeführt wird. Um einen Workflow manuell zu starten, brauchst du Schreibzugriff auf dein Lern-Repository. Stand 20.10.2026, siehe [GitHub-Dokumentation zu manuellen Workflow-Starts](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow).

## Vorbereitung

**Arbeite in deinem eigenen Lern-Repository aus Teil 1 weiter.** Das Kurs-Repository ist die Vorlage; dein Lern-Repository ist der Ausführungsort für die Workflows. Übertrage die folgenden Kursvorlagen für Lektionen 5 bis 8 in die angegebenen Pfade. Workflow 09 überträgst du zur Vorbereitung des Abschlussprojekts; die Antwortdatei für Aufgabe 1 legst du selbst an:

| Datei oder Aktion | Zielpfad im Lern-Repository |
|---|---|
| Workflow-Datei für Lektion 5 kopieren | `.github/workflows/05-mehrere-jobs.yml` |
| Workflow-Datei für Lektion 6 kopieren | `.github/workflows/06-auswerten.yml` |
| Workflow-Datei für Lektion 7 kopieren | `.github/workflows/07-artefakte.yml` |
| Workflow-Datei für Lektion 8 kopieren | `.github/workflows/08-zeitplan.yml` |
| Beispieldatei mit Zugriffsereignissen kopieren | `daten/zugriffe.log` |
| Berichtdatei kopieren | `daten/bericht.txt` |
| Antwortdatei für Aufgabe 1 des Abschlussprojekts anlegen | `loesungen/aufgabe1.txt` |

Committe und pushe die vier Workflow-Dateien der Lektionen 5 bis 8 nach `.github/workflows/` sowie beide Beispieldateien nach `daten/`, bevor du diese Lektionen startest. Für `workflow_dispatch` muss die betreffende Workflow-Datei auf dem Standardbranch liegen. Im Dialog **Run workflow** wählst du den Branch in deinem Lern-Repository aus, den GitHub ausführen soll. Der Schedule-Test in Lektion 8 wird betreut: Die Kursleitung integriert die Teständerung nach dem Git-Flow des Kurses in den Standardbranch deines Lern-Repositorys und setzt sie nach dem Test zurück.

`daten/server.log` und weitere Grundlagen für Teil 2 stammen aus Teil 1. Bei der Vorbereitung des Abschlussprojekts erstellst du auf einem Arbeitsbranch die Datei `loesungen/aufgabe1.txt` mit der Beispielantwort `3`.

`daten/zugriffe.log` enthält zehn erfundene Zugriffsdatensätze. `daten/bericht.txt` ist eine Beispieldatei für die Dateisuche und das Lesen von Dateien.


**`daten/zugriffe.log`** (erfundene Beispieldaten; die folgenden zehn Zeilen sind die Zugriffsdatensätze):

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

Erwartete Seitenaufrufe in den zehn Beispielzeilen: `/produkte` 4, `/start` 3, `/kontakt` 3. Damit ist die meistbesuchte Seite eindeutig. Die Datei `daten/zugriffe.log` enthält zusätzlich zwei Kommentarzeilen zur Datenherkunft und Lizenz. Kopiere die vollständige Datei ins Lern-Repository; die Auswertungsbefehle filtern Kommentarzeilen heraus.

**`daten/bericht.txt`** (Beispielinhalt für die Übung „Berichtdatei lesen“):

```text
Quartalsbericht
Umsatz steigt
Kosten sinken
Ausblick positiv
```

Kopiere die vollständige Beispieldatei `daten/bericht.txt` ins Lern-Repository und pushe sie mit den anderen Daten dieser Lektion. Sie enthält vier Berichtszeilen und zwei Kommentarzeilen zu Herkunft und Lizenz. In Workflow 06 listet „Dateien finden“ sie unter `daten/`; „Bericht lesen“ gibt ihren Inhalt aus.

> In den Logs und Berichten sind keine echten Nutzerdaten oder Zugangsdaten enthalten; verwende für Kursübungen ausschließlich Beispieldaten.

---

## Lektion 5: Mehrere Jobs und `needs:`

**Lernziel:** Du kannst parallele und voneinander abhängige Jobs unterscheiden und Werte über `GITHUB_OUTPUT` als Job-Ausgaben weitergeben.

**Workflow-Datei:** Kopiere `.github/workflows/05-mehrere-jobs.yml` aus dem Kurs-Repository in dein Lern-Repository. Behalte den Pfad bei. Committe und pushe die Datei, bevor du den Workflow manuell startest.

**Ausprobieren und kontrollieren:** Starte den Workflow in deinem Lern-Repository manuell unter **Actions**. Für `workflow_dispatch` muss die Workflow-Datei im Standardbranch liegen. Falls sie dort noch fehlt, bitte die Kursleitung, die Datei nach dem Git-Flow des Kurs-Repositories in den Standardbranch zu integrieren. Im Graphen können `zaehlen` und `parallel-a` parallel starten; `melden` wartet auf `zaehlen`. Prüfe im Protokoll: `Gefunden: 3` und `Der Job zaehlen meldet 3 Fehler`. `grep` sucht im Beispiel nach ` ERROR `, also nach dem Schweregrad zwischen Leerzeichen; Lizenzkommentare werden so nicht mitgezählt.

`actions/checkout@v7` lädt auf dem Runner `ubuntu-latest` die Dateien ins Arbeitsverzeichnis. Die Hauptversion 7 verwendet Node.js 24. Stand 20.10.2026 ist [checkout v7.0.1 die neueste Veröffentlichung](https://github.com/actions/checkout/releases). Das Hauptversions-Tag `@v7` folgt der neuesten Patch-Version seiner Hauptversion; es fixiert keinen einzelnen Patch. Bei selbst gehosteten Runnern ist für Node.js-24-Actions mindestens Runner-Version 2.327.1 erforderlich.

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
1. Prüfe, dass Workflow 05 und die benötigten Beispieldateien in dein Lern-Repository gepusht sind. Starte den Workflow über **Actions**. Sieh dir die Graph-Ansicht an: Welche Jobs können parallel starten?
2. Füge in Workflow 05 deines Lern-Repositorys einen vierten Job `abschluss` hinzu, der erst nach `melden` und `parallel-a` startet: `needs: [melden, parallel-a]`. Committe und pushe die Workflow-Änderung, dann starte den Lauf erneut.
3. Ändere in Workflow 05 in deinem Lern-Repository im Job `zaehlen` den Suchbegriff auf ` FATAL `. Committe und pushe die Änderung. Starte den Workflow erneut: Läuft `melden` trotzdem? Was meldet er?
4. Entferne in Workflow 05 im Lern-Repository den Checkout-Schritt im Job `zaehlen`. Committe und pushe die Änderung. Starte den Workflow erneut. Im Protokoll erscheint eine `grep`-Fehlermeldung auf stderr. Warum endet der Schritt trotzdem erfolgreich? Prüfe `ANZAHL` und die Ausgabe von `melden`; beide enthalten keinen Zählerwert, denn `ANZAHL` ist leer. Erkläre, wie `|| true` dazu führt, dass der Fehlerstatus abgefangen wird.

---

## Lektion 6: Häufigkeiten zählen und Dateien durchsuchen

**Lernziel:** Du kannst mit Sortieren und Zählen Häufigkeiten ermitteln, Spalten aus Texten lesen und Dateien mit `find` suchen.

**Dateien:** Kopiere `.github/workflows/06-auswerten.yml`, `daten/zugriffe.log` und `daten/bericht.txt` aus dem Kurs-Repository in dein Lern-Repository. Behalte die Pfade bei. Committe und pushe alle drei Dateien.

**Runner:** Der Workflow läuft auf dem GitHub-gehosteten Runner `ubuntu-latest` und verwendet `actions/checkout@v7` mit Node.js 24. Stand 20.10.2026 ist [checkout v7.0.1 die neueste Veröffentlichung](https://github.com/actions/checkout/releases). Das Major-Tag `@v7` folgt der neuesten Patch-Version seiner Hauptversion; es fixiert keinen einzelnen Patch. Selbst gehostete Runner benötigen für Node.js 24 mindestens Runner-Version 2.327.1.

**Ausprobieren und kontrollieren:** Nachdem Workflow 06 sowie `daten/zugriffe.log` und `daten/bericht.txt` in deinem Lern-Repository liegen und gepusht sind, starte den Workflow über **Actions → 06 - Auswerten → Run workflow**. Falls die Schaltfläche fehlt, prüfe, ob die Workflow-Datei im Standardbranch liegt. Erwartete Zählungen: `anna` vier Zugriffe, `ben` drei, `clara` drei; `/produkte` vier, `/start` drei und `/kontakt` drei. Die Top-1-Ausgabe ist `/produkte`. `find daten -type f` listet unter anderem `einkauf.txt`, `server.log`, `zugriffe.log` und `bericht.txt` auf. Anschließend zeigt der Job-Protokollschritt den Inhalt von `daten/bericht.txt`.

**Das Zählmuster (merken!)**

```
grep -v '^#' datei | cut -d' ' -f1 | sort | uniq -c | sort -nr
   ↓ Kommentare weg  ↓ Spalte holen  ↓   ↓ zählt       ↓ größte zuerst
```

`grep -v '^#'` blendet Kommentarzeilen aus. `cut` teilt die Zugriffszeilen anhand von Leerzeichen in Felder: `-f1` wählt die Person, `-f2` den Seitenpfad. `uniq` erkennt nur **aufeinanderfolgende** gleiche Werte; deshalb sortiert `sort` sie vorher. Probiere es aus: Entferne das `sort`, das unmittelbar vor `uniq -c` steht, und vergleiche die Ausgabe.

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
| `find . -name "*.log"` | Dateien mit der Endung `.log` suchen |
| `find daten -type f` | Alle Dateien im Ordner `daten/` finden (`-type d` beschränkt die Suche auf Ordner) |
| `wc -l datei` | Physische Zeilen zählen; auch Kommentarzeilen werden mitgezählt |
| `grep -v '^#' datei` | Kommentarzeilen aus der Ausgabe herausfiltern |

> `find` mit Platzhaltern: Setze das Muster in Anführungszeichen (`"*.log"`), damit die Shell es nicht schon vorher auflöst, sondern `find` es bekommt.

**Aufgaben**
1. Passe das gezeigte Zählmuster an, nutze `head -n 1` und führe es im Lern-Repository aus. Welche Person hat die meisten Zugriffe? Vergleiche mit der Kontrollzählung.
2. Zähle die Log-Level in der aus Teil 1 kopierten Datei `daten/server.log`. Filtere zuerst die Kommentarzeilen mit `grep -v '^#'` heraus, danach liest `awk '{print $3}'` die dritte Spalte des Logs. Erwartet werden `INFO=5`, `ERROR=3`, `WARNING=1`.
3. Suche im Lern-Repository mit `find daten -type f -name "*.txt"` nach Textdateien im Ordner `daten/`. Erwartet werden `daten/einkauf.txt` und `daten/bericht.txt`.
4. Entferne in deinem Lern-Repository das `sort`, das direkt vor `uniq -c` steht. Beschreibe, was sich ändert: `uniq` zählt dann nur direkt benachbarte gleiche Zeilen.

---

## Lektion 7: Artefakte hochladen und herunterladen

**Lernziel:** Du kannst einen Bericht als Artefakt hochladen, ihn selbst über die Weboberfläche herunterladen und erklären, wie ein anderer Job das Artefakt automatisch weiterverwendet.

**Zu übertragen:** Kopiere `.github/workflows/07-artefakte.yml` aus dem Kurs-Repository ins Lern-Repository. Behalte den Pfad bei. Pushe den Workflow mit `daten/server.log` aus Teil 1 und `daten/zugriffe.log` aus Teil 2. Beide Beispieldateien müssen vor dem Start im Lern-Repository liegen.

**Runner und Actions:** Der Workflow läuft auf dem von GitHub gehosteten Runner `ubuntu-latest` und verwendet `actions/checkout@v7`, `actions/upload-artifact@v7` sowie `actions/download-artifact@v8`; alle drei Actions verwenden Node.js 24. Stand 20.10.2026 sind die neuesten Releases von [actions/checkout v7.0.1](https://github.com/actions/checkout/releases), [actions/upload-artifact v7.0.2](https://github.com/actions/upload-artifact/releases) und [actions/download-artifact v8.0.2](https://github.com/actions/download-artifact/releases). Die Hauptversions-Tags `@v7` und `@v8` folgen jeweils der neuesten Patch-Version ihrer Hauptversion. Sie fixieren keinen einzelnen Patch. Selbst gehostete Runner benötigen für Node.js 24 mindestens Runner-Version 2.327.1.

**Zwei Wege, dasselbe Artefakt zu nutzen:**

1. **Selbst herunterladen:** Öffne nach dem Lauf in deinem Lern-Repository die Laufübersicht und scrolle zum Bereich **Artifacts**. Lade `auswertung` als ZIP-Datei herunter, entpacke es auf deinem Rechner und lies `bericht.txt`.
2. **Automatisiert weitergeben:** Der Job `weiterverarbeiten` lädt das Artefakt mit `actions/download-artifact@v8` herunter. Der Job braucht dafür keinen Checkout-Schritt, weil das Artefakt über GitHub zwischen den Jobs übertragen wird. Jeder Job hat eine eigene Arbeitsumgebung.

Erwarteter Berichtinhalt in `bericht.txt` (das Datum ändert sich):

```text
Auswertung vom YYYY-MM-DD
Fehler im Server-Log: 3
Datensätze im Zugriffslog: 10
Beliebteste Seite:
      4 /produkte
```

Zwei Kommentarzeilen am Anfang der Datei `daten/zugriffe.log` kennzeichnen Herkunft und Lizenz; sie sind keine Zugriffsdatensätze. Der Bericht zählt daher nur Zeilen, die nicht mit `#` beginnen. `grep -vc '^#'` zählt diese Zugriffsdatensätze; `wc -l` würde auch die Kommentarzeilen mitzählen.

> Nach Ablauf der Aufbewahrungsfrist werden Artefakte gelöscht. `retention-days` kann bei `upload-artifact@v7` 1 bis 90 Tage betragen. Richtlinien für Repository, Organisation oder Enterprise können die Höchstfrist verkürzen. Geänderte Werte gelten nur für neu erstellte Artefakte. Artefakte sind nicht für Geheimnisse oder echte Nutzerdaten gedacht.
>
> `grep -c ... || true` erlaubt eine Null bei keinen Treffern, fängt aber auch echte `grep`-Fehler ab. Für eigene Workflows solltest du Fehler getrennt behandeln.

**So funktioniert es**

| Element | Bedeutung |
|---------|-----------|
| `tee datei` | Schreibt die Eingabe in eine Datei und zugleich ins Jobprotokoll |
| `wc -l < datei` | Zeilen zählen ohne Dateinamen auszugeben |
| `actions/upload-artifact@v7` | Hängt Dateien als Artefakt an den Workflow-Lauf an |
| `actions/download-artifact@v8` | Lädt ein Artefakt im Arbeitsverzeichnis eines Jobs herunter |
| `needs: bericht` | Wartet auf den Job `bericht` |

Beim Download des Artefakts aus demselben Workflow-Lauf ist kein zusätzliches Token nötig. Die Actions v7 und v8 verwenden Node.js 24. Selbst gehostete Runner benötigen mindestens Runner-Version 2.327.1. GitHub verwaltet den GitHub-gehosteten Runner `ubuntu-latest`.

**Aufgaben**
1. Starte den Workflow in deinem Lern-Repository. Unter **Artifacts** in der Laufübersicht kannst du das Artefakt `auswertung` als ZIP auf deinen Rechner herunterladen. Entpacke es und lies die Datei `bericht.txt`. Der erwartete Inhalt ist oben gezeigt. Falls **Run workflow** nicht angeboten wird, prüfe, ob die Workflow-Datei auf dem Standardbranch liegt.
2. Öffne im Lern-Repository den Job `weiterverarbeiten` und prüfe, dass `bericht.txt` ausgegeben wird. Erkläre, warum der Job `needs: bericht` braucht.
3. Ergänze im Workflow deines Lern-Repositorys eine Zeile mit der Anzahl der `WARNING`-Einträge. Committe und pushe die Änderung, dann starte den Workflow erneut. Kontrolliere, dass die neue Zeile im Browser-Download und im Job `weiterverarbeiten` erscheint.
4. Ergänze im `with:`-Block von `actions/upload-artifact@v7` den Wert `retention-days: 1`. Committe und pushe die Änderung im Lern-Repository und starte den Workflow erneut. Prüfe die Aufbewahrungsfrist, falls GitHub sie in der Laufübersicht anzeigt. Der Wert gilt nur für neu erstellte Artefakte und kann durch Richtlinien für Repository, Organisation oder Enterprise begrenzt sein.
5. Ändere im Workflow deines Lern-Repositorys `path:` auf einen mehrzeiligen Wert und lade zusätzlich `daten/server.log` hoch. Committe und pushe die Änderung und kontrolliere, dass beide Dateien im ZIP-Download sind. Lade keine Geheimnisse oder persönlichen Daten hoch.


**Mit `>` statt `tee`:** `>` schreibt die Ausgabe nur in die Datei und überschreibt einen vorhandenen Inhalt; `tee` schreibt in die Datei und zugleich ins Jobprotokoll.

```bash
echo "Hallo" > ergebnis/datei.txt
echo "Hallo" | tee ergebnis/datei.txt
```

---

## Lektion 8: Zeitplan mit Cron und weitere Trigger

**Lernziel:** Du kannst die Auslöser `workflow_dispatch`, `push`, `pull_request` und `schedule` unterscheiden sowie einfache Cron-Zeitpläne lesen. Workflow 08 demonstriert diese Trigger. Die Workflows 05 bis 07 startest du mit `workflow_dispatch` manuell. Workflow 09 im Abschlussprojekt nutzt zusätzlich den Push-Trigger.

**Datei:** Übertrage `.github/workflows/08-zeitplan.yml` aus dem Kurs-Repository in dein Lern-Repository und behalte den Pfad bei. Committe und pushe die Datei auf den Standardbranch deines Lern-Repositorys, damit GitHub **Run workflow** anbietet. Erstelle Arbeitsbranches danach von diesem aktualisierten Standardbranch, damit sie ebenfalls die Workflow-Datei enthalten.

`ubuntu-latest` ist der GitHub-gehostete Runner. `actions/checkout@v7` verwendet Node.js 24. Stand 20.10.2026 ist [checkout v7.0.1 die neueste Veröffentlichung](https://github.com/actions/checkout/releases). Das Major-Tag `@v7` folgt stets der neuesten Patch-Version seiner Hauptversion; es pinnt keinen einzelnen Patch. Selbst gehostete Runner benötigen für Node.js 24 mindestens Runner-Version 2.327.1.

**Ausprobieren:** Committe und pushe die Workflow-Datei auf den Standardbranch deines Lern-Repositorys. Starte sie über **Actions → 08 - Zeitplan → Run workflow** manuell und prüfe im Job-Protokoll `Ausgelöst durch: workflow_dispatch`. Erstelle danach einen Arbeitsbranch aus dem aktualisierten Standardbranch. Dieser Branch enthält die Workflow-Datei. Ändere dort eine Datei unter `daten/`, committe und pushe sie, um den `push`-Trigger zu testen. Im Job-Protokoll sollte `Ausgelöst durch: push` stehen. Erstelle für den `pull_request`-Trigger einen Pull Request mit Änderungen unter `daten/`. Öffne danach die zugehörige Laufübersicht und prüfe, ob GitHub einen Lauf gestartet hat.

> Dieser Lernworkflow ist eine ausdrücklich beauftragte Ausnahme von der üblichen Regel, Kursbeispiele nur manuell zu starten: Er enthält `workflow_dispatch`, `push`, `pull_request` und `schedule`, damit die verschiedenen Trigger praktisch sichtbar werden.

**Trigger im Überblick**

| Trigger | Wann läuft der Workflow? |
|---------|--------------------------|
| `workflow_dispatch` | Über **Run workflow** manuell starten; Workflow-Datei muss auf dem Standardbranch liegen, Branch für den Lauf auswählen |
| `push` | Startet bei Push-Vorgängen mit Änderungen an Dateien unter `daten/` (`paths:`-Filter); die Workflow-Datei muss auf dem gepushten Branch liegen |
| `pull_request` | Startet bei Pull Requests mit Änderungen an Dateien unter `daten/` (`paths:`-Filter); verwendet die Workflow-Datei aus dem zum Ereignis gehörenden Commit/Ref |
| `schedule` | Zeitgesteuert; Workflow-Datei und Ausführung liegen auf dem Standardbranch |

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
- In öffentlichen Repositories deaktiviert GitHub geplante Workflows automatisch, wenn das Repository 60 Tage inaktiv war. Du kannst sie anschließend im Actions-Tab wieder aktivieren.
- Der kürzeste Abstand laut GitHub-Dokumentation ist 5 Minuten.

**`push` testen:** Erstelle nach dem Veröffentlichen von Workflow 08 im Standardbranch einen Arbeitsbranch, der die Workflow-Datei enthält. Ändere dort eine Datei unter `daten/`, committe und pushe sie. Der Push löst den Workflow aus. Im Job-Protokoll siehst du `Ausgelöst durch: push`. Ein Pull Request mit Änderungen unter `daten/` kann ebenfalls einen Lauf auslösen. GitHub verwendet dabei die Workflow-Version aus dem zum Ereignis gehörenden Commit oder Ref.

**Aufgaben**
1. Ändere auf einem Arbeitsbranch, der Workflow 08 enthält, `daten/einkauf.txt`. Committe und pushe die Änderung. Prüfe im Job-Protokoll, dass `Ausgelöst durch: push` erscheint.
2. Schreibe Cron-Ausdrücke für:
   - jeden Tag um 12:00 UTC
   - jeden Freitag um 17:45 UTC
   - alle 30 Minuten
   Vergleiche deine Cron-Ausdrücke mit den Beispielen in der Tabelle oben.

3. **Zeitplan praktisch prüfen (betreute Zusatzaufgabe):** Bitte die Kursleitung, den Schedule-Test in deinem Lern-Repository zu betreuen. Die Zeitplan-Datei `.github/workflows/08-zeitplan.yml` muss auf dessen Standardbranch liegen. Der Schedule-Trigger verwendet den neuesten Commit dieses Branches. Die Kursleitung integriert nach dem Git-Flow des Kurses eine geprüfte Änderung in den Standardbranch deines Lern-Repositorys. Diese Änderung setzt den Cron-Ausdruck vorübergehend auf `*/5 * * * *`. Warte einige Minuten und prüfe unter **Actions**, ob ein Lauf mit `Ausgelöst durch: schedule` erscheint. Ein manueller `workflow_dispatch`-Start löst den Workflow aus, testet aber nicht den Zeitplan. Geplante Läufe können verzögert sein oder ausbleiben. Danach stellt die Kursleitung den ursprünglichen Cron-Ausdruck mit einer weiteren geprüften Änderung im Standardbranch deines Lern-Repositorys wieder her.

---

## Abschlussprojekt: Der Auto-Prüfer

Verbinde die Lektionen zu einem Workflow, der Aufgaben **automatisch prüft**. Der Workflow hat zwei Testwege: manueller Start über `workflow_dispatch` und automatischer Start bei einem `push` mit Änderungen unter `loesungen/`.

**Datei und Vorbereitung:** Übertrage `.github/workflows/09-pruefer.yml` aus dem Kurs-Repository in dein Lern-Repository und pushe sie auf den Standardbranch. Erstelle danach einen Arbeitsbranch vom aktualisierten Standardbranch, damit die Workflow-Datei auch dort vorhanden ist. Lege auf dem Arbeitsbranch `loesungen/aufgabe1.txt` mit der Beispielantwort `3` an und pushe sie.

Der `push`-Trigger des Auto-Prüfers in Workflow 09 ist auf Änderungen unter `loesungen/` beschränkt. Prüfe im Job-Protokoll des Schritts `Aufgabe 1 prüfen`, dass `Erwartet: 3, Antwort: 3` und `Richtig!` ausgegeben werden.

> Damit `workflow_dispatch` angeboten wird, muss die Workflow-Datei auf dem Standardbranch liegen. Beim manuellen Start wählst du den Branch für die Ausführung. Bei einem `push`-Lauf wird die Workflow-Datei aus dem gepushten Branch verwendet; deshalb muss auch der Arbeitsbranch den Prüfer-Workflow enthalten. Siehe die [GitHub-Dokumentation zu manuellen Starts](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/manually-run-a-workflow) und zum [`push`-Ereignis](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#push) (Stand: 20.10.2026).

Der Workflow verwendet den GitHub-gehosteten Runner `ubuntu-latest` und `actions/checkout@v7` (Node.js 24; Stand 20.10.2026 ist `v7.0.1` die neueste Veröffentlichung). Das Major-Tag `@v7` folgt stets der neuesten Patch-Version seiner Hauptversion; es fixiert keinen einzelnen Patch. GitHub verwaltet den Runner für `ubuntu-latest`. Selbst gehostete Runner benötigen für Node.js-24-Actions mindestens Runner-Version 2.327.1.

**Das Prinzip**
- Der Prüfer berechnet die richtige Antwort **selbst** aus den Daten
- Er liest die Antwort aus der Lösungsdatei und vergleicht beides
- `exit 1` lässt den Schritt rot werden, `exit 0` (oder kein `exit`) grün
- `tr -d '[:space:]'` entfernt Leerzeichen, Tabs und Zeilenumbrüche, damit `3` und `3` mit abschließendem Zeilenumbruch gleich behandelt werden

| Element | Bedeutung |
|---------|-----------|
| `[ "$A" = "$B" ]` | Texte vergleichen (Leerzeichen innerhalb der Klammern sind Pflicht) |
| `if ... then ... else ... fi` | Bedingung |
| `exit 1` | Mit Fehlerstatus beenden |
| `tr -d` | Zeichen löschen |

> `|| true` fängt auch hier echte `grep`-Fehler ab (siehe Lektion 5). Für den Kurs ist das eine bewusste Vereinfachung.

**Aufgaben**
1. Ändere `loesungen/aufgabe1.txt` auf `5`, committe und pushe die Änderung auf den Arbeitsbranch, der die Workflow-Datei enthält. Der Prüfschritt sollte rot werden.
2. Korrigiere die Antwort auf `3`, committe und pushe erneut. Der Prüfschritt sollte grün werden.
3. Erweitere im Lern-Repository den Prüfer um Aufgabe 2: „Wie viele Einkaufseinträge enthält `daten/einkauf.txt`?“ Filtere die Kommentarzeilen mit `grep -v '^#'` heraus. Lege `loesungen/aufgabe2.txt` mit der Antwort `5` an, committe und pushe die Änderung.
4. Ergänze im Lern-Repository Aufgabe 3 mit einer eigenen Frage auf Basis von `daten/zugriffe.log`. Filtere Kommentarzeilen heraus, lege `loesungen/aufgabe3.txt` an, committe und pushe die Änderung.

---

## Häufige Fehler in Teil 2

| Fehler | Ursache |
|--------|---------|
| `needs`-Job startet nicht | Der vorherige Job ist fehlgeschlagen oder wurde übersprungen |
| Output ist leer | `id:` am Schritt fehlt oder der Name in `outputs:` stimmt nicht. Fehlt die Datei, meldet `grep` den Fehler auf stderr; `|| true` lässt den Schritt trotzdem erfolgreich enden und `ANZAHL` bleibt leer. |
| Dateien fehlen im nächsten Job | Jeder Job hat eine eigene Arbeitsumgebung. Dateien zwischen Jobs mit Artefakten weitergeben. |
| `uniq -c` zählt falsch | `sort` davor vergessen |
| Artefakt nicht zu finden | `path:` zeigt auf keinen vorhandenen Datei- oder Ordnerpfad |
| Geändertes `retention-days` wirkt nicht | Der neue Wert gilt nur für nach der Änderung erstellte Artefakte; Workflow erneut starten |
| Häufigkeitswert zu hoch | Beispieldatei enthält Kommentarzeilen; vor der Auswertung mit `grep -v '^#'` herausfiltern |
| Beispieldatei fehlt im Runner | Datei ist lokal, aber noch nicht in den ausgewählten Branch des Lern-Repositorys gepusht |
| Zeitplan läuft nicht | Schedule-Datei fehlt auf dem Standardbranch, UTC-Zeit falsch gerechnet, Lauf verzögert oder öffentliches Repo inaktiv |
| Push-Lauf startet nicht | Änderung liegt außerhalb des `paths:`-Filters oder die Workflow-Datei fehlt auf dem gepushten Branch |
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
