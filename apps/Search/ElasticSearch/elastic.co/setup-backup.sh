#!/bin/bash

# Setup Backup Location for Snapshots
curl -X PUT "localhost:9200/_snapshot/es_backups?pretty" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/usr/share/elasticsearch/backups",
    "compress": true
  }
}
'


