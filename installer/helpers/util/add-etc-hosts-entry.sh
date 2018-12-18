#add new ip host pair to /etc/hosts
function addhost() {
    if [[ "$1" && "$2" ]]; then
        IP=$1
        HOSTNAME=$2

        if [ "$HOSTNAME" == "localhost" ]; then
          echo "Not removing '$HOSTNAME'"
          return
        fi

        if [ -n "$(grep $HOSTNAME /etc/hosts)" ]
            then
                echo "'$HOSTNAME' already exists:";
                echo $(grep $HOSTNAME /etc/hosts);
            else
                echo "Adding '$HOSTNAME' to /etc/hosts";
                printf "%s\t%s\n" "$IP" "$HOSTNAME" | sudo tee -a /etc/hosts > /dev/null;

                if [ -n "$(grep $HOSTNAME /etc/hosts)" ]
                    then
                        echo "'$HOSTNAME' was added succesfully:";
                        echo $(grep $HOSTNAME /etc/hosts);
                    else
                        echo "Failed to add '$HOSTNAME'";
                fi
        fi
    else
        echo "Error: missing required parameters."
        echo "Usage: "
        echo "  addhost ip domain"
    fi
}

addhost $@
