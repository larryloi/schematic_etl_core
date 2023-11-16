# frozen-string-literal: true

module Schematic
  class Cipher
    def generate_keys
      rsa_key = OpenSSL::PKey::RSA.generate key_length

      FileUtils.mkdir_p(File.dirname("#{private_key_file}"))
      print "Saving private Key (#{private_key_file}) ... "
      File.write(private_key_file, rsa_key.to_pem)
      puts 'done'

      FileUtils.mkdir_p(File.dirname("#{public_key_file}"))
      print "Saving public key (#{public_key_file}) ..."
      File.write(public_key_file, rsa_key.public_to_pem)
      puts 'done'
    end
  end
end
