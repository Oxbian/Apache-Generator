#!/bin/bash
package="Apache Generator"

while test $# -gt 0; do
    case "$1" in
        ?|--help)
            echo "$package - attempt to capture frames"
            echo " "
            echo "$package [options] application [arguments]"
            echo " "
            echo "options:"
            echo ""
            echo "?, --help                   show brief help"
            echo "-u, --user=SSH_USER         specify remote ssh user"
            echo "-h, --host=HOST_IP          specifiy remote host IP"
            echo "-p, --port=SSH_PORT         specify remote ssh port"
            echo ""
            echo "-n, --name=SERVER_NAME      specify server name"
            echo "--path=PATH                 specify path to the files of the server"
            echo ""
            echo "-d, --dir=DIRECTORY_PATH    specify directory to protect path"
            echo "--allow-ip=IP               specify ip to allow access the directory"
            echo "--dir-default=DEFAULT       specify a default file"
            echo ""
            echo "-P, --proxy=PROXIED_URL     specify proxy url"
            echo "-N, --proxy-path=NAME       specify proxy path"
            echo ""
            exit 0
            ;;
        # SSH flags
        -u)
            shift
            if test $# -gt 0; then
                export user=$1
            else
                echo "No remote user specified"
                exit 1
            fi
            shift
            ;;
        --user*)
            export user=`echo $1 | sed -e 's/^[^=]*=//g'`
            shift
            ;;
        -h)
            shift
            if test $# -gt 0; then
                export host=$1
            else
                echo "No remote host specified"
                exit 1
            fi
            shift
            ;;
        --host*)
            export host=`echo $1 | sed -e 's/^[^=]*=//g'`
            shift
            ;;
        -p)
            shift
            if test $# -gt 0; then
                export port=$1
            else
                echo "No remote port specified"
                exit 1
            fi
            shift
            ;;
        --port*)
            export port=`echo $1 | sed -e 's/^[^=]*=//g'`
            shift
            ;;

        #Basic config flags
        -n)
            shift
            if test $# -gt 0; then
                export name=$1
            else
                echo "No server name specified"
                exit 1
            fi
            shift
            ;;
        --name*)
            export name=`echo $1 | sed -e 's/^[^=]*=//g'`
            shift
            ;;
        --path*)
            export path=`echo $1 | sed -e 's/^[^=]*=//g'`
            shift
            ;;
        
        #Directory flags
        -d)
            shift
            if test $# -gt 0; then
                export dir=$1
            else
                echo "No directory specified"
                exit 1
            fi
            shift
            ;;
        --dir*)
            export dir=`echo $1 | sed -e 's/^[^=]*=//g'`
            shift
            ;;
        --allow-ip*)
            export dirIp=`echo $1 | sed -e 's/^[^=]*=//g'`
            shift
            ;;
        --dir-default*)
            export dirDefault=`echo $1 | sed -e 's/^[^=]*=//g'`
            shift
            ;;

        #Proxy flags
        -P)
            shift
            if test $# -gt 0; then
                export proxy=$1
            else
                echo "No proxy specified"
                exit 1
            fi
            shift
            ;;
        --proxy*)
            export proxy=`echo $1 | sed -e 's/^[^=]*=//g'`
            shift
            ;;
        -N)
            shift
            if test $# -gt 0; then
                export proxy=$1
            else
                echo "No proxy path specified"
                exit 1
            fi
            shift
            ;;
        --proxy-path*)
            export proxyPath=`echo $1 | sed -e 's/^[^=]*=//g'`
            shift
            ;;

        *)
            break
            ;;
    esac
done

#Checking logic fail in the user command 
# TODO: dir & no dir request
# dir request & no dir
# proxy name and no proxy path
# proxy path and no proxy name
# server name and no docu root
# docu root and no server name
# ssh user and no host
# ssh host and no user

#if (( ${#}))

# Testing if the user want to use ssh
if [ ${#user} -gt 0 ] && [ ${#host} -gt 0 ];
then
    if ((${#port} < 0));
    then
        port="22"
    fi

    #Checking if the user provides us the needing servername and file path
    if [ ${#name} -gt 0 ] && [ ${#path} -gt 0 ];
    then
        ssh -t ${user}@${host} -p ${port} << EOF
            sudo -u root printf '<VirtualHost *:80>\n\tServerName %s\n\tServerAdmin webmaster@localhost\n\tServerAlias www.%s\n\tDocumentRoot %s\n\tErrorLog \${APACHE_LOG_DIR}/error-%s.log\n\tCustomLog \${APACHE_LOG_DIR}/access-%s.log combined\n' "$name" "$name" "$path" "$name" "$name" >> /etc/apache2/sites-available/$name.conf
EOF
        # If the user input a directory path
        if [ ${#dir} -gt 0 ];
        then
            ssh -t ${user}@${host} -p ${port} << EOF
                sudo -u root printf '<Directory %s>\n' "$dir" >> /etc/apache2/sites-available/$name.conf
EOF
            # If the user input a access allow ip
            if [ ${#dirIp} -gt 0 ];
            then
                ssh -t ${user}@${host} -p ${port} << EOF
                    sudo -u root printf '\tOrder deny,allow\n\tdeny from all\n\tAllow from %s\n' "$dirIP" >> /etc/apache2/sites-available/$name.conf
EOF
            fi

            #If the user input a default index file
            if [ ${#dirDefault} -gt 0 ];
            then
                ssh -t ${user}@${host} -p ${port} << EOF
                    sudo -u root printf '\tDirectoryIndex %s\n' "$dirDefault" >> /etc/apache2/sites-available/$name.conf
EOF
            fi

        fi #Endif for directory

        # If the user input a proxy path
        if [ ${#proxy} -gt 0 ] && [ ${#proxyPath} -gt 0 ];
        then
            ssh -t ${user}@${host} -p ${port} << EOF
                sudo -u root printf 'ProxyPass \"%s\" \"%s\"\nProxyPassReverse \"%s\" \"%s\"' "$proxy" "$proxyPath" "$proxy" "$proxyPath" >> /etc/apache2/sites-available/$name.conf
EOF
        fi

        ssh -t ${user}@${host} -p ${port} << EOF
            sudo -u root printf "</VirtualHost>" >> /etc/apache2/sites-available/$name.conf
            sudo -u root a2ensite $name.conf
            sudo -u root systemctl restart apache2
EOF
        echo "$host  $name" >> /etc/hosts
        printf "\033[32m[✔] File generated\033[0m\n"
    else
        printf "\033[31mPlease specify the server name and the path to the server files with the -n and --path flags!\n\033[0m\n"
    fi


#we assume that the user want to generate the file on his local machine
else
   #Checking if the user provides us the needing servername and file path
    if [ ${#name} -gt 0 ] && [ ${#path} -gt 0 ];
    then
        echo $name $path
        printf '<VirtualHost *:80>\n\tServerName %s\n\tServerAdmin webmaster@localhost\n\tServerAlias www.%s\n\tDocumentRoot %s\n\tErrorLog \${APACHE_LOG_DIR}/error-%s.log\n\tCustomLog \${APACHE_LOG_DIR}/access-%s.log combined\n' "$name" "$name" "$path" "$name" "$name" >> /etc/apache2/sites-available/$name.conf
        # If the user input a directory path
        if [ ${#dir} -gt 0 ];
        then
            printf '<Directory %s>\n' "$dir" >> /etc/apache2/sites-available/$name.conf

            # If the user input a access allow ip
            if [ ${#dirIp} -gt 0 ];
            then
                printf '\tOrder deny,allow\n\tdeny from all\n\tAllow from %s\n' "$dirIP" >> /etc/apache2/sites-available/$name.conf
            fi

            #If the user input a default index file
            if [ ${#dirDefault} -gt 0 ];
            then
                printf '\tDirectoryIndex %s\n' "$dirDefault" >> /etc/apache2/sites-available/$name.conf
            fi

        fi #Endif for directory

        # If the user input a proxy path
        if [ ${#proxy} -gt 0 ] && [ ${#proxyPath} -gt 0 ];
        then
            printf 'ProxyPass \"%s\" \"%s\"\nProxyPassReverse \"%s\" \"%s\"' "$proxy" "$proxyPath" "$proxy" "$proxyPath" >> /etc/apache2/sites-available/$name.conf
        fi

        printf "</VirtualHost>" >> /etc/apache2/sites-available/$name.conf
        $( a2ensite $name.conf; systemctl restart apache2; echo "127.0.0.1 $name" > /etc/hosts)
        printf "\033[32m[✔] File generated\033[0m\n"
    else
        printf "\033[31mPlease specify the server name and the path to the server files with the -n and --path flags!\n\033[0m\n"
    fi

fi