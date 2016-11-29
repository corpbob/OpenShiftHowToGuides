# How to Setup A-MQ xPaas

1. Clone or fork the repository https://github.com/corpbob/OpenShiftHowToGuides.git

git clone https://github.com/corpbob/OpenShiftHowToGuides.git

2. Clone or fork the repository https://github.com/corpbob/application-templates.git

git clone https://github.com/corpbob/application-templates.git

3. Cd to directory OpenShiftHowToGuides/amq/scripts. Inside this directory you can find scripts:

$ ls amq/scripts/
01-gen-client-ks.sh    03-gen-broker-ks.sh  05-gen-broker-cert.sh       07-gen-base64-broker-ks.sh
02-gen-client-cert.sh  04-gen-broker-ts.sh  06-gen-base64-broker-ts.sh  create-amq-project.sh
 
Run these scripts starting from 01-gen-client-ks.sh up to 05-gen-broker-cert.sh.

4. Copy the files application-templates/amq/amq62-persistent-ssl.json and application-templates/secrets/amq-app-secret.json into the current directory.

5. Run the script 06-gen-base64-broker-ts.sh. It should give something like this:

/u3+7QAAAAIAAAABAAAAAgAKYW1xLWJyb2tlcgAAAViKkXC6AAVYLjUwOQAAA3UwggNxMIICWaADAgECAgRjbl2XMA0GCSqGSIb3DQEBCwUAMGkxCzAJBgNVBAYTAlNHMRIwEAYDVQQIEwlTaW5nYXBvcmUxEjAQBgNVBAcTCVNpbmdhcG9yZTEQMA4GA1UEChMHUmVkIEhhdDEPMA0GA1UECxMGQnJva2VyMQ8wDQYDVQQDEwZCcm9rZXIwHhcNMTYxMTIyMDU0NDU3WhcNMTcwMjIwMDU0NDU3WjBpMQswCQYDVQQGEwJTRzESMBAGA1UECBMJU2luZ2Fwb3JlMRIwEAYDVQQHEwlTaW5nYXBvcmUxEDAOBgNVBAoTB1JlZCBIYXQxDzANBgNVBAsTBkJyb2tlcjEPMA0GA1UEAxMGQnJva2VyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmZ9BMv17yggfcnN1fTZJaheRwCdoDM9xClU5Aq5t/Vyon2OEeV2ZxSRJw1Pwl3peLMPRBqj0wJR4fLYBw1Y4/UdjDW0RhOf+/lVI/FRnnEJyDZlpXhmhwh0FmaLt+QyTnqBFQ7Rv5swAbLOZgLOh0sYeD/t0TgU86A/yN9CkRcQ02EBdse5bAkJjyV3CvzN/tPwiVqtqxR6N2ev3Vk6apOcDJvUqaiIGaftEj9SY7xlQhQ+msRm+7E/Vr/DrjX15rO2OahHX3MqDBKI0nInCbzFhpz4gS8FXrWKNLmDlO0XeKTWmKp4NHOt19nJUIrsynxurs3gAYwiTKUUWp3CPMwIDAQABoyEwHzAdBgNVHQ4EFgQU9Rm/Ua2M3RG3gdPLnn0OnHcE7GwwDQYJKoZIhvcNAQELBQADggEBAFffWn+GSywVBf/PpvNf8YPiq031V9/7QWIO2yqaS5EwV9QkAorp5Og6bZ9T43iMrBBiP7YnFheQxS/ubKW+Gs8jqb84iXUuVmqov4tzkN4bBWWkjEaCGDoCtK6a125gi1PyEIMF/GiOK9vsK4gnwS8rw3RSKkVIhjaB1GN4T6fckV7HTrkhWKATyeen1VVqF+Lds91Ym0arGl+THAZIsO0HNZYvCBz9UyPDmjP9apmn8EBkQtLxu8dSn3PqkObT4XJFPeCxQ3Tlf4bkMe45dW/jCsSpdzmDxB1GI+fAYVsa9+FPyFan8lXsvGlNdc9/Jf/RlRYR9Mib5JGzDo3YQRshGrPXM0J4xhueRyusPB4pwFOOzA==

Copy the output to clipboard. Open the file amq-app-secret.json and look for the line containing broker.ts and replace the value with the value of the clipboard.

6. Run the script 07-gen-base64-broker-ks.sh. The output should replace the value of the line containing broker.ks.

7. Save the file.

8. Run the script create-amq-project.sh.

It will execute the following commands:

oc new-project amq-demo
oc policy add-role-to-user view system:serviceaccount:amq-demo:amq-service-account
oc create -n amq-demo -f amq-app-secret.json
oc create -n amq-demo -f amq62-persistent-ssl.json

9. Launch your browser at https://10.1.2.2:8443/console/ and click on the amq-demo project. Click on Add To Project and look for the template amq62-persistent-ssl and click on it. Set the values of the following parameters:

MQ_USERNAME = amq-demo-user
MQ_PASSWORD = password
AMQ_TRUSTSTORE_PASSWORD = password
AMQ_KEYSTORE_PASSWORD = password

Click "Create". 

10. It will then create the application. Click on Continue to Overview. Click on a pod and view the logs. 

Once you are able to see something like this:

 INFO | For help or more information please see: http://activemq.apache.org
 WARN | Store limit is 102400 mb (current store usage is 0 mb). The data directory: /opt/amq/data/kahadb only has 2998 mb of usable space - resetting to maximum available disk space: 2998 mb
 WARN | Temporary Store limit is 51200 mb, whilst the temporary data directory: /opt/amq/data/broker-amq-1-h5t07/tmp_storage only has 2998 mb of usable space - resetting to maximum available 2998 mb.

you can now start to test the A-MQ.

10. Copy the files OpenShiftHowToGuides/amq/scripts/amq-client.* to OpenShiftHowToGuides/amq/java/swissarmy.
11. Cd to OpenShiftHowToGuides/amq/java/swissarmy. You should see a file run-producer.sh. Run this file to test the A-MQ.

./run-producer.sh

You should see something like:

Buildfile: /home/vagrant/amq-copied-from-container/amq/examples/openwire/swissarmy/build.xml

init:

compile:

producer:
       [echo] Running producer against server at $url = ssl://172.17.0.16:61617 for subject $subject = TEST.FOO
       [java] Connecting to URL: ssl://172.17.0.16:61617 (amq-demo-user:password)
       [java] Publishing a Message with size 1000 to topic: TEST.FOO
     [java] Using non-persistent messages
     [java] Sleeping between publish 0 ms
     [java] Running 1 parallel threads
     [java] log4j:WARN No appenders could be found for logger (org.apache.activemq.transport.WireFormatNegotiator).
     [java] log4j:WARN Please initialize the log4j system properly.
     [java] log4j:WARN See http://logging.apache.org/log4j/1.2/faq.html#noconfig for more info.
     [java] [Thread-1] Sending message: 'Message: 0 sent at: Tue Nov 22 01:54:54 EST 2016  ...'
     [java] [Thread-1] Done.
     [java] [Thread-1] Results:
     [java] 
     [java] connection {
     [java]   session {
     [java]     messageCount{ count: 0 unit: count startTime: 1479797694312 lastSampleTime: 1479797694312 description: Number of messages exchanged }
     [java]     messageRateTime{ count: 0 maxTime: 0 minTime: 0 totalTime: 0 averageTime: 0.0 averageTimeExMinMax: 0.0 averagePerSecond: 0.0 averagePerSecondExMinMax: 0.0 unit: millis startTime: 1479797694313 lastSampleTime: 1479797694313 description: Time taken to process a message (thoughtput rate) }
     [java]     pendingMessageCount{ count: 0 unit: count startTime: 1479797694312 lastSampleTime: 1479797694312 description: Number of pending messages }
     [java]     expiredMessageCount{ count: 0 unit: count startTime: 1479797694312 lastSampleTime: 1479797694312 description: Number of expired messages }
     [java]     messageWaitTime{ count: 0 maxTime: 0 minTime: 0 totalTime: 0 averageTime: 0.0 averageTimeExMinMax: 0.0 averagePerSecond: 0.0 averagePerSecondExMinMax: 0.0 unit: millis startTime: 1479797694313 lastSampleTime: 1479797694313 description: Time spent by a message before being delivered }
     [java]     durableSubscriptionCount{ count: 0 unit: count startTime: 1479797694313 lastSampleTime: 1479797694313 description: The number of durable subscriptions }
     [java] 
     [java]     producers {
     [java]       producer topic://TEST.FOO {
     [java]         messageCount{ count: 0 unit: count startTime: 1479797694319 lastSampleTime: 1479797694319 description: Number of messages processed }
     [java]         messageRateTime{ count: 0 maxTime: 0 minTime: 0 totalTime: 0 averageTime: 0.0 averageTimeExMinMax: 0.0 averagePerSecond: 0.0 averagePerSecondExMinMax: 0.0 unit: millis startTime: 1479797694319 lastSampleTime: 1479797694319 description: Time taken to process a message (thoughtput rate) }
     [java]         pendingMessageCount{ count: 0 unit: count startTime: 1479797694319 lastSampleTime: 1479797694319 description: Number of pending messages }
     [java]         messageRateTime{ count: 0 maxTime: 0 minTime: 0 totalTime: 0 averageTime: 0.0 averageTimeExMinMax: 0.0 averagePerSecond: 0.0 averagePerSecondExMinMax: 0.0 unit: millis startTime: 1479797694319 lastSampleTime: 1479797694319 description: Time taken to process a message (thoughtput rate) }
     [java]         expiredMessageCount{ count: 0 unit: count startTime: 1479797694319 lastSampleTime: 1479797694319 description: Number of expired messages }
     [java]         messageWaitTime{ count: 0 maxTime: 0 minTime: 0 totalTime: 0 averageTime: 0.0 averageTimeExMinMax: 0.0 averagePerSecond: 0.0 averagePerSecondExMinMax: 0.0 unit: millis startTime: 1479797694319 lastSampleTime: 1479797694319 description: Time spent by a message before being delivered }
     [java]       }
     [java]     }
     [java]     consumers {
     [java]     }
     [java]   }
     [java] }
     [java] All threads completed their work

BUILD SUCCESSFUL
Total time: 1 second

Your test should be successful.
