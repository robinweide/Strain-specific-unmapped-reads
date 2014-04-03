Strain-donuts
====================================
![](screenshot.png?raw=true)
This makes donut-charts of all available _id's. There is mouse-over information per donut-slice.
Workflow for making the rat-figure: local (.csv)
---------
Rat_data.csv hold all rat-field. A shot snippet of this csv:
```
Strain,Split mapped,Low quality & length,Mapped Y,Contamination,Non-reference reads,Mapped Celera,Strain-specific reads
Da/BklArbNsi,0.013331389,27.9059000593,49.5468500965,0.272537455,4.8796506815,17.3817303188,0
F344/NCrl,0.0020170836,26.8085849336,36.6673559791,0.0052116035,18.4008912748,9.0579695627,9.0579695627
```
Runnning the d3-based html-script "rat_figure-local.html" will then create the figure.
Workflow for making the rat-figure: noSQL
---------
Rat_docid.json has all rat-fields. A short snippet of this json:

```
{"docs":[
   {
      "_id":"Da/BklArbNsi",
      "Split mapped":0.013331389,
      "Low quality & length":27.9059000593,
      "Mapped Y":49.5468500965,
      "Contamination":0.272537455,
      "Non-reference reads":4.8796506815,
      "Mapped Celera":17.3817303188,
      "Strain-specific reads":0
   },
   {
      "_id":"F344/NCrl",

 [...]

      "Strain-specific reads":5.506465316
   }
]}
```
post json to couchdb-server
```
sudo curl -X POST -H "Content-Type: application/json" -d @/home/robin/Rat_docid.json http://student:hello@umcu-bioinf.is-not-certified.com/robin/_bulk_docs -v
```
Workflow for making the scatter plot of Pjotr
---------
![](pjotr_screenshot.png?raw=true)
This figure nog has serveral additions:
* Mouse-over functionality: returns tumor and normal value of a point.
* logarithmic scales: for better visualisation
* enhanced title and axes
```
pjotr.html
```