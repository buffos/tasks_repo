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

### The project.json file

In order to keep this the center of operation of all projects, the project.json will hold all necessary information about the project. We associate the project with a key and this key is passed in the taskfile.yml as the var $PROJECT_KEY. This way, we only have to change that key, and all scripts will take parameters, if needed from there. We did not follow this route in the build section, because a single project can build multiple images, so it it easier to select the json file that contains the configuration for that image, than creating nested objects inside the json file and figure out a way to let the user select the image they want to build.

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

The project.json file has a separate secrets section.

- It is necessary to have defined the path.root key (which is the path to the project we are working)
- Every entry in the secrets object corresponds to a different secret on the server. It has the name property (which is the name on the server) and the path, which is the path of the .env file stored relative to the root path as noted above.

- secrets:to_aws `exports the contents to aws`
    - Usage: task:to_aws -- <key_secret>
    - Example: The secrets section of the project.json template file looks like
    ```json
            "secrets": {
                "aws_dev": {
                    "name": "aws/secret/name/path",
                    "path": "file/path/relative/to/root"
                },
                "aws_prod": {
                    "name": "aws/secret/name/path",
                    "path": "file/path/relative/to/root"
                }
            }
    ```
    This means that task:to_aws -- aws_dev , will export the file that "path" points to, to the secret "name" points to.
- secrets:from_aws `imports a secret from aws to local drive`
    - Usage: task:from_aws -- <key_secret>

    It uses the same keys and values as the export script. The exported file is saved in the secrets folder of **this** directory.

### 8. Local project tasks

We obviously need to run the local taskfile commands, which are defined in the project. Build, run, test etc.
To do that use

- task local -- "command we want to issue"

For example

`task local -- "task --list"` will list all the tasks of the local project

Important: The project we are targeting is the one defined in the $PROJECT_KEY variable in taskfile.yml. Changing the key all you need to target that project in all scripts. Just make sure the root path is configured correctly.