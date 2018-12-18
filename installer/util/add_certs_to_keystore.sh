for f in *.cer; do
  keytool -importcert -v -trustcacerts -alias `basename $f` -file $f -keystore cacerts -storepass changeit -noprompt -storetype JKS
done
