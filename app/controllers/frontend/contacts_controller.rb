class Frontend::ContactsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token
  invisible_captcha only: [:create], honeypots: ['phone', 'country_prefix', 'address'], on_spam: :spam_detected

  def index; end

  def create
    @human_instructions = I18n.t('invisible_captcha.human_instructions')
    @contact = Contact.new(contact_params)
    respond_to do |format|
      if @contact.save
        flash.now[:success] = { title: t('.success.title'), message: t('.success.message') }
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

  def spam_detected
    flash.now[:success] = { title: t('.spam.title'), message: t('.spam.message') }
    redirect_to root_path
  end
end
