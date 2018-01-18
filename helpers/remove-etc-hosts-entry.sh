# remove specified host from /etc/hosts
function removehost() {
    if [[ "$1" ]]
    then
        HOSTNAME=$1

        if [ -n "$(grep $HOSTNAME /etc/hosts)" ]
        then
            echo "'$HOSTNAME' found in /etc/hosts, removing.";
            sudo sed -i".bak" "/$HOSTNAME/d" /etc/hosts
        else
            echo "'$HOSTNAME' was not found in /etc/hosts";
        fi
    else
        echo "Error: missing required parameters."
        echo "Usage: "
        echo "  removehost domain"
    fi
}

removehost $@
