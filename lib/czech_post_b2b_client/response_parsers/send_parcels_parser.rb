# frozen_string_literal: true

module CzechPostB2bClient
  module ResponseParsers
    class SendParcelsParser < BaseParser
      def build_result
        super

        @result[:async_result] = {
          transaction_id: response_header['idTransaction'],
          processing_end_expected_at: parse_time_with_correction(response_header['timeStampProcessing'])
        }
      end

      def parse_time_with_correction(b2b_time_str)
        # b2b time in XML is NOT CORRECT! They return CET time value with UTC timezone
        # Like `2016-02-25T09:30:03.678Z`, which is actually `2016-02-25T09:30:03.678+0100`  (CET)
        # Or   `2016-05-25T09:30:03.678Z`, which is actually `2016-05-25T09:30:03.678+0200` (CET + DST)
        # But we must be prepare for unnoticed fix by CPost

        # unfortunattely this can be done for only freshly generated XMLs (comparing b2b_time with Time.now.utc)
        # but we have to kepp it compatible for old XML
        # so we pass it up and leave comments in documenation
        # Users of this gem will have to care of it

        Time.parse(b2b_time_str)
      end

      # just for info
      def cpost_time_zone
        timezone('Europe/Prague')
      end
    end
  end
end
