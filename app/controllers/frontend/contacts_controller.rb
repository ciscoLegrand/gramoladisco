class Frontend::ContactsController < ApplicationController
  skip_before_action :authenticate_user!

  def index; end

  def create
    @contact = Contact.new(contact_params)
    respond_to do |format|
      if @contact.save
        flash.now[:success] = { title: 'Gracias por contactar!', body: 'Pronto responderemos tu consulta'}
        format.html { redirect_to frontend_contacts_path }
        format.turbo_stream
      else
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:title, :subject, :email)
  end
end
