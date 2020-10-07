module RubySMB
  module Dcerpc
    module Samr

      # [3.1.5.1.4 SamrConnect (Opnum 0)](https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-samr/defe2091-0a61-4dfa-be9a-2c1206d53a1f)
      class SamrConnectRequest < BinData::Record
        attr_reader :opnum

        endian :little

        psampr_server_name :server_name
        string             :pad, length: -> { pad_length(self.server_name) }
        # Access control on a server object: bitwise OR of common ACCESS_MASK
        # and server ACCESS_MASK values (see lib/ruby_smb/dcerpc/samr.rb)
        uint32             :desired_access

        def initialize_instance
          super
          @opnum = SAMR_CONNECT
        end

        # Determines the correct length for the padding, so that the next
        # field is 4-byte aligned.
        def pad_length(prev_element)
          offset = (prev_element.abs_offset + prev_element.to_binary_s.length) % 4
          (4 - offset) % 4
        end
      end

    end
  end
end


