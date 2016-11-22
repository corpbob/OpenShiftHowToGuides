CLIENT_KEYSTORE_PASSWORD=password
$JAVA_HOME/bin/keytool \
-genkey \
-keyalg RSA \
-alias amq-client \
-keystore amq-client.ks \
-storepass $CLIENT_KEYSTORE_PASSWORD \
   -keypass $CLIENT_KEYSTORE_PASSWORD
