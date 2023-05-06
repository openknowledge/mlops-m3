# Blöcke

## I Einleitung / Grundlagen
#### Was sollen die Teilnehmer lernen?
- Abholen mit Notebook: So sieht vielleicht ein Projekt aus von dem die Teilnehmer denken, es sei fertig
- Bei uns geht es jetzt erst los
- Warum MLOPs?

### Übung
- Vertraut machen mit dem Anwendungensfall und dem Notebook, alle auf denselben Stand bringen

## II Professionalisierung
### Was sollen die Teilnehmer lernen?
- Was ist der Unterschied zwischen einem Notebook und einem Software Projekt
- Man bringt kein Notebook in Produktion
- Ein ML Service ist weit mehr als nur ein Modell

### Übung
1. Image über Dockerfile bauen und starten
1. Über Swagger einen Request gegen den Server machen

## III Betrieb
### Was sollen die Teilnehmer lernen?
- Einen Service manuell in Produktion zu bringen, ist wenig professionell
- Änderungen müssen automatisch gebaut und deployed werden

### Übung
1. Installation mit Terraform (wenn nicht schon am Anfang gemacht)
   * wie in der Readme beschrieben
1. Pipeline und Trigger erkunden
   1. Kapazität des Modells herunterschrauben
   1. Pipeline läuft nicht durch, da Qualität des Modells zu niedrig
   1. Kapazität des Modells wider heraufschrauben und Pipeline läuft wieder durch
1. Modell-Code in Gitea erweitern, sodass es genug Kapazität hat bis es erfolgreich durch die Pipeline geht 

## IV Monitoring
### Was sollen die Teilnehmer lernen?
- Man ist nicht fertig, wenn das Modell ist Produktion ist
- Monitoring von ML ist besonders, braucht Statistik und Interpretation

### Übung
1. Requests abfeuern
1. Drift beobachten
