module ExcelService
  class Generator
    attr_reader :collection, :headers, :attributes, :options

    def initialize(collection:, headers:, attributes:, options: [])
      @collection = collection
      @headers = headers
      @attributes = attributes
      @options = options.to_h.symbolize_keys
    end

    def call
      p = Axlsx::Package.new
      p.workbook.add_worksheet(name: worksheet_name) do |sheet|
        ExcelService::Initializer.new(sheet: sheet, headers: headers, styles: options[:styles], options: options).call
        ExcelService::Rowable.new(sheet: sheet, collection: collection, attributes: attributes, styles: options[:styles]).call
        protect_with_password(sheet: sheet, protection: options[:protection], password: options[:password])
      end
      file_path = Rails.root.join('public', 'reports', file_name)
      p.serialize(file_path)
      { stream: p.to_stream.read, file_name: file_name, file_path: file_path }
    end

    private

    def worksheet_name
      options[:sheet_name] || collection.first.class.name
    end

    def file_name
      options[:file_name] || "#{worksheet_name}_#{Time.zone.now.strftime('%d%m%H%M')}.xlsx"
    end

    def protect_with_password(sheet:, protection:, password:)
      Rails.logger.info "🔑 Protection: #{protection}, Password: #{password}"
      protection ||= false
      password   ||= 'PWD-CRYPT-0202'
      return unless protection

      sheet.sheet_protection.password = password
    end
  end
end
