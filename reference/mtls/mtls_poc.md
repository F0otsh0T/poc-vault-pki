##mTLS
@ https://codeburst.io/mutual-tls-authentication-mtls-de-mystified-11fa2a52e9cf

####Step One: CREATE CA (Certificate Authority)
```
openssl req \
  -new \
  -x509 \
  -nodes \
  -days 365 \
  -subj '/CN=my-ca' \
  -keyout ca.key \
  -out ca.crt
```
This outputs two files, ca.key and ca.crt, in the PEM format (base64 encoding of the private key and X.509 certificate respectively).

Looking at the openssl req documentation, we see that the -new and -x509 options enable the creation of a self-signed root CA X.509 certificate. The nodes (No DES) option disables securing the private key with a pass-code; this option is optional. The subj option provides the CA’s identity; in this case the Common Name (CN) of my-ca. The remaining options are self-explanatory.

We can turn-around and inspect the certificate using the following command:
```
openssl x509 \
  --in ca.crt \
  -text \
  --noout
```
```
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            [OBMITTED]
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN = my-ca
        Validity
            Not Before: Jun 13 00:49:48 2020 GMT
            Not After : Jun 13 00:49:48 2021 GMT
        Subject: CN = my-ca
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                RSA Public-Key: (2048 bit)
                Modulus:
                    [OBMITTED]
                Exponent: [OBMITTED]
        X509v3 extensions:
            X509v3 Subject Key Identifier: 
                [OBMITTED]
            X509v3 Authority Key Identifier: 
                keyid:[OBMITTED]            X509v3 Basic Constraints: critical
                CA:TRUE
    Signature Algorithm: sha256WithRSAEncryption
         [OBMITTED]
```
- Both the Subject and Issuer have the value CN = my-ca; this indicates that this certificate is self-signed
- The Validity indicates that the certificate is valid for a year
- The X509v3 Basic Constraints value CA:TRUE indicate that this certificate can be used as a CA, i.e., can be used to sign certificates

####Step Two: CREATE SERVER KEY
```
openssl genrsa \
  -out server.key 2048
```

####Step Three: CREATE CSR (Certificate Signing Request)
We now create a Certificate Signing Request (CSR) with the Common Name (CN) localhost:
```
openssl req \
  -new \
  -key server.key \
  -subj '/CN=localhost' \
  -out server.csr
```

####Step Four: CREATE SIGNED CRT
Using the CSR, the CA (really using the CA key and certificate) creates the signed certificate:
```
openssl x509 \
  -req \
  -in server.csr \
  -CA ca.crt \
  -CAkey ca.key \
  -CAcreateserial \
  -days 365 \
  -out server.crt
```
The output is the signed server certificate, server.crt, in the PEM format.

Inspect CRT:
```
openssl x509 \
  --in server.crt \
  -text \
  --noout
```
```
Certificate:
    Data:
        Version: 1 (0x0)
        Serial Number:
            [OBMITTED]
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN = my-ca
        Validity
            Not Before: Jun 13 00:50:18 2020 GMT
            Not After : Jun 13 00:50:18 2021 GMT
        Subject: CN = localhost
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                RSA Public-Key: (2048 bit)
                Modulus:
                    [OBMITTED]
                Exponent: [OBMITTED]
    Signature Algorithm: sha256WithRSAEncryption
         [OBMITTED]
```
- The Issuer has the value CN = my-ca; this indicates that this certificate is signed by the my-ca certificate authority
- The Validity indicates that the certificate is valid for a year
- The Subject has the value CN = localhost; this indicates that this certificate can be served to a client to validate that the server is trusted to serve up content for the DNS name localhost

####Step Five: CREATE CLIENT KEY
We essentially repeat the process to create the client’s key and certificate; starting by creating the client’s key:
```
openssl genrsa \
  -out client.key 2048
```

####Step Six: CREATE CLIENT CSR
Creating the CSR with the arbitrary Common Name of my-client:
```
openssl req \
  -new \
  -key client.key \
  -subj '/CN=my-client' \
  -out client.csr
```

####Step Seven: CREATE CLIENT CRT
```
openssl x509 \
  -req \
  -in client.csr \
  -CA ca.crt \
  -CAkey ca.key \
  -CAcreateserial \
  -days 365 \
  -out client.crt
```
NOTE: If you inspect this certificate, you will observe that the Serial Number is indeed different than the server’s certificate.


####Step Eight: CONFIGURE SERVER & CLIENT
With all of our keys and certificates (ca, server, and client) created we can configure our server and client.

The server is the basic Hello World example, provided by Node.js, enhanced to support mTLS.
@ https://gist.githubusercontent.com/larkintuckerllc/8e7cb29d62bec20ae925a39c3c90a908/raw/401d5a832594bdd27bd976a1e3df420e6e00f5c5/index.js
```
const https = require('https');
const fs = require('fs');

const hostname = 'localhost';
const port = 3000;

const options = { 
    ca: fs.readFileSync('ca.crt'), 
    cert: fs.readFileSync('server.crt'), 
    key: fs.readFileSync('server.key'), 
    rejectUnauthorized: true,
    requestCert: true, 
}; 

const server = https.createServer(options, (req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('Hello World');
});

server.listen(port, hostname, () => {
  console.log(`Server running at http://${hostname}:${port}/`);
});

```
Here the requestCert, rejectUnauthorized, and ca options are used to require the browser (client) to supply a certificate signed by the CA certificate to interact with the server.

The key and cert options enable the server to serve up the CA signed server certificate.

The client is simply the cURL web browser with options:
```
curl \
  --cacert ca.crt \
  --key client.key \
  --cert client.crt \
  https://localhost:3000
```
Here the cacert option is used so that the client (cURL) can validate the server supplied certificate. The key and cert are used so the client sends the CA signed client certificate with the request.

Indeed, we observe that this request successfully returns hello world. If, however, we leave off the cacert option, we get the error:

```
curl --key client.key --cert client.crt  https://localhost:3000
curl: (60) SSL certificate problem: self signed certificate in certificate chain
More details here: https://curl.haxx.se/docs/sslcerts.htmlcurl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.
```
On the other hand, if we leave off the key and cert options, we get a different error:
```
curl --cacert ca.crt https://localhost:3000
curl: (56) OpenSSL SSL_read: error:1409445C:SSL routines:ssl3_read_bytes:tlsv13 alert certificate required, errno 0
```







