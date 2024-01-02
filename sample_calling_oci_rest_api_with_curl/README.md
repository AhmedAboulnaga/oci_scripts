Prior to invoking 'createdb.sh', there is a section where a number of values need to be updated.

1. Get the Tenancy OCID from the OCI console (this will be added to 'createdb.sh').

2. Get the User OCID from the OCI console (this will be added to 'createdb.sh').

3. Create a public/private key pair on your Linux server (the public key will eventually be added as an 'API Key' to the OCI account in step #6; the private key will be used by the script):
```
ssh-keygen -t rsa -f oci -C oracle
```
4. Use openssl to view the X.509 MD5 PEM certificate fingerprint (this will be added to 'createdb.sh'):

openssl rsa -pubout -outform DER -in oci | openssl md5 -c

5. Use openssl to get the public key from the private key in PEM format (OCI requires that the public key is imported in PEM format):

openssl rsa -in oci -pubout

6. Add the public key from step #5 to the OCI user's API key on the OCI console.

7. Update the customizable values in 'createdb.sh':

tenancy_ocid="XXXXXXXXXX"
user_ocid="XXXXXXXXXX"
fingerprint="XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX"

8. Run the script:

./createdb.sh
