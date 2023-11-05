module ExcelService
  class Initializer
    attr_reader :workbook, :sheet, :headers, :styles, :options

    def initialize(sheet:, headers:, styles: {}, options: {})
      @workbook = sheet.workbook
      @sheet = sheet
      @headers = headers
      @styles = styles
      @options = options
    end

    def call
      add_logo
      add_headers
    end

    private

    def add_logo
      # Inserta una fila vacía en la posición 0
      sheet.add_row []
      # Establece la altura de la fila 0
      sheet.rows[0].height = 100
      sheet.add_image(image_src: Rails.root.join('app/assets/images/gramola-logo.png').to_s, noSelect: true, noMove: true, noRot: true) do |image|
        image.width = 222
        image.height = 100
        image.start_at 0, 0
      end
      sheet.merge_cells("A1:N1")
    end

    def add_headers
      sheet.add_row headers, style: header_default_style
      default_hidden_ids(headers)
      set_rows_height
      sheet.column_widths 50
    end

    def set_rows_height
      sheet.rows[1].height = 40
    end

    def header_default_style
      workbook.styles.add_style(
        {
          bg_color: "0000FF",
          fg_color: "FFFFFF",
          sz: 14,
          b: true,
          alignment: { horizontal: :center, vertical: :center, wrap_text: true }
        }
      )
    end

    def default_hidden_ids(headers)
      # ocultar las columnas que contengan *_id
      headers_with_ids = headers.map.with_index { |header, index| index if header.include?('_id') }.compact
      sheet.column_info.each_with_index do |column, index|
        column.hidden = true if headers_with_ids.include?(index)
      end
    end
  end
end
