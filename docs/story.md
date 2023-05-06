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

## Produktion
1. Was ist Kubernetes?
1. TODO: die Installation wird bei 24 Leuten ewig dauern und wahrscheinlich gar nicht möglich sein
   - nur einer im Team macht es?
   - am Anfang vor 10 schon so viele Rechner flott machen wie möglich
1. Cluster und Services wie in README.md beschrieben
   - Das kann alles bisschen dauern, insbesondere wenn wir uns das Netz mit allen teilen

1. Beendigung der Tekton Pipelines in http://tekton.localhost/#/pipelineruns abwarten
   - Selbst mit bestem Netz dauert das auf meinem Rechner 15 Minuten
   - Durchgehen, was da eigentlich alles passiert
   
1. Hier liegt unser Source-Code http://gitea.local/
   1. Login: ok-user / Password1234!
   1. http://gitea.local/ok-user/ok-gitea-repository/src/branch/main/src/insurance_prediction/train/train.py
   1. Hier die Kapazität herunter schrauben
   1. Hier müsste eine neue Pipeline anlaufen: http://tekton.localhost/#/namespaces/cicd/pipelineruns
1. Service hier ausprobieren: http://localhost:30080/docs   
1. k9s
   - Läuft da ein pod im production Namespace? Das ist unsere Anwendung
   - Platt machen und gucken, was passiert
   - kommt man hier noch drauf: http://localhost:30080/docs


## Monitoring
1. Evidently Metrics: http://localhost:30080/metrics/
1. Prometheus Time Series: http://localhost:30090
1. Grafana Dashboards: http://localhost:30031
   - login: admin/admin   
1. Produktion simulieren
   1. Story:
     1. die Performance des Modells degradiert
	  1. aber wir haben erst nach Jahren eine Ground Truth, die uns das anhand der Metrik zeigt
	  1. wir simulieren 3 Jahre Betrieb mit
         1. Leute werden immer Älter, das passiert aber langsam (age)
	     1. Es wird immer weniger Auto gefahren, Leute steigen um auf die Bahn und öffentliche Verkehrsmittel (miles)
	     1. Die Sicherheit der Autos wird immer besser und der Einfluss der individuellen Fahrleistung wird verringert (emergency_braking, pred)  
   1. `./scripts/curl-drift.sh localhost:30080`
   1. `http://localhost:30080/metrics/`
   1. `http://localhost:30031/d/U54hsxv7k/evidently-data-drift-dashboard?orgId=1&refresh=5s`
