require 'buftok'
require 'json'
require 'http/parser'

module SimpleStream
  class Response
    attr_reader :block, :parser, :tokenizer

    def initialize(&block)
      @block = block
      @parser = Http::Parser.new(self)
      @tokenizer = BufferedTokenizer.new("\r\n")
    end

    def <<(data)
      parser << data
    end

    def on_headers_complete(headers)
      # TODO
      p(status_code: parser.status_code, header: headers) unless parser.status_code == 200
    end

    def on_body(data)
      tokenizer.extract(data).each do |line|
        next if line.empty?
        block.call(JSON.parse(line, symbolize_names: true))
      end
    end
  end
end
