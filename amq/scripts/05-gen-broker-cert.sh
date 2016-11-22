BROKER_KEYSTORE_PASSWORD=password
$JAVA_HOME/bin/keytool \
-export \
-alias amq-broker \
-keystore amq-broker.ks \
   -storepass $BROKER_KEYSTORE_PASSWORD \
-file amq-broker.cert

$JAVA_HOME/bin/keytool \
-import \
-alias amq-client \
-keystore amq-client.ts \
-file amq-broker.cert \
-storepass $BROKER_TRUSTSTORE_PASSWORD \
   -trustcacerts \
   -noprompt
