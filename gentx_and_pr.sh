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

    archwayd config chain-id $ARCHWAY_CHAIN
    archwayd config node https://rpc.torii-1.archway.tech:443
    archwayd init ${ARCHWAY_MONIKER} --chain-id $ARCHWAY_CHAIN

    wget -O $HOME/.archway/config/genesis.json "https://raw.githubusercontent.com/archway-network/testnets/main/torii-1/penultimate_genesis.json"

    echo -e '\n\e[40m\e[92m3. Generating keypair...\e[0m' 
    echo -e '\e[40m\e[92mEnter \e[40m\e[91mand remember\e[40m\e[92m at least 8 any characters (e.g. 1a3b5c7e), when asked...\e[0m'
    archwayd keys add $ARCHWAY_WALLET
    echo -e '\e[40m\e[92m\nYour \e[40m\e[91mpriv_validator_key.json\e[40m\e[92m:\n\e[0m'
    cat $HOME/.archway/config/priv_validator_key.json
    echo -e '\n\n\e[42m^^^ SAVE DATA ABOVE ^^^\e[0m' 
    echo -e '\n\e[40m\e[92mSave the information \e[40m\e[91mbetween\e[40m\e[92m \e[0m"Re-enter keyring passphrase:"\e[40m\e[92m \e[40m\e[91mand\e[40m\e[92m \e[42m\e[37m^^^ SAVE ALL DATA ABOVE ^^^\e[0m\e[40m\e[92m.\e[0m' && sleep 3
     
    echo -e '\n\e[40m\e[92m4. Setting address as a variable...\e[0m' 
    echo -e '\e[40m\e[92mEnter the characters that you entered in the last step, when asked...\e[0m'
    ARCHWAY_ADDR=$(archwayd keys show $ARCHWAY_WALLET -a)
    echo 'export ARCHWAY_ADDR='${ARCHWAY_ADDR} >> $HOME/.bash_profile
    source $HOME/.bash_profile

    echo -e '\n\e[40m\e[92m5. Setting valoper as a variable...\e[0m' 
    echo -e '\e[40m\e[92mEnter the characters that you entered in the last step, when asked...\e[0m'
    ARCHWAY_VALOPER=$(archwayd keys show $ARCHWAY_WALLET --bech val -a)
    echo 'export ARCHWAY_VALOPER='${ARCHWAY_VALOPER} >> $HOME/.bash_profile
    source $HOME/.bash_profile

    archwayd add-genesis-account $ARCHWAY_ADDR 1000000000utorii

    echo -e '\n\e[40m\e[91m6. Generating gentx...\e[0m' 
    echo -e '\e[40m\e[92mEnter the characters that you entered in the last step, when asked...\e[0m'
    archwayd gentx $ARCHWAY_WALLET 1000000000utorii --commission-rate 0.1 --commission-max-rate 0.1 --commission-max-change-rate 0.1 --pubkey $(archwayd tendermint show-validator) --chain-id $ARCHWAY_CHAIN --moniker="${ARCHWAY_MONIKER}"

    echo -e '\n\n\n\e[40m\e[92mGentx generated.\e[0m\n\n'
    echo -e '\e[40m\e[92mName of your gentx:\e[0m'
    cd /root/.archway/config/gentx/ && ls && grep -o -a -m 1 -r "gentx-"
    echo -e '\n\e[40m\e[92mYour gentx:\e[0m'
    cat /root/.archway/config/gentx/$(cd /root/.archway/config/gentx/ && ls && grep -o -a -m 1 -r "gentx-")
    echo -e '\n\n\e[40m\e[92mMake sure that you save save all data between \e[0m"Re-enter keyring passphrase:"\e[40m\e[92m and \e[42m\e[37m^^^ SAVE ALL DATA ABOVE ^^^\e[40m\e[92m.\e[0m'
    echo -e '\e[40m\e[92mTo be completely at ease, you can save the file \e[40m\e[91m$HOME/.archway/config/priv_validator_key.json\e[40m\e[92m.\e[0m'
    echo -e '\n\e[40m\e[92mTo open a PR automatically execute \e[40m\e[91m/bin/bash $HOME/gentx_and_pr.sh\e[40m\e[92m, select option \e[40m\e[91m2\e[40m\e[92m and press \e[40m\e[91mEnter\e[40m\e[92m OR check article for manual submission guide.\e[0m'
}

function open_PR {
   if cat $HOME/testnets/torii-1/gentx/$(cd /root/.archway/config/gentx/ && ls && grep -o -a -m 1 -r "gentx-") > /dev/null 2>&1
    then
       cd $HOME/testnets && git add torii-1/gentx/$(cd /root/.archway/config/gentx/ && ls && grep -o -a -m 1 -r "gentx-")
       git commit -m "$ARCHWAY_MONIKER gentx submission"
       echo -e '\e[40m\e[92mGo to \e[40m\e[91mhttps://github.com/settings/tokens\e[40m\e[92m and generate access token with \e[40m\e[91mfull repo access\e[40m\e[92m (tick the checkboxes). \nSave generated token, it will look like \e[40m\e[91mghp_xxxxxxxxxxxPbIpI8YJ1dieTOoxxxxxxxxxx\e[40m\e[92m.\e[0m'
       echo -e '\n\e[40m\e[92mPushing changes to your repo...\e[0m'
       echo -e '\e[40m\e[92mYou will be asked for you \e[40m\e[91mgithub nickname\e[40m\e[92m and \e[2mpassword\e[0m\e[40m\e[92m. \e[5m\e[40m\e[91mEnter ACCESS TOKEN instead of password\e[0m\e[40m\e[92m.\e[0m' 
       git push origin main -f
       echo -e '\n\e[40m\e[92mIf you see something like \e[40m\e[91maqtak3s..vb2u3g9  main -> main\e[40m\e[92m a line above, go to https://github.com/\e[40m\e[91mYOUR_NICKNAME\e[40m\e[92m/testnets.\e[0m'
       echo -e '\e[40m\e[92mClick \e[40m\e[91mContribute\e[40m\e[92m -> \e[40m\e[91mOpen pull request\e[40m\e[92m, give a name to your request, then click \e[40m\e[91mCreate pull request\e[40m\e[92m and you are all set.\e[0m'
   else
       echo -e '\e[40m\e[92mFork \e[40m\e[91mhttps://github.com/archway-network/testnets\e[40m\e[92m and copy link to \e[5m\e[40m\e[91mforked repo\e[0m\e[40m\e[92m. It will look like https://github.com/\e[5m\e[40m\e[91mYOUR_NICKNAME\e[0m\e[40m\e[92m/testnets.\e[0m'
       echo -e '\e[40m\e[92m' && read -p "Enter link to FORKED repo: " REPO_LINK && echo -e '\e[0m'
       cd $HOME && git clone $REPO_LINK
       cp /root/.archway/config/gentx/$(cd /root/.archway/config/gentx/ && ls && grep -o -a -m 1 -r "gentx-") $HOME/testnets/torii-1/gentx
       cd $HOME/testnets && git add torii-1/gentx/$(cd /root/.archway/config/gentx/ && ls && grep -o -a -m 1 -r "gentx-")
       git commit -m "$ARCHWAY_MONIKER gentx submission"
       echo -e '\e[40m\e[92mGo to \e[40m\e[91mhttps://github.com/settings/tokens\e[40m\e[92m and generate access token with \e[40m\e[91mfull repo access\e[40m\e[92m (tick the checkboxes). \nSave generated token, it will look like \e[40m\e[91mghp_xxxxxxxxxxxPbIpI8YJ1dieTOoxxxxxxxxxx\e[40m\e[92m.\e[0m'
       echo -e '\n\e[40m\e[92mPushing changes to your repo...\e[0m'
       echo -e '\e[40m\e[92mYou will be asked for you \e[40m\e[91mgithub nickname\e[40m\e[92m and \e[2mpassword\e[0m\e[40m\e[92m. \e[5m\e[40m\e[91mEnter ACCESS TOKEN instead of password\e[0m\e[40m\e[92m.\e[0m' 
       git push origin main -f
       echo -e '\n\e[40m\e[92mIf you see something like \e[40m\e[91maqtak3s..vb2u3g9  main -> main\e[40m\e[92m a line above, go to https://github.com/\e[40m\e[91mYOUR_NICKNAME\e[40m\e[92m/testnets.\e[0m'
       echo -e '\e[40m\e[92mClick \e[40m\e[91mContribute\e[40m\e[92m -> \e[40m\e[91mOpen pull request\e[40m\e[92m, give a name to your request, then click \e[40m\e[91mCreate pull request\e[40m\e[92m and you are all set.\e[0m'
   fi
}

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
options=("Generate gentx" "Open PR" "Clean up!" "Quit")
select option in "${options[@]}"
do
    case $option in
        "Generate gentx")
            generate_gentx
            break
            ;;
         "Open PR")
            open_PR
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
