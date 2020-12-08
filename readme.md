# GCP Cloud Run. MySql. WordPress.  

### 1.Step - Create MySql DB.  
Create instance:   
***Warning*** about reuse the instance name -- [https://cloud.google.com/sql/faq?hl=en#reuse](https://cloud.google.com/sql/faq?hl=en#reuse) and  [https://googlecloudplatform.uservoice.com/forums/302613-cloud-sql/suggestions/9919266-bug-cannot-create-instance-with-the-same-name-as](https://googlecloudplatform.uservoice.com/forums/302613-cloud-sql/suggestions/9919266-bug-cannot-create-instance-with-the-same-name-as). So, here intance is ***`mysql4`*** (yet).   
```sh
gcloud sql instances create mysql4 \
--tier=db-f1-micro \
--zone=us-central1-f
```   
Change root password:   
```sh
gcloud sql users set-password root \
--host % \
--instance mysql4 \
--password "Passw0rd("
```   
Create DB and User for WordPress:   
```sh
gcloud sql databases create wp --instance=mysql4 --charset=utf8 --collation=utf8_general_ci

gcloud sql users create wp --host=% --instance=mysql4 --password="Passw0rd("
```   
`INSTANCE_CONNECTION_NAME = kubernetes-258422:us-central1:mysql4` is using at next step.     
There are `PROJECT-ID:REGION:INSTANCE-ID.`   

***Note:*** Users created using Cloud SQL have all privileges except FILE and SUPER.   

### 2.Step - Build Image and Run.   
[Container runtime contract](https://cloud.google.com/run/docs/reference/container-contract) about the listening port - Respect.   

Here are considered 2 ways to connect with MySql:   
-  **Using the Unix domain socket** [https://cloud.google.com/sql/docs/mysql/connect-run](
https://cloud.google.com/sql/docs/mysql/connect-run).   
Realised in dir `Apache-socket`. 
****Warning**** `wp-config.php` need to contain `define( 'DB_HOST', 'localhost:/cloudsql/<INSTANCE_CONNECTION_NAME>' );`    ***'localhost'*** must have, no ~~'127.0.0.1'~~.   

Build image:   
```sh
gcloud builds submit --tag gcr.io/<project-id>/apache-socket:1
```    
Deploying this container:   
```sh 
gcloud beta run deploy wp-socket \
--region us-central1 \
--allow-unauthenticated \
--image gcr.io/<project-id>/apache-socket:1 \
--platform managed \
--add-cloudsql-instances <INSTANCE-CONNECTION-NAME> 
```   
      
-  **Using the Cloud SQL Proxy** [https://cloud.google.com/sql/docs/mysql/connect-admin-proxy](
https://cloud.google.com/sql/docs/mysql/connect-admin-proxy).   
Realised in dir `Apache-proxy`.   
`Cloud_sql_proxy` has installed and started inside the container then `DB_HOST` is defined as `'127.0.0.1'`. Change `<INSTANCE-CONNECTION-NAME>` in `cloud-run-entrypoint.sh`.   

Build image:   
```sh
gcloud builds submit --tag gcr.io/<project-id>/apache-proxy:1
```   
Deploying this container:   
```sh
gcloud beta run deploy wp-proxy \
--region us-central1 \
--allow-unauthenticated \
--platform managed \
--image gcr.io/<project-id>/apache-proxy:1
```



