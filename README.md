# Apache Generator
-------------

Apache Generator is a tool to generate apache configuration file. It allows you to generate simple files with proxy, directory protection and custom path / name / Directory index.

## How to use ?

> git clone 

> chmod +x apache-generator.sh

> ./apache-generator -n CONFIG_NAME --path=FILE_PATH

## List of possibles options

| Command           |             Description                     |
|:-----------------:|--------------------------------------------:|
|   ?               | Show the help menu                          |
|   -u / --user     | Specify ssh user                            |
|   -h / --host     | Specify ssh host                            |
|   -p / --port     | Specify ssh port                            |
|   -n / --name     | Specify server name                         |
|   --path          | Specify DocumentRoot path                   |
|  -d /--dir        | Specify Directory to protect                |
| --allow-ip        | Specify an ip allowed to access to this dir |
| --dir-default     | Specify the directoryIndex                  |
| -P / --proxy      | Specify the proxy url                       |
| -N / --proxy-path | Specify the proxy path                      |