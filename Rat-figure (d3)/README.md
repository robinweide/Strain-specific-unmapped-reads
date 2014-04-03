Workflow for making the rat-figure
====================================
![](screenshot.png?raw=true)
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
