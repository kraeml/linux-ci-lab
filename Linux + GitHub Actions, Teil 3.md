# Kurs: Linux + GitHub Actions, Teil 3 (v5)

Teil 3 baut auf Teil 1 und 2 auf. Du brauchst die Repo-Struktur aus Teil 1 und 2, insbesondere `daten/server.log` und `daten/zugriffe.log`. Die Aktionen `checkout@v7`, `upload-artifact@v7` und `download-artifact@v8` verwenden Node.js 24 (Stand 20.10.2026). Die Major-Tags folgen jeweils dem neuesten Patch ihrer Hauptversion und pinnen keine exakte Patch-Version. Es gibt **4 Lektionen** (9 bis 12) und ein Abschlussprojekt.

> Wie in Teil 2 gilt: Befehlsausgaben in den Erklärungen sind Beispiele. Prüfe sie gegen dein echtes Log im Actions-Tab.

> **Nummerierung:** In Teil 2 hieß der Auto-Prüfer `09-pruefer.yml`. Die neuen Dateien beginnen deshalb bei `10`. Die Lektionstitel zählen unabhängig davon (Lektion 9 bis 12).

## Vorbereitung

Für Lektion 10 brauchst du einen Eintrag unter **Settings → Secrets and variables → Actions** (Beschreibung dort). Weitere Dateien sind nicht nötig.

---

## Lektion 9: Matrix-Builds

**Lernziele:** `strategy.matrix`, mehrere Läufe aus einer Job-Definition, `fail-fast`, `include`

**Action-Versionen:** Die Workflows in diesem Kursteil verwenden `actions/checkout@v7` (Node.js 24), `actions/upload-artifact@v7` (Node.js 24) und `actions/download-artifact@v8` (Node.js 24). Stand 20.10.2026: neueste Veröffentlichungen v7.0.1, v7.0.2 bzw. v8.0.2; die Tags `@v7`/`@v8` folgen jeweils dem neuesten Patch innerhalb ihrer Hauptversion und pinnen keine feste Patch-Version. Bei selbst betriebenen Runnern ist für Node.js 24 mindestens Runner-Version 2.327.1 erforderlich.

**Datei:** `.github/workflows/10-matrix.yml`

```yaml
name: 10 - Matrix

on:
  workflow_dispatch:

jobs:
  suchen:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        stufe: [INFO, WARNING, ERROR]
    steps:
      - uses: actions/checkout@v7

      - name: Einträge zählen
        env:
          STUFE: ${{ matrix.stufe }}
        run: |
          ANZAHL=$(grep -c "$STUFE" daten/server.log || true)
          echo "Stufe $STUFE: $ANZAHL Einträge"
```

**Wie das funktioniert**

| Konzept | Bedeutung |
|---------|-----------|
| `strategy.matrix` | Erzeugt aus einer Job-Definition mehrere Jobs, einen pro Wert |
| `matrix.stufe` | Zugriff auf den Wert des jeweiligen Laufs |
| `fail-fast: false` | Die anderen Läufe laufen weiter, auch wenn einer fehlschlägt (Standard ist `true`: dann werden laufende Matrix-Jobs abgebrochen) |
| Parallelität | GitHub führt Matrix-Jobs parallel aus, soweit Runner verfügbar sind |

Im Actions-Tab erscheinen drei Jobs, benannt nach dem Wert, etwa `suchen (INFO)`.

> Der Wert wird wieder über `env:` übergeben, nicht direkt in den Shell-Text eingesetzt. Das ist dieselbe Sicherheitsregel wie in Teil 1: `${{ ... }}` wird vor der Shell ersetzt, ein Wert mit Sonderzeichen könnte sonst den Befehl verändern. Bei festen Listenwerten wie hier wäre es ungefährlich, aber die Gewohnheit lohnt sich.

> **`|| true` wieder:** Es fängt den Exit-Code 1 bei null Treffern ab, verdeckt aber auch echte `grep`-Fehler (siehe Teil 2, Lektion 5). Hier vertretbar, weil die Kursdatei vorausgesetzt wird.

**Mehrere Dimensionen**

```yaml
    strategy:
      matrix:
        stufe: [INFO, ERROR]
        datei: [daten/server.log, daten/zugriffe.log]
```

Das ergibt **4 Läufe** (jede Stufe mit jeder Datei). Bei zwei Dimensionen multiplizieren sich die Werte.

**`include`: gezielt Kombinationen ergänzen**

```yaml
    strategy:
      matrix:
        stufe: [INFO, ERROR]
        include:
          - stufe: ERROR
            hinweis: "kritisch"
```

Der Eintrag unter `include:` ergänzt die bestehende Kombination mit `stufe: ERROR` um die zusätzliche Variable `hinweis`. Sie steht als `matrix.hinweis` nur für diese Kombination zur Verfügung. Es wird **kein zusätzlicher Lauf** erzeugt, die Anzahl der Läufe bleibt bei zwei. Wie `include` genau mit den Matrix-Werten verrechnet wird, hat einige Sonderfälle (ein `include`-Eintrag, der zu keiner bestehenden Kombination passt, erzeugt dagegen einen neuen Lauf). Lies dazu die aktuelle GitHub-Dokumentation, bevor du komplexere Kombinationen baust.

**Aufgaben**
1. Starte den Workflow. Wie viele Jobs siehst du? Wie heißen sie?
2. Füge `FATAL` zur Liste hinzu. Läuft der Job grün durch? Warum?
3. Baue die zweidimensionale Matrix (Stufe und Datei) ein. Wie viele Läufe entstehen? Beschreibe, warum manche Kombinationen sinnlos sind.
4. Lass einen Lauf bewusst fehlschlagen: Ergänze `[ "$STUFE" != "WARNING" ] || exit 1`. Teste einmal mit `fail-fast: true` und einmal mit `false`. Was passiert mit den anderen Läufen? (Bei `true` hängt es vom Timing ab, welche Läufe schon fertig sind.)

---

## Lektion 10: Secrets und Variablen

**Lernziele:** Repository-Secrets, Repository-Variablen, `secrets.` und `vars.`, Maskierung im Log, Umgang mit sensiblen Werten

**Einrichten (einmalig):**

1. Öffne im Repository **Settings → Secrets and variables → Actions**
2. Tab **Secrets** → **New repository secret**: Name `KURS_GEHEIMNIS`, Wert `Pinguin42`
3. Tab **Variables** → **New repository variable**: Name `KURS_THEMA`, Wert `Linux`

> **Nutze ausschließlich Testwerte.** `Pinguin42` ist ein reiner Demowert, der in diesem Kurs absichtlich ausgegeben wird. Gib hier niemals echte Passwörter, Tokens oder Zugangsdaten ein, auch nicht vorübergehend.

**Datei:** `.github/workflows/11-secrets.yml`

```yaml
name: 11 - Secrets und Variablen

on:
  workflow_dispatch:

jobs:
  zeigen:
    runs-on: ubuntu-latest
    steps:
      - name: Variable verwenden
        env:
          THEMA: ${{ vars.KURS_THEMA }}
        run: echo "Das Kursthema ist $THEMA"

      - name: Secret verwenden
        env:
          GEHEIMNIS: ${{ secrets.KURS_GEHEIMNIS }}
        run: |
          echo "Länge des Geheimnisses: ${#GEHEIMNIS}"
          echo "Wert: $GEHEIMNIS"
```

**Unterschied auf einen Blick**

| | Variable (`vars.`) | Secret (`secrets.`) |
|--|--------------------|---------------------|
| Für | Nicht sensible Konfiguration | Passwörter, Tokens, Schlüssel |
| Sichtbar in den Einstellungen | Ja, Wert lesbar | Nein, nach dem Speichern nicht mehr angezeigt |
| Im Log | Wird normal angezeigt | Wird automatisch als `***` maskiert |
| Zugriff | `${{ vars.NAME }}` | `${{ secrets.NAME }}` |

**Maskierung: eine Sicherung, kein verlässlicher Schutz**

GitHub ersetzt den exakten Secret-Wert im Log durch `***`. Das hilft gegen versehentliche Ausgabe, ist aber ausdrücklich keine Garantie:

- Die Maskierung kann bei veränderten Werten (etwa kodiert, zerlegt oder umgeformt) versagen. Verlass dich nie darauf.
- Secrets gehören nicht in Artefakte, Dateien oder Ausgaben, die andere sehen könnten.
- Gib Secrets nie mit `echo` aus. Das tun wir hier **nur zu Demonstrationszwecken** mit einem wertlosen Testwert.
- Prüfe nach einem Lauf, was im Log tatsächlich steht.

**Weitere Regeln zu Secrets**
- Bei Workflows, die durch einen `pull_request` aus einem **Fork** ausgelöst werden, stehen Secrets standardmäßig nicht zur Verfügung (Ausnahme: das `GITHUB_TOKEN`, dort mit eingeschränkten Rechten). Das schützt davor, dass fremder Code in einem Pull Request deine Secrets liest. Für andere Trigger und bestimmte Konfigurationen gelten abweichende Regeln, lies dazu die aktuelle GitHub-Dokumentation.
- Der gespeicherte Wert wird in den Einstellungen nicht wieder angezeigt, du kannst ihn nur überschreiben. Berechtigte Workflows können ihn dennoch verwenden, sonst wären Secrets nutzlos.
- Secrets und Variablen gibt es auf Repository-, Organisations- und Umgebungsebene. Bei gleichem Namen gilt die spezifischere Ebene. Wie Umgebungen (`environments`) genau funktionieren, behandeln wir hier nicht.

**Aufgaben**
1. Lege Secret und Variable an, starte den Workflow und vergleiche die Ausgaben. Was steht bei `Wert:`?
2. Ändere die Variable `KURS_THEMA` in den Einstellungen und starte den Workflow erneut. Muss die Workflow-Datei geändert werden?
3. Gib den Wert verändert aus, etwa mit `echo "$GEHEIMNIS" | rev`. Was zeigt GitHub im Log? Wird der veränderte Wert maskiert? Warum darfst du dich auf die Maskierung nicht verlassen?
4. Erkläre in zwei Sätzen: Warum sollte ein echtes Passwort nie als Variable gespeichert werden, auch wenn es technisch funktionieren würde?

---

## Lektion 11: Wiederverwendbare Workflows

**Lernziele:** `workflow_call`, `inputs:`, aufrufender und aufgerufener Workflow, `uses:` mit lokalem Pfad

**Idee:** Statt dieselben Schritte in vielen Workflows zu kopieren, schreibst du sie einmal und rufst sie auf.

**Datei 1: der wiederverwendbare Workflow** `.github/workflows/12-zaehler.yml`

```yaml
name: 12 - Zähler (wiederverwendbar)

on:
  workflow_call:
    inputs:
      datei:
        description: "Pfad zur Datei"
        required: true
        type: string
      suchwort:
        description: "Gesuchtes Wort"
        required: true
        type: string
    outputs:
      anzahl:
        description: "Anzahl der Treffer"
        value: ${{ jobs.zaehlen.outputs.anzahl }}

jobs:
  zaehlen:
    runs-on: ubuntu-latest
    outputs:
      anzahl: ${{ steps.suche.outputs.anzahl }}
    steps:
      - uses: actions/checkout@v7

      - name: Zählen
        id: suche
        env:
          DATEI: ${{ inputs.datei }}
          SUCHWORT: ${{ inputs.suchwort }}
        run: |
          ANZAHL=$(grep -c -- "$SUCHWORT" "$DATEI" || true)
          echo "$SUCHWORT in $DATEI: $ANZAHL"
          echo "anzahl=$ANZAHL" >> "$GITHUB_OUTPUT"
```

**Datei 2: der aufrufende Workflow** `.github/workflows/13-aufrufer.yml`

```yaml
name: 13 - Aufrufer

on:
  workflow_dispatch:

jobs:
  fehler:
    uses: ./.github/workflows/12-zaehler.yml
    with:
      datei: daten/server.log
      suchwort: ERROR

  zugriffe:
    uses: ./.github/workflows/12-zaehler.yml
    with:
      datei: daten/zugriffe.log
      suchwort: produkte

  ergebnis:
    runs-on: ubuntu-latest
    needs: [fehler, zugriffe]
    steps:
      - name: Ergebnisse ausgeben
        env:
          FEHLER: ${{ needs.fehler.outputs.anzahl }}
          ZUGRIFFE: ${{ needs.zugriffe.outputs.anzahl }}
        run: |
          echo "Fehler im Server-Log: $FEHLER"
          echo "Zugriffe auf /produkte: $ZUGRIFFE"
```

**Wie das funktioniert**

| Element | Bedeutung |
|---------|-----------|
| `on: workflow_call` | Macht den Workflow von anderen Workflows aufrufbar |
| `inputs:` | Parameter, die der Aufrufer über `with:` übergibt |
| `outputs:` (oben) | Werte, die der aufgerufene Workflow an den Aufrufer zurückgibt |
| `uses: ./.github/workflows/...` | Ruft einen Workflow **im selben Repository** auf |
| `with:` | Übergibt die Eingaben |

Zwei Besonderheiten:

- Ein Job, der einen Workflow aufruft, hat `uses:` **statt** `runs-on:` und `steps:`.
- Die Ausgabe wird in **mehreren Stufen** durchgereicht: Schritt → Job (`outputs:` am Job) → Workflow (`outputs:` unter `workflow_call`) → Aufrufer (`needs.<job>.outputs.<name>`).

> Das `--` in `grep -c -- "$SUCHWORT"` sagt `grep`, dass danach keine Optionen mehr kommen. So wird ein Suchwort, das mit `-` beginnt, nicht als Option gedeutet.

> Der aufgerufene Workflow führt `actions/checkout` selbst aus. Das ist nötig, weil er in einem eigenen Job mit eigener Umgebung läuft.

**Aufgaben**
1. Starte `13-aufrufer.yml`. Wie erscheinen die aufgerufenen Jobs in der Graph-Ansicht?
2. Ergänze einen dritten Aufruf, der `WARNING` in `daten/server.log` zählt. Du änderst dafür nur den Aufrufer, nicht `12-zaehler.yml`.
3. Mache `suchwort` optional: Setze in `12-zaehler.yml` **beide** Angaben `required: false` und `default: "ERROR"`. Ohne den Default wäre `suchwort` beim Auslassen leer. Rufe den Workflow einmal ohne `suchwort` auf. Welches Suchwort wird verwendet?
4. Benenne `anzahl` in `12-zaehler.yml` nur im Schritt um (nicht in `outputs:`). Was passiert, und warum?

---

## Lektion 12: Bedingungen, Zusammenfassungen und Fehlerbehandlung

**Lernziele:** `if:`, Statusfunktionen (`always()`, `failure()`, `success()`, `cancelled()`), `continue-on-error`, `$GITHUB_STEP_SUMMARY`, `timeout-minutes`

**Datei:** `.github/workflows/14-bedingungen.yml`

```yaml
name: 14 - Bedingungen

on:
  workflow_dispatch:
    inputs:
      modus:
        description: "Modus"
        type: choice
        options:
          - normal
          - fehler
        default: normal

jobs:
  pruefen:
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - uses: actions/checkout@v7

      - name: Immer
        run: echo "Dieser Schritt läuft normal"

      - name: Absichtlicher Fehler
        if: ${{ inputs.modus == 'fehler' }}
        run: |
          echo "Jetzt schlägt es fehl"
          exit 1

      - name: Nur bei Erfolg
        if: ${{ success() }}
        run: echo "Alles bisher in Ordnung"

      - name: Nur bei Fehler
        if: ${{ failure() }}
        run: echo "Etwas ist schiefgegangen"

      - name: Aufräumen (läuft immer)
        if: ${{ always() }}
        run: echo "Aufräumen, egal was war"

      - name: Zusammenfassung
        if: ${{ always() }}
        env:
          MODUS: ${{ inputs.modus }}
          STATUS: ${{ job.status }}
        run: |
          {
            echo "## Ergebnis"
            echo "- Modus: $MODUS"
            echo "- Status: $STATUS"
          } >> "$GITHUB_STEP_SUMMARY"

  optional:
    runs-on: ubuntu-latest
    steps:
      - name: Darf scheitern
        continue-on-error: true
        run: exit 1

      - name: Läuft trotzdem
        run: echo "Der Fehler davor wurde toleriert"
```

**Wie das funktioniert**

| Element | Bedeutung |
|---------|-----------|
| `if:` | Schritt oder Job läuft nur, wenn die Bedingung wahr ist |
| `success()` | Wahr, wenn alle vorherigen Schritte erfolgreich waren (das ist die **Standardbedingung** ohne `if:`) |
| `failure()` | Wahr, wenn ein vorheriger Schritt fehlgeschlagen ist |
| `always()` | Wird unabhängig vom Ergebnis der vorherigen Schritte ausgeführt, auch nach einer Abbruchanforderung (der Abbruch kann den Schritt später trotzdem beenden) |
| `cancelled()` | Wahr, wenn der Lauf abgebrochen wurde |
| `!cancelled()` | Läuft nach Erfolg und nach Fehler, aber nicht nach einem Abbruch |
| `continue-on-error: true` | Ein Fehler in diesem Schritt lässt den Job nicht scheitern |
| `timeout-minutes` | Bricht den Job nach der angegebenen Zeit ab |
| `$GITHUB_STEP_SUMMARY` | Datei, deren Markdown-Inhalt als Zusammenfassung im Lauf erscheint |
| `job.status` | Aktueller Status des Jobs (`success`, `failure` oder `cancelled`) |

**Warum „Nur bei Erfolg“ im Fehlermodus übersprungen wird:** Der Schritt „Absichtlicher Fehler“ schlägt fehl. Danach wird jeder Schritt, dessen Bedingung ohne Statusfunktion auskommt, nur ausgeführt, wenn bisher alles erfolgreich war. „Nur bei Erfolg“ nutzt `success()` ausdrücklich und wird deshalb übersprungen, während `failure()` und `always()` greifen.

**`always()` oder `!cancelled()`?** Nach einer Abbruchanforderung kann ein Schritt mit `always()` noch starten. Der Abbruch kann ihn aber anschließend beenden, ein Weiterlaufen ist nicht garantiert. `always()` eignet sich für kurze, sichere Aufräumschritte. Für Schritte, die nach einem Fehler weiterlaufen sollen, bei einem Abbruch aber gar nicht erst starten sollen, ist `!cancelled()` meist die passendere Bedingung. Das gilt besonders für Schritte, die lange dauern oder hängen könnten.

**Die Zusammenfassung ansehen:** Öffne den fertigen Lauf, die Zusammenfassung erscheint oben auf der Übersichtsseite des Laufs.

> **Eingaben bei `workflow_dispatch`:** `type: choice` zeigt beim manuellen Start ein Auswahlfeld. Eingaben erreichst du über `inputs.<name>`. Wie in Teil 1 gilt: Bei Freitext-Eingaben immer über `env:` in die Shell geben, nie direkt in `run:` einsetzen. Hier ist `modus` eine feste Auswahl, wird aber trotzdem über `env:` gelesen.

**Aufgaben**
1. Starte den Workflow mit Modus `normal`. Welche Schritte laufen, welche werden übersprungen?
2. Starte ihn mit Modus `fehler`. Welche Schritte laufen jetzt? Wo erscheint die Zusammenfassung?
3. Entferne bei `Aufräumen` das `if: always()`. Wie ändert sich das Verhalten im Fehlerfall?
4. Setze `timeout-minutes: 1` und füge einen Schritt `sleep 90` ein. Was passiert nach einer Minute?

---

## Abschlussprojekt: Auswertungs-Pipeline

Verbinde Matrix, Artefakte und Zusammenfassung.

**Ziel:** Ein Workflow zählt für mehrere Log-Stufen die Einträge, sammelt die Ergebnisse und schreibt eine Zusammenfassung.

**Datei:** `.github/workflows/15-pipeline.yml`

```yaml
name: 15 - Pipeline

on:
  workflow_dispatch:

jobs:
  zaehlen:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        stufe: [INFO, WARNING, ERROR]
    steps:
      - uses: actions/checkout@v7

      - name: Zählen und speichern
        env:
          STUFE: ${{ matrix.stufe }}
        run: |
          mkdir -p ergebnis
          ANZAHL=$(grep -c "$STUFE" daten/server.log || true)
          echo "$STUFE=$ANZAHL" > "ergebnis/$STUFE.txt"
          echo "$STUFE: $ANZAHL"

      - name: Teilergebnis hochladen
        uses: actions/upload-artifact@v7
        with:
          name: ergebnis-${{ matrix.stufe }}
          path: ergebnis/

  zusammenfassen:
    runs-on: ubuntu-latest
    needs: zaehlen
    if: ${{ !cancelled() }}
    steps:
      - name: Teilergebnisse laden
        id: laden
        continue-on-error: true
        uses: actions/download-artifact@v8
        with:
          pattern: ergebnis-*
          merge-multiple: true
          path: sammlung/

      - name: Zusammenfassung schreiben
        env:
          LADEN: ${{ steps.laden.outcome }}
        run: |
          if [ "$LADEN" != "success" ]; then
            echo "Download fehlgeschlagen (Status: $LADEN), Details im Log des Schritts 'Teilergebnisse laden'." | tee -a "$GITHUB_STEP_SUMMARY"
            exit 1
          fi
          if ! ls sammlung/*.txt > /dev/null 2>&1; then
            echo "Download erfolgreich, aber keine Teilergebnis-Dateien gefunden." | tee -a "$GITHUB_STEP_SUMMARY"
            exit 1
          fi
          {
            echo "## Log-Auswertung"
            echo ""
            for datei in sammlung/*.txt; do
              echo "- $(cat "$datei")"
            done
          } >> "$GITHUB_STEP_SUMMARY"
          cat sammlung/*.txt
```

**Das Prinzip**
- Die **Matrix** erzeugt je Stufe einen Lauf, jeder lädt sein Teilergebnis als eigenes Artefakt hoch (Artefaktnamen müssen innerhalb eines Laufs eindeutig sein, deshalb `ergebnis-${{ matrix.stufe }}`)
- Der Job `zusammenfassen` lädt mit `pattern` und `merge-multiple` alle Teilergebnisse in einen Ordner
- `if: ${{ !cancelled() }}` startet die Zusammenfassung nach Erfolg **und** nach einem fehlgeschlagenen Matrix-Lauf, aber nicht, wenn jemand den Lauf abbricht

**Der Kontrollfluss im Zusammenfassungsschritt**

Der Download hat `continue-on-error: true`, damit der Folgeschritt auch dann noch läuft, wenn der Download scheitert. Der Folgeschritt prüft zwei Dinge in dieser Reihenfolge:

1. **Ist der Download gescheitert** (`outcome` ist nicht `success`)? Erwartet wird, dass die Action bei null passenden Artefakten fehlschlägt. Das ist **keine ausdrücklich dokumentierte Zusage**, sondern beobachtetes Verhalten, das du in Aufgabe 4b selbst überprüfst. Trifft es zu, erscheint die Meldung "Download fehlgeschlagen", und der Schritt endet mit Fehler. Die `ls`-Prüfung wird dann nicht erreicht.
2. **War der Download erfolgreich, aber der Ordner enthält keine `.txt`-Dateien?** Das ist nur eine zusätzliche Absicherung für einen ungewöhnlichen Fall, etwa wenn Artefakte mit passendem Namen existieren, aber andere Inhalte haben. Mit den Kursdaten tritt er normalerweise nicht auf.

Erst wenn beide Prüfungen bestanden sind, wird die Zusammenfassung geschrieben. Ein leeres Ergebnis wird so nie als Erfolg gemeldet.

**`outcome` und `conclusion`: zwei Ergebnisse pro Schritt**

Für einen Schritt mit `continue-on-error: true` gibt es zwei Angaben, die auseinanderfallen können:

| Angabe | Bedeutung | Bei fehlgeschlagenem Download mit `continue-on-error` |
|--------|-----------|-------------------------------------------------------|
| `steps.laden.outcome` | Das tatsächliche Ergebnis des Schritts, **bevor** `continue-on-error` angewendet wird | `failure` |
| `steps.laden.conclusion` | Das Ergebnis **nach** Anwendung von `continue-on-error`, so wie GitHub es für den weiteren Ablauf wertet | `success` |

Deshalb prüft der Workflow `outcome`: Nur dort ist der echte Fehler noch sichtbar. Mit `conclusion` würde der Folgeschritt einen gescheiterten Download für erfolgreich halten.

> **Grenze dieser Lösung:** `continue-on-error` toleriert **jeden** Fehler des Download-Schritts, nicht nur "keine Artefakte vorhanden", sondern auch ungültige Einstellungen oder Berechtigungsprobleme. Der Folgeschritt kann diese Fälle nicht sicher unterscheiden, er erkennt nur, dass der Download nicht erfolgreich war. Die tatsächliche Ursache steht im Log des Download-Schritts. Für einen Kurs ist das eine vertretbare Vereinfachung. In eigenen Workflows solltest du genauer prüfen, welche Fehler du wirklich tolerieren willst.

> **Dateikollisionen bei `merge-multiple`:** Mit `merge-multiple: true` landen die Dateien aller Artefakte im selben Ordner. Hier ist das unproblematisch, weil jeder Matrix-Lauf eine anders benannte Datei erzeugt (`INFO.txt`, `WARNING.txt`, `ERROR.txt`). Würden zwei Läufe eine gleichnamige Datei hochladen, könnte eine die andere überschreiben.

> **Zu `download-artifact@v8`:** `pattern` und `merge-multiple` werden von dieser Action unterstützt. Prüfe die Optionen trotzdem vor der Veröffentlichung gegen die aktuelle Dokumentation, da sich Optionen und Hauptversionen ändern können.

**Aufgaben**
1. Starte die Pipeline. Wo findest du die Zusammenfassung, und welche Zahlen zeigt sie?
2. Ergänze `FATAL` in der Matrix. Wie sieht die Zusammenfassung aus?
3. Baue den Zählschritt so um, dass er den wiederverwendbaren Workflow aus Lektion 11 verwendet statt eigenem `grep`. Welche Teile der Pipeline müssen sich ändern, welche nicht? (Tipp: Ein Aufruf per `uses:` kann ebenfalls in einer Matrix stehen, aber der Artefakt-Upload müsste dann im wiederverwendbaren Workflow stattfinden.)
4. Teste zwei verschiedene Fehlerfälle:
   - **a) Ein Lauf scheitert vor dem Upload:** Füge im Zählschritt `[ "$STUFE" != "WARNING" ] || exit 1` ein, vor dem Speichern. Dieser Lauf lädt nichts hoch. Welche Datei fehlt in `sammlung/`? Entsteht die Zusammenfassung trotzdem?
   - **b) Alle Läufe scheitern vor dem Upload:** Füge `exit 1` direkt nach `mkdir -p ergebnis` ein. Es wird nichts hochgeladen. Welche Werte haben `steps.laden.outcome` und `steps.laden.conclusion`? (Gib sie zum Testen zusätzlich im Schritt "Zusammenfassung schreiben" aus, die Conclusion über eine zweite Umgebungsvariable mit `${{ steps.laden.conclusion }}`.) Warum läuft der Folgeschritt trotz fehlgeschlagenem Download weiter? Welche Meldung erscheint in der Zusammenfassung, wie endet der Job `zusammenfassen`, und was steht im Log des Download-Schritts? Du solltest hier die Meldung "Download fehlgeschlagen" sehen, nicht eine Zusammenfassung mit Zahlen. **Falls stattdessen die Meldung "Download erfolgreich, aber keine Teilergebnis-Dateien gefunden" erscheint**, behandelt die Action null Treffer als Erfolg. Dann greift die `ls`-Absicherung, und du hast gerade ein Verhalten gefunden, das du im Kurstext korrigieren solltest.
5. Breche einen laufenden Lauf von Hand ab. Läuft `zusammenfassen` noch? Ändere die Bedingung auf `always()` und wiederhole den Test. Was ändert sich, und warum hängt das Ergebnis vom Zeitpunkt des Abbruchs ab?

---

## Häufige Fehler in Teil 3

| Fehler | Ursache |
|--------|---------|
| Matrix-Wert ist leer | Falsche Schreibweise, es heißt `matrix.stufe` und nicht `matrix.Stufe` oder `${{ stufe }}` |
| Zu viele Läufe | Zwei Dimensionen multiplizieren sich |
| Secret ist leer | Name falsch geschrieben, nicht angelegt, oder Workflow läuft aus einem Fork |
| Secret erscheint lesbar im Log | Wert wurde verändert (kodiert, zerlegt), die Maskierung ist keine Garantie |
| `workflow_call` startet nicht | Pfad bei `uses:` falsch, Datei nicht auf dem Branch, `on: workflow_call` fehlt |
| Output des Aufrufers leer | Ausgabe nicht in allen Stufen durchgereicht (Schritt, Job, Workflow) |
| `uses:` zusammen mit `steps:` | Aufrufende Jobs haben `uses:` **statt** `runs-on:` und `steps:` |
| `suchwort` ist leer trotz `required: false` | `default:` fehlt |
| Schritt nach Fehler übersprungen | Standardmäßig gilt `success()`, `always()`, `!cancelled()` oder `failure()` nutzen |
| Aufräumschritt läuft nach Abbruch weiter | `always()` kann nach einer Abbruchanforderung noch starten, `!cancelled()` verwenden |
| Artefakt-Download findet nichts | Muster passt nicht zu den Artefaktnamen, alle Uploads sind gescheitert, oder die Artefakte kommen aus einem anderen Lauf |
| Download-Fehler wird nicht erkannt | `conclusion` statt `outcome` geprüft, oder `continue-on-error` verbirgt die Ursache (im Log des Download-Schritts nachsehen) |
| Zwei Artefakte mit gleichem Namen | Artefaktnamen müssen innerhalb eines Laufs eindeutig sein |
| Dateien überschreiben sich nach dem Download | `merge-multiple` legt alle Dateien in einen Ordner, gleichnamige Dateien kollidieren |

---

## Spickzettel-Ergänzung (`CHEATSHEET.md`)

```
strategy.matrix                 Ein Job, mehrere Läufe
matrix.<name>                   Wert im jeweiligen Lauf (z. B. matrix.stufe)
fail-fast: false                Andere Läufe nicht abbrechen
vars.NAME                       Variable (nicht geheim)
secrets.NAME                    Secret (maskiert, nie ausgeben)
on: workflow_call               Workflow aufrufbar machen
uses: ./.github/workflows/x.yml Lokalen Workflow aufrufen
with:                           Eingaben übergeben
if: ${{ !cancelled() }}         Läuft nach Erfolg und Fehler, nicht nach Abbruch
if: ${{ always() }}             Kann auch nach Abbruchanforderung starten
if: ${{ failure() }}            Läuft nur nach Fehler
continue-on-error: true         Fehler tolerieren (verdeckt auch echte Fehler)
steps.<id>.outcome              Echtes Ergebnis eines Schritts (vor continue-on-error)
steps.<id>.conclusion           Ergebnis nach continue-on-error (Fehler wird zu success)
timeout-minutes: N              Zeitlimit für den Job
>> "$GITHUB_STEP_SUMMARY"       Zusammenfassung im Lauf anzeigen
```

---

## Änderungen gegenüber v4

| Stelle | Änderung |
|--------|----------|
| Abschlussprojekt | Neuer Abschnitt "`outcome` und `conclusion`" mit Vergleichstabelle und Begründung, warum `outcome` geprüft wird |
| Abschlussprojekt, Aufgabe 4b | Fragt ausdrücklich nach `outcome` und `conclusion`, mit Anleitung zur zusätzlichen Ausgabe und der Frage, warum der Folgeschritt weiterläuft |
| Lektion 10 | Satz zu Secrets präzisiert: Wert wird nicht mehr angezeigt, berechtigte Workflows können ihn verwenden; Tabellenzeile "nicht mehr angezeigt" statt "nicht mehr lesbar" |
| Fehlertabelle | Zeile "Download-Fehler wird nicht erkannt" um die Verwechslung von `conclusion` und `outcome` ergänzt |
| Spickzettel | `steps.<id>.conclusion` ergänzt, `outcome` präzisiert |
