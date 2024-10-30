A collection of tasks to perform in projects.

## Installation

Install `task` according to your OS as described [here](https://taskfile.dev/installation/)
The tasks have been tested on a Windows OS, but should work in other OS's. Those using pwsh (powershell) scripts, require Powershell to be installed.

Using [ps-menu](https://github.com/chrisseroka/ps-menu) to create interactive selection in pwsh scripts. Install using `Install-Module PS-Menu`

## Configuration

- You can add variables that are available throughout all tasks in the vars section.
- define env variables under the env section
- by adding env files you wish to load. By changing the CURRENT_ENV env variable you can load different env files besides the basic .env file.
- secrets folders will hold all of our .env files or other files we do not want in the repository.
- scripts folder in the root, will have all powershell or bash scripts we want to use in our tasks.

## Usage

### 1. Default

Running task will list all available commands

### 2. Go app commands

- go:run `runs the main package, one or multiple files which are in the current directory`. Add more run commands for main packages in other folders

### 3. Atlas

- atlas:inspect_db `reads the DB_URL and extracts a schema using the ATLAS project. Then it uploads it to the web.

### 4. Database

- db:psql `it creates a docker container with the latest image version of the postgres database`
- db:create -- name_of_db `creates a new database. it will log by default to the local client. Edit compose.pgclient.local.yml file to log to another database server`
- db:drop -- name_of_db `drops a database. Same as create`
- db:cli `connects to the server defined in the compose file and opens the interactive cli`
- db:list `lists the db of the server`
- db:roles `list the roles in the db server`
- db:tb_info `lists the tablespace information of the server`
- db:list_tables -- name_of_db `lists the tables of the database `
- db:users `lists all the users defined in the db server`
- db:version `reports the version of the database server`
- db:backup -- db_name `it creates a tar backup file of the database in the compose folder`
- db:restore -- db_name `it takes the tar file generated in the previous step, the name is provided without the tar extension, and restores it back in the server`
- db:backupGlobals `using pg_dumpall it backups in an all.sql file in the compose folder the globals of the server`
- db:restoreGlobals `restores the global objects created in the previous step`

### 5. Docker containers

Create some containers

- docker:create_atlas `downloads the image of atlas and runs it once, but removes the container`
- docker:create_prometheus: `gets the latest image of prometheus and spins a container in the background. no remove. Name = prometheus`
- docker:create_grafana: `gets the latest image of grafana and spins a container in the background. Name = grafana `
- docker:build_image `this command builds a docker image based on a configuration file.`
    >You are asked about the location of the config file, initially opens at the build directory.
    >The configuration file has all the different types of images you want to create. Local, beta, production, test etc. Just edit the >fields of the template project_name.json file and you are done.
    >The configuration of each build covers image-name (repo/name), tags that you may want to apply, architecture etc. Of course you can >always edit the script to add more info.
    >Once the build is done successfully, the build number is increased. The build number is the number of the **next** build.


### 6. Metrics

Create a permanent service for prometheus, grafana, loki etc

All containers listen to of their defaults, in case we need to deploy others in the default port.

- metrics:up `spins up the metrics service`
- metrics:down `spins down the metrics service`

### 7. Secrets

It uses the values found in the /secrets/secrets.env file to get some values


- secrets:aws_dev `exports the contents of the file $DEV_SECRETS_FILE to aws secret manager with name $DEV_SECRET_NAME`
- secrets:aws_prod `same as the dev, but using the $PROD_SECRETS_FILE and $PROD_SECRET_NAME variables`
- secrets:aws_import `reads the secret with name $DEV_SECRET_NAME and exports it to export.env file in the secrets folder. Change the variable to point to a different secret`

