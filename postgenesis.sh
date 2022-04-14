#!/bin/bash

if curl -s https://raw.githubusercontent.com/cryptongithub/init/main/empty.sh > /dev/null 2>&1; then
	echo ''
else
  sudo apt install curl -y
fi

curl -s https://raw.githubusercontent.com/cryptongithub/init/main/logo.sh | bash 
echo -e '\e[40m\e[92mCrypton Academy is a unique cryptocurrency community. \nCommunity chat, early gems, calendar of events, Ambassador programs, nodes, testnets, personal assistant. \nJoin (TG): \e[95mt.me/CryptonLobbyBot\e[40m\e[92m.\e[0m\n'

function generate_gentx {

    echo -e '\n\e[40m\e[92m1. Starting update...\e[0m'

    sudo apt update && sudo apt upgrade -y

    sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils git make ncdu gcc jq chrony liblz4-tool uidmap dbus-user-session libcurl4-gnutls-dev -y 
    
    source $HOME/.bash_profile
    if go version > /dev/null 2>&1
    then
        echo -e '\n\e[40m\e[92mSkipped Go installation\e[0m'
    else
        echo -e '\n\e[40m\e[92mStarting Go installation...\e[0m'
        cd $HOME && ver="1.17.2"
        wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
        sudo rm "go$ver.linux-amd64.tar.gz"
        echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile
        echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profilesource
        source $HOME/.bash_profile
        go version
    fi

    echo -e '\n\e[40m\e[92m2. Starting Archway Installation...\e[0m'
    cd $HOME && git clone https://github.com/archway-network/archway
    cd $HOME/archway && git checkout main && make install

    echo -e '\e[40m\e[92m' && read -p "Enter Node name: " ARCHWAY_MONIKER && echo -e '\e[0m'
    echo -e '\e[40m\e[92m' && read -p "Enter Wallet name: " ARCHWAY_WALLET && echo -e '\e[0m'
    ARCHWAY_CHAIN="torii-1"
    echo 'export ARCHWAY_CHAIN='${ARCHWAY_CHAIN} >> $HOME/.bash_profile
    echo 'export ARCHWAY_MONIKER='${ARCHWAY_MONIKER} >> $HOME/.bash_profile
    echo 'export ARCHWAY_WALLET='${ARCHWAY_WALLET} >> $HOME/.bash_profile
    source $HOME/.bash_profile

    wget -O $HOME/.archway/config/genesis.json "https://raw.githubusercontent.com/archway-network/testnets/main/torii-1/penultimate_genesis.json"

    echo -e '\n\e[40m\e[92m3. Generating keypair...\e[0m' 
    echo -e '\e[40m\e[92mEnter \e[40m\e[91mand remember\e[40m\e[92m at least 8 any characters (e.g. 1a3b5c7e), when asked...\e[0m'
    archwayd keys add $ARCHWAY_WALLET
    echo -e '\e[40m\e[92m\nYour \e[40m\e[91mpriv_validator_key.json\e[40m\e[92m:\n\e[0m'
    cat $HOME/.archway/config/priv_validator_key.json
    echo -e '\n\n\e[42m^^^ SAVE DATA ABOVE ^^^\e[0m' 
    echo -e '\n\e[40m\e[92mSave the information \e[40m\e[91mbetween\e[40m\e[92m \e[0m"Re-enter keyring passphrase:"\e[40m\e[92m \e[40m\e[91mand\e[40m\e[92m \e[42m\e[37m^^^ SAVE ALL DATA ABOVE ^^^\e[0m\e[40m\e[92m.\e[0m' && sleep 3
     
    archwayd config chain-id $ARCHWAY_CHAIN
    archwayd config node https://rpc.torii-1.archway.tech:443
    archwayd init ${ARCHWAY_MONIKER} --chain-id $ARCHWAY_CHAIN
    
    echo -e '\n\e[40m\e[92m4. Setting address as a variable...\e[0m' 
    echo -e '\e[40m\e[92mEnter the characters that you entered in the last step, when asked...\e[0m'
    ARCHWAY_ADDR=$(archwayd keys show $ARCHWAY_WALLET -a)
    echo 'export ARCHWAY_ADDR='${ARCHWAY_ADDR} >> $HOME/.bash_profile
    source $HOME/.bash_profile
    echo -e '\n\e[40m\e[92mYour address:\e[0m'$ARCHWAY_ADDR
    
    echo -e '\n\e[40m\e[92m5. Setting valoper as a variable...\e[0m' 
    echo -e '\e[40m\e[92mEnter the characters that you entered in the last step, when asked...\e[0m'
    ARCHWAY_VALOPER=$(archwayd keys show $ARCHWAY_WALLET --bech val -a)
    echo 'export ARCHWAY_VALOPER='${ARCHWAY_VALOPER} >> $HOME/.bash_profile
    source $HOME/.bash_profile
    echo -e '\n\e[40m\e[92mYour valoper:\e[0m'$ARCHWAY_VALOPER

}

function faucet {
    curl -X POST "https://faucet.torii-1.archway.tech/" \
    -H "accept: application/json" \
    -H "Content-Type: application/json" \
    -d "{ \"address\": \"$ARCHWAY_ADDR\", \"coins\": [ \"1000000000utorii\" ]}"
}

#function startup {
#    echo -e '\e[40m\e[92m' && read -p "Enter commission rate (between 0.01 and 1, 0.1 by default): " COMMISSION-RATE && echo -e '\e[0m'
#    echo -e '\e[40m\e[92m' && read -p "Enter commission max rate: (between 0.01 and 1, 0.1 by default)" COMMISSION-MAX-RATE && echo -e '\e[0m'
#    echo -e '\e[40m\e[92m' && read -p "Enter commission max change rate: (between 0.01 and 1, 0.01 by default)" COMMISSION-MAX-CHANGE-RATE && echo -e '\e[0m'
#    archwayd tx staking create-validator \
#      --from $ARCHWAY_ADDR \
#      --amount 1000000utorii \
#      --min-self-delegation 1000000 \
#      --commission-rate $COMMISSION-RATE \
#      --commission-max-rate $COMMISSION-MAX-RATE \
#      --commission-max-change-rate $COMMISSION-MAX-CHANGE-RATE \
#      --pubkey $(archwayd tendermint show-validator) \
#}

function cleanup {
      echo -e '\e[40m\e[91mAll previous data will be deleted. Triple check that you have saved all the necessary data.\e[0m' 
      read -p "Do you want to continue? Y/N: " -n 1 -r 
      if [[ $REPLY =~ ^[Yy]$ ]] 
        then
            sudo rm -rf $HOME/.archway/
            sudo rm -rf $HOME/archway/
            sudo rm -rf $HOME/testnets/
            sed -i '/ARCHWAY_CHAIN/d' $HOME/.bash_profile
            sed -i '/ARCHWAY_MONIKER/d' $HOME/.bash_profile
            sed -i '/ARCHWAY_WALLET/d' $HOME/.bash_profile
            sed -i '/ARCHWAY_ADDR/d' $HOME/.bash_profile
            sed -i '/ARCHWAY_VALOPER/d' $HOME/.bash_profile
            echo -e '\n\e[40m\e[92mAll previous data has been deleted.\e[0m'      
      elif [[ $REPLY =~ ^[Nn]$ ]] 
        then
            echo 
      else
            echo -e "\e[91mInvalid option $REPLY\e[0m"
      fi
}

echo -e '\e[40m\e[92mPlease enter your choice (input your option number and press Enter): \e[0m'
options=("Create wallet" "Request utorii" "Clean up!" "Quit")
select option in "${options[@]}"
do
    case $option in
        "Create wallet")
            generate_gentx
            break
            ;;
         "Request utorii")
            faucet
            break
            ;;
         "Clean up!")
            cleanup
            break
            ;;
        "Quit")
            break
            ;;
        *) echo -e '\e[91mInvalid option $REPLY\e[0m';;
    esac
done
