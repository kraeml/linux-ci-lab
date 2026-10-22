# Kurs: Linux + GitHub Actions, Teil 3 (v6)

Teil 3 baut auf Teil 1 und 2 auf. Du brauchst die Struktur deines eigenen Lern-Repositorys aus den vorherigen Teilen, insbesondere `daten/server.log` und `daten/zugriffe.log`. Für Teil 3 wird dasselbe Lern-Repository weiterverwendet; Git Flow ist dafür nicht nötig. Die Workflows verwenden `actions/checkout@v7`, `actions/upload-artifact@v7` und `actions/download-artifact@v8` auf `ubuntu-latest`. Die Major-Tags folgen jeweils der neuesten Patch-Version ihrer Hauptversion; sie pinnen keine einzelne Patch-Version. Die offiziellen Versionshinweise nennen Node.js 24 für alle drei Actions und für selbst gehostete Runner mindestens Version 2.327.1 (Prüfstand: 22.10.2026). Es gibt **4 Lektionen** (9 bis 12) und ein Abschlussprojekt.

> Wie in Teil 2 gilt: Befehlsausgaben in den Erklärungen sind Beispiele. Prüfe sie gegen dein echtes Log im Actions-Tab.
>
> **Nummerierung:** In Teil 2 hieß der Auto-Prüfer `09-pruefer.yml`. Die neuen Dateien beginnen deshalb bei `10`. Die Lektionstitel zählen unabhängig davon (Lektion 9 bis 12).

## Vorbereitung

Lege die gezeigten Workflow-Dateien unter ihren Pfaden auf dem Standardbranch deines Lern-Repositorys an und committe sie dort. So kannst du sie über **Actions** manuell starten. Beim Bearbeiten im GitHub-Browser speichert **Commit changes** auf dem ausgewählten Branch; arbeitest du lokal, pushe deine Commits wie beschrieben. Lizenzhinweise in den Codeblöcken verweisen auf Dateien im Kurs-Repository.

Für Lektion 10 brauchst du außerdem einen Eintrag unter **Settings → Secrets and variables → Actions** (Beschreibung dort).

---

## Lektion 9: Matrix-Builds

**Lernziel:** Du erstellst mehrere sinnvolle Läufe aus einer Job-Definition, ergänzt mit `include` gezielt Werte und untersuchst, wie `fail-fast` mit Fehlern umgeht.

**Action-Versionen:** Zum Prüfstand 22.10.2026 zeigen die offiziellen Release-Seiten `checkout` v7.0.1, `upload-artifact` v7.0.2 und `download-artifact` v8.0.2 als neueste Releases. Die verwendeten Major-Tags folgen neuen Patch-Releases innerhalb ihrer Hauptversion und pinnen keine exakte Version. Die veröffentlichten Aktionshinweise nennen Node.js 24 für alle drei Actions und für selbst gehostete Runner mindestens Version 2.327.1. Der gehostete Runner `ubuntu-latest` wird von GitHub verwaltet. Für produktive oder sicherheitskritische Workflows empfiehlt GitHub, Actions ohne Dependency-Lockfile auf eine geprüfte vollständige Commit-SHA zu pinnen und Aktualisierungen bewusst zu prüfen; ein Major-Tag ist einfacher zu warten, folgt aber einem beweglichen Verweis. Prüfe Versionsangaben vor einer späteren Aktualisierung erneut in den [Release-Hinweisen von checkout](https://github.com/actions/checkout/releases), [upload-artifact](https://github.com/actions/upload-artifact/releases) und [download-artifact](https://github.com/actions/download-artifact/releases) sowie den jeweiligen Readmes.

**Datei anlegen:** `.github/workflows/10-matrix.yml`

```yaml
# Linux CI — Beispielcode
# Lizenz: MIT (siehe LICENSE-CODE.txt im Kurs-Repository)
name: 10 - Matrix

on:
  workflow_dispatch:

jobs:
  suchen:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        suchbegriff: [INFO, WARNING, ERROR]
        datei: [daten/server.log]
        include:
          - suchbegriff: ERROR
            hinweis: "kritischer Fehler"
          - suchbegriff: produkte
            datei: daten/zugriffe.log
    steps:
      - uses: actions/checkout@v7

      - name: Einträge zählen
        env:
          SUCHBEGRIFF: ${{ matrix.suchbegriff }}
          DATEI: ${{ matrix.datei }}
          HINWEIS: ${{ matrix.hinweis }}
        run: |
          if [ ! -f "$DATEI" ]; then
            echo "Datei $DATEI fehlt" >&2
            exit 2
          fi
          if ANZAHL=$(grep -F -c -- "$SUCHBEGRIFF" "$DATEI"); then
            :
          else
            STATUS=$?
            if [ "$STATUS" -eq 1 ]; then
              ANZAHL=0
            else
              exit "$STATUS"
            fi
          fi
          echo "$SUCHBEGRIFF in $DATEI: $ANZAHL Einträge"
          if [ -n "$HINWEIS" ]; then
            echo "$HINWEIS"
          fi
```

**Wie das funktioniert**

| Konzept | Bedeutung |
| --------- | ----------- |
| `strategy.matrix` | Erzeugt aus einer Job-Definition mehrere Jobs, einen pro Wert |
| `matrix.suchbegriff` | Suchtext des jeweiligen Laufs; beim Zugriffslauf `produkte` |
| `matrix.datei` | Datei des jeweiligen Laufs |
| `include` | Ergänzt oder erweitert gezielt Matrix-Kombinationen |
| `fail-fast: false` | Die übrigen Matrix-Läufe werden bei einem Fehler nicht wegen `fail-fast` abgebrochen |
| Parallelität | GitHub führt Matrix-Jobs parallel aus, soweit Runner verfügbar sind |

Im Actions-Tab erscheinen vier Jobs. Drei werten `server.log` nach INFO, WARNING und ERROR aus; der vierte zählt `produkte` in `zugriffe.log`. Die genaue Darstellung der Job-Namen kann sich in der Oberfläche ändern.

> Der Wert wird wieder über `env:` übergeben, nicht direkt in den Shell-Text eingesetzt. Das ist dieselbe Sicherheitsregel wie in Teil 1: `${{ ... }}` wird vor der Shell ersetzt, ein Wert mit Sonderzeichen könnte sonst den Befehl verändern. Bei festen Listenwerten wie hier wäre es ungefährlich, aber die Gewohnheit lohnt sich.

Die Shell-Behandlung unterscheidet drei Fälle: Eine fehlende Datei führt zu einem Fehler, kein Treffer ergibt den gültigen Zählerstand 0 und mindestens ein Treffer liefert die Trefferzahl. `grep -F` behandelt den Wert als wörtliche Zeichenfolge statt als regulären Ausdruck. Andere Suchfehler werden nicht verschluckt. `suchbegriff` beschreibt den gesuchten Text; auch ein `include`-Lauf darf daher einen anderen Suchbegriff wie `produkte` erhalten.

**Mehrere Dimensionen**

```yaml
    strategy:
      matrix:
        suchbegriff: [INFO, WARNING, ERROR]
        datei: [daten/server.log]
        include:
          - suchbegriff: produkte
            datei: daten/zugriffe.log
```

Der zugehörige Job-Code verwendet `grep` mit `matrix.suchbegriff` und `matrix.datei` wie im Beispiel der Datei `10-matrix.yml`.

Das ergibt **4 sinnvolle Läufe**: drei Zählungen der Log-Stufen in `server.log` und eine Zählung von `produkte` in `zugriffe.log`. Bei Matrixdimensionen, die vollständig miteinander kombiniert werden, multiplizieren sich die Werte; `include` kann einzelne passende Kombinationen gezielt erweitern oder zusätzliche Läufe erzeugen.

**`include`: gezielt Kombinationen ergänzen**

```yaml
    strategy:
      matrix:
        suchbegriff: [INFO, ERROR]
        include:
          - suchbegriff: ERROR
            hinweis: "kritisch"
```

Der Eintrag unter `include:` ergänzt die bestehende Kombination `suchbegriff: ERROR` um die zusätzliche Variable `hinweis`. Sie steht als `matrix.hinweis` nur für diese Kombination zur Verfügung. Es wird **kein zusätzlicher Lauf** erzeugt; die Anzahl bleibt bei zwei. Ein `include`-Eintrag, der mit keiner ursprünglichen Kombination vereinbar ist, kann dagegen einen Lauf hinzufügen. Eine vollständige Regelübersicht mit Beispielen steht in der [offiziellen Dokumentation zu Matrix-Läufen](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs).

**Aufgaben**
1. Starte den Workflow. Wie viele Jobs siehst du? Wie heißen sie?
2. Füge `FATAL` zur Liste `suchbegriff` hinzu. Läuft der Job grün durch? Warum?
3. Ändere den `include`-Eintrag mit `hinweis` vorübergehend von `suchbegriff: ERROR` zu `suchbegriff: WARNING`. Da WARNING bereits in der Ausgangsmatrix vorkommt, wird diese Kombination um den Hinweis erweitert; es entsteht kein zusätzlicher Lauf. Starte den Workflow erneut und kontrolliere, in welchem Lauf der Hinweis ausgegeben wird. Stelle danach den ursprünglichen Wert wieder her.
4. Das Grundbeispiel enthält den `datei`-Eintrag und `include` bereits. Erkläre, warum diese vier Kombinationen fachlich sinnvoll sind, und nenne für jede Kombination Datei und Suchbegriff.
5. **Nur beobachten:** Lass den WARNING-Lauf bewusst fehlschlagen: Ergänze im `run:`-Block vor der Zählung `[ "$SUCHBEGRIFF" != "WARNING" ] || exit 1`. Starte mit `fail-fast: false` und kontrolliere, dass die anderen Matrix-Läufe weiterlaufen. Stelle danach `fail-fast: true` ein und beobachte, welche noch laufenden bzw. wartenden Läufe GitHub abbricht. Entferne die Fehlerzeile danach wieder. Das Timing ist nicht festgelegt und soll nicht bewertet werden.

---

## Lektion 10: Secrets und Variablen

**Lernziel:** Du unterscheidest nicht geheime Variablen von Secrets, verwendest beide sicher in einem Workflow und erklärst die Grenzen der Log-Maskierung.

**Einrichten (einmalig):**

1. Öffne im Repository **Settings → Secrets and variables → Actions**
2. Tab **Secrets** → **New repository secret**: Name `KURS_GEHEIMNIS`, Wert `Pinguin42`
3. Tab **Variables** → **New repository variable**: Name `KURS_THEMA`, Wert `Linux`

> **Nutze ausschließlich Testwerte.** `Pinguin42` ist ein reiner Demowert. Gib niemals echte Passwörter, Tokens oder Zugangsdaten ein, auch nicht vorübergehend. Das Beispiel prüft nur, ob das Secret gesetzt ist; es gibt weder den Wert noch seine Länge aus.

**Datei anlegen:** `.github/workflows/11-secrets.yml`

```yaml
# Linux CI — Beispielcode
# Lizenz: MIT (siehe LICENSE-CODE.txt im Kurs-Repository)
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
          if [ -z "$GEHEIMNIS" ]; then
            echo "Secret fehlt oder ist leer"
            exit 1
          fi
          echo "Secret ist gesetzt"
```

**Unterschied auf einen Blick**

| | Variable (`vars.`) | Secret (`secrets.`) |
| -- | -------------------- | --------------------- |
| Für | Nicht sensible Konfiguration | Passwörter, Tokens, Schlüssel |
| Sichtbar in den Einstellungen | Ja, Wert lesbar | Nein, nach dem Speichern nicht mehr angezeigt |
| Im Log | Wird normal angezeigt | GitHub versucht den Secret-Wert als `***` zu maskieren; darauf nicht als Schutz verlassen |
| Zugriff | `${{ vars.NAME }}` | `${{ secrets.NAME }}` |

**Maskierung: eine Sicherung, kein verlässlicher Schutz**

GitHub versucht, erkannte Secret-Werte im Log durch `***` zu ersetzen. Das hilft gegen versehentliche Ausgabe, ist aber ausdrücklich keine Garantie:

- Die Maskierung kann bei veränderten Werten (etwa kodiert, zerlegt oder umgeformt) versagen. Verlass dich nie darauf.
- Secrets gehören nicht in Artefakte, Dateien oder Ausgaben, die andere sehen könnten.
- Gib Secrets nie mit `echo` aus. Auch bei einem Demowert üben wir hier nur die sichere Prüfung, ob das Secret gesetzt ist.
- Der Beispiel-Workflow gibt ausschließlich `Secret ist gesetzt` aus; er zeigt nicht den Wert und nicht dessen Länge.

**Weitere Regeln zu Secrets**
- Bei Workflows, die durch einen `pull_request` aus einem **Fork** ausgelöst werden, stehen Secrets standardmäßig nicht zur Verfügung (Ausnahme: das `GITHUB_TOKEN`, dort mit eingeschränkten Rechten). Das schützt davor, dass fremder Code in einem Pull Request deine Secrets liest. Für andere Trigger und bestimmte Konfigurationen gelten abweichende Regeln, lies dazu die aktuelle GitHub-Dokumentation.
- Der gespeicherte Wert wird in den Einstellungen nicht wieder angezeigt, du kannst ihn nur überschreiben. Berechtigte Workflows können ihn dennoch verwenden, sonst wären Secrets nutzlos.
- Secrets und Variablen gibt es auf Repository-, Organisations- und Umgebungsebene. Bei gleichem Namen gilt die spezifischere Ebene. Wie Umgebungen (`environments`) genau funktionieren, behandeln wir hier nicht.

**Aufgaben**
1. Lege Secret und Variable an, starte den Workflow und vergleiche die Ausgaben. Was wird über das Kursthema und das Secret angezeigt? Bestätige, dass weder Secret-Wert noch Länge erscheinen.
2. Ändere die Variable `KURS_THEMA` in den Einstellungen und starte den Workflow erneut. Muss die Workflow-Datei geändert werden?
3. Erkläre ohne das Secret auszugeben, warum eine veränderte Darstellung (zum Beispiel kodiert oder umgedreht) möglicherweise nicht maskiert wird. Warum darfst du dich auf die Maskierung nicht verlassen?
4. Erkläre in zwei Sätzen: Warum sollte ein echtes Passwort nie als Variable gespeichert werden, auch wenn es technisch funktionieren würde?

---

## Lektion 11: Wiederverwendbare Workflows

**Lernziel:** Du rufst einen Workflow mit Eingaben auf und verfolgst, wie eine Ausgabe vom Schritt über Job und Workflow an den Aufrufer gelangt.

**Idee:** Statt dieselben Schritte in vielen Workflows zu kopieren, schreibst du sie einmal und rufst sie auf.

**Datei anlegen 1: wiederverwendbarer Workflow** `.github/workflows/12-zaehler.yml`

```yaml
# Linux CI — Beispielcode
# Lizenz: MIT (siehe LICENSE-CODE.txt im Kurs-Repository)
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
          if [ ! -f "$DATEI" ]; then
            echo "Datei nicht gefunden: $DATEI" >&2
            exit 2
          fi
          if ANZAHL=$(grep -F -c -- "$SUCHWORT" "$DATEI"); then
            :
          else
            STATUS=$?
            if [ "$STATUS" -eq 1 ]; then
              ANZAHL=0
            else
              exit "$STATUS"
            fi
          fi
          echo "$SUCHWORT in $DATEI: $ANZAHL"
          echo "anzahl=$ANZAHL" >> "$GITHUB_OUTPUT"
```

**Datei anlegen 2: aufrufender Workflow** `.github/workflows/13-aufrufer.yml`

```yaml
# Linux CI — Beispielcode
# Lizenz: MIT (siehe LICENSE-CODE.txt im Kurs-Repository)
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
| --------- | ----------- |
| `on: workflow_call` | Macht den Workflow von anderen Workflows aufrufbar |
| `inputs:` | Parameter, die der Aufrufer über `with:` übergibt |
| `outputs:` (oben) | Werte, die der aufgerufene Workflow an den Aufrufer zurückgibt |
| `uses: ./.github/workflows/...` | Ruft einen Workflow **im selben Repository** auf |
| `with:` | Übergibt die Eingaben |

Zwei Besonderheiten:

- Ein Job, der einen Workflow aufruft, hat `uses:` **statt** `runs-on:` und `steps:`.
- Die Ausgabe wird in **mehreren Stufen** durchgereicht: Schritt → Job (`outputs:` am Job) → Workflow (`outputs:` unter `workflow_call`) → Aufrufer (`needs.<job>.outputs.<name>`).

> Das `--` in `grep -F -c -- "$SUCHWORT"` sagt `grep`, dass danach keine Optionen mehr kommen. So wird ein Suchwort, das mit `-` beginnt, nicht als Option gedeutet. `-F` sucht den Text wörtlich, nicht als regulären Ausdruck. Vorher prüft der Schritt, ob die Datei vorhanden ist; nur der Exit-Code 1 (kein Treffer) wird als Anzahl 0 behandelt.

> Der aufgerufene Workflow führt `actions/checkout` selbst aus. Das ist nötig, weil er in einem eigenen Job mit eigener Umgebung läuft.

**Aufgaben**
1. Starte `13-aufrufer.yml`. Wie erscheinen die aufgerufenen Jobs in der Graph-Ansicht?
2. Ergänze einen dritten Aufruf, der `WARNING` in `daten/server.log` zählt. Du änderst dafür nur den Aufrufer, nicht `12-zaehler.yml`.
3. Mache `suchwort` optional: Setze in `12-zaehler.yml` **beide** Angaben `required: false` und `default: "ERROR"`. Ohne den Default wäre `suchwort` beim Auslassen leer. Rufe den Workflow einmal ohne `suchwort` auf. Welches Suchwort wird verwendet?
4. Benenne in `12-zaehler.yml` die Schritt-ID `suche` in `ermitteln` um, aber ändere zunächst nicht den Verweis `steps.suche.outputs.anzahl` in den Job-`outputs`. Prüfe den Workflow und die Ausgabe im aufrufenden Workflow. Passe anschließend den Verweis auf `steps.ermitteln.outputs.anzahl` an. Was war die Ursache des fehlenden Werts?

---

## Lektion 12: Bedingungen, Zusammenfassungen und Fehlerbehandlung

**Lernziel:** Du steuerst Schritte mit Bedingungen und Statusfunktionen, behandelst erwartete Fehler und schreibst eine Lauf-Zusammenfassung.

**Datei anlegen:** `.github/workflows/14-bedingungen.yml`

```yaml
# Linux CI — Beispielcode
# Lizenz: MIT (siehe LICENSE-CODE.txt im Kurs-Repository)
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

      - name: Aufräumschritt (läuft immer)
        if: ${{ always() }}
        run: echo "Dieser kurze Schritt läuft unabhängig vom Ergebnis"

      - name: Abbruch prüfen
        if: ${{ cancelled() }}
        run: echo "Abbruch erkannt (falls Schritt noch startet)"

      - name: Nach Erfolg oder Fehler
        if: ${{ !cancelled() }}
        run: echo "Der Lauf wurde nicht abgebrochen"

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
| --------- | ----------- |
| `if:` | Schritt oder Job läuft nur, wenn die Bedingung wahr ist |
| `success()` | Wahr, wenn alle vorherigen Schritte erfolgreich waren (das ist die **Standardbedingung** ohne `if:`) |
| `failure()` | Wahr, wenn ein vorheriger Schritt fehlgeschlagen ist |
| `always()` | Wird unabhängig vom Ergebnis der vorherigen Schritte ausgeführt, auch nach einer Abbruchanforderung (der Abbruch kann den Schritt später trotzdem beenden) |
| `cancelled()` | Wahr, wenn der Lauf abgebrochen wurde; der Schritt mit dieser Bedingung zeigt das Muster, wird nach Abbruch aber nicht garantiert ausgeführt |
| `!cancelled()` | Läuft nach Erfolg und nach Fehler, aber nicht nach einem Abbruch |
| `continue-on-error: true` | Ein Schrittfehler wird toleriert; im Beispiel scheitert der Job deshalb nicht |
| `timeout-minutes` | Bricht den Job nach der angegebenen Zeit ab |
| `$GITHUB_STEP_SUMMARY` | Datei, deren Markdown-Inhalt als Zusammenfassung im Lauf erscheint |
| `job.status` | Aktueller Status des Jobs (`success`, `failure` oder `cancelled`) |

**Warum „Nur bei Erfolg“ im Fehlermodus übersprungen wird:** Der Schritt „Absichtlicher Fehler“ schlägt fehl. Danach wird jeder Schritt, dessen Bedingung ohne Statusfunktion auskommt, nur ausgeführt, wenn bisher alles erfolgreich war. „Nur bei Erfolg“ nutzt `success()` ausdrücklich und wird deshalb übersprungen, während `failure()` und `always()` greifen.

**`cancelled()` selbst beobachten:** Der Schritt „Abbruch prüfen“ zeigt, wie `cancelled()` geschrieben wird und macht im Schrittnamen sowie in der Ausgabe deutlich, dass sein Start nicht garantiert ist. Ein manueller Abbruch kann Schritte überspringen, bevor diese Bedingung noch sichtbar ausgewertet wird. Betrachte deshalb den Abbruchversuch als Beobachtung, nicht als Test mit garantiertem Schritt-Ergebnis.

**`always()` oder `!cancelled()`?** Nach einer Abbruchanforderung kann ein Schritt mit `always()` noch starten. Der Abbruch kann ihn aber anschließend beenden, ein Weiterlaufen ist nicht garantiert. `always()` eignet sich für kurze, sichere Aufräumschritte. Für Schritte, die nach einem Fehler weiterlaufen sollen, bei einem Abbruch aber gar nicht erst starten sollen, ist `!cancelled()` meist die passendere Bedingung. Das gilt besonders für Schritte, die lange dauern oder hängen könnten.

**Die Zusammenfassung ansehen:** Öffne den fertigen Lauf, die Zusammenfassung erscheint oben auf der Übersichtsseite des Laufs.

> **Eingaben bei `workflow_dispatch`:** `type: choice` zeigt beim manuellen Start ein Auswahlfeld. Eingaben erreichst du über `inputs.<name>`. Wie in Teil 1 gilt: Bei Freitext-Eingaben immer über `env:` in die Shell geben, nie direkt in `run:` einsetzen. Hier ist `modus` eine feste Auswahl, wird aber trotzdem über `env:` gelesen.

**Aufgaben**
1. Starte den Workflow mit Modus `normal`. Welche Schritte laufen, welche werden übersprungen?
2. Starte ihn mit Modus `fehler`. Welche Schritte laufen jetzt? Wo erscheint die Zusammenfassung?
3. Entferne beim Schritt `Kurzer Aufräumschritt` das `if: always()`. Wie ändert sich das Verhalten im Fehlerfall? Stelle die Zeile anschließend wieder her.
4. **Nur beobachten:** Setze `timeout-minutes: 1` und füge einen Schritt `sleep 90` ein. Was passiert ungefähr nach einer Minute? Entferne die Änderung danach wieder.
5. **Nur beobachten:** Füge einen Schritt `sleep 60` ein, starte den Workflow und brich den Lauf während des Wartens manuell ab. Prüfe, ob `cancelled()`- und `!cancelled()`-Schritte noch ausgeführt werden. Das Ergebnis ist timingabhängig und kein festes Soll-Ergebnis. Entferne den Testschritt anschließend.

---

## Abschlussprojekt: Auswertungs-Pipeline

**Lernziel:** Du sammelst Ergebnisse mehrerer Matrix-Läufe als Artefakte und fasst sie in einem eigenen Schritt zusammen.

Verbinde Matrix, Artefakte und Zusammenfassung. Für die Action-Versionen und den Versionsstand gelten die Angaben aus Lektion 9. Die offizielle Dokumentation beschreibt `pattern` und `merge-multiple` für den Download; siehe [upload-artifact](https://github.com/actions/upload-artifact/blob/v7/README.md) und [download-artifact](https://github.com/actions/download-artifact/blob/v8/README.md).

**Datei anlegen:** `.github/workflows/15-pipeline.yml`

```yaml
# Linux CI — Beispielcode
# Lizenz: MIT (siehe LICENSE-CODE.txt im Kurs-Repository)
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
          if [ ! -f daten/server.log ]; then
            echo "Datei daten/server.log fehlt" >&2
            exit 2
          fi
          mkdir -p ergebnis
          if ANZAHL=$(grep -F -c -- "$STUFE" daten/server.log); then
            :
          else
            STATUS=$?
            if [ "$STATUS" -eq 1 ]; then
              ANZAHL=0
            else
              exit "$STATUS"
            fi
          fi
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
            echo "Download fehlgeschlagen (Status: $LADEN)," \
              "Details im Log des Schritts 'Teilergebnisse laden'." \
              | tee -a "$GITHUB_STEP_SUMMARY"
            exit 1
          fi
          if ! ls sammlung/*.txt > /dev/null 2>&1; then
            echo "Download erfolgreich, aber keine Teilergebnis-Dateien" \
              "gefunden." | tee -a "$GITHUB_STEP_SUMMARY"
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

Für diese Pipeline bleiben die Werte bei den drei Stufen INFO, WARNING und ERROR; `FATAL` wird in Aufgabe 2 als zusätzliche Matrix-Variante ergänzt.

**Der Kontrollfluss im Zusammenfassungsschritt**

Der Download hat `continue-on-error: true`, damit der Folgeschritt auch dann noch läuft, wenn der Download scheitert. Die offizielle [Dokumentation zu `download-artifact@v8`](https://github.com/actions/download-artifact/blob/v8/README.md) beschreibt den Download passender Artefakte, legt aber nicht fest, dass ein Muster ohne Treffer zwingend einen Fehlerstatus liefert. Der Workflow behandelt daher beide möglichen Ergebnisse sicher: Er prüft erst `outcome` und kontrolliert anschließend, ob `.txt`-Dateien vorhanden sind. Bei null hochgeladenen Artefakten kann die Meldung je nach Action-Verhalten entweder „Download fehlgeschlagen“ oder „Download erfolgreich, aber keine Teilergebnis-Dateien gefunden“ lauten; beide Fälle beenden den Zusammenfassungsschritt mit Fehler. Kein leeres Ergebnis wird als Erfolg gemeldet.

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
2. Ergänze `FATAL` in der `stufe`-Liste des Matrixjobs. Wie sieht die Zusammenfassung aus?
3. Baue den Zählschritt so um, dass er den wiederverwendbaren Workflow aus Lektion 11 verwendet statt eigenem `grep`. Welche Teile der Pipeline müssen sich ändern, welche nicht? (Tipp: Ein Aufruf per `uses:` kann ebenfalls in einer Matrix stehen, aber der Artefakt-Upload müsste dann im wiederverwendbaren Workflow stattfinden.)
4. Teste zwei Fehlerfälle. Füge jeweils die angegebene Zeile in den Schritt `Zählen und speichern` ein und entferne sie nach dem Test wieder:
   - **a) Ein Lauf scheitert vor dem Upload:** Füge vor der Zählung `[ "$STUFE" != "WARNING" ] || exit 1` ein. Der WARNING-Lauf lädt nichts hoch. Kontrolliere im Log, welche Dateien heruntergeladen und in die Zusammenfassung aufgenommen wurden.
   - **b) Alle Läufe scheitern vor dem Upload:** Füge `exit 1` direkt nach `mkdir -p ergebnis` ein. Es wird nichts hochgeladen. Im Workflow sind die Ausgaben von `outcome` und `conclusion` vorbereitet. Prüfe, ob die Action einen Fehler meldet oder der Download-Schritt erfolgreich, aber ohne Dateien endet. In beiden Fällen muss die Prüfung den Zusammenfassungsschritt scheitern lassen. Das genaue Verhalten bei null Artefakten ist eine Beobachtung und keine feste Soll-Ausgabe.
5. Breche einen laufenden Lauf von Hand ab. Beobachte, ob `zusammenfassen` startet oder weiterläuft. Ändere die Bedingung auf `always()` und wiederhole den Versuch. Die Ergebnisse hängen vom Abbruchzeitpunkt ab; bewerte nicht, ob der Job noch gestartet oder beendet wurde. Stelle die ursprüngliche Bedingung anschließend wieder her.

---

## Häufige Fehler in Teil 3

| Fehler | Ursache |
| -------- | --------- |
| Matrix-Wert ist leer | Falsche Schreibweise, es heißt `matrix.suchbegriff` und nicht `matrix.Suchbegriff` oder `${{ suchbegriff }}`; für die Datei nutze `matrix.datei` |
| Zu viele Läufe | Zwei Dimensionen multiplizieren sich |
| Secret fehlt oder ist leer | Name falsch geschrieben, nicht angelegt oder im Kontext nicht verfügbar |
| Secret erscheint lesbar im Log | Der Wert wurde ausgegeben oder verändert; Maskierung ist keine Garantie |
| `workflow_call` startet nicht | Pfad bei `uses:` falsch, Datei nicht auf dem Branch, `on: workflow_call` fehlt |
| Output des Aufrufers leer | Ausgabe nicht in allen Stufen durchgereicht (Schritt, Job, Workflow) |
| `uses:` zusammen mit `steps:` | Aufrufende Jobs haben `uses:` **statt** `runs-on:` und `steps:` |
| `suchwort` ist leer trotz `required: false` | `default:` fehlt; `suchwort` ist eine Eingabe des wiederverwendbaren Workflows, `suchbegriff` dagegen ein Matrix-Wert |
| Schritt nach Fehler übersprungen | Standardmäßig gilt `success()`, `always()`, `!cancelled()` oder `failure()` nutzen |
| Schritt nach Abbruch wird nicht ausgeführt | Auch mit `cancelled()` oder `always()` ist ein Start nach manueller Abbruchanforderung nicht garantiert |
| Artefakt-Download findet nichts | Muster passt nicht zu den Artefaktnamen, alle Uploads sind gescheitert, oder die Artefakte kommen aus einem anderen Lauf |
| Download-Fehler wird nicht erkannt | `conclusion` statt `outcome` geprüft, oder `continue-on-error` verbirgt die Ursache (im Log des Download-Schritts nachsehen) |
| Zwei Artefakte mit gleichem Namen | Artefaktnamen müssen innerhalb eines Laufs eindeutig sein |
| `grep`-Zähler ist leer oder unerwartet | Datei prüfen; nur Status 1 bedeutet „kein Treffer“, andere Fehler weitergeben |
| Dateien überschreiben sich nach dem Download | `merge-multiple` legt alle Dateien in einen Ordner, gleichnamige Dateien kollidieren |

---

## Spickzettel-Ergänzung: Eintrag in deine `CHEATSHEET.md`

Lege in deinem eigenen Lern-Repository eine Datei `CHEATSHEET.md` an, falls du sie noch nicht hast. Ergänze dort zum Beispiel diese Übersicht:

```
strategy.matrix                 Ein Job, mehrere Läufe
matrix.<name>                   Wert im jeweiligen Lauf (z. B. matrix.stufe)
matrix.include                  Kombination ergänzen oder erweitern
fail-fast: false                Andere Läufe nicht wegen eines Fehlers abbrechen
vars.NAME                       Variable (nicht geheim)
secrets.NAME                    Secret (nicht ausgeben)
on: workflow_call               Workflow aufrufbar machen
uses: ./.github/workflows/x.yml Lokalen Workflow aufrufen
with:                           Eingaben übergeben
if: ${{ !cancelled() }}         Läuft nach Erfolg und Fehler, nicht nach Abbruch
if: ${{ always() }}             Kann auch nach Abbruchanforderung starten
if: ${{ failure() }}            Läuft nur nach Fehler
if: ${{ cancelled() }}          Bedingung für abgebrochene Läufe
continue-on-error: true         Schrittfehler tolerieren, outcome bleibt sichtbar
steps.<id>.outcome              Echtes Ergebnis eines Schritts (vor continue-on-error)
steps.<id>.conclusion           Ergebnis nach continue-on-error (Fehler wird zu success)
timeout-minutes: N              Zeitlimit für den Job
>> "$GITHUB_STEP_SUMMARY"       Zusammenfassung im Lauf anzeigen
```

---
