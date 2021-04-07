#!/bin/bash

## Variables
target=$1
time=$(date '+%F-%H:%M')
resultsPath="$HOME/Desktop/Recon/$target/$time"
subPath="$resultsPath/subdomain"
scrPath="$resultsPath/scrennshot"
waybackPath="$resultsPath/wayback"
jsPath="$resultsPath/javascript"
paramPath="$resultsPath/param"

setupDir(){
	echo 'setup dir'
	mkdir -p $subPath $scrPath $waybackPath $jsPath $paramPath
}

scanSub(){
	echo 'run amass'
	amass enum --passive -d $target -o $subPath/amass.txt

	echo 'run subfinder'
	subfinder -d $target -o $subPath/subfinder.txt

	cat $subPath/*.txt | sort | uniq > $subPath/final_subdomains.txt

	cat $subPath/final_subdomains.txt | httprobe --prefer-https > $subPath/live_subdomains.txt
}

screenshot(){
	echo 'screenshot'
	eyewitness --no-prompt -f $subPath/live_subdomains.txt -d $scrPath
}


wayback(){
	echo 'gau'
	cat $subPath/live_subdomains.txt | gau -subs > $waybackPath/gau.txt
#	gau -subs -o $waybackPath/gau.txt $target

	echo 'wayback'
	cat $subPath/live_subdomains.txt | waybackurls > $waybackPath/waybackurls.txt

	cat $waybackPath/*.txt | sort | uniq > $waybackPath/pass_urls.txt
}

jsrecon(){
	echo 'getjs'
	cat $waybackPath/pass_urls.txt | grep -iE '\.js'|grep -ivE '\.json' | sort -u > $jsPath/js.txt

	echo 'live js'
	cat $jsPath/js.txt | antiburl > $jsPath/anti_js.txt
	cat $jsPath/anti_js.txt | grep -Eo "(http|https)://[a-zA-Z0-9./?=_%:-]*" > $jsPath/live_js.txt

	echo 'extract js'
	cat $jsPath/live_js.txt | xargs -n2 -I @ bash -c 'echo -e "\n[URL] @\n";python3 $HOME/Desktop/tools/LinkFinder/linkfinder.py -i @ -o cli' >> $jsPath/info_js.txt
}

param(){
	echo "paramspider"
	python3 /root/Desktop/tools/ParamSpider/paramspider.py -d $target -e woff,css,png,svg,jpg -o $paramPath/all_param.txt
	
	if [ -s $paramPath/all_param.txt ]; then
		echo "gf results"
		gf debug_logic $paramPath/all_param.txt >> $paramPath/debug.txt
		gf idor $paramPath/all_param.txt >> $paramPath/idor.txt
		gf interestingEXT $paramPath/all_param.txt >> $paramPath/interestingEXT.txt
		gf interestingparams $paramPath/all_param.txt >> $paramPath/interestingparam.txt
		gf lfi $paramPath/all_param.txt >> $paramPath/lfi.txt
		gf rce $paramPath/all_param.txt >> $paramPath/rce.txt
		gf redirect $paramPath/all_param.txt >> $paramPath/redirect.txt
		gf sqli $paramPath/all_param.txt >> $paramPath/sqli.txt
		gf ssrf $paramPath/all_param.txt >> $paramPath/ssrf.txt
		gf ssti $paramPath/all_param.txt >> $paramPath/ssti.txt
		gf xss $paramPath/all_param.txt >> $paramPath/xss.txt
	fi
}

nuclei_scan(){
	echo "nuclei"
	nuclei -l $subPath/live_subdomains.txt -t $HOME/nuclei-templates -o $resultsPath/nuclei.txt 
}

setupDir
scanSub
screenshot
wayback
jsrecon
param
nuclei_scan
