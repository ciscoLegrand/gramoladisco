class ContactMailer < ApplicationMailer
  def customer_email
    @contact = params[:contact]
    mail(to: @contact.email, subject: 'Gracias por tu petición')
  end

  def admin_email
    @contact = params[:contact]
    mail(to: 'cisco.glez@gmail.com', subject: 'Nueva petición de contacto')
  end
end
