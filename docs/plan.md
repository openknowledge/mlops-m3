# Story

## Intro
1. Problemstellung: innovative Kfz-Versicherungsgesellschaft
1. Ausgangspunkt mit Colab: notebooks/exploration.ipynb
   1. Features
   1. Was wollen wir vorhersagen?
   1. Tests, Training, 
1. MLOps Grundlagen / Überblick über die Phasen, wieso kann ich damit nicht in Prod gehen

## Professionalisierung

1. Intro Docker
1. Notebook in Libs und Scripte
1. Docker Container starten
   1. `cd insurance-prediction`
   1. `docker build -t insurance-prediction .`
   1. Gucken welcher Port frei ist und den beim Mapping nach außen nutzen
   1. `docker run -d -p 8080:80 insurance-prediction`
1. Build: Scripte im Docker Container laufen lassen
   1. TODO: wie machen die ein Terminal auf?
   1. TODO: wie starten wir das im Container?
   1. Validation diskutieren
      * was haben wir eingebaut
      * wie sinnvoll ist das, was kann man noch machen?
      * was für eine Art Test ist das?
1. Server ausprobieren
   1. `http://localhost:8080/docs`
   1. Für eigene Werte ausprobieren
   1. Was passiert bei komischen Werten
   1. Ensemble, ML als kompletter Service

## Produktion TODO   

## Monitoring
1. Evidently Metrics: http://localhost:8080/metrics/
1. Prometheus Time Series: http://localhost:30090
1. Grafana Dashboards: http://localhost:30031   
1. Produktion simulieren
   1. Story:
      1. die Performance des Modells degradiert
	  1. aber wir haben erst nach Jahren eine Ground Truth, die uns das anhand der Metrik zeigt
	  1. wir simulieren 3 Jahre Betrieb mit
         1. Leute werden immer Älter, das passiert aber langsam (age)
	     1. Es wird immer weniger Auto gefahren, Leute steigen um auf die Bahn und öffentliche Verkehrsmittel (miles)
	     1. Die Sicherheit der Autos wird immer besser und der Einfluss der individuellen Fahrleistung wird verringert (emergency_braking, pred) 
   1. `(mlops-workshop-d2d) olli@DESKTOP-BEN73DP:~/mlops-data2day$ ./scripts/example_run_request.py` 
   1. `http://localhost:8085/metrics`
   1. `http://localhost:3000/d/U54hsxv7k/evidently-data-drift-dashboard?orgId=1&refresh=5s`


# Zeitplan

## ab 09:00 Uhr: Wer noch Hilfe bei der Installation braucht, kann bereits jetzt erscheinen

## 10:00 Uhr: Beginn

## Einleitung / Grundlagen (Olli 1h)
- Unser Beispiel
- Unser Ausgangspunkt: Notebooks
- Übersicht MLOps

## Professionalisierung (Yannick 1,5h)
- Bestehendes Notebook professionalisieren 
- Das Modell mit FastAPI via REST bereitstellen
- Einführung in die Containerisierung
- Training und Deployment in Containern

Ausblick auf den Block nach der Mittagspause
- Mit vorhandener Infrastructure as Code einen Cluster erzeugen

## 12:30 - 13:30 Uhr: Mittagspause

## Betrieb (Tobi 1,5h)
- Aufsetzen eines Clusters mittels Terraform in Kind
- Überblick über die verschiedenen Anwendungen im Cluster
- Die Build und Trainings-Pipeline ausführen (CI)
- Deployment der ML Anwendung und des Modells (CD)

## 15:00 - 15:15 Uhr: Kaffeepause

## Monitoring (Olli 1h)
- Drift verstehen und detektieren
- Drift Detection mit Prometheus, Evidently und Grafana

## 16:15 - 16:30 Uhr: Kaffeepause

## Abschluss (Alle 0,5h)
- Zusammenfassung
- Offene Fragen
- Ausblick

## ca. 17:00 Uhr: Ende

## Notwendige Software
* Einen aktuellen Chrome Browser und ein Google Login
* git: https://git-scm.com/downloads
* Empfohlen für Windows: WSL2 mit Ubuntu für Shell und Docker: https://ubuntu.com/tutorials/install-ubuntu-on-wsl2-on-windows-11-with-gui-support
* kubectl: https://kubernetes.io/de/docs/tasks/tools/install-kubectl/
* docker: https://docs.docker.com/get-docker/`
* kind: https://kind.sigs.k8s.io/docs/user/quick-start#installation
* terraform: https://developer.hashicorp.com/terraform/downloads?product_intent=terraform
* Als Bonus: k9s: https://k9scli.io/topics/install/

# Didaktische Prinzipien

- Phasen klar haben, und klar kommunizieren, z.B. Übung: 
  - was sollen die Leute machen
  - ist die Aufgabenstellung klar?
  - wie viel Zeit
  - wann sollen die loslegen 
- sich nicht in Details verlieren, 
  - den Überblick behalten
  - es muss nicht jeder alles immer verstehen oder am laufen haben
  - versuchen, das Ziel im der Übung/Blocks im Auge zu behalten
- dennoch: Störung haben Vorrang 
  - Unklarheiten
  - Zweifel
  - Fragen / Diskussionen

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
