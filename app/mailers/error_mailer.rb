class ErrorMailer < ApplicationMailer
  def import_error(error_info)
    @error_info = error_info
    mail(to: 'fran@lagramoladisco.com', subject: "ERROR - Importación de álbum")
  end

  def import_summary(info)
    @info = info
    mail(to: 'fran@lagramoladisco.com', subject: "Resumen de #{info[:process_name]}")
  end
end
