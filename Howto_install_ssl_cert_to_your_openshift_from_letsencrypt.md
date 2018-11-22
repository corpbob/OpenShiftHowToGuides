# How to install SSL certificates from Letsencrypt

## Assumptions
- You are using Openshift on Centos 7
- You have shell access and able to install software.
- You have access to your DNS to add a TXT record

## WildCard certificate

- Install certbot using the instructions here: https://certbot.eff.org/lets-encrypt/centosrhel7-other
- Let's assume your wildcard domain is openshift.$YOUR_DOMAIN, where for example your domain is "example.com".
- Define the shell variable: YOUR_WILDCARD_DOMAIN=openshift.$YOUR_DOMAIN
- Execute the command below where you should have defined YOUR_WILDCARD_DOMAIN beforehand.
```
sudo certbot --server https://acme-v02.api.letsencrypt.org/directory -d *.$YOUR_WILDCARD_DOMAIN --manual --preferred-challenges dns-01 certonly
```
- You will be asked to insert a txt record into your DNS. After inserting, verify that you are able to resolve the TXT record. For example if the TXT record is __acme-challenge.openshift:

```
dig -t _acme-challenge.$YOUR_WILDCARD_DOMAIN
```
It should give you something like the below:

```
;; ANSWER SECTION:
_acme-challenge.$YOUR_WILDCARD_DOMAIN.	599 IN TXT "--1YDlFE4K73i9cjHN5de6e-D8yhmOqaj6yIRcpZ_BU"
```

- After verifying that the TXT record is resolvable, you can now continue the installation of the certificates. At the end of the process, you will be given the location of the certificates. At the time of this writing, it should be found in the directory 
```
/etc/letsencrypt/live/$YOUR_WILDCARD_DOMAIN
```
You can find the following files in that directory:
```
ls /etc/letsencrypt/live/$YOUR_WILDCARD_DOMAIN
cert.pem  chain.pem  fullchain.pem  privkey.pem  README
```
- Concatenate the fullchain.pem, /etc/origin/master/ca.crt and privkey.pem to derive the router certificate:
```
cat fullchain.pem /etc/origin/master/ca.crt privkey.pem > router.pem
```

## Update the OpenShift router certificates
- Backup the old router certs
```
oc project default
oc export secret router-certs > ~/old-router-certs-secret.yaml
```
- Do a dry run
```
oc create secret tls router-certs --cert=router.pem --key=privkey.pem -o json --dry-run
```
- Replace the certs.
```
oc create secret tls router-certs --cert=router.pem --key=privkey.pem -o json --dry-run| oc replace -f -
```
- Annotate the service
```
oc annotate service router     service.alpha.openshift.io/serving-cert-secret-name-     service.alpha.openshift.io/serving-cert-signed-by-
oc annotate service router     service.alpha.openshift.io/serving-cert-secret-name=router-certs
```
- Redeploy the router
```
oc rollout latest dc/router
```
