class Frontend::ContactsController < ApplicationController
  def index; end
  def new; end
  def create
    @contact = Contact.new(contact_params)
    Rails.logger.info "🔥 Contact: #{contact_params.inspect} 🔥"
    respond_to do |format|
      if @contact.save
        Rails.logger.info "✅🔥 Contact saved: #{contact_params.inspect} 🔥✅"
        format.html { redirect_to new_contact_path, success: "Contact was successfully sended." }
      else
        Rails.logger.info "❌🔥 Contact not saved: #{@contact.errors.full_messages} 🔥❌"
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:title, :subject, :email)
  end
end
