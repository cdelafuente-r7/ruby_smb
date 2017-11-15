module RubySMB
  module Dcerpc
    module Srvsvc

      class NetShareEnumAll < BinData::Record
        endian :little

        uint32 :referent_id, initial_value: 0x00000001
        uint32 :max_count,    initial_value: -> { (server_unc.do_num_bytes / 2) + 1 }
        uint32 :offset,       initial_value: 0
        uint32 :actual_count, initial_value: -> {max_count}
        string :server_unc,   pad_front: false,
                              initial_value: -> {host.encode('utf-16le')}

        uint16 :nullterminator, initial_value: 0

        uint16 :padding, initial_value: 0
        uint32 :level, initial_value: 1

        uint32 :ctr, initial_value: 1
        uint32 :ctr_referent_id, initial_value: 0x00000001
        uint32 :ctr_count, initial_value: 0
        uint32 :pointer_to_array, initial_value: 0

        uint32 :max_buffer, initial_value: 4294967295

        uint32 :resume_referent_id, value: 0x00000001
        uint32 :resume_handle, initial_value: 0
      end
    end
  end
end
