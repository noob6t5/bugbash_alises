# ====== BUG HUNTING WORKFLOW ======

# 1. ----- Subdomain Enumeration -----
subenum(){ # Enumerates subdomains using Assetfinder and Subfinder, taking domain as argument
  assetfinder --subs-only $1 | tee -a $1-assetfinder.txt
  subfinder -d $1 -silent | tee -a $1-subfinder.txt
  findomain -t "$1" -q -u "$1-findomain.txt"
  cat "$1-assetfinder.txt" "$1-subfinder.txt" "$1-findomain.txt" | sort -u | tee -a "$1-subdomains.txt"
}

# 2. ----- URL Probing -----
urlprobe(){ 
  cat $1 | httprobe -c 50 | tee -a $1-alive.txt
}

# 3. ----- DNS and Network Information -----
dnsrecon(){ # Discovers DNS records using dnsrecon, taking domain as argument
  dnsrecon -d $1 -t std -a | tee -a $1-dnsrecon.txt
}

asnlookup(){ 
  whois -h whois.cymru.com " -v $1" | tee -a $1-asninfo.txt
}

# 4. ----- Vulnerability Scanning -----
nuclei_scan(){
  cat $1 | nuclei -t ~/nuclei-templates/ -o $1-nuclei-results.txt
}

subjack(){ 
  subjack -w $1 -t 20 -o $1-takeover.txt -ssl
}

# 5. ----- Endpoint Discovery -----
waymore(){ # 
  waymore -d $1 -e txt -o $1-waymore.txt
}

paramspider(){ 
  python3 ~/tools/ParamSpider/paramspider.py -d $1 -o $1-params.txt
}

gf_patterns(){ # Add more 
  cat $1 | gf xss | tee -a $1-xss.txt
  cat $1 | gf sqli | tee -a $1-sqli.txt
  cat $1 | gf lfi | tee -a $1-lfi.txt
}

# 6. ----- Directory Bruteforcing -----
ffufdir(){ 
  ffuf -u https://$1/FUZZ -w ~/wordlists/directory-list-2.3-medium.txt -o $1-ffuf-dir.txt
}

dirb(){
  dirb https://$1 /usr/share/dirb/wordlists/common.txt -o $1-dirb.txt
}

# 7. ----- Port Scanning -----


# ====== COMPLETE RECON WORKFLOW ======
recon_all(){ #taking domain as argument
  subenum $1                                              
  urlprobe $1-subdomains.txt        
  dnsrecon $1                       
  asnlookup $1                      
  nuclei_scan $1-alive.txt           
  subjack $1-subdomains.txt         
  waymore $1                        
  paramspider $1                     
  gf_patterns $1-waymore.txt         
  ffufdir $1                       
 
}
