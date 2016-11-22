BROKER_TRUSTSTORE_PASSWORD=password
$JAVA_HOME/bin/keytool \
-import \
-alias amq-broker \
-keystore amq-broker.ts \
-file amq-client.cert \
-storepass $BROKER_TRUSTSTORE_PASSWORD \
   -trustcacerts \
   -noprompt
