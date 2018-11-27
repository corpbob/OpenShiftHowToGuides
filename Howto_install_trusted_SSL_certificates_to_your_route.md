# Howto Install SSL Certificates to your Openshift route
## Assumptions
- You have OpenShift 3.9 or above
- You are using Openshift on Centos 7
- You have shell access and able to install software.
- You have access to your DNS to add a TXT record
## Obtain SSL certificat from LetsEncrypt
- Install certbot using the instructions here: https://certbot.eff.org/lets-encrypt/centosrhel7-other 
- Define the shell variable ROUTE_URL whose value is the url of your route. 
- Execute the command below where you should have defined YOUR_WILDCARD_DOMAIN beforehand.
```
sudo certbot --server https://acme-v02.api.letsencrypt.org/directory -d $ROUTE_URL --manual --preferred-challenges dns-01 certonly
```
- You will be asked to insert a txt record into your DNS. After inserting, verify that you are able to resolve the TXT record. 

```
dig -t txt _acme-challenge.$ROUTE_URL
```
It should give you something like the below:

```
;; ANSWER SECTION:
_acme-challenge.$ROUTE_URL.	599 IN TXT "--1YDlFE4K73i9cjHN5de6e-D8yhmOqaj6yIRcpZ_BU"
```

- After verifying that the TXT record is resolvable, you can now continue the installation of the certificates. At the end of the process, you will be given the location of the certificates. At the time of this writing, it should be found in the directory 
```
/etc/letsencrypt/live/$ROUTE_URL
```
You can find the following files in that directory:
```
ls /etc/letsencrypt/live/$ROUTE_URL
cert.pem  chain.pem  fullchain.pem  privkey.pem  README
```
## Install your certificates to the route
- Using the GUI, navigate to your route and click edit or create a new route.
- Enter the route url which you got a certificate for
- Click "Secure Route"
- TLS Termination = Edge
- Insecure Traffic = None
- Paste the contents of fullchain.pem to "Certificate" text area.
- Paste the contents of privkey.pem to "Private Key" text area.
- Click Save
## Test your route to see the the certificate is already trusted.

