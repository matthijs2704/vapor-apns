//
//  Hash+P256.swift
//  VaporAPNS
//
//  Created by Matthijs Logemann on 29/09/2016.
//
//

import Foundation
import CLibreSSL
import Essentials
import Hash

class P256 {

//    typealias Bytes = [CUnsignedChar]
    public typealias Byte = UInt8
    public typealias Bytes = [Byte]
    
    func hash(privateKey: String, message: Bytes) throws {
        let key: OpaquePointer! // EC_KEY
        let signature: UnsafeMutablePointer<ECDSA_SIG>! // ECDSA_SIG
//        var digest = [UInt8](repeating: 0, count: Int(SHA256_DIGEST_LENGTH))
        var der_len: Int

        let privBytes = privateKey.utf8.array;
        
        var hash = try Hash.init(.sha256, message).hash()

        key = newKeyPair(privKeyPath: "/Users/matthijs/Downloads/APNSAuthKey_4K8N6Q55G7.p8");

        if key == nil {
            //todo change to thrown error
            fatalError("Unable to create keypair")
        }
        
        // TODO: TESTING
        signature = ECDSA_do_sign(hash, Int32(hash.count), key);
        
        let verify_status = ECDSA_do_verify(hash, Int32(hash.count), signature, key);
        let verify_success = 1 as Int32;
        if (verify_success != verify_status)
        {
            print("Failed to verify EC Signature\n");
        }
        else
        {
            print("Verifed EC Signature\n");
        }
        // END TESTING

//        printHex("digest", &digest, 32);
        
//        signature = ECDSA_do_sign(digest, Int32(digest.count), key);
        let r = BN_bn2hex(signature.pointee.r)!
        let s = BN_bn2hex(signature.pointee.s)!
        print("r: \(String(cString: UnsafePointer<CChar>(r)))")
        print("s: \(String(cString: UnsafePointer<CChar>(s)))")

        der_len = Int(ECDSA_size(key));
        print ("der_len = \(der_len)")
        
        var derSignature = NSMutableData(length: der_len)!
        var pos = derSignature.mutableBytes.assumingMemoryBound(to: UInt8.self) as UnsafeMutablePointer<UInt8>?
        der_len = Int(i2d_ECDSA_SIG(signature, &pos));
        printHex("DER-encoded", pos!, der_len);
        print (pos)
//        let data = Data(bytes: pos!, count: Int(der_len))
        let str = String(data: derSignature as Data, encoding: .utf8)
        print (str)

        ECDSA_SIG_free(signature);
        EC_KEY_free(key);
        
//        (!test_ecdh_curve(NID_X9_62_prime256v1, "NIST Prime-Curve P-256",
//                          ctx, out))
    }
    
    private func sha256Hash(_ digest: UnsafeMutablePointer<UInt8>!, _ message: Bytes, _ len: Int) {
        var ctx = SHA256_CTX();
        SHA256_Init(&ctx);
        
//        let stream = BasicByteStream.init(message)
//        while !stream.closed {
//            let bytes = try! stream.next()
            guard SHA256_Update(&ctx, message, message.count) == 1 else {
//                throw Error.updating
                fatalError()
            }
//        }
        
        SHA256_Update(&ctx, message, len);
        SHA256_Final(digest, &ctx);
    }
    
    private func printHex (_ label: String, _ v: UnsafeMutablePointer<UInt8>, _ len: Int) {
        var string = ""
        for i in 0..<len {
            string += String(format:"%2X", v[i])
        }
        
        print("\(label): \(string)")
    }
    
    private func printHex (_ label: String, _ v: Bytes) {
        let string = String.init(cString: UnsafePointer(v))
    
        print("\(label): \(string)")
    }

    

    private func newKeyPair(privKeyPath: String) -> OpaquePointer! {
        var privateKeyPath = FileManager.default.fileSystemRepresentation(withPath: privKeyPath)
        var fp = fopen(privateKeyPath, "r")
        
        let key: OpaquePointer! // EC_KEY
//        var priv: BIGNUM // BIG_NUM
        let ctx: OpaquePointer! // BN_CTX
        let group: OpaquePointer! // EC_GROUP
        let pub: OpaquePointer! // EC_POINT
        let signature: UnsafeMutablePointer<ECDSA_SIG>! // ECDSA_SIG

        /* init empty OpenSSL EC keypair */
        key = EC_KEY_new(); // NID_secp256k1 //NID_X9_62_prime256v1
        
        
        OPENSSL_add_all_algorithms_noconf();
        ERR_load_BIO_strings();
        ERR_load_crypto_strings();
        
//        PKCS8 *pkey = NULL;
        var pkey: UnsafeMutablePointer<PKCS8_PRIV_KEY_INFO>?
        var pkcs8_enc: UnsafeMutablePointer<X509_SIG>?
//        var bio: UnsafeMutablePointer<BIO>!
        
        
        /* ---------------------------------------------------------- *
         * Load the certificate from file (PEM).                      *
         * ---------------------------------------------------------- */

        pkey = PEM_read_PKCS8_PRIV_KEY_INFO(fp, nil, nil, nil)
        if (pkey == nil) {
            print( "Error loading privatekey from bio\n");
            exit(-1);
        }

        let evp_key = EVP_PKCS82PKEY(pkey)
        
        let pkey_in = EVP_PKEY_get1_EC_KEY(evp_key)
        let numKey = EC_KEY_get0_private_key(pkey_in)

        group = EC_GROUP_new_by_curve_name(NID_X9_62_prime256v1)
        EC_KEY_set_private_key(key, numKey)
        EC_KEY_set_group(key, group)

        /* derive public key from private key and group */

        ctx = BN_CTX_new();
        BN_CTX_start(ctx);
        pub = EC_POINT_new(group);
        EC_POINT_mul(group, pub, numKey, nil, nil, ctx);
        EC_KEY_set_public_key(key, pub);

        let publicKey = self.publicKey(fromECPoint: pub, compressed: true)
        print("Public Key: \(publicKey.hexString)")

//        /* release resources */
//        
        EC_POINT_free(pub);
        BN_CTX_end(ctx);
        BN_CTX_free(ctx);
        EC_GROUP_free(group)
        
        return key
    }
    
    func publicKey(fromECPoint publicKeyPoint: OpaquePointer!, compressed: Bool) -> Data {
        var group = EC_GROUP_new_by_curve_name(NID_X9_62_prime256v1)
        var publicKeyBn: BIGNUM = BIGNUM()
        BN_init(&publicKeyBn)
        var pointConversionForm = compressed ? POINT_CONVERSION_COMPRESSED : POINT_CONVERSION_UNCOMPRESSED
        EC_POINT_point2bn(group, publicKeyPoint, pointConversionForm, &publicKeyBn, nil)
        var length = compressed ? 33 : 65
        var publicKey = NSMutableData(length: length)!
        var offset = publicKey.length - BN_num_bytes(bignum: &publicKeyBn)
        assert(offset < publicKey.length, "Invalid offset")
        BN_bn2bin(&publicKeyBn, publicKey.mutableBytes.assumingMemoryBound(to: UInt8.self))
        BN_clear(&publicKeyBn)
        EC_GROUP_free(group)
        return publicKey as Data
    }
    
    func publicKeyPoint(fromPrivateKeyBN privateKeyBn: UnsafePointer<BIGNUM>?) -> OpaquePointer! {
        let group = EC_GROUP_new_by_curve_name(NID_X9_62_prime256v1)
        let publicKeyPoint = EC_POINT_new(group)
        let result = EC_POINT_mul(group, publicKeyPoint, privateKeyBn, nil, nil, nil)
        if result != 1 {
            // Check result outside of the NSAssert to avoid "unused variable" warnings in the release
            // build.
            assert(false, "Failed to create public key from private key")
        }
        EC_GROUP_free(group)
        return publicKeyPoint
    }
    
    private func BN_num_bytes(bignum: inout BIGNUM) -> Int
    {
        let bits = Int(BN_num_bits(&bignum))
        return (bits + 7) / 8;
    }
}
