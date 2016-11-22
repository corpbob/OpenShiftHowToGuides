BROKER_KEYSTORE_PASSWORD=password
$JAVA_HOME/bin/keytool \
-genkey \
-keyalg RSA \
-alias amq-broker \
-keystore amq-broker.ks \
-storepass $BROKER_KEYSTORE_PASSWORD \
   -keypass $BROKER_KEYSTORE_PASSWORD
