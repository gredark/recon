#!/bin/bash

path="$HOME/tools"
gopath="$HOME/go/bin"

echo "Starting install."

#Update
apt Update

#Install Go
if [[ -z "$GOPATH" ]]; then	
	apt install -y golang
	echo 'export GOROOT=/usr/lib/go' >> ~/.zshrc
	echo 'export GOPATH=$HOME/go' >> ~/.zshrc
	echo 'export PATH=$GOPATH/bin:$GOROOT/bin:$PATH' >> ~/.zshrc 
	source ~/.zshrc
fi

#Install amass
apt install -y amass

#Install subfinder
if [ ! -e $HOME/go/bin/subfinder ]; then
	go get github.com/subfinder/subfinder
fi

#Install httprobe
if [ ! -e $HOME/go/bin/httprobe ]; then
	go get github.com/tomnomnom/httprobe
fi


#Install eyewitness
apt install -y eyewitness

if [ ! -e $HOME/go/bin/subfinder ]; then
	go get github.com/subfinder/subfinder
fi

#Install waybackurls
if [ ! -e $HOME/go/bin/waybackurls ]; then
	go get github.com/tomnomnom/waybackurls
fi

#Install gau
if [ ! -e $HOME/go/bin/gau ]; then
	go get github.com/lc/gau
fi

#Intsal antiburl
if [ ! -e $HOME/go/bin/antiburl ]; then
	git clone https://github.com/tomnomnom/hacks.git $path/hacks
	go build -o $path/hacks/anti-burl/antiburl $path/hacks/anti-burl/main.go
	cp $path/hacks/anti-burl/antiburl $gopath
fi

#Install paramspider
git clone https://github.com/devanshbatham/ParamSpider.git $path/ParamSpider


#Install GF
go get -u github.com/tomnomnom/gf
echo 'source /root/go/src/github.com/tomnomnom/gf/gf-completion.bash' >> ~/.zshrc
source ~/.zshrc

#Install GF-Patterns
git clone https://github.com/1ndianl33t/Gf-Patterns.git $path/Gf-Patterns
cp $path/Gf-Patterns/*.json /root/.gf

#Instal nuclei
GO111MODULE=on go get -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei
nuclei -update-templates

echo "Install was finished."
