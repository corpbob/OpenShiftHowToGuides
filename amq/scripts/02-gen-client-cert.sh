CLIENT_KEYSTORE_PASSWORD=password
$JAVA_HOME/bin/keytool \
-export \
-alias amq-client \
-keystore amq-client.ks \
   -storepass $CLIENT_KEYSTORE_PASSWORD \
-file amq-client.cert
