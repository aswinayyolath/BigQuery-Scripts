#!/bin/bash
# Script to execute BigQuery Operations

create_bq_ds() {
    ds=$1
    loc=$2
    exists=$(bq ls -d | grep -w $ds)
    if [ -n "$exists" ]; then
       echo "Not creating $ds since it already exists"
    else
       echo "Creating $dataset"
       bq --location=$loc mk $ds
    fi
}

remove_bq_ds(){
   ds=$1
   exists=$(bq ls -d | grep -w $ds)
    if [ -n "$exists" ]; then
       bq rm -r -d $ds
       echo "$ds successfully deleted"
    else
       echo "$ds does not exists !!!!"
    fi
}


create_table(){
  ds=$1
  table_name=$2
  schema_path=$3
  bq mk --table $ds.$table_name $schema_path 
}


PS3='Please enter your choice: '
options=("Create Dataset" "Delete Dataset" "Create a Table" "Delete Table"
         "List Dataset" "List tables in Dataset" "Show table Details" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Create Dataset")
           read -p "Dataset Name: " Datasetname
           read -p "Dataset Location: " DsLoc
           create_bq_ds $Datasetname $DsLoc
            ;;
        "Delete Dataset")
           read -p "Dataset Name: " Datasetname
           remove_bq_ds $Datasetname
            ;;
        "Create a Table")
            read -p "Dataset Name: " Datasetname
            read -p "Table Name: " Tablename
            read -p "Path to table schema: " TableSchema
            create_table $Datasetname $Tablename $TableSchema
            ;;
        "Delete Table")
            read -p "Dataset Name: " Datasetname
            read -p "Table Name: " Tablename
            bq rm $Datasetname.$Tablename            
            ;;
        "List Dataset")
            bq ls
            ;;
        "List tables in Dataset")
            read -p "Dataset Name: " Datasetname
            bq ls $Datasetname
            ;;
        "Show table Details")
            project=gcloud config list --format 'value(core.project)' 2>/dev/null
            read -p "Dataset Name: " Datasetname
            read -p "Table Name: " Tablename
            bq show --format=prettyjson $project:$Datasetname.$Tablename
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done


