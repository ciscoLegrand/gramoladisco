module ExcelService
  class Rowable
    attr_reader :sheet, :collection, :attributes, :styles

    def initialize(sheet:, collection:, attributes:, styles: {})
      @sheet = sheet
      @collection = collection
      @attributes = attributes
      @styles = styles
    end

    def call
      add_data_rows
      set_data_rows_height
    end

    private

    def add_data_rows
      collection.each do |record|
        row_data = attributes.map do |attr|
          # Verificar si el registro es un Hash y acceder a los valores de manera diferente si es necesario
          record.is_a?(Hash) ? record[attr] : record.send(attr)
        end
        sheet.add_row row_data, style: row_default_style
      end
    end

    def set_data_rows_height
      (1..sheet.rows.size - 1).each do |row_index|
        sheet.rows[row_index].height = 60
      end
    end

    def row_default_style
      sheet.workbook.styles.add_style(
        {
          alignment: {
            vertical: :top,
            horizontal: :left,
            wrap_text: true,
            indent: 2
          }
        }
      )
    end
  end
end
