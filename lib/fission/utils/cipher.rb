require 'fission'
require 'openssl'
require 'base64'

module Fission
  module Utils
    # Simple helper to remove plaintext
    module Cipher

      class << self

        # Salt for key generation
        CRYPT_SALT='fission~crypt~salt'
        # Computation iteration length
        CRYPT_ITER=10000
        # Length of generated key
        CRYPT_KEY_LENGTH=32

        # Encrypt string
        #
        # @param string [String] string to encrypt
        # @param crypt_hash [Hash]
        # @option crypt_hash [String] :key
        # @option crypt_hash [String] :iv
        # @return [String]
        def encrypt(string, crypt_hash)
          cipher = build_cipher(crypt_hash)
          res = cipher.update(string) + cipher.final
          Base64.urlsafe_encode64(res)
        end

        # Decrypt string
        #
        # @param string [String] string to decrypt
        # @param crypt_hash [Hash]
        # @option crypt_hash [String] :key
        # @option crypt_hash [String] :iv
        # @return [String]
        def decrypt(string, crypt_hash)
          string = Base64.urlsafe_decode64(string)
          cipher = build_cipher(crypt_hash.merge(:decrypt => true))
          cipher.update(string) + cipher.final
        end

        # Create a new cipher instance
        #
        # @param args [Hash]
        # @option args [String] :key
        # @option args [String] :iv
        # @option args [Truthy, Falsey] :decrypt
        # @return [OpenSSL::Cipher]
        def build_cipher(args={})
          cipher = OpenSSL::Cipher.new('AES-256-CBC')
          args[:decrypt] ? cipher.decrypt : cipher.encrypt
          iv = args[:iv]
          until(iv.length > 65)
            iv = iv * 2
          end
          key = OpenSSL::PKCS5.pbkdf2_hmac_sha1(
            args[:key], CRYPT_SALT, CRYPT_ITER, CRYPT_KEY_LENGTH
          )
          cipher.iv = iv
          cipher.key = key
          cipher
        end

      end
    end
  end
end
